/**
 * Google Gemini AI Service
 * 
 * Handles text-based AI generation for vehicle summaries, part identification,
 * and spare parts recommendations using professional prompts.
 * Ensures output is clear, technical, and does NOT sound AI-generated.
 * Includes rate limiting protection and intelligent retry logic.
 */

import axios from 'axios';

const GEMINI_API_BASE_URL = 'https://generativelanguage.googleapis.com/v1beta/models';
const MODEL = 'gemini-2.0-flash'; // Available model from API

// Rate limiting configuration
class RateLimiter {
    constructor() {
        this.requestQueue = [];
        this.lastRequestTime = 0;
        this.minInterval = 1000; // Minimum 1 second between requests
        this.isProcessing = false;
    }

    async throttledRequest(requestFn) {
        return new Promise((resolve, reject) => {
            this.requestQueue.push({ requestFn, resolve, reject });
            this.processQueue();
        });
    }

    async processQueue() {
        if (this.isProcessing || this.requestQueue.length === 0) return;

        this.isProcessing = true;

        while (this.requestQueue.length > 0) {
            const timeSinceLastRequest = Date.now() - this.lastRequestTime;

            if (timeSinceLastRequest < this.minInterval) {
                await new Promise(resolve => setTimeout(resolve, this.minInterval - timeSinceLastRequest));
            }

            const { requestFn, resolve, reject } = this.requestQueue.shift();
            this.lastRequestTime = Date.now();

            try {
                const result = await requestFn();
                resolve(result);
            } catch (error) {
                reject(error);
            }
        }

        this.isProcessing = false;
    }
}

const rateLimiter = new RateLimiter();

// Helper function to get API key
function getApiKey() {
    const key = process.env.GEMINI_API_KEY;
    if (!key) {
        throw new Error('GEMINI_API_KEY is not configured in environment');
    }
    return key;
}

/**
 * System prompt for all Gemini calls
 * Ensures output is professional, technical, and doesn't sound AI-generated
 */
const SYSTEM_PROMPT = `You are a professional automotive technical expert specializing in German vehicles (BMW, Audi, Mercedes-Benz, Volkswagen, Porsche).

Your responses must:
1. Be technical and precise - use manufacturer specifications where applicable
2. Sound like an experienced mechanic, not an AI assistant
3. Include specific part numbers and technical terms (use OEM references)
4. Be concise and actionable - no filler or marketing language
5. Include practical information mechanics actually need
6. Never use emojis, excessive formatting, or generic phrases like "Let me tell you about..."
7. Focus on mechanical function and real-world application
8. Use German automotive terminology where appropriate and well-known

Response format requirements:
- Use bullet points for clarity, not paragraphs
- Include specific measurements, pressures, torque specs where relevant
- Reference OEM part numbers and compatibility information
- Be direct and informative - mechanics are busy`;

/**
 * Generate vehicle summary with 5 bullet points
 * @param {Object} vehicleData - Vehicle data from VIN decode
 * @returns {Promise<Object>} Summary with 5 bullet points
 */
export async function generateVehicleSummary(vehicleData) {
    const { make, model, year, engine, bodyType, trim } = vehicleData;

    const userPrompt = `Provide a professional technical summary for a ${year} ${make} ${model}${trim ? ` ${trim}` : ''} (Engine: ${engine || 'standard'}, Body: ${bodyType || 'standard'}).

Generate exactly 5 sections. Each section MUST:
- Start with a bold category label using **Category:** format
- Be concise (2-3 sentences max)
- Include specific technical data where available

Sections required:
1. **Engine:** Power output, displacement, configuration, fuel economy
2. **Transmission:** Type, speeds, fluid type, notable features
3. **Chassis/Suspension:** Platform, suspension type, brake specs
4. **Maintenance/Issues:** Service intervals, common problems for this model
5. **Features/Quirks:** Unique features, known quirks for this year/model

Format: Return ONLY the 5 sections, one per line. Use **bold** for category labels. No intro text.`;

    try {
        const response = await callGeminiAPI(userPrompt);
        const bullets = parseBulletPoints(response);

        // Ensure we have exactly 5 bullets
        const summary = bullets.slice(0, 5);
        if (summary.length < 5) {
            console.warn('Warning: Generated less than 5 bullet points');
        }

        return {
            success: true,
            make,
            model,
            year,
            summary,
            pointCount: summary.length,
            generatedAt: new Date().toISOString()
        };
    } catch (error) {
        console.error('Error generating vehicle summary:', error);
        throw new GeminiAiError(
            error.message || 'Failed to generate vehicle summary',
            'SUMMARY_GENERATION_FAILED',
            500
        );
    }
}

/**
 * Identify and provide information about a specific part
 * @param {Object} params - Part identification parameters
 * @returns {Promise<Object>} Part information
 */
export async function identifyPart(params) {
    const { partName, vehicleData, imageDescription } = params;

    // Build vehicle context
    const vehicleContext = vehicleData ?
        ` on a ${vehicleData.year} ${vehicleData.make} ${vehicleData.model}` :
        '';

    const userPrompt = `Provide technical specifications for the ${partName}${vehicleContext}.

Include:
0. Main components/subparts that make up this ${partName} (list 3-5 key components)
1. Part function and purpose in the vehicle system
2. Common OEM part number(s) or equivalents
3. Typical replacement cost range (if applicable)
4. Expected service life or maintenance interval
5. Symptoms of failure or common issues
6. Compatible aftermarket alternatives (if applicable)
7. Installation complexity (simple/moderate/complex)

Format: Use concise bullet points. Be specific with part numbers. Include metric measurements where relevant.`;

    try {
        const response = await callGeminiAPI(userPrompt);

        return {
            success: true,
            partName,
            vehicle: vehicleData ? {
                year: vehicleData.year,
                make: vehicleData.make,
                model: vehicleData.model
            } : null,
            information: response,
            generatedAt: new Date().toISOString()
        };
    } catch (error) {
        console.error('Error identifying part:', error);
        throw new GeminiAiError(
            error.message || 'Failed to identify part',
            'PART_IDENTIFICATION_FAILED',
            500
        );
    }
}

/**
 * Generate spare parts recommendations
 * @param {Object} vehicleData - Vehicle data
 * @param {string} system - Vehicle system (engine, transmission, electrical, etc.)
 * @returns {Promise<Object>} Spare parts recommendations
 */
export async function generateSparePartsSummary(vehicleData, system = 'general') {
    const { make, model, year } = vehicleData;

    const systemContext = system && system !== 'general' ? ` for the ${system} system` : '';

    const userPrompt = `Recommend the top commonly needed spare parts${systemContext} for a ${year} ${make} ${model}.

Provide exactly up to 5 parts that:
1. Are commonly replaced during the vehicle's life
2. Have reasonable replacement intervals
3. Are essential for proper maintenance
4. Include OEM part number references where possible

For each part, include:
- Part name (technical name)
- OEM part number
- Approximate price range
- Replacement interval (miles/hours/months)
- Why it's important

Format: Number each part 1-5. Use bullet points for details. Be specific with numbers and measurements.`;

    try {
        const response = await callGeminiAPI(userPrompt);
        const parts = parsePartsList(response);

        return {
            success: true,
            make,
            model,
            year,
            system,
            parts: parts.slice(0, 5), // Max 5 items
            partCount: Math.min(parts.length, 5),
            generatedAt: new Date().toISOString()
        };
    } catch (error) {
        console.error('Error generating spare parts summary:', error);
        throw new GeminiAiError(
            error.message || 'Failed to generate spare parts summary',
            'SPARE_PARTS_GENERATION_FAILED',
            500
        );
    }
}

/**
 * Generic AI response generation for vehicle enrichment
 * @param {string} prompt - User prompt
 * @returns {Promise<string>} Generated response
 */
export async function generateResponse(prompt) {
    try {
        return await callGeminiAPI(prompt);
    } catch (error) {
        console.error('Error generating AI response:', error);
        throw new GeminiAiError(
            error.message || 'Failed to generate AI response',
            'AI_GENERATION_FAILED',
            500
        );
    }
}

/**
 * Call Gemini API with system prompt, rate limiting, and retry logic
 * @param {string} userPrompt - User prompt
 * @returns {Promise<string>} API response text
 */
async function callGeminiAPI(userPrompt) {
    const maxRetries = 3;
    const baseDelay = 2000; // 2 seconds base delay

    for (let attempt = 1; attempt <= maxRetries; attempt++) {
        try {
            // Use rate limiter to throttle requests
            return await rateLimiter.throttledRequest(async () => {
                const apiKey = getApiKey();

                console.log(`🤖 Gemini API call (attempt ${attempt}/${maxRetries})`);

                const response = await axios.post(
                    `${GEMINI_API_BASE_URL}/${MODEL}:generateContent?key=${apiKey}`,
                    {
                        systemInstruction: {
                            parts: [{
                                text: SYSTEM_PROMPT
                            }]
                        },
                        contents: [{
                            parts: [{
                                text: userPrompt
                            }]
                        }],
                        generationConfig: {
                            temperature: 0.3, // Low temperature for consistent, factual output
                            topP: 0.8,
                            topK: 10,
                            maxOutputTokens: 2048
                        }
                        // Note: Safety settings removed - BLOCK_NONE not allowed for standard API keys
                        // Default safety settings are sufficient for automotive technical content
                    },
                    {
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        timeout: 30000
                    }
                );

                // Extract text from response
                const text = response.data?.candidates?.[0]?.content?.parts?.[0]?.text;
                if (!text) {
                    throw new Error('No text content in API response');
                }

                console.log(`✅ Gemini API success (attempt ${attempt})`);
                return text;
            });
        } catch (error) {
            const isRateLimit = error.response?.status === 429;
            const isQuotaExceeded = error.response?.status === 403;
            const isLastAttempt = attempt === maxRetries;

            if (isRateLimit) {
                if (isLastAttempt) {
                    throw new GeminiAiError(
                        'API rate limit exceeded. Please try again in a moment.',
                        'RATE_LIMIT',
                        429
                    );
                } else {
                    // Exponential backoff for rate limits
                    const delay = baseDelay * Math.pow(2, attempt - 1) + Math.random() * 1000;
                    console.log(`⏳ Rate limited, retrying in ${Math.round(delay / 1000)}s...`);
                    await new Promise(resolve => setTimeout(resolve, delay));
                    continue;
                }
            }

            if (isQuotaExceeded) {
                throw new GeminiAiError(
                    'API key is invalid or quota exceeded.',
                    'INVALID_API_KEY',
                    403
                );
            }

            if (isLastAttempt) {
                console.error(`❌ Gemini API failed after ${maxRetries} attempts:`, error.message);
                throw new GeminiAiError(
                    error.message || 'Failed to call Gemini API',
                    'API_ERROR',
                    500
                );
            }

            // For other errors, wait briefly before retry
            const delay = 1000;
            console.log(`⚠️ API error, retrying in ${delay / 1000}s... (${error.message})`);
            await new Promise(resolve => setTimeout(resolve, delay));
        }
    }
}

/**
 * Parse bullet points from response text
 * @param {string} text - Response text
 * @returns {Array<string>} Array of bullet points
 */
function parseBulletPoints(text) {
    console.log('Raw Gemini response:', text.substring(0, 500)); // Debug log

    const lines = text.split('\n').filter(line => line.trim());

    // Try multiple bullet formats: •, -, *, or numbered (1., 2., etc.)
    const bulletPatterns = /^[•\-\*]\s*|^\d+[\.\)]\s*/;

    const bullets = lines
        .filter(line => bulletPatterns.test(line.trim()) || line.trim().length > 20) // Also accept long lines
        .map(line => line.replace(/^[•\-\*\d+.\)]\s*/, '').trim())
        .filter(line => line.length > 10); // Filter out very short lines

    // If no bullets found, try to split by double newlines or return as single points
    if (bullets.length === 0 && text.trim().length > 0) {
        return text.split(/\n\n+/).map(p => p.trim()).filter(p => p.length > 10).slice(0, 5);
    }

    return bullets;
}

/**
 * Parse parts list from response text
 * @param {string} text - Response text
 * @returns {Array<string>} Array of parts
 */
function parsePartsList(text) {
    const lines = text.split('\n').filter(line => line.trim());
    const parts = [];
    let currentPart = '';

    for (const line of lines) {
        // Check if line starts a new part entry (number followed by period or closing paren)
        if (/^\d+[\.\)]\s/.test(line.trim())) {
            if (currentPart) {
                parts.push(currentPart);
            }
            currentPart = line.replace(/^\d+[\.\)]\s*/, '').trim();
        } else if (line.trim().startsWith('•') || line.trim().startsWith('-')) {
            // Add details to current part
            if (currentPart) {
                currentPart += ' ' + line.replace(/^[•\-]\s*/, '').trim();
            }
        }
    }

    if (currentPart) {
        parts.push(currentPart);
    }

    return parts.filter(part => part.length > 0);
}

/**
 * Custom error class for Gemini AI errors
 */
export class GeminiAiError extends Error {
    constructor(message, code, statusCode) {
        super(message);
        this.name = 'GeminiAiError';
        this.code = code;
        this.statusCode = statusCode;
    }
}

export default {
    generateVehicleSummary,
    identifyPart,
    generateSparePartsSummary,
    GeminiAiError,
    SYSTEM_PROMPT
};
