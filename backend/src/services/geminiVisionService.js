/**
 * Gemini Vision Service for Spare Parts Analysis
 * 
 * Analyzes spare part images using Gemini's vision capabilities to:
 * 1. Identify automotive parts from photos
 * 2. Provide technical specifications
 * 3. Suggest compatible parts and alternatives
 * 4. Answer questions about the scanned part
 * 
 * Uses Gemini Pro Vision with professional automotive prompts
 */

import axios from 'axios';

const GEMINI_API_BASE_URL = 'https://generativelanguage.googleapis.com/v1beta/models';
const VISION_MODEL = 'gemini-2.0-flash'; // Supports vision and text

// Helper function to get API key
function getApiKey() {
    const key = process.env.GEMINI_API_KEY;
    if (!key) {
        throw new Error('GEMINI_API_KEY is not configured in environment');
    }
    return key;
}

/**
 * System prompt for vision-based part analysis
 */
const VISION_SYSTEM_PROMPT = `You are an expert automotive technician and parts specialist with extensive knowledge of German vehicle systems (BMW, Audi, Mercedes-Benz, Volkswagen, Porsche).

When analyzing automotive part images, you must:
1. Identify the part accurately with specific technical names
2. Provide OEM part numbers when recognizable
3. Describe the part's function and location in the vehicle
4. Include compatibility information (which vehicles/years)
5. Note visible condition and any wear patterns
6. Suggest related parts that commonly need replacement
7. Use professional automotive terminology
8. Be specific and technical - avoid generic responses

Your responses should sound like an experienced mechanic examining the part, not an AI assistant. Include practical information mechanics actually need for diagnosis and ordering.

Format responses with clear sections using bullet points for readability.`;

/**
 * Analyze a spare part image and provide detailed information
 * @param {string} imageBase64 - Base64 encoded image
 * @param {string} mimeType - Image MIME type (image/jpeg, image/png, etc.)
 * @param {Object} vehicleContext - Optional vehicle context for better analysis
 * @returns {Promise<Object>} Part analysis results
 */
export async function analyzePartImage(imageBase64, mimeType, vehicleContext = null) {
    try {
        // Create context-aware prompt
        let contextInfo = '';
        if (vehicleContext) {
            const { make, model, year, engine } = vehicleContext;
            contextInfo = `\n\nVehicle context: ${year} ${make} ${model}${engine ? ` with ${engine}` : ''}`;
        }

        const userPrompt = `Analyze this automotive part image and provide a comprehensive technical assessment.

Please identify:
1. **Part Name & Category**: Exact technical name and what system it belongs to
2. **Visual Condition**: Current state, wear patterns, damage, or issues visible
3. **OEM Information**: Part numbers, manufacturer markings if visible
4. **Function & Purpose**: What this part does and where it's located
5. **Vehicle Compatibility**: Which vehicles/models typically use this part
6. **Replacement Recommendations**: When to replace and what to look for
7. **Related Parts**: Other components commonly replaced together
8. **Installation Notes**: Any special considerations for replacement

Be specific about technical details you can observe. If markings are visible on the part, include them exactly.${contextInfo}

Format your response with clear section headers and bullet points for easy reading.`;

        const response = await callGeminiVisionAPI(userPrompt, imageBase64, mimeType);

        return {
            success: true,
            analysis: response,
            vehicleContext: vehicleContext || null,
            analysisType: 'part_identification',
            timestamp: new Date().toISOString(),
            model: VISION_MODEL
        };

    } catch (error) {
        console.error('Error analyzing part image:', error);
        throw new GeminiVisionError(
            error.message || 'Failed to analyze part image',
            'IMAGE_ANALYSIS_FAILED',
            500
        );
    }
}

/**
 * Ask a specific question about a spare part image
 * @param {string} imageBase64 - Base64 encoded image
 * @param {string} mimeType - Image MIME type
 * @param {string} question - Specific question about the part
 * @param {Object} vehicleContext - Optional vehicle context
 * @returns {Promise<Object>} Question response
 */
export async function askPartQuestion(imageBase64, mimeType, question, vehicleContext = null) {
    try {
        let contextInfo = '';
        if (vehicleContext) {
            const { make, model, year } = vehicleContext;
            contextInfo = ` The part is from a ${year} ${make} ${model}.`;
        }

        const userPrompt = `Looking at this automotive part image, please answer this specific question: "${question}"

${contextInfo}

Provide a detailed, technical answer based on what you can see in the image. Include:
- Direct answer to the question
- Supporting visual evidence from the image
- Technical specifications if relevant
- Practical advice for the mechanic
- Any safety considerations

Be specific and professional in your response.`;

        const response = await callGeminiVisionAPI(userPrompt, imageBase64, mimeType);

        return {
            success: true,
            question: question,
            answer: response,
            vehicleContext: vehicleContext || null,
            analysisType: 'question_answer',
            timestamp: new Date().toISOString(),
            model: VISION_MODEL
        };

    } catch (error) {
        console.error('Error answering part question:', error);
        throw new GeminiVisionError(
            error.message || 'Failed to answer part question',
            'QUESTION_FAILED',
            500
        );
    }
}

/**
 * Compare multiple part images (up to 4)
 * @param {Array<Object>} images - Array of {imageBase64, mimeType, label} objects
 * @param {string} comparisonType - Type of comparison (condition, compatibility, etc.)
 * @param {Object} vehicleContext - Optional vehicle context
 * @returns {Promise<Object>} Comparison results
 */
export async function comparePartImages(images, comparisonType = 'general', vehicleContext = null) {
    if (!images || images.length < 2 || images.length > 4) {
        throw new GeminiVisionError(
            'Must provide 2-4 images for comparison',
            'INVALID_COMPARISON_INPUT',
            400
        );
    }

    try {
        let contextInfo = '';
        if (vehicleContext) {
            const { make, model, year } = vehicleContext;
            contextInfo = ` The parts are for a ${year} ${make} ${model}.`;
        }

        const comparisonPrompts = {
            'condition': 'Compare the condition and wear patterns of these automotive parts. Which parts need replacement and why?',
            'compatibility': 'Analyze if these parts are compatible with each other or serve similar functions.',
            'quality': 'Compare the quality and type (OEM vs aftermarket) of these parts.',
            'general': 'Compare these automotive parts and explain their differences, similarities, and relationships.'
        };

        const prompt = comparisonPrompts[comparisonType] || comparisonPrompts['general'];

        const userPrompt = `${prompt}${contextInfo}

For each part, provide:
1. Part identification and condition assessment
2. Key differences or similarities between parts
3. Recommendations based on the comparison
4. Which part(s) would be best for replacement (if applicable)

Label your analysis clearly for each part and provide a summary comparison.`;

        // Prepare multiple images for the API call
        const imageParts = images.map(img => ({
            inlineData: {
                mimeType: img.mimeType,
                data: img.imageBase64
            }
        }));

        const response = await callGeminiVisionAPIMultipleImages(userPrompt, imageParts);

        return {
            success: true,
            comparisonType,
            imageCount: images.length,
            comparison: response,
            vehicleContext: vehicleContext || null,
            analysisType: 'part_comparison',
            timestamp: new Date().toISOString(),
            model: VISION_MODEL
        };

    } catch (error) {
        console.error('Error comparing part images:', error);
        throw new GeminiVisionError(
            error.message || 'Failed to compare part images',
            'COMPARISON_FAILED',
            500
        );
    }
}

/**
 * Detect part numbers and markings in an image
 * @param {string} imageBase64 - Base64 encoded image
 * @param {string} mimeType - Image MIME type
 * @returns {Promise<Object>} Detected markings and part numbers
 */
export async function detectPartMarkings(imageBase64, mimeType) {
    try {
        const userPrompt = `Examine this automotive part image and identify ALL visible markings, part numbers, text, and symbols.

Please extract:
1. **Part Numbers**: Any alphanumeric codes that appear to be part numbers
2. **Brand/Manufacturer Markings**: Company names, logos, brand indicators
3. **Date Codes**: Manufacturing dates, production codes
4. **Technical Markings**: Pressure ratings, size specifications, material codes
5. **Quality Markings**: OEM indicators, certification marks
6. **Other Text**: Any other visible text or symbols

For each marking found:
- Provide the exact text/number as visible
- Indicate its location on the part (top, bottom, side, etc.)
- Describe its likely purpose or meaning
- Note if the marking is clear or partially obscured

If no clear markings are visible, indicate that and explain what might be preventing clear reading (angle, lighting, wear, etc.).`;

        const response = await callGeminiVisionAPI(userPrompt, imageBase64, mimeType);

        return {
            success: true,
            markings: response,
            analysisType: 'marking_detection',
            timestamp: new Date().toISOString(),
            model: VISION_MODEL
        };

    } catch (error) {
        console.error('Error detecting part markings:', error);
        throw new GeminiVisionError(
            error.message || 'Failed to detect part markings',
            'MARKING_DETECTION_FAILED',
            500
        );
    }
}

/**
 * Assess part condition and provide replacement recommendations
 * @param {string} imageBase64 - Base64 encoded image
 * @param {string} mimeType - Image MIME type
 * @param {Object} vehicleContext - Optional vehicle context
 * @returns {Promise<Object>} Condition assessment and recommendations
 */
export async function assessPartCondition(imageBase64, mimeType, vehicleContext = null) {
    try {
        let contextInfo = '';
        if (vehicleContext) {
            const { make, model, year, mileage } = vehicleContext;
            contextInfo = ` Vehicle: ${year} ${make} ${model}${mileage ? `, ${mileage} miles` : ''}`;
        }

        const userPrompt = `Assess the condition of this automotive part and provide professional replacement recommendations.

Analyze:
1. **Current Condition**: Overall state (excellent, good, fair, poor, failed)
2. **Wear Indicators**: Specific signs of wear, damage, or deterioration
3. **Failure Signs**: Any indications of current or imminent failure
4. **Safety Concerns**: Any condition that affects vehicle safety
5. **Performance Impact**: How current condition affects performance
6. **Replacement Priority**: Immediate, soon (1-6 months), routine maintenance, or preventive
7. **Related Inspections**: Other parts to check when replacing this one

Provide a clear recommendation with reasoning based on visual evidence.${contextInfo}

Use a professional tone as if advising a customer about their vehicle.`;

        const response = await callGeminiVisionAPI(userPrompt, imageBase64, mimeType);

        return {
            success: true,
            assessment: response,
            vehicleContext: vehicleContext || null,
            analysisType: 'condition_assessment',
            timestamp: new Date().toISOString(),
            model: VISION_MODEL
        };

    } catch (error) {
        console.error('Error assessing part condition:', error);
        throw new GeminiVisionError(
            error.message || 'Failed to assess part condition',
            'CONDITION_ASSESSMENT_FAILED',
            500
        );
    }
}

/**
 * Call Gemini Vision API with a single image
 * @param {string} prompt - Text prompt
 * @param {string} imageBase64 - Base64 encoded image
 * @param {string} mimeType - Image MIME type
 * @returns {Promise<string>} API response text
 */
async function callGeminiVisionAPI(prompt, imageBase64, mimeType) {
    try {
        const apiKey = getApiKey();

        const requestBody = {
            systemInstruction: {
                parts: [{
                    text: VISION_SYSTEM_PROMPT
                }]
            },
            contents: [{
                parts: [
                    {
                        text: prompt
                    },
                    {
                        inlineData: {
                            mimeType: mimeType,
                            data: imageBase64
                        }
                    }
                ]
            }],
            generationConfig: {
                temperature: 0.4, // Slightly higher for descriptive analysis
                topP: 0.8,
                topK: 10,
                maxOutputTokens: 3072 // Higher limit for detailed analysis
            }
        };

        const response = await axios.post(
            `${GEMINI_API_BASE_URL}/${VISION_MODEL}:generateContent?key=${apiKey}`,
            requestBody,
            {
                headers: {
                    'Content-Type': 'application/json'
                },
                timeout: 45000 // Longer timeout for vision processing
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
            throw new GeminiVisionError(
                'API rate limit exceeded. Please try again in a moment.',
                'RATE_LIMIT',
                429
            );
        }

        if (error.response?.status === 403) {
            throw new GeminiVisionError(
                'API key is invalid or quota exceeded.',
                'INVALID_API_KEY',
                403
            );
        }

        if (error.response?.status === 413) {
            throw new GeminiVisionError(
                'Image file too large. Please use a smaller image.',
                'IMAGE_TOO_LARGE',
                413
            );
        }

        throw error;
    }
}

/**
 * Call Gemini Vision API with multiple images
 * @param {string} prompt - Text prompt
 * @param {Array} imageParts - Array of image parts with inlineData
 * @returns {Promise<string>} API response text
 */
async function callGeminiVisionAPIMultipleImages(prompt, imageParts) {
    try {
        const apiKey = getApiKey();

        const requestBody = {
            systemInstruction: {
                parts: [{
                    text: VISION_SYSTEM_PROMPT
                }]
            },
            contents: [{
                parts: [
                    { text: prompt },
                    ...imageParts
                ]
            }],
            generationConfig: {
                temperature: 0.4,
                topP: 0.8,
                topK: 10,
                maxOutputTokens: 4096 // Even higher for multiple image analysis
            }
        };

        const response = await axios.post(
            `${GEMINI_API_BASE_URL}/${VISION_MODEL}:generateContent?key=${apiKey}`,
            requestBody,
            {
                headers: {
                    'Content-Type': 'application/json'
                },
                timeout: 60000 // Longer timeout for multiple images
            }
        );

        const text = response.data?.candidates?.[0]?.content?.parts?.[0]?.text;
        if (!text) {
            throw new Error('No text content in API response');
        }

        return text;

    } catch (error) {
        if (error.response?.status === 429) {
            throw new GeminiVisionError(
                'API rate limit exceeded. Please try again in a moment.',
                'RATE_LIMIT',
                429
            );
        }

        throw error;
    }
}

/**
 * Validate image format and size
 * @param {string} imageBase64 - Base64 encoded image
 * @param {string} mimeType - Image MIME type
 * @returns {Object} Validation result
 */
export function validateImage(imageBase64, mimeType) {
    const supportedTypes = ['image/jpeg', 'image/png', 'image/webp'];

    if (!supportedTypes.includes(mimeType)) {
        return {
            valid: false,
            error: `Unsupported image type: ${mimeType}. Supported types: ${supportedTypes.join(', ')}`
        };
    }

    // Estimate file size from base64
    const fileSizeBytes = imageBase64.length * 0.75;
    const maxSizeBytes = 20 * 1024 * 1024; // 20MB limit

    if (fileSizeBytes > maxSizeBytes) {
        return {
            valid: false,
            error: `Image too large: ${Math.round(fileSizeBytes / (1024 * 1024))}MB. Maximum size: 20MB`
        };
    }

    return {
        valid: true,
        fileSizeBytes,
        mimeType
    };
}

/**
 * Convert image file to base64
 * @param {Buffer} imageBuffer - Image buffer
 * @returns {string} Base64 encoded string
 */
export function imageToBase64(imageBuffer) {
    return imageBuffer.toString('base64');
}

/**
 * Custom error class for Gemini Vision errors
 */
export class GeminiVisionError extends Error {
    constructor(message, code, statusCode) {
        super(message);
        this.name = 'GeminiVisionError';
        this.code = code;
        this.statusCode = statusCode;
    }
}

export default {
    analyzePartImage,
    askPartQuestion,
    comparePartImages,
    detectPartMarkings,
    assessPartCondition,
    validateImage,
    imageToBase64,
    GeminiVisionError,
    VISION_SYSTEM_PROMPT
};