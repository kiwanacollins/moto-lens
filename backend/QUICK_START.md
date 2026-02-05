# MotoLens Backend - Quick Start Guide

## 🚀 Quick Setup (5 Minutes)

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Start PostgreSQL (Choose one)

**Option A: Docker (Easiest)**
```bash
docker run --name motolens-postgres \
  -e POSTGRES_USER=motolens \
  -e POSTGRES_PASSWORD=motolens_dev_password \
  -e POSTGRES_DB=motolens_dev \
  -p 5432:5432 \
  -d postgres:16-alpine
```

**Option B: Homebrew (macOS)**
```bash
brew install postgresql@16
brew services start postgresql@16
createdb motolens_dev
```

### 3. Configure Environment
```bash
cp .env.example .env

# Generate JWT secrets
echo "JWT_SECRET=$(openssl rand -base64 32)" >> .env
echo "JWT_REFRESH_SECRET=$(openssl rand -base64 32)" >> .env
```

### 4. Run Database Migrations
```bash
npx prisma generate
npx prisma migrate dev --name init
```

### 5. Start Server
```bash
npm run dev
```

## ✅ Verify Installation

1. **Check Database**: `npx prisma studio` → Opens http://localhost:5555
2. **Test API**: Server should be running on http://localhost:3001
3. **View Logs**: Check console output for any errors

## 📋 What Was Installed?

### Database Schema
- ✅ Users table with authentication fields
- ✅ User profiles with extended information
- ✅ User sessions for token management
- ✅ Login history for security auditing
- ✅ Password reset tokens
- ✅ Email verification tokens
- ✅ VIN scan history
- ✅ API usage tracking
- ✅ Security event logging

### NPM Packages
- ✅ `@prisma/client` - Database ORM
- ✅ `prisma` - Database migrations
- ✅ `bcryptjs` - Password hashing
- ✅ `jsonwebtoken` - JWT authentication
- ✅ `express-rate-limit` - Rate limiting
- ✅ `express-validator` - Input validation
- ✅ `helmet` - Security headers
- ✅ `nodemailer` - Email service
- ✅ `uuid` - Unique ID generation

## 🎯 Next Steps

Now that your database is set up, proceed to:

1. **Phase 14.2**: Implement JWT utilities (`src/utils/jwt.js`)
2. **Phase 14.3**: Create password security utilities (`src/utils/password.js`)
3. **Phase 14.4**: Set up email service (`src/services/emailService.js`)
4. **Phase 14.5**: Build authentication routes (`src/routes/auth.js`)

## 🆘 Common Issues

**Error: Port 5432 already in use**
```bash
# Stop existing PostgreSQL
brew services stop postgresql@16
# Or kill the process
lsof -ti:5432 | xargs kill -9
```

**Error: Cannot connect to database**
```bash
# Check if PostgreSQL is running
pg_isready
# Restart PostgreSQL
brew services restart postgresql@16
```

**Error: Prisma Client not found**
```bash
npx prisma generate
```

## 📚 Documentation

- Full setup guide: [DATABASE_SETUP.md](./DATABASE_SETUP.md)
- Prisma schema: [prisma/schema.prisma](./prisma/schema.prisma)
- Environment variables: [.env.example](./.env.example)

---

*Ready to build! 🚀*
