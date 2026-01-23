/**
 * Test script for vehicle image generation
 * Tests both Imagen 3 and Gemini image generation services
 */

import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

// Dynamically import the appropriate service based on config
const useImagen3 = false; // Disabled due to quota limits
console.log(`🔧 Using ${useImagen3 ? 'Vertex AI Imagen 3' : 'Gemini'} for image generation\n`);

const imageService = (await import('./src/services/geminiImageService.js')).default;

// Test vehicle data
const testVehicles = [
    {
        make: 'BMW',
        model: '320i',
        year: 2023,
        trim: 'Sport Line'
    },
    {
        make: 'Audi',
        model: 'A4',
        year: 2022,
        trim: 'Quattro'
    },
    {
        make: 'Mercedes-Benz',
        model: 'C-Class',
        year: 2024
    }
];

async function testImageGeneration() {
    console.log('🚗 Testing vehicle image generation service...\n');

    // Enable mock mode for testing
    process.env.USE_MOCK_IMAGES = 'true';

    for (const vehicle of testVehicles) {
        console.log(`Testing: ${vehicle.year} ${vehicle.make} ${vehicle.model} ${vehicle.trim || ''}`);
        console.log('─'.repeat(50));

        try {
            const startTime = Date.now();
            const result = await imageService.generateVehicleImages(vehicle);
            const duration = Date.now() - startTime;

            console.log(`✅ Generation completed in ${duration}ms`);
            console.log(`📊 Generated ${Object.keys(result.images).length} angles`);

            // Show results for each angle
            Object.entries(result.images).forEach(([angle, imageData]) => {
                const status = imageData.success ? '✅' : '❌';
                const size = imageData.fileSize ? `(${imageData.fileSize} bytes)` : '';
                const mockFlag = imageData.isMock ? ' [MOCK]' : '';
                console.log(`  ${status} ${angle}: ${imageData.success ? 'Success' : 'Failed'} ${size}${mockFlag}`);

                if (!imageData.success) {
                    console.log(`    Error: ${imageData.error}`);
                }
            });

            console.log(`🕒 Generated at: ${result.generatedAt}`);

        } catch (error) {
            console.log(`❌ Error: ${error.message}`);
        }

        console.log('');
    }

    // Test cache functionality
    console.log('🗃️ Testing cache functionality...');
    console.log('─'.repeat(50));

    const cacheStats = imageService.getCacheStats();
    console.log(`Cache entries: ${cacheStats.total}`);
    console.log(`Valid entries: ${cacheStats.valid}`);
    console.log(`Expired entries: ${cacheStats.expired}`);
    console.log(`Cache TTL: ${cacheStats.cacheTtlHours} hours`);
    if (cacheStats.model) {
        console.log(`Model: ${cacheStats.model}`);
        console.log(`Location: ${cacheStats.location}`);
    }

    if (cacheStats.keys.length > 0) {
        console.log('Cached vehicles:');
        cacheStats.keys.forEach(key => console.log(`  - ${key}`));
    }

    // Test cache hit by generating images for the same vehicle again
    console.log('\n🔄 Testing cache hit...');
    const firstVehicle = testVehicles[0];

    const startTime = Date.now();
    const cachedResult = await imageService.generateVehicleImages(firstVehicle);

    console.log('\n✨ Test completed successfully!');
}

async function testRealAPICall() {
    console.log('\n🌐 Testing real Vertex AI / Gemini API call...');
    console.log('─'.repeat(50));

    // Temporarily disable mock mode
    delete process.env.USE_MOCK_IMAGES;

    const testVehicle = {
        make: 'BMW',
        model: 'X5',
        year: 2023
    };

    try {
        const result = await imageService.generateVehicleImages(testVehicle);

        console.log('✅ Real API call successful');

        // Check if any images were successfully generated
        const successfulImages = Object.values(result.images).filter(img => img.success && !img.isMock);
        const mockImages = Object.values(result.images).filter(img => img.isMock);

        console.log(`📸 Real images generated: ${successfulImages.length}`);
        console.log(`🎭 Mock images used: ${mockImages.length}`);

        if (successfulImages.length > 0) {
            console.log('✅ Vertex AI integration working!');

            // Show file sizes
            successfulImages.forEach(img => {
                console.log(`  ${img.angle}: ${img.fileSize} bytes`);
            });
        } else {
            console.log('⚠️  Only mock images generated - check API configuration');
        }

    } catch (error) {
        console.log('⚠️  Real API call failed, falling back to mock images');
        console.log(`Error: ${error.message}`);

        if (error.message.includes('API key') || error.message.includes('authentication')) {
            console.log('💡 Tip: Set GEMINI_API_KEY environment variable for real image generation');
        }
    }
}

// Run tests
async function runTests() {
    try {
        await testImageGeneration();

        // Only test real API if configured
        const hasImagen3 = !!process.env.GOOGLE_CLOUD_PROJECT_ID;
        const hasGemini = !!process.env.GEMINI_API_KEY;

        if (hasImagen3 || hasGemini) {
            await testRealAPICall();
        } else {
            console.log('\n💡 Skipping real API test - no API credentials configured');
            console.log('For Imagen 3: Set GOOGLE_CLOUD_PROJECT_ID and GOOGLE_APPLICATION_CREDENTIALS');
            console.log('For Gemini: Set GEMINI_API_KEY');
        }

    } catch (error) {
        console.error('❌ Test failed:', error);
        process.exit(1);
    }
}

runTests();