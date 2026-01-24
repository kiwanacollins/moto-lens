import { generateResponse } from './geminiAiService.js';

/**
 * Vehicle Data Enrichment Service
 * Uses AI to fill in missing vehicle specifications based on make, model, year
 */
class VehicleEnrichmentService {
    /**
     * Enriches vehicle data by predicting missing specifications using AI
     * @param {Object} vehicleData - Base vehicle data from VIN decode
     * @returns {Object} - Enriched vehicle data with AI-predicted specifications
     */
    async enrichVehicleData(vehicleData) {
        try {
            const { make, model, year, vin } = vehicleData;

            // Create a detailed prompt for AI enrichment
            const enrichmentPrompt = this.createEnrichmentPrompt(make, model, year, vehicleData);

            // Get AI predictions
            const aiResponse = await generateResponse(enrichmentPrompt);

            // Parse AI response into structured data
            const enrichedSpecs = this.parseAiResponse(aiResponse, vehicleData);

            // Merge with original data, preserving any existing valid values
            const enrichedData = {
                ...vehicleData,
                ...enrichedSpecs,
                // Add metadata about enrichment
                _enriched: true,
                _enrichedAt: new Date().toISOString(),
                _enrichedFields: Object.keys(enrichedSpecs)
            };

            return enrichedData;
        } catch (error) {
            console.error('Error enriching vehicle data:', error);
            // Return original data if enrichment fails
            return {
                ...vehicleData,
                _enriched: false,
                _enrichmentError: error.message
            };
        }
    }

    /**
     * Creates a detailed prompt for AI vehicle specification prediction
     */
    createEnrichmentPrompt(make, model, year, currentData) {
        return `You are an automotive database expert. Based on the vehicle information provided, predict the most likely technical specifications.

Vehicle: ${year} ${make} ${model}
Current VIN decode data: ${JSON.stringify(currentData, null, 2)}

Please provide ONLY a JSON response with these exact fields (use realistic specifications based on the vehicle):

{
  "engine": "Detailed engine specification (e.g., '2.0L TSI 4-cylinder turbo', '1.4L TDI diesel')",
  "bodyType": "Body style (e.g., 'Hatchback', 'Sedan', 'SUV', 'Coupe', 'Wagon')",
  "transmission": "Transmission type (e.g., '6-speed manual', '8-speed automatic DSG', 'CVT')",
  "drivetrain": "Drive type (e.g., 'Front-wheel drive', 'All-wheel drive', 'Rear-wheel drive')",
  "trim": "Most common trim level (e.g., 'SE', 'SEL', 'R-Line', 'GTI')",
  "fuelType": "Fuel type (e.g., 'Gasoline', 'Diesel', 'Hybrid', 'Electric')",
  "displacement": "Engine displacement in liters (e.g., '2.0', '1.8', '3.0')",
  "cylinders": "Number of cylinders (e.g., 4, 6, 8)",
  "horsepower": "Estimated horsepower (e.g., '147 hp', '220 hp')",
  "torque": "Estimated torque (e.g., '184 lb-ft', '258 lb-ft')",
  "doors": "Number of doors (e.g., 2, 4, 5)",
  "seats": "Number of seats (e.g., 2, 4, 5, 7)"
}

Guidelines:
- Use realistic specifications for this specific year/make/model combination
- Be specific and professional (no generic terms)
- For German vehicles (BMW, Audi, Mercedes, VW, Porsche), use European specifications
- If multiple variants exist, choose the most common/base model specifications
- Ensure all values are realistic and accurate for the vehicle
- Do not include any markdown formatting, only pure JSON

RESPOND ONLY WITH THE JSON OBJECT, NO OTHER TEXT.`;
    }

    /**
     * Parses AI response and validates the data
     */
    parseAiResponse(aiResponse, originalData) {
        try {
            // Clean the response (remove any markdown or extra text)
            let cleanedResponse = aiResponse.trim();

            // Extract JSON if wrapped in markdown
            const jsonMatch = cleanedResponse.match(/\{[\s\S]*\}/);
            if (jsonMatch) {
                cleanedResponse = jsonMatch[0];
            }

            const parsed = JSON.parse(cleanedResponse);

            // Validate required fields exist
            const requiredFields = ['engine', 'bodyType', 'transmission', 'drivetrain'];
            const validatedData = {};

            requiredFields.forEach(field => {
                if (parsed[field] && parsed[field] !== 'Not specified' && parsed[field] !== null) {
                    validatedData[field] = parsed[field];
                }
            });

            // Add optional fields if present and valid
            const optionalFields = ['trim', 'fuelType', 'displacement', 'cylinders', 'horsepower', 'torque', 'doors', 'seats'];
            optionalFields.forEach(field => {
                if (parsed[field] && parsed[field] !== 'Not specified' && parsed[field] !== null) {
                    validatedData[field] = parsed[field];
                }
            });

            return validatedData;
        } catch (error) {
            console.error('Error parsing AI response:', error);
            console.error('Raw AI response:', aiResponse);
            return {};
        }
    }

    /**
     * Quick enrichment for essential fields only (faster response)
     */
    async quickEnrich(make, model, year) {
        const quickPrompt = `Vehicle: ${year} ${make} ${model}

Provide ONLY JSON with essential specs:
{
  "engine": "Engine spec",
  "bodyType": "Body type", 
  "transmission": "Transmission",
  "drivetrain": "Drive type"
}

NO other text, only JSON:`;

        try {
            const response = await generateResponse(quickPrompt);
            return this.parseAiResponse(response, {});
        } catch (error) {
            console.error('Quick enrichment failed:', error);
            return {};
        }
    }
}

export default new VehicleEnrichmentService();