/**
 * Part Scanning Service
 * 
 * Handles communication with the part scanning API endpoints
 * for computer vision analysis of spare parts using Gemini
 */

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3001/api';

export interface VehicleContext {
    make?: string;
    model?: string;
    year?: number;
    engine?: string;
    mileage?: number;
}

export interface PartScanResult {
    success: boolean;
    analysis?: string;
    vehicleContext?: VehicleContext | null;
    analysisType: 'part_identification' | 'question_answer' | 'part_comparison' | 'marking_detection' | 'condition_assessment';
    timestamp: string;
    model: string;
}

export interface PartQuestionResult {
    success: boolean;
    question: string;
    answer?: string;
    vehicleContext?: VehicleContext | null;
    analysisType: 'question_answer';
    timestamp: string;
    model: string;
}

export interface PartComparisonResult {
    success: boolean;
    comparisonType: string;
    imageCount: number;
    comparison?: string;
    vehicleContext?: VehicleContext | null;
    analysisType: 'part_comparison';
    timestamp: string;
    model: string;
}

export interface PartMarkingResult {
    success: boolean;
    markings?: string;
    analysisType: 'marking_detection';
    timestamp: string;
    model: string;
}

export interface PartConditionResult {
    success: boolean;
    assessment?: string;
    vehicleContext?: VehicleContext | null;
    analysisType: 'condition_assessment';
    timestamp: string;
    model: string;
}

export interface ImageData {
  imageBase64: string;
  mimeType: string;
  label?: string;
}

/**
 * Convert a File or Blob to base64 string
 */
export const fileToBase64 = (file: File | Blob): Promise<string> => {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => {
      const result = reader.result as string;
      // Remove the data URL prefix (e.g., "data:image/jpeg;base64,")
      const base64 = result.split(',')[1];
      resolve(base64);
    };
    reader.onerror = reject;
    reader.readAsDataURL(file);
  });
};

/**
 * Validate image file before upload
 */
export const validateImageFile = (file: File): { valid: boolean; error?: string } => {
  const maxSizeBytes = 20 * 1024 * 1024; // 20MB
  const supportedTypes = ['image/jpeg', 'image/png', 'image/webp'];

  if (!supportedTypes.includes(file.type)) {
    return {
      valid: false,
      error: `Unsupported file type: ${file.type}. Please use JPEG, PNG, or WebP.`
    };
  }

  if (file.size > maxSizeBytes) {
    return {
      valid: false,
      error: `File too large: ${Math.round(file.size / (1024 * 1024))}MB. Maximum size: 20MB.`
    };
  }

  return { valid: true };
};

/**
 * Scan and analyze a spare part image
 */
export const scanPartImage = async (
  imageFile: File,
  vehicleContext?: VehicleContext
): Promise<PartScanResult> => {
  // Validate image
  const validation = validateImageFile(imageFile);
  if (!validation.valid) {
    throw new Error(validation.error);
  }

  // Convert to base64
  const imageBase64 = await fileToBase64(imageFile);

  const response = await fetch(`${API_BASE_URL}/parts/scan`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      imageBase64,
      mimeType: imageFile.type,
      vehicleContext
    }),
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.message || 'Failed to scan part');
  }

  return response.json();
};

/**
 * Ask a specific question about a part image
 */
export const askPartQuestion = async (
  imageFile: File,
  question: string,
  vehicleContext?: VehicleContext
): Promise<PartQuestionResult> => {
  // Validate inputs
  const validation = validateImageFile(imageFile);
  if (!validation.valid) {
    throw new Error(validation.error);
  }

  if (!question || question.trim().length < 3) {
    throw new Error('Question must be at least 3 characters long');
  }

  // Convert to base64
  const imageBase64 = await fileToBase64(imageFile);

  const response = await fetch(`${API_BASE_URL}/parts/scan/question`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      imageBase64,
      mimeType: imageFile.type,
      question: question.trim(),
      vehicleContext
    }),
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.message || 'Failed to answer question');
  }

  return response.json();
};

/**
 * Compare multiple part images
 */
export const comparePartImages = async (
  imageFiles: File[],
  comparisonType: 'condition' | 'compatibility' | 'quality' | 'general' = 'general',
  vehicleContext?: VehicleContext
): Promise<PartComparisonResult> => {
  if (imageFiles.length < 2 || imageFiles.length > 4) {
    throw new Error('Must provide 2-4 images for comparison');
  }

  // Validate all images
  for (let i = 0; i < imageFiles.length; i++) {
    const validation = validateImageFile(imageFiles[i]);
    if (!validation.valid) {
      throw new Error(`Image ${i + 1}: ${validation.error}`);
    }
  }

  // Convert all images to base64
  const images: ImageData[] = await Promise.all(
    imageFiles.map(async (file, index) => ({
      imageBase64: await fileToBase64(file),
      mimeType: file.type,
      label: `Image ${index + 1}`
    }))
  );

  const response = await fetch(`${API_BASE_URL}/parts/scan/compare`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      images,
      comparisonType,
      vehicleContext
    }),
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.message || 'Failed to compare images');
  }

  return response.json();
};

/**
 * Detect part numbers and markings in an image
 */
export const detectPartMarkings = async (imageFile: File): Promise<PartMarkingResult> => {
  // Validate image
  const validation = validateImageFile(imageFile);
  if (!validation.valid) {
    throw new Error(validation.error);
  }

  // Convert to base64
  const imageBase64 = await fileToBase64(imageFile);

  const response = await fetch(`${API_BASE_URL}/parts/scan/markings`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      imageBase64,
      mimeType: imageFile.type
    }),
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.message || 'Failed to detect markings');
  }

  return response.json();
};

/**
 * Assess part condition and get replacement recommendations
 */
export const assessPartCondition = async (
  imageFile: File,
  vehicleContext?: VehicleContext
): Promise<PartConditionResult> => {
  // Validate image
  const validation = validateImageFile(imageFile);
  if (!validation.valid) {
    throw new Error(validation.error);
  }

  // Convert to base64
  const imageBase64 = await fileToBase64(imageFile);

  const response = await fetch(`${API_BASE_URL}/parts/scan/condition`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      imageBase64,
      mimeType: imageFile.type,
      vehicleContext
    }),
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.message || 'Failed to assess condition');
  }

  return response.json();
};

export default {
  scanPartImage,
  askPartQuestion,
  comparePartImages,
  detectPartMarkings,
  assessPartCondition,
  validateImageFile,
  fileToBase64
};