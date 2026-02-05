# MotoLens Flutter Mobile App Specification

## Overview

This document provides comprehensive specifications for building the Flutter mobile version of MotoLens - a professional automotive spare parts scanner and VIN decoder application. The app enables mechanics and car enthusiasts to decode VINs, view vehicle information, and use AI-powered computer vision to analyze spare parts.

## Table of Contents

1. [Project Structure & Development Setup](#project-structure--development-setup)
2. [App Architecture](#app-architecture)
3. [Design System](#design-system)
4. [Authentication](#authentication)
5. [Screens & Navigation](#screens--navigation)
6. [Backend API Integration](#backend-api-integration)
7. [Data Models](#data-models)
8. [Key Features](#key-features)
9. [Components](#components)
10. [Camera Integration](#camera-integration)
11. [Error Handling](#error-handling)
12. [Performance Considerations](#performance-considerations)
13. [Backend Modification Guidelines](#backend-modification-guidelines)

---

## Project Structure & Development Setup

### Recommended Monorepo Structure

The MotoLens project should be organized as a monorepo with mobile and backend living in the same workspace for seamless development:

```
moto-lens/                                    # Root workspace folder
├── README.md                                 # Main project overview
├── FLUTTER_MOBILE_SPECIFICATION.md          # This document (mobile spec)
├── .vscode/
│   └── settings.json                        # Workspace settings for both projects
│
├── mobile/                                   # Flutter mobile app
│   ├── README.md
│   ├── pubspec.yaml
│   ├── analysis_options.yaml
│   ├── android/
│   ├── ios/
│   └── lib/
│       ├── main.dart
│       ├── config/
│       │   └── environment.dart             # Backend URL configuration
│       ├── models/
│       ├── services/
│       ├── screens/
│       ├── widgets/
│       └── utils/
│
└── backend/                                  # Node.js backend (existing)
    ├── README.md
    ├── package.json
    ├── ecosystem.config.cjs
    └── src/
        ├── server.js
        ├── services/
        └── utils/
```

### Why This Structure Works:

✅ **Single VS Code Workspace**: Open the root `moto-lens/` folder to work on both projects
✅ **Easy Backend Tweaks**: Modify backend endpoints while building mobile features
✅ **Shared Context**: AI agents can see both projects and understand their relationship
✅ **Version Control**: Git tracks changes to both mobile and backend together
✅ **Documentation Proximity**: Specs and code live in the same workspace

### Setting Up the Development Environment

#### Step 1: Create the Mobile App Folder
```bash
# From the root moto-lens/ directory
cd /Users/kiwana/projects/moto-lens
flutter create mobile
cd mobile
```

#### Step 2: Configure VS Code Workspace
Create or update `.vscode/settings.json` in the root:

```json
{
  "files.exclude": {
    "**/.git": true,
    "**/.DS_Store": true,
    "**/node_modules": false,
    "**/.dart_tool": true,
    "**/build": true
  },
  "search.exclude": {
    "**/node_modules": true,
    "**/build": true,
    "**/.dart_tool": true,
    "**/ios/Pods": true,
    "**/android/.gradle": true
  },
  "[dart]": {
    "editor.formatOnSave": true,
    "editor.formatOnType": true,
    "editor.rulers": [80],
    "editor.selectionHighlight": false,
    "editor.suggest.snippetsPreventQuickSuggestions": false,
    "editor.suggestSelection": "first",
    "editor.tabCompletion": "onlySnippets",
    "editor.wordBasedSuggestions": "off"
  },
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true
  },
  "dart.flutterSdkPath": "/Users/kiwana/development/flutter",
  "typescript.tsdk": "frontend/node_modules/typescript/lib"
}
```

#### Step 3: Create Root README.md
Add a comprehensive README at the root to guide development:

```markdown
# MotoLens - Automotive Spare Parts Scanner

Professional VIN decoder and AI-powered spare parts identification system.

## Project Structure

- **`mobile/`** - Flutter mobile application (iOS & Android)
- **`backend/`** - Node.js + Express API server
- **`frontend/`** - React web application (legacy, minimal maintenance)

## Quick Start

### Backend Development
\`\`\`bash
cd backend
npm install
npm run dev  # Starts on http://localhost:3000
\`\`\`

### Mobile Development
\`\`\`bash
cd mobile
flutter pub get
flutter run  # Opens device selector
\`\`\`

### Running Both Simultaneously
\`\`\`bash
# Terminal 1: Start backend
cd backend && npm run dev

# Terminal 2: Start mobile app
cd mobile && flutter run
\`\`\`

## Development Workflow

1. **Mobile + Backend Changes**: 
   - Open root `moto-lens/` folder in VS Code
   - Both projects visible in sidebar
   - Make changes to backend API endpoints
   - Update mobile app to consume new endpoints
   - Test immediately with local backend

2. **Backend-Only Changes**:
   - Navigate to `backend/` folder
   - Modify endpoints, add features
   - Update API documentation

3. **Mobile-Only Changes**:
   - Navigate to `mobile/` folder  
   - Build UI, add features
   - Test with existing backend

## AI Agent Instructions

When working on this project:
- **Context**: Always open the root `moto-lens/` folder to see both projects
- **Backend Changes**: When mobile app needs a new endpoint, modify `backend/src/server.js`
- **Mobile Changes**: Update `mobile/lib/` to consume backend APIs
- **Configuration**: Backend URL is in `mobile/lib/config/environment.dart`
- **Testing**: Run backend locally, point mobile app to `http://10.0.2.2:3000/api`
\`\`\`

### Development Workflow for AI Agents

#### When Building Mobile Features:

1. **Check Backend First**: Verify if the required endpoint exists in `backend/src/server.js`
2. **Add/Modify Backend Endpoint** if needed:
   ```javascript
   // Example: Adding a new endpoint in backend/src/server.js
   app.post('/api/parts/scan/compare', async (req, res) => {
     // Implementation
   });
   ```
3. **Update Mobile Service**: Create/update the corresponding service in `mobile/lib/services/`
4. **Build Mobile UI**: Implement the feature in `mobile/lib/screens/` or `mobile/lib/widgets/`
5. **Test Locally**: Run both backend and mobile app, test the integration

#### Development Commands Reference:

```bash
# Terminal Window 1 - Backend Server
cd backend
npm run dev

# Terminal Window 2 - Mobile App  
cd mobile
flutter run

# Terminal Window 3 - Backend Changes (if needed)
cd backend
# Edit files, nodemon auto-restarts

# Terminal Window 4 - Mobile Hot Reload
# Just save files in mobile/, Flutter hot-reloads automatically
```

### VS Code Multi-Root Workspace (Alternative)

If you prefer explicit multi-root workspace, create `moto-lens.code-workspace`:

```json
{
  "folders": [
    {
      "name": "Mobile App",
      "path": "mobile"
    },
    {
      "name": "Backend API",
      "path": "backend"
    },
    {
      "name": "Documentation",
      "path": "."
    }
  ],
  "settings": {
    "files.exclude": {
      "**/node_modules": true,
      "**/.dart_tool": true
    }
  }
}
```

Open with: `code moto-lens.code-workspace`

---

## App Architecture

### Tech Stack
- **Framework**: Flutter
- **HTTP Client**: Dio or http package
- **State Management**: Provider or Riverpod
- **Image Handling**: image_picker, camera
- **Storage**: shared_preferences (auth state)
- **Navigation**: go_router or traditional Navigator

### Project Structure
```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── routes.dart
│   └── theme.dart
├── models/
│   ├── vehicle.dart
│   ├── part_scan.dart
│   └── api_response.dart
├── services/
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── vehicle_service.dart
│   └── part_scan_service.dart
├── screens/
│   ├── login_screen.dart
│   ├── vin_input_screen.dart
│   ├── vehicle_detail_screen.dart
│   └── part_scanner_screen.dart
├── widgets/
│   ├── common/
│   ├── vehicle/
│   └── parts/
└── utils/
    ├── constants.dart
    ├── validators.dart
    └── image_utils.dart
```

---

## Design System

### Brand Colors
```dart
// Primary Brand Colors
class AppColors {
  // Primary - Actions, CTAs, interactive elements
  static const Color electricBlue = Color(0xFF0EA5E9);
  
  // Main text, headings, high-contrast elements
  static const Color carbonBlack = Color(0xFF0A0A0A);
  
  // Secondary text, icons, subtle elements  
  static const Color gunmetalGray = Color(0xFF52525B);
  
  // Backgrounds
  static const Color white = Color(0xFFFFFFFF);
  
  // Zinc Neutral Scale
  static const Color zinc50 = Color(0xFFFAFAFA);
  static const Color zinc100 = Color(0xFFF4F4F5);
  static const Color zinc200 = Color(0xFFE4E4E7);
  static const Color zinc300 = Color(0xFFD4D4D8);
  static const Color zinc600 = Color(0xFF52525B);
  static const Color zinc900 = Color(0xFF0A0A0A);
  
  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
}
```

### Typography
```dart
class AppTypography {
  static const String fontFamily = 'Inter';
  static const String fontMono = 'JetBrains Mono';
  
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColors.carbonBlack,
    height: 1.2,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.carbonBlack,
    height: 1.3,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.carbonBlack,
    height: 1.4,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.carbonBlack,
    height: 1.6,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.carbonBlack,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.gunmetalGray,
    height: 1.4,
  );
  
  static const TextStyle monoText = TextStyle(
    fontSize: 15,
    fontFamily: fontMono,
    fontWeight: FontWeight.w500,
    color: AppColors.electricBlue,
    letterSpacing: 0.5,
  );
}
```

### Spacing & Sizing
```dart
class AppSpacing {
  static const double xs = 8.0;   // 8px
  static const double sm = 12.0;  // 12px  
  static const double md = 16.0;  // 16px
  static const double lg = 24.0;  // 24px
  static const double xl = 32.0;  // 32px
}

class AppSizing {
  // Touch targets (minimum sizes for mobile)
  static const double minTouchTarget = 44.0; // iOS minimum
  static const double comfortableTouchTarget = 48.0; // Recommended
  static const double largeTouchTarget = 56.0; // Extra comfortable
  
  // Button heights
  static const double buttonHeight = 52.0;
  static const double smallButtonHeight = 44.0;
}
```

---

## Authentication

### Simple Auth Implementation
The app uses a simple hardcoded authentication system for MVP:

**Credentials**: `admin` / `admin`

```dart
// lib/services/auth_service.dart
class AuthService extends ChangeNotifier {
  static const String _authKey = 'motolens_auth';
  static const String _validUsername = 'admin';
  static const String _validPassword = 'admin';
  
  bool _isAuthenticated = false;
  String? _username;
  
  bool get isAuthenticated => _isAuthenticated;
  String? get username => _username;
  
  AuthService() {
    _loadAuthState();
  }
  
  Future<bool> login(String username, String password) async {
    // Simulate API delay
    await Future.delayed(Duration(milliseconds: 500));
    
    if (username == _validUsername && password == _validPassword) {
      _isAuthenticated = true;
      _username = username;
      await _saveAuthState();
      notifyListeners();
      return true;
    }
    return false;
  }
  
  Future<void> logout() async {
    _isAuthenticated = false;
    _username = null;
    await _clearAuthState();
    notifyListeners();
  }
  
  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final authData = prefs.getString(_authKey);
    if (authData != null) {
      final decoded = jsonDecode(authData);
      _isAuthenticated = decoded['isAuthenticated'] ?? false;
      _username = decoded['username'];
      notifyListeners();
    }
  }
  
  Future<void> _saveAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authKey, jsonEncode({
      'isAuthenticated': _isAuthenticated,
      'username': _username,
      'timestamp': DateTime.now().toIso8601String(),
    }));
  }
  
  Future<void> _clearAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authKey);
  }
}
```

---

## Screens & Navigation

### 1. Login Screen (`login_screen.dart`)

**Purpose**: Simple authentication with hardcoded credentials

**UI Elements**:
- App logo/branding
- Username field (admin)
- Password field (admin)
- Login button
- Loading state
- Error messages

**Layout**:
```dart
// Simple centered form with app branding
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    AppLogo(size: 120),
    SizedBox(height: AppSpacing.xl),
    Text('German Car Medic', style: AppTypography.heading1),
    SizedBox(height: AppSpacing.lg),
    LoginForm(),
  ],
)
```

### 2. VIN Input Screen (`vin_input_screen.dart`)

**Purpose**: Main entry point for VIN decoding

**UI Elements**:
- Header with logo and navigation (menu button, part scanner button)
- VIN input field (17 characters, uppercase, monospace font)
- Character counter (e.g., "12/17")
- Decode button (disabled until VIN complete)
- Loading state during decoding
- Error handling for invalid VINs
- Info section about supported brands
- Mobile-friendly drawer menu

**Key Features**:
- Live VIN validation as user types
- Format VIN to uppercase
- Visual checkmark when VIN is complete
- Large touch targets for buttons

**Navigation Actions**:
- **Part Scanner**: Navigate to part scanner
- **Logout**: Clear auth and return to login
- **Decode VIN**: Navigate to vehicle detail screen

### 3. Vehicle Detail Screen (`vehicle_detail_screen.dart`)

**Purpose**: Display comprehensive vehicle information and enable part scanning

**UI Elements**:
- **Header**: Back button, logout button
- **Basic Vehicle Info Card**: Make, model, year, body type, drivetrain
- **Manufacturer Info Card**: Manufacturer, address, origin, region
- **VIN Display**: Formatted in monospace font
- **360° Vehicle Images**: Swipeable image carousel
- **AI Summary Card**: Bullet points with technical overview
- **Scan Parts CTA**: Large button to access part scanner
- **Parts Grid**: Interactive hotspot grid for common parts

**ScrollView Layout**:
```dart
SingleChildScrollView(
  child: Column(
    children: [
      VehicleInfoCard(vehicle: vehicle),
      ManufacturerCard(vehicle: vehicle),
      Vehicle360Viewer(vin: vin, vehicleName: name),
      ScanPartsCTA(onPressed: () => navigateToScanner()),
      VehicleSummaryCard(summary: summary),
      PartsGrid(vehicle: vehicle),
    ],
  ),
)
```

### 4. Part Scanner Screen (`part_scanner_screen.dart`)

**Purpose**: AI-powered part analysis via camera

**UI Structure**:
- **Header**: Back button, title
- **Tab Navigation**: 
  - Analyze Part (general analysis)
  - Read Markings (part numbers, text)
  - Check Condition (wear assessment)
- **Camera Section**: Image capture/upload
- **Results Section**: AI analysis display
- **Quick Actions**: Clear, retry, ask questions

**Tabs Implementation**:
```dart
TabBarView(
  children: [
    AnalyzePartTab(),
    ReadMarkingsTab(), 
    CheckConditionTab(),
  ],
)
```

### Navigation Flow
```dart
// Route definitions
class AppRoutes {
  static const String login = '/login';
  static const String home = '/';
  static const String vehicleDetail = '/vehicle';
  static const String partScanner = '/scanner';
}

// Navigation example
void navigateToVehicleDetail(String vin, VehicleData vehicle) {
  Navigator.pushNamed(
    context,
    AppRoutes.vehicleDetail,
    arguments: {'vin': vin, 'vehicle': vehicle},
  );
}
```

---

## Backend API Integration

### Backend Environment Strategy

**Recommended Approach**: Use a **hybrid development strategy** with easy switching between local and deployed backends.

#### When to Use Each Backend:

**Local Backend (`http://localhost:3000/api` or `http://10.0.2.2:3000/api` for Android emulator)**
- ✅ **Initial development phase**: Building features, UI components, and logic
- ✅ **Rapid iteration**: When making frequent backend changes
- ✅ **Debugging**: Full access to backend logs and debugging tools
- ✅ **No network dependency**: Faster response times, no API costs
- ✅ **Emulator/Simulator testing**: Works seamlessly on virtual devices

**Deployed Backend (`https://your-production-url.com/api`)**
- ✅ **Physical device testing**: Required for real device testing
- ✅ **QA and final testing**: Testing in production-like environment
- ✅ **Team collaboration**: Multiple developers testing simultaneously
- ✅ **Network condition testing**: Real-world latency and connectivity issues
- ✅ **Production preparation**: Final validation before release

#### Important Notes on Local Backend:
- **Android Emulator**: Use `http://10.0.2.2:3000/api` (special alias for host machine's localhost)
- **iOS Simulator**: Use `http://localhost:3000/api` (works directly)
- **Physical Devices**: Devices must be on same WiFi network, use your machine's local IP (e.g., `http://192.168.1.100:3000/api`)

### Base API Configuration with Environment Switching
```dart
// lib/config/environment.dart
enum Environment {
  local,
  deployed,
}

class EnvironmentConfig {
  static const Environment current = Environment.local; // Change this to switch
  
  static String get baseUrl {
    switch (current) {
      case Environment.local:
        // Use 10.0.2.2 for Android emulator, localhost for iOS simulator
        // Change to your machine's IP (e.g., 192.168.1.100) for physical devices
        return 'http://10.0.2.2:3000/api'; // Android Emulator
        // return 'http://localhost:3000/api'; // iOS Simulator
        // return 'http://192.168.1.100:3000/api'; // Physical devices on same network
        
      case Environment.deployed:
        return 'https://your-deployed-backend-url.com/api'; // Update with your actual URL
    }
  }
  
  static bool get isLocal => current == Environment.local;
  static bool get isDeployed => current == Environment.deployed;
  
  static Duration get timeout {
    // Longer timeout for local development (debugging)
    return isLocal ? Duration(seconds: 30) : Duration(seconds: 8);
  }
}

// lib/services/api_service.dart
class ApiService {
  static Duration get defaultTimeout => EnvironmentConfig.timeout;
  
  final Dio _dio;
  
  ApiService() : _dio = Dio(BaseOptions(
    baseUrl: EnvironmentConfig.baseUrl,
    connectTimeout: defaultTimeout,
    receiveTimeout: defaultTimeout,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  )) {
    // Add logging interceptor for local development
    if (EnvironmentConfig.isLocal) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ));
    }
  }
  
  Future<Response> get(String endpoint) async {
    return await _dio.get(endpoint);
  }
  
  Future<Response> post(String endpoint, {dynamic data}) async {
    return await _dio.post(endpoint, data: data);
  }
}
```

#### Quick Environment Switching:
```dart
// To switch environments, just change one line in lib/config/environment.dart:
static const Environment current = Environment.local;    // For local development
// OR
static const Environment current = Environment.deployed; // For production testing
```

#### Development Workflow Recommendation:
1. **Phase 1 (Weeks 1-3)**: Build all UI, navigation, and features using `Environment.local`
   - Run backend locally: `cd backend && npm start`
   - Test on emulator with fast iteration
   
2. **Phase 2 (Week 4)**: Integration testing with `Environment.deployed`
   - Test on physical devices
   - Validate network error handling
   - Performance testing with real network conditions
   
3. **Phase 3 (Week 5)**: Final QA exclusively on `Environment.deployed`
   - Production readiness validation
   - End-to-end testing

### API Endpoints

#### 1. Health Check
```dart
GET /api/health

Response:
{
  "status": "ok",
  "message": "MotoLens API is running",
  "timestamp": "2026-02-05T00:00:00.000Z"
}
```

#### 2. VIN Decoding
```dart
POST /api/vin/decode
Content-Type: application/json

Request Body:
{
  "vin": "1HGCM82633A123456",
  "enrich": false // Optional, defaults to false for faster response
}

Response:
{
  "success": true,
  "vehicle": {
    "make": "BMW",
    "model": "X5",
    "year": 2023,
    "trim": "xDrive40i",
    "engine": "3.0L Inline-6 Turbo",
    "bodyType": "SUV",
    "manufacturer": "BMW AG",
    "vin": "1HGCM82633A123456",
    "drivetrain": "AWD",
    "origin": "Germany",
    // ... additional fields
  },
  "enrichmentApplied": false
}

Error Response (400):
{
  "error": "Invalid VIN",
  "message": "VIN must be exactly 17 characters",
  "vinInput": "123"
}
```

#### 3. Vehicle Images (360° Views)
```dart
GET /api/vehicle/images/{vin}

Response:
{
  "success": true,
  "vin": "1HGCM82633A123456",
  "vehicle": { "make": "BMW", "model": "X5", "year": 2023 },
  "images": [
    {
      "angle": "front",
      "imageUrl": "https://example.com/image1.jpg",
      "thumbnail": "https://example.com/thumb1.jpg",
      "title": "2023 BMW X5 Front View",
      "source": "google-images"
    },
    // ... more angles
  ],
  "source": "web-search"
}
```

#### 4. Vehicle Summary (AI-Generated)
```dart
GET /api/vehicle/summary/{vin}

Response:
{
  "success": true,
  "summary": [
    "**Engine**: 3.0L twin-turbocharged inline-6 producing 335 horsepower and 330 lb-ft of torque",
    "**Transmission**: 8-speed automatic with Sport and Eco Pro driving modes",
    "**All-Wheel Drive**: xDrive intelligent AWD system for enhanced traction and stability",
    // ... more technical bullet points
  ],
  "model": "gemini-pro",
  "generatedAt": "2026-02-05T00:00:00.000Z"
}
```

#### 5. Part Scanning (AI Vision)
```dart
POST /api/parts/scan
Content-Type: application/json

Request Body:
{
  "imageBase64": "iVBORw0KGgoAAAANSUhEUgAA...", // Base64 image data
  "mimeType": "image/jpeg",
  "vehicleContext": { // Optional
    "make": "BMW",
    "model": "X5", 
    "year": 2023
  }
}

Response:
{
  "success": true,
  "analysis": "This is a BMW brake caliper, specifically a front brake caliper assembly. The caliper appears to be a 4-piston fixed caliper design, commonly found on BMW performance vehicles...",
  "analysisType": "part_identification",
  "model": "gemini-pro-vision",
  "timestamp": "2026-02-05T00:00:00.000Z",
  "vehicleContext": {
    "make": "BMW",
    "model": "X5",
    "year": 2023
  }
}
```

#### 6. Part Questions (Follow-up AI Analysis)
```dart
POST /api/parts/scan/question
Content-Type: application/json

Request Body:
{
  "imageBase64": "iVBORw0KGgoAAAANSUhEUgAA...",
  "mimeType": "image/jpeg", 
  "question": "What is the condition of this part?",
  "vehicleContext": { "make": "BMW", "model": "X5", "year": 2023 }
}

Response:
{
  "success": true,
  "question": "What is the condition of this part?",
  "answer": "Based on the image, this brake caliper shows signs of normal wear with some surface corrosion on the mounting bracket. The caliper body appears intact with no visible cracks...",
  "analysisType": "question_answer",
  "model": "gemini-pro-vision",
  "timestamp": "2026-02-05T00:00:00.000Z"
}
```

#### 7. Part Markings Detection
```dart
POST /api/parts/scan/markings

Request Body: Same as /scan but focused on text recognition

Response:
{
  "success": true,
  "markings": "Part markings detected: BMW 34116794300, TRW logo, DOT-4 specification markings visible on brake caliper housing...",
  "analysisType": "marking_detection",
  "timestamp": "2026-02-05T00:00:00.000Z"
}
```

#### 8. Part Condition Assessment  
```dart
POST /api/parts/scan/condition

Response:
{
  "success": true,
  "assessment": "**Condition Assessment**: Good overall condition with minor surface wear. **Recommendation**: Part is serviceable, consider replacement in next 20,000 miles...",
  "analysisType": "condition_assessment",
  "timestamp": "2026-02-05T00:00:00.000Z"
}
```

---

## Data Models

### Vehicle Models
```dart
// lib/models/vehicle.dart
class Vehicle {
  final String make;
  final String model;
  final int year;
  final String? trim;
  final String engine;
  final String bodyType;
  final String manufacturer;
  final String vin;
  final String? transmission;
  final String? drivetrain;
  final String? fuelType;
  final String? origin;
  final bool? vinValid;
  final String? source;
  
  Vehicle({
    required this.make,
    required this.model,
    required this.year,
    this.trim,
    required this.engine,
    required this.bodyType,
    required this.manufacturer,
    required this.vin,
    this.transmission,
    this.drivetrain,
    this.fuelType,
    this.origin,
    this.vinValid,
    this.source,
  });
  
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 0,
      trim: json['trim'],
      engine: json['engine'] ?? '',
      bodyType: json['bodyType'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      vin: json['vin'] ?? '',
      transmission: json['transmission'],
      drivetrain: json['drivetrain'],
      fuelType: json['fuelType'],
      origin: json['origin'],
      vinValid: json['vinValid'],
      source: json['_source'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'make': make,
      'model': model,
      'year': year,
      'trim': trim,
      'engine': engine,
      'bodyType': bodyType,
      'manufacturer': manufacturer,
      'vin': vin,
      'transmission': transmission,
      'drivetrain': drivetrain,
      'fuelType': fuelType,
      'origin': origin,
      'vinValid': vinValid,
      '_source': source,
    };
  }
}

class VehicleImage {
  final String angle;
  final String imageUrl;
  final String? thumbnail; 
  final String? title;
  final String? source;
  
  VehicleImage({
    required this.angle,
    required this.imageUrl,
    this.thumbnail,
    this.title,
    this.source,
  });
  
  factory VehicleImage.fromJson(Map<String, dynamic> json) {
    return VehicleImage(
      angle: json['angle'] ?? 'front',
      imageUrl: json['imageUrl'] ?? json['url'] ?? '',
      thumbnail: json['thumbnail'],
      title: json['title'],
      source: json['source'],
    );
  }
}

class VehicleSummary {
  final List<String> bulletPoints;
  
  VehicleSummary({required this.bulletPoints});
  
  factory VehicleSummary.fromJson(Map<String, dynamic> json) {
    return VehicleSummary(
      bulletPoints: List<String>.from(json['summary'] ?? json['bulletPoints'] ?? []),
    );
  }
}
```

### Part Scan Models
```dart
// lib/models/part_scan.dart
class PartScanResult {
  final bool success;
  final String? analysis;
  final PartAnalysisType analysisType;
  final String model;
  final DateTime timestamp;
  final VehicleContext? vehicleContext;
  
  PartScanResult({
    required this.success,
    this.analysis,
    required this.analysisType,
    required this.model,
    required this.timestamp,
    this.vehicleContext,
  });
  
  factory PartScanResult.fromJson(Map<String, dynamic> json) {
    return PartScanResult(
      success: json['success'] ?? false,
      analysis: json['analysis'] ?? json['answer'] ?? json['markings'] ?? json['assessment'],
      analysisType: _parseAnalysisType(json['analysisType']),
      model: json['model'] ?? 'unknown',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      vehicleContext: json['vehicleContext'] != null 
          ? VehicleContext.fromJson(json['vehicleContext'])
          : null,
    );
  }
  
  static PartAnalysisType _parseAnalysisType(String? type) {
    switch (type) {
      case 'part_identification':
        return PartAnalysisType.partIdentification;
      case 'question_answer':
        return PartAnalysisType.questionAnswer;
      case 'marking_detection':
        return PartAnalysisType.markingDetection;
      case 'condition_assessment':
        return PartAnalysisType.conditionAssessment;
      case 'part_comparison':
        return PartAnalysisType.partComparison;
      default:
        return PartAnalysisType.partIdentification;
    }
  }
}

enum PartAnalysisType {
  partIdentification,
  questionAnswer,
  markingDetection,
  conditionAssessment,
  partComparison,
}

class VehicleContext {
  final String? make;
  final String? model;
  final int? year;
  final int? mileage;
  
  VehicleContext({this.make, this.model, this.year, this.mileage});
  
  factory VehicleContext.fromJson(Map<String, dynamic> json) {
    return VehicleContext(
      make: json['make'],
      model: json['model'],
      year: json['year'],
      mileage: json['mileage'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'make': make,
      'model': model,
      'year': year,
      'mileage': mileage,
    };
  }
}
```

### API Response Models
```dart
// lib/models/api_response.dart
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? message;
  
  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.message,
  });
  
  factory ApiResponse.success(T data) {
    return ApiResponse(success: true, data: data);
  }
  
  factory ApiResponse.error(String error, {String? message}) {
    return ApiResponse(success: false, error: error, message: message);
  }
  
  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['vehicle'] != null ? fromJsonT(json['vehicle']) : 
            json['data'] != null ? fromJsonT(json['data']) : null,
      error: json['error'],
      message: json['message'],
    );
  }
}
```

---

## Key Features

### 1. VIN Validation & Auto-formatting
```dart
// lib/utils/validators.dart
class VinValidator {
  static const int vinLength = 17;
  static final RegExp vinPattern = RegExp(r'^[A-HJ-NPR-Z0-9]{17}$');
  static const Set<String> excludedChars = {'I', 'O', 'Q'};
  
  static ValidationResult validateVin(String vin) {
    final cleaned = vin.trim().toUpperCase();
    
    if (cleaned.length != vinLength) {
      return ValidationResult(
        isValid: false,
        error: 'VIN must be exactly 17 characters',
        cleanedVin: cleaned,
      );
    }
    
    if (!vinPattern.hasMatch(cleaned)) {
      return ValidationResult(
        isValid: false,
        error: 'VIN contains invalid characters (no I, O, Q allowed)',
        cleanedVin: cleaned,
      );
    }
    
    return ValidationResult(
      isValid: true,
      cleanedVin: cleaned,
    );
  }
  
  static String formatVin(String input) {
    return input.trim().toUpperCase();
  }
}

class ValidationResult {
  final bool isValid;
  final String? error;
  final String cleanedVin;
  
  ValidationResult({
    required this.isValid,
    this.error,
    required this.cleanedVin,
  });
}
```

### 2. Image Handling & Compression
```dart
// lib/utils/image_utils.dart
class ImageUtils {
  static const int maxImageSize = 20 * 1024 * 1024; // 20MB
  static const List<String> supportedTypes = ['image/jpeg', 'image/png', 'image/webp'];
  
  static Future<String> fileToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }
  
  static ValidationResult validateImageFile(File file) {
    final fileSize = file.lengthSync();
    final extension = file.path.toLowerCase().split('.').last;
    
    if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
      return ValidationResult(
        isValid: false,
        error: 'Unsupported file type. Please use JPEG, PNG, or WebP.',
      );
    }
    
    if (fileSize > maxImageSize) {
      final sizeMB = (fileSize / (1024 * 1024)).round();
      return ValidationResult(
        isValid: false,
        error: 'File too large: ${sizeMB}MB. Maximum size: 20MB.',
      );
    }
    
    return ValidationResult(isValid: true);
  }
  
  static String getMimeType(File file) {
    final extension = file.path.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
```

### 3. 360° Image Viewer
```dart
// lib/widgets/vehicle/vehicle_360_viewer.dart
class Vehicle360Viewer extends StatefulWidget {
  final String vin;
  final String vehicleName;
  final double height;
  
  const Vehicle360Viewer({
    Key? key,
    required this.vin,
    required this.vehicleName,
    this.height = 400,
  }) : super(key: key);
  
  @override
  State<Vehicle360Viewer> createState() => _Vehicle360ViewerState();
}

class _Vehicle360ViewerState extends State<Vehicle360Viewer> {
  List<VehicleImage> images = [];
  int currentIndex = 0;
  bool isLoading = true;
  String? error;
  
  @override
  void initState() {
    super.initState();
    _loadVehicleImages();
  }
  
  Future<void> _loadVehicleImages() async {
    try {
      final vehicleService = Provider.of<VehicleService>(context, listen: false);
      final loadedImages = await vehicleService.getVehicleImages(widget.vin);
      
      setState(() {
        images = loadedImages;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: widget.height,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (error != null || images.isEmpty) {
      return Container(
        height: widget.height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.car_rental, size: 64, color: AppColors.gunmetalGray),
              SizedBox(height: AppSpacing.md),
              Text('No vehicle images available', style: AppTypography.bodyMedium),
            ],
          ),
        ),
      );
    }
    
    return Container(
      height: widget.height,
      child: PageView.builder(
        itemCount: images.length,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: images[index].imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => Icon(Icons.error),
          );
        },
      ),
    );
  }
}
```

---

## Camera Integration

### Camera Capture Component
```dart
// lib/widgets/parts/part_camera.dart
class PartCamera extends StatefulWidget {
  final Function(File) onImageCapture;
  final bool isProcessing;
  
  const PartCamera({
    Key? key,
    required this.onImageCapture,
    this.isProcessing = false,
  }) : super(key: key);
  
  @override
  State<PartCamera> createState() => _PartCameraState();
}

class _PartCameraState extends State<PartCamera> {
  final ImagePicker _picker = ImagePicker();
  
  Future<void> _captureFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      
      if (image != null) {
        final file = File(image.path);
        widget.onImageCapture(file);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture image: $e')),
      );
    }
  }
  
  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        final file = File(image.path);
        widget.onImageCapture(file);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.zinc200, width: 2),
            borderRadius: BorderRadius.circular(12),
            color: AppColors.zinc50,
          ),
          child: widget.isProcessing
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: AppSpacing.md),
                      Text('Analyzing part...', style: AppTypography.bodyMedium),
                    ],
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 48,
                        color: AppColors.gunmetalGray,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        'Tap to capture or select image',
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                ),
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.isProcessing ? null : _captureFromCamera,
                icon: Icon(Icons.camera),
                label: Text('Camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricBlue,
                  foregroundColor: Colors.white,
                  minimumSize: Size(0, AppSizing.buttonHeight),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.isProcessing ? null : _pickFromGallery,
                icon: Icon(Icons.photo_library),
                label: Text('Gallery'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.electricBlue,
                  side: BorderSide(color: AppColors.electricBlue),
                  minimumSize: Size(0, AppSizing.buttonHeight),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
```

---

## Components

### 1. VIN Input Widget
```dart
// lib/widgets/common/vin_input.dart
class VinInput extends StatefulWidget {
  final Function(String) onVinChanged;
  final Function(String) onVinSubmitted;
  final bool isLoading;
  final String? error;
  
  const VinInput({
    Key? key,
    required this.onVinChanged,
    required this.onVinSubmitted,
    this.isLoading = false,
    this.error,
  }) : super(key: key);
  
  @override
  State<VinInput> createState() => _VinInputState();
}

class _VinInputState extends State<VinInput> {
  final TextEditingController _controller = TextEditingController();
  String _vin = '';
  
  void _handleVinChange(String value) {
    final formatted = VinValidator.formatVin(value);
    if (formatted != _controller.text) {
      _controller.text = formatted;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: formatted.length),
      );
    }
    setState(() {
      _vin = formatted;
    });
    widget.onVinChanged(formatted);
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          onChanged: _handleVinChange,
          maxLength: 17,
          style: AppTypography.monoText,
          decoration: InputDecoration(
            labelText: 'Vehicle Identification Number',
            hintText: '17-character VIN',
            errorText: widget.error,
            suffixIcon: _vin.length == 17
                ? Icon(Icons.check, color: AppColors.success)
                : Text(
                    '${_vin.length}/17',
                    style: AppTypography.bodySmall,
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.zinc200),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.electricBlue, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_vin.length == 17 && !widget.isLoading) 
                ? () => widget.onVinSubmitted(_vin)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricBlue,
              foregroundColor: Colors.white,
              minimumSize: Size(0, AppSizing.buttonHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: widget.isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Decode VIN', style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(width: AppSpacing.sm),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### 2. Vehicle Info Card
```dart
// lib/widgets/vehicle/vehicle_info_card.dart
class VehicleInfoCard extends StatelessWidget {
  final Vehicle vehicle;
  
  const VehicleInfoCard({Key? key, required this.vehicle}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle Information',
              style: AppTypography.heading3,
            ),
            SizedBox(height: AppSpacing.lg),
            _buildInfoGrid(),
            SizedBox(height: AppSpacing.lg),
            _buildVinDisplay(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 3,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      children: [
        _buildInfoItem('Make', vehicle.make),
        _buildInfoItem('Model', vehicle.model),
        _buildInfoItem('Year', vehicle.year.toString()),
        _buildInfoItem('Body', vehicle.bodyType),
        if (vehicle.drivetrain != null)
          _buildInfoItem('Drive', vehicle.drivetrain!),
        if (vehicle.origin != null)
          _buildInfoItem('Origin', vehicle.origin!),
      ],
    );
  }
  
  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall),
        SizedBox(height: 4),
        Text(value, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
  
  Widget _buildVinDisplay() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.zinc50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.zinc200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VIN',
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.gunmetalGray,
            ),
          ),
          SizedBox(height: 4),
          Text(
            vehicle.vin,
            style: AppTypography.monoText,
          ),
        ],
      ),
    );
  }
}
```

### 3. Part Analysis Results
```dart
// lib/widgets/parts/part_analysis.dart
class PartAnalysis extends StatelessWidget {
  final PartScanResult? result;
  final File? imageFile;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;
  
  const PartAnalysis({
    Key? key,
    this.result,
    this.imageFile,
    this.isLoading = false,
    this.error,
    this.onRetry,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Card(
        child: Container(
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: AppSpacing.md),
                Text('Analyzing part...', style: AppTypography.bodyMedium),
              ],
            ),
          ),
        ),
      );
    }
    
    if (error != null) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
              SizedBox(height: AppSpacing.md),
              Text('Analysis Failed', style: AppTypography.heading3),
              SizedBox(height: AppSpacing.sm),
              Text(
                error!,
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.lg),
              if (onRetry != null)
                ElevatedButton(
                  onPressed: onRetry,
                  child: Text('Retry Analysis'),
                ),
            ],
          ),
        ),
      );
    }
    
    if (result == null) {
      return Card(
        child: Container(
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.scanner,
                  size: 64,
                  color: AppColors.gunmetalGray,
                ),
---

## Backend Modification Guidelines

### When to Modify the Backend

As you build the mobile app, you may need to modify the backend for:
- **Mobile-optimized responses** (smaller payloads, faster responses)
- **New mobile-specific endpoints** (push notifications, device registration)
- **Enhanced features** (batch operations, improved image processing)
- **Better error handling** (mobile-friendly error messages)

### Backend Structure Overview

```javascript
// backend/src/server.js
const express = require('express');
const app = express();

// Existing endpoints (already compatible with mobile)
app.post('/api/vin/decode', ...);              // ✅ Ready
app.get('/api/vehicle/images/:vin', ...);      // ✅ Ready
app.get('/api/vehicle/summary/:vin', ...);     // ✅ Ready
app.post('/api/parts/scan', ...);              // ✅ Ready
app.post('/api/parts/scan/question', ...);     // ✅ Ready
app.post('/api/parts/scan/markings', ...);     // ✅ Ready
app.post('/api/parts/scan/condition', ...);    // ✅ Ready

// Add mobile-specific improvements as needed
```

### Common Backend Modifications for Mobile

#### 1. Add Request Logging for Mobile Debugging
```javascript
// backend/src/server.js
app.use((req, res, next) => {
  const userAgent = req.get('User-Agent') || '';
  const isMobile = userAgent.includes('Dart') || userAgent.includes('Flutter');
  
  if (isMobile) {
    console.log(`[MOBILE] ${req.method} ${req.path}`, {
      body: req.body,
      query: req.query,
      timestamp: new Date().toISOString(),
    });
  }
  next();
});
```

#### 2. Optimize Image Response for Mobile
```javascript
// Add mobile-optimized image sizes
app.get('/api/vehicle/images/:vin', async (req, res) => {
  const { vin } = req.params;
  const { thumbnail = true } = req.query; // Mobile can request thumbnails only
  
  try {
    const images = await getVehicleImages(vin);
    
    // If mobile app requests thumbnails, return smaller images
    if (thumbnail === 'true') {
      return res.json({
        success: true,
        images: images.map(img => ({
          ...img,
          imageUrl: img.thumbnail || img.imageUrl, // Prefer thumbnails
        })),
      });
    }
    
    res.json({ success: true, images });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});
```

#### 3. Add Batch VIN Decoding (Future Mobile Feature)
```javascript
// Useful for scanning multiple VINs in garage mode
app.post('/api/vin/decode-batch', async (req, res) => {
  const { vins } = req.body; // Array of VINs
  
  if (!Array.isArray(vins) || vins.length > 10) {
    return res.status(400).json({
      error: 'Invalid request',
      message: 'Provide array of 1-10 VINs',
    });
  }
  
  try {
    const results = await Promise.all(
      vins.map(vin => decodeVIN(vin).catch(e => ({ error: e.message, vin })))
    );
    
    res.json({
      success: true,
      results,
      count: results.length,
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});
```

#### 4. Add Health Check with Version Info
```javascript
// Mobile app can check backend compatibility
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    message: 'MotoLens API is running',
    version: '2.0.0', // Add version tracking
    mobileCompatible: true,
    features: {
      vinDecoding: true,
      partScanning: true,
      aiAnalysis: true,
      batchProcessing: false, // Enable when implemented
    },
    timestamp: new Date().toISOString(),
  });
});
```

#### 5. Improve Error Messages for Mobile
```javascript
// Middleware for mobile-friendly errors
app.use((err, req, res, next) => {
  const isMobile = req.get('User-Agent')?.includes('Flutter');
  
  if (isMobile) {
    // Mobile-friendly error format
    return res.status(err.status || 500).json({
      success: false,
      error: err.message,
      code: err.code || 'INTERNAL_ERROR',
      suggestion: getMobileSuggestion(err), // User-friendly fix suggestions
      timestamp: new Date().toISOString(),
    });
  }
  
  // Standard error response for web
  res.status(err.status || 500).json({
    success: false,
    error: err.message,
  });
});

function getMobileSuggestion(error) {
  const suggestions = {
    'Network error': 'Check your internet connection and try again',
    'Invalid VIN': 'Make sure the VIN is exactly 17 characters',
    'Image too large': 'Use a smaller image or compress it',
    'Timeout': 'Request taking too long. Try again with a better connection',
  };
  
  return suggestions[error.message] || 'Please try again or contact support';
}
```

### Backend Testing After Changes

```bash
# Test endpoint locally
curl -X POST http://localhost:3000/api/vin/decode \
  -H "Content-Type: application/json" \
  -d '{"vin":"1HGCM82633A123456"}'

# Test with mobile user agent
curl -X POST http://localhost:3000/api/vin/decode \
  -H "Content-Type: application/json" \
  -H "User-Agent: Dart/2.19 (dart:io)" \
  -d '{"vin":"1HGCM82633A123456"}'
```

### Backend Deployment After Mobile Changes

```bash
# Test all endpoints work
cd backend
npm test  # If tests exist

# Deploy to VPS (existing scripts)
./deployment/deploy-to-vps.sh

# Verify deployed backend
curl https://your-deployed-backend.com/api/health
```

### AI Agent Guidelines for Backend Changes

When modifying the backend for mobile needs:

1. **Check Existing Endpoints First**: Review `backend/src/server.js` before adding new endpoints
2. **Maintain Backward Compatibility**: Web client may still use some endpoints
3. **Add Mobile-Specific Query Params**: Use `?mobile=true` or check User-Agent instead of breaking changes
4. **Document Changes**: Update API documentation in this file
5. **Test Locally First**: Run backend, test with mobile app emulator before deploying
6. **Restart Backend**: After changes, restart the dev server (`npm run dev`)

### Coordination Between Mobile and Backend Changes

**Example: Adding a "Favorites" Feature**

1. **Backend** (`backend/src/server.js`):
```javascript
// Add new endpoints
app.post('/api/user/favorites', addFavorite);
app.get('/api/user/favorites', getFavorites);
app.delete('/api/user/favorites/:vin', removeFavorite);
```

2. **Mobile** (`mobile/lib/services/favorites_service.dart`):
```dart
class FavoritesService {
  Future<void> addFavorite(String vin) async {
    await apiService.post('/user/favorites', data: {'vin': vin});
  }
  
  Future<List<Vehicle>> getFavorites() async {
    final response = await apiService.get('/user/favorites');
    return (response.data['favorites'] as List)
        .map((json) => Vehicle.fromJson(json))
        .toList();
  }
}
```

3. **Test**: Run both, verify the feature works end-to-end

---

## Summary

This specification provides a complete roadmap for building the MotoLens Flutter mobile application with full feature parity to the web version and optimized mobile-specific functionality. The monorepo structure ensures seamless development across mobile and backend, enabling AI coding agents to efficiently work on both projects simultaneousl
                Text(
                  'Capture an image to begin analysis',
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 24,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Analysis Complete',
                    style: AppTypography.heading3.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.zinc50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.zinc200),
              ),
              child: Text(
                result!.analysis ?? 'No analysis available',
                style: AppTypography.bodyMedium.copyWith(height: 1.6),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getAnalysisTypeLabel(result!.analysisType),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.electricBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatTimestamp(result!.timestamp),
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  String _getAnalysisTypeLabel(PartAnalysisType type) {
    switch (type) {
      case PartAnalysisType.partIdentification:
        return 'Part Identification';
      case PartAnalysisType.questionAnswer:
        return 'Question Answer';
      case PartAnalysisType.markingDetection:
        return 'Marking Detection';
      case PartAnalysisType.conditionAssessment:
        return 'Condition Assessment';
      case PartAnalysisType.partComparison:
        return 'Part Comparison';
    }
  }
  
  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
```

---

## Error Handling

### Global Error Handler
```dart
// lib/utils/error_handler.dart
class ErrorHandler {
  static void handleApiError(dynamic error, BuildContext context) {
    String message;
    
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = 'Request timed out. Please try again.';
          break;
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 400) {
            message = error.response?.data['message'] ?? 'Invalid request';
          } else if (statusCode == 500) {
            message = 'Server error. Please try again later.';
          } else {
            message = 'Network error. Please check your connection.';
          }
          break;
        case DioExceptionType.cancel:
          message = 'Request was cancelled';
          break;
        default:
          message = 'Network error. Please check your connection.';
      }
    } else {
      message = error.toString();
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
  
  static void showSuccessMessage(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
```

---

## Performance Considerations

### 1. Image Optimization
- Compress images before upload (max 20MB, 80% quality)
- Cache network images using `cached_network_image`
- Lazy load images in lists and grids

### 2. API Optimization  
- Implement request caching for vehicle data
- Use timeout handling for all network requests
- Implement retry mechanisms for failed requests

### 3. Memory Management
- Dispose controllers and listeners properly
- Use `const` constructors where possible
- Implement image placeholder and error widgets

### 4. Background Processing
- Use isolates for image processing
- Implement proper loading states
- Cache API responses in local storage

---

## Testing Strategy

### Unit Tests
- VIN validation logic
- API response parsing
- Image utilities
- Data model serialization

### Widget Tests
- VIN input component
- Camera capture component
- Error handling displays
- Navigation flows

### Integration Tests
- Full VIN decode flow
- Part scanning workflow
- Authentication flow
- Image upload and analysis

---

## App Features Summary

### Core Features ✅
1. **VIN Decoding**: Enter 17-character VIN, decode vehicle information
2. **Vehicle Display**: Comprehensive vehicle details with 360° images  
3. **Part Scanning**: AI-powered part identification via camera
4. **Part Analysis**: Multiple analysis modes (identification, markings, condition)
5. **Authentication**: Simple admin/admin login system

### Advanced Features 🚀
1. **360° Vehicle Viewer**: Swipeable image carousel of vehicle angles
2. **AI Question System**: Ask follow-up questions about scanned parts
3. **Part Condition Assessment**: Analyze wear and recommend replacement
4. **Marking Detection**: OCR for part numbers and specifications
5. **Vehicle Context**: Use vehicle info to enhance part analysis

### Technical Features 🔧
1. **Offline Support**: Cache vehicle data and auth state
2. **Image Processing**: Compression, validation, base64 encoding
3. **Error Handling**: Comprehensive error states and retry mechanisms
4. **Loading States**: Professional loading indicators throughout
5. **Responsive Design**: Mobile-first, garage-friendly interface

This specification provides a complete roadmap for building the MotoLens Flutter mobile application with full feature parity to the web version and optimized mobile-specific functionality.