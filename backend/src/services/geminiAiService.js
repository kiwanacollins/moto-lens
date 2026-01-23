/**
 * Google Gemini AI Service
 * 
 * Handles text-based AI generation for vehicle summaries, part identification,
 * and spare parts recommendations using professional prompts.
 * Ensures output is clear, technical, and does NOT sound AI-generated.
 */

import axios from 'axios';

const GEMINI_API_BASE_URL = 'https://generativelanguage.googleapis.com/v1beta/models';
const MODEL = 'gemini-2.0-flash';

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

    const userPrompt = `Provide a technical summary of a ${year} ${make} ${model}${trim ? ` ${trim}` : ''} with engine: ${engine}, body type: ${bodyType}.

Generate exactly 5 concise bullet points covering:
1. Engine performance and specifications
2. Transmission and drivetrain characteristics
3. Chassis and suspension key points
4. Common maintenance intervals or known issues
5. Notable features or quirks for this year/model

Format: Return ONLY the 5 bullet points, one per line, starting with "•". No introduction or explanation.`;

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
 * Call Gemini API with system prompt
 * @param {string} userPrompt - User prompt
 * @returns {Promise<string>} API response text
 */
async function callGeminiAPI(userPrompt) {
    try {
        const apiKey = getApiKey();

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
                },
                safetySettings: [
                    {
                        category: 'HARM_CATEGORY_HARASSMENT',
                        threshold: 'BLOCK_NONE'
                    },
                    {
                        category: 'HARM_CATEGORY_HATE_SPEECH',
                        threshold: 'BLOCK_NONE'
                    },
                    {
                        category: 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
                        threshold: 'BLOCK_NONE'
                    },
                    {
                        category: 'HARM_CATEGORY_DANGEROUS_CONTENT',
                        threshold: 'BLOCK_NONE'
                    }
                ]
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

        return text;
    } catch (error) {
        if (error.response?.status === 429) {
            throw new GeminiAiError(
                'API rate limit exceeded. Please try again in a moment.',
                'RATE_LIMIT',
                429
            );
        }

        if (error.response?.status === 403) {
            throw new GeminiAiError(
                'API key is invalid or quota exceeded.',
                'INVALID_API_KEY',
                403
            );
        }

        throw error;
    }
}

/**
 * Parse bullet points from response text
 * @param {string} text - Response text
 * @returns {Array<string>} Array of bullet points
 */
function parseBulletPoints(text) {
    const lines = text.split('\n').filter(line => line.trim());
    return lines
        .filter(line => line.trim().startsWith('•') || /^\d+\./.test(line.trim()))
        .map(line => line.replace(/^[•\d+.\-]\s*/, '').trim())
        .filter(line => line.length > 0);
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
