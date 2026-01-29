/**
 * Part Scanning Service
 *
 * Handles communication with the part scanning API endpoints
 * for computer vision analysis of spare parts using Gemini
 */

// Use proxy for production to avoid mixed content issues
const isProd = typeof window !== 'undefined' && window.location.hostname !== 'localhost';
const API_BASE_URL = isProd 
  ? '/api/proxy'  // Use Vercel serverless proxy in production
  : (import.meta.env.VITE_API_BASE_URL || 'http://localhost:3001/api');

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
  analysisType:
  | 'part_identification'
  | 'question_answer'
  | 'part_comparison'
  | 'marking_detection'
  | 'condition_assessment';
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
      error: `Unsupported file type: ${file.type}. Please use JPEG, PNG, or WebP.`,
    };
  }

  if (file.size > maxSizeBytes) {
    return {
      valid: false,
      error: `File too large: ${Math.round(file.size / (1024 * 1024))}MB. Maximum size: 20MB.`,
    };
  }

  return { valid: true };
};

/**
 * Scan and analyze a spare part image
 * Note: Vehicle context is not used for AI analysis to prevent bias
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
      vehicleContext, // For display only, not used in AI analysis
    }),
  });

  if (!response.ok) {
    let errorMessage = 'Failed to scan part';

    try {
      // Check if response is JSON
      const contentType = response.headers.get('content-type');
      if (contentType && contentType.includes('application/json')) {
        const error = await response.json();
        errorMessage = error.message || errorMessage;
      } else {
        // Non-JSON response, likely HTML error page
        const text = await response.text();
        if (text.includes('Request Entity Too Large')) {
          errorMessage = 'Image file is too large. Please use a smaller image (max 20MB).';
        } else if (response.status >= 500) {
          errorMessage = 'Server error. Please try again later.';
        } else if (response.status === 404) {
          errorMessage = 'API endpoint not found. Please check your connection.';
        } else {
          errorMessage = `Request failed (${response.status}). Please try again.`;
        }
      }
    } catch {
      // Fallback error message if parsing fails
      errorMessage = 'Network error. Please check your connection and try again.';
    }

    throw new Error(errorMessage);
  }

  // Parse response with error handling for non-JSON responses
  try {
    const contentType = response.headers.get('content-type');
    if (contentType && contentType.includes('application/json')) {
      return await response.json();
    } else {
      // Successful status but non-JSON response
      console.error('Unexpected non-JSON response from API');
      throw new Error('Server returned an unexpected response. Please try again.');
    }
  } catch (parseError) {
    if (parseError instanceof SyntaxError) {
      console.error('JSON parse error:', parseError);
      throw new Error('Server returned invalid data. Please try again.');
    }
    throw parseError;
  }
};

/**
 * Ask a specific question about a part image
 * Note: Vehicle context is not used for AI analysis to prevent bias
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
      vehicleContext, // For display only, not used in AI analysis
    }),
  });

  if (!response.ok) {
    let errorMessage = 'Failed to answer question';

    try {
      // Check if response is JSON
      const contentType = response.headers.get('content-type');
      if (contentType && contentType.includes('application/json')) {
        const error = await response.json();
        errorMessage = error.message || errorMessage;
      } else {
        // Non-JSON response, likely HTML error page
        const text = await response.text();
        if (text.includes('Request Entity Too Large')) {
          errorMessage = 'Image file is too large. Please use a smaller image (max 20MB).';
        } else if (response.status >= 500) {
          errorMessage = 'Server error. Please try again later.';
        } else if (response.status === 404) {
          errorMessage = 'API endpoint not found. Please check your connection.';
        } else {
          errorMessage = `Request failed (${response.status}). Please try again.`;
        }
      }
    } catch {
      // Fallback error message if parsing fails
      errorMessage = 'Network error. Please check your connection and try again.';
    }

    throw new Error(errorMessage);
  }

  // Parse response with error handling for non-JSON responses
  try {
    const contentType = response.headers.get('content-type');
    if (contentType && contentType.includes('application/json')) {
      return await response.json();
    } else {
      console.error('Unexpected non-JSON response from API');
      throw new Error('Server returned an unexpected response. Please try again.');
    }
  } catch (parseError) {
    if (parseError instanceof SyntaxError) {
      console.error('JSON parse error:', parseError);
      throw new Error('Server returned invalid data. Please try again.');
    }
    throw parseError;
  }
};

/**
 * Compare multiple part images
 * Note: Vehicle context is not used for AI analysis to prevent bias
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
      label: `Image ${index + 1}`,
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
      vehicleContext, // For display only, not used in AI analysis
    }),
  });

  if (!response.ok) {
    let errorMessage = 'Failed to compare images';

    try {
      // Check if response is JSON
      const contentType = response.headers.get('content-type');
      if (contentType && contentType.includes('application/json')) {
        const error = await response.json();
        errorMessage = error.message || errorMessage;
      } else {
        // Non-JSON response, likely HTML error page
        const text = await response.text();
        if (text.includes('Request Entity Too Large')) {
          errorMessage = 'Image files are too large. Please use smaller images (max 20MB each).';
        } else if (response.status >= 500) {
          errorMessage = 'Server error. Please try again later.';
        } else if (response.status === 404) {
          errorMessage = 'API endpoint not found. Please check your connection.';
        } else {
          errorMessage = `Request failed (${response.status}). Please try again.`;
        }
      }
    } catch {
      // Fallback error message if parsing fails
      errorMessage = 'Network error. Please check your connection and try again.';
    }

    throw new Error(errorMessage);
  }

  // Parse response with error handling for non-JSON responses
  try {
    const contentType = response.headers.get('content-type');
    if (contentType && contentType.includes('application/json')) {
      return await response.json();
    } else {
      console.error('Unexpected non-JSON response from API');
      throw new Error('Server returned an unexpected response. Please try again.');
    }
  } catch (parseError) {
    if (parseError instanceof SyntaxError) {
      console.error('JSON parse error:', parseError);
      throw new Error('Server returned invalid data. Please try again.');
    }
    throw parseError;
  }
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
      mimeType: imageFile.type,
    }),
  });

  if (!response.ok) {
    let errorMessage = 'Failed to detect markings';

    try {
      // Check if response is JSON
      const contentType = response.headers.get('content-type');
      if (contentType && contentType.includes('application/json')) {
        const error = await response.json();
        errorMessage = error.message || errorMessage;
      } else {
        // Non-JSON response, likely HTML error page
        const text = await response.text();
        if (text.includes('Request Entity Too Large')) {
          errorMessage = 'Image file is too large. Please use a smaller image (max 20MB).';
        } else if (response.status >= 500) {
          errorMessage = 'Server error. Please try again later.';
        } else if (response.status === 404) {
          errorMessage = 'API endpoint not found. Please check your connection.';
        } else {
          errorMessage = `Request failed (${response.status}). Please try again.`;
        }
      }
    } catch {
      // Fallback error message if parsing fails
      errorMessage = 'Network error. Please check your connection and try again.';
    }

    throw new Error(errorMessage);
  }

  // Parse response with error handling for non-JSON responses
  try {
    const contentType = response.headers.get('content-type');
    if (contentType && contentType.includes('application/json')) {
      return await response.json();
    } else {
      console.error('Unexpected non-JSON response from API');
      throw new Error('Server returned an unexpected response. Please try again.');
    }
  } catch (parseError) {
    if (parseError instanceof SyntaxError) {
      console.error('JSON parse error:', parseError);
      throw new Error('Server returned invalid data. Please try again.');
    }
    throw parseError;
  }
};

/**
 * Assess part condition and get replacement recommendations
 * Note: Vehicle context is not used for AI analysis to prevent bias
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
      vehicleContext, // For display only, not used in AI analysis
    }),
  });

  if (!response.ok) {
    let errorMessage = 'Failed to assess condition';

    try {
      // Check if response is JSON
      const contentType = response.headers.get('content-type');
      if (contentType && contentType.includes('application/json')) {
        const error = await response.json();
        errorMessage = error.message || errorMessage;
      } else {
        // Non-JSON response, likely HTML error page
        const text = await response.text();
        if (text.includes('Request Entity Too Large')) {
          errorMessage = 'Image file is too large. Please use a smaller image (max 20MB).';
        } else if (response.status >= 500) {
          errorMessage = 'Server error. Please try again later.';
        } else if (response.status === 404) {
          errorMessage = 'API endpoint not found. Please check your connection.';
        } else {
          errorMessage = `Request failed (${response.status}). Please try again.`;
        }
      }
    } catch {
      // Fallback error message if parsing fails
      errorMessage = 'Network error. Please check your connection and try again.';
    }

    throw new Error(errorMessage);
  }

  // Parse response with error handling for non-JSON responses
  try {
    const contentType = response.headers.get('content-type');
    if (contentType && contentType.includes('application/json')) {
      return await response.json();
    } else {
      console.error('Unexpected non-JSON response from API');
      throw new Error('Server returned an unexpected response. Please try again.');
    }
  } catch (parseError) {
    if (parseError instanceof SyntaxError) {
      console.error('JSON parse error:', parseError);
      throw new Error('Server returned invalid data. Please try again.');
    }
    throw parseError;
  }
};

export default {
  scanPartImage,
  askPartQuestion,
  comparePartImages,
  detectPartMarkings,
  assessPartCondition,
  validateImageFile,
  fileToBase64,
};
