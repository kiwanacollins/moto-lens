# MotoLens - Automotive Spare Parts Scanner

Professional VIN decoder and AI-powered spare parts identification system for German vehicles (BMW, Audi, Mercedes-Benz, Volkswagen, Porsche).

## 🏗️ Project Structure

This is a **monorepo** containing both the mobile app and backend API:

```
moto-lens/
├── mobile/              # 📱 Flutter mobile app (iOS & Android) [PRIMARY FOCUS]
├── backend/             # 🔧 Node.js + Express API server
├── frontend/            # 🌐 React web app (legacy, minimal maintenance)
├── deployment/          # 🚀 Deployment scripts
└── docs/               # 📚 Documentation
```

## 🚀 Quick Start

### Prerequisites
- **Backend**: Node.js 16+ 
- **Mobile**: Flutter SDK 3.38.9+, Android SDK, Xcode (for iOS)
- **Tools**: VS Code with Flutter & Dart extensions

### Running the Full Stack

```bash
# 1. Open the root workspace in VS Code
code /Users/kiwana/projects/moto-lens

# 2. Terminal 1 - Start Backend Server
cd backend
npm install
npm run dev  # Runs on http://localhost:3000

# 3. Terminal 2 - Start Mobile App
cd mobile
flutter pub get
flutter run  # Select your device/emulator
```

## 📱 Mobile App Development

The Flutter mobile app is the **primary focus** of development.

### First Time Setup
```bash
cd mobile
flutter pub get
flutter doctor  # Verify setup
```

### Running on Emulator/Simulator
```bash
# Android Emulator (must be already running)
flutter run

# iOS Simulator
open -a Simulator
flutter run
```

### Running on Physical Device
```bash
# List connected devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

### Key Configuration
- **Backend URL**: Edit `mobile/lib/config/environment.dart`
  - Local: `http://10.0.2.2:3000/api` (Android) or `http://localhost:3000/api` (iOS)
  - Deployed: `https://your-backend-url.com/api`

### Documentation
- **Full Specification**: [FLUTTER_MOBILE_SPECIFICATION.md](./FLUTTER_MOBILE_SPECIFICATION.md)
- **Features, API, Design System, Components, etc.**

## 🔧 Backend API Development

Node.js + Express server providing VIN decoding and AI part analysis.

### Running Backend
```bash
cd backend
npm install
npm run dev     # Development with auto-reload
npm start       # Production mode
```

### Key Endpoints
- `POST /api/vin/decode` - Decode VIN to vehicle data
- `GET /api/vehicle/images/:vin` - Get 360° vehicle images
- `GET /api/vehicle/summary/:vin` - AI-generated technical summary
- `POST /api/parts/scan` - AI part identification
- `POST /api/parts/scan/question` - Ask questions about parts
- `POST /api/parts/scan/markings` - Detect part numbers/text
- `POST /api/parts/scan/condition` - Assess part wear

### Testing Backend
```bash
# Health check
curl http://localhost:3000/api/health

# Decode VIN
curl -X POST http://localhost:3000/api/vin/decode \
  -H "Content-Type: application/json" \
  -d '{"vin":"WBAKG9C55BE123456"}'
```

## 🎯 Development Workflow

### For Mobile Feature Development

1. **Check Backend Endpoint**: Verify if endpoint exists in `backend/src/server.js`
2. **Modify Backend** (if needed): Add/update endpoints
3. **Restart Backend**: Backend auto-reloads with nodemon
4. **Build Mobile Feature**: Create screens, services, widgets
5. **Test Integration**: Mobile app → Local backend
6. **Hot Reload**: Save files, Flutter hot-reloads automatically

### For Backend Modifications

1. **Edit Endpoint**: Modify `backend/src/server.js`
2. **Test Locally**: Use curl or Postman
3. **Update Mobile Service**: Reflect changes in `mobile/lib/services/`
4. **Test End-to-End**: Run mobile app with updated backend

### Working Across Both Projects

**Recommended**: Open the root `moto-lens/` folder in VS Code
- ✅ See both `mobile/` and `backend/` in sidebar
- ✅ Make cross-project changes easily
- ✅ Search across entire codebase
- ✅ AI agents have full context

## 👥 For AI Coding Agents

### Context Instructions

When working on MotoLens:

1. **Always open** the root `moto-lens/` folder for full project visibility
2. **Mobile development** lives in `mobile/` folder
3. **Backend API** lives in `backend/src/` folder
4. **Mobile-Backend alignment**: When mobile needs backend changes, edit both
5. **Configuration**: Backend URL is in `mobile/lib/config/environment.dart`
6. **Testing**: Run backend first (`npm run dev`), then mobile app (`flutter run`)

### Common Tasks

**Add New Feature (e.g., Part Favorites)**:
1. Design mobile UI in `mobile/lib/screens/`
2. Add backend endpoint in `backend/src/server.js`
3. Create mobile service in `mobile/lib/services/`
4. Connect UI to service using Provider/Riverpod
5. Test end-to-end

**Modify Existing Endpoint**:
1. Update `backend/src/server.js`
2. Update corresponding service in `mobile/lib/services/`
3. Update data models if needed in `mobile/lib/models/`
4. Test integration

**Debug Issues**:
1. Check backend logs in Terminal 1
2. Check mobile logs in Terminal 2
3. Verify backend URL in `mobile/lib/config/environment.dart`
4. Test backend endpoint directly with curl

## 🔐 Authentication

Currently using simple hardcoded auth for MVP:
- **Username**: `admin`
- **Password**: `admin`

⚠️ **Replace with proper authentication before production release**

## 🧪 Testing

### Mobile Tests
```bash
cd mobile
flutter test                    # Unit tests
flutter test integration_test/  # Integration tests
```

### Backend Tests
```bash
cd backend
npm test  # (If test suite exists)
```

## 🚀 Deployment

### Backend Deployment
```bash
cd deployment
./deploy-to-vps.sh
```

See [DEPLOYMENT.md](./DEPLOYMENT.md) for full deployment guide.

### Mobile Deployment

**Android**:
```bash
cd mobile
flutter build apk --release
# APK at: build/app/outputs/flutter-apk/app-release.apk
```

**iOS**:
```bash
cd mobile
flutter build ios --release
# Archive in Xcode, submit to App Store
```

## 📚 Documentation

- **[FLUTTER_MOBILE_SPECIFICATION.md](./FLUTTER_MOBILE_SPECIFICATION.md)** - Complete mobile app specification
- **[PRD.md](./PRD.md)** - Product Requirements Document
- **[DEPLOYMENT.md](./DEPLOYMENT.md)** - Deployment guide
- **[TASKS.md](./TASKS.md)** - Development checklist

## 🛠️ Tech Stack

### Mobile (Flutter)
- **Framework**: Flutter 3.38.9+
- **Language**: Dart
- **State Management**: Provider / Riverpod
- **HTTP**: Dio
- **Camera**: camera, image_picker
- **Navigation**: go_router

### Backend
- **Runtime**: Node.js + Express
- **AI Services**: Google Gemini Vision
- **VIN Decoding**: NHTSA API, multi-provider fallback
- **Image Search**: Google Custom Search API

## 🤝 Contributing

### Development Guidelines

1. Use monorepo structure (work from root folder)
2. Keep mobile and backend in sync
3. Test locally before deploying
4. Follow Flutter/Dart style guide
5. Write meaningful commit messages

## 📄 License

Proprietary - All rights reserved

## 📧 Contact

For questions or support, contact the development team.

---

**Happy Coding! 🚀**
