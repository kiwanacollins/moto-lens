# MotoLens Development Setup

## Backend & Database Configuration

### Database
- **Type**: PostgreSQL
- **Database Name**: `motolens_dev`
- **Connection String**: `postgresql://kiwana@localhost:5432/motolens_dev?schema=public`

### Test User Credentials

The database has been seeded with the following test accounts:

#### 1. Admin User
- **Email**: `admin@motolens.com`
- **Username**: `admin`
- **Password**: `Admin123`
- **Role**: ADMIN
- **Subscription**: ENTERPRISE
- **Email Verified**: ✅ Yes

#### 2. Mechanic User
- **Email**: `mechanic@motolens.com`
- **Username**: `mechanic`
- **Password**: `Test123`
- **Role**: MECHANIC
- **Subscription**: PRO
- **Garage**: Test Auto Repair
- **Specializations**: BMW, Mercedes, Audi, Volkswagen
- **Email Verified**: ✅ Yes

#### 3. Test User
- **Email**: `test@example.com`
- **Username**: `testuser`
- **Password**: `Test123`
- **Role**: MECHANIC
- **Subscription**: FREE
- **Garage**: Quick Fix Garage
- **Email Verified**: ✅ Yes

---

## Backend API

### Starting the Backend
```bash
cd backend
npm run dev
```

The backend will start on: `http://localhost:3001`

### API Endpoints

#### Authentication
- **Login**: `POST /api/auth/login`
- **Register**: `POST /api/auth/register`
- **Logout**: `POST /api/auth/logout`
- **Refresh Token**: `POST /api/auth/refresh`

#### Example Login Request
```bash
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@motolens.com",
    "password": "Admin123"
  }'
```

#### Example Response
```json
{
  "success": true,
  "message": "Login successful",
  "tokens": {
    "accessToken": "eyJ...",
    "refreshToken": "eyJ..."
  },
  "user": {
    "id": "...",
    "email": "admin@motolens.com",
    "firstName": "Admin",
    "lastName": "User",
    "role": "ADMIN",
    "emailVerified": true,
    "subscriptionTier": "ENTERPRISE"
  }
}
```

---

## Flutter Mobile App

### API Configuration

The mobile app is configured to connect to the backend via the environment configuration:

**File**: `lib/config/environment.dart`

#### For Android Emulator:
```dart
static String get apiUrl => 'http://10.0.2.2:3001';
```

#### For iOS Simulator:
```dart
static String get apiUrl => 'http://localhost:3001';
```

#### For Real Device:
Replace with your computer's IP address:
```dart
static String get apiUrl => 'http://192.168.1.100:3001';
```

### Starting the Flutter App
```bash
cd moto_lens_mobile
flutter run
```

### Testing Login in the App

1. Launch the app on your emulator/simulator
2. You'll see the splash screen with the MotoLens logo
3. After the splash screen, you'll see the login screen
4. Use any of the test credentials above to login

**Recommended for testing:**
- Email: `admin@motolens.com`
- Password: `Admin123`

---

## Database Management

### Useful Commands

```bash
cd backend

# View database in Prisma Studio (GUI)
npm run db:studio

# Reset database and reseed
npm run db:reset

# Run migrations
npm run db:migrate

# Reseed only
npm run db:seed
```

### Prisma Studio
Run `npm run db:studio` to open a web interface at `http://localhost:5555` where you can:
- View all tables
- Edit records
- Add new data
- Delete data

---

## Troubleshooting

### Mobile App Can't Connect to Backend

1. **Check backend is running**: Visit `http://localhost:3001/api/health`
2. **Check the API URL** in `lib/config/environment.dart`:
   - Android Emulator: Use `10.0.2.2:3001`
   - iOS Simulator: Use `localhost:3001`
   - Real Device: Use your computer's IP (e.g., `192.168.1.100:3001`)

3. **Get your computer's IP**:
   ```bash
   # On Mac/Linux
   ifconfig | grep "inet "

   # On Windows
   ipconfig
   ```

### Login Fails

1. **Verify backend is running** on port 3001
2. **Check credentials** match the seeded data
3. **Check backend logs** for errors
4. **Test with curl** to isolate if it's an app or backend issue

### Database Issues

1. **Reset database**:
   ```bash
   cd backend
   npm run db:reset
   ```

2. **Check PostgreSQL is running**:
   ```bash
   psql -U kiwana -d postgres -c "SELECT version();"
   ```

---

## Security Note

⚠️ **Development Mode**: The backend security middleware (input sanitization and SQL injection validation) is currently disabled in development mode to make testing easier. This will be re-enabled in production.

---

## Next Steps

Now that authentication is working, you can:

1. ✅ Test login in the Flutter app
2. ✅ Access authenticated screens (Dashboard, Profile, etc.)
3. ✅ Implement VIN scanning features
4. ✅ Add parts identification functionality
5. ✅ Build out the rest of the app features

Happy coding! 🚀
