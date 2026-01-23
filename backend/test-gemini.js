// Quick test for Gemini API key
import { GoogleGenerativeAI } from '@google/generative-ai';
import dotenv from 'dotenv';

dotenv.config();

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

async function testGemini() {
    try {
        console.log('Testing Gemini API key...');
        console.log('API Key preview:', process.env.GEMINI_API_KEY?.substring(0, 10) + '...');

        // Try the basic text generation model first
        const model = genAI.getGenerativeModel({ model: "gemini-pro" });
        const prompt = "Hello, can you generate a simple response?";

        const result = await model.generateContent(prompt);
        const response = await result.response;
        const text = response.text();

        console.log('✅ API key works! Response:', text);
        return true;
    } catch (error) {
        console.error('❌ API key test failed:', error.message);
        if (error.status) {
            console.error('Status:', error.status);
        }
        return false;
    }
}

testGemini();