# MotoLens Database Setup Guide

This guide walks you through setting up the PostgreSQL database and Prisma ORM for the MotoLens backend authentication system.

## Prerequisites

- Node.js 18+ installed
- PostgreSQL 14+ installed locally or access to a managed PostgreSQL service
- Basic understanding of database concepts

## Step 1: Install PostgreSQL

### macOS (using Homebrew)
```bash
brew install postgresql@16
brew services start postgresql@16
```

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
```

### Windows
Download and install from: https://www.postgresql.org/download/windows/

### Docker (Alternative)
```bash
docker run --name motolens-postgres \
  -e POSTGRES_USER=motolens \
  -e POSTGRES_PASSWORD=motolens_dev_password \
  -e POSTGRES_DB=motolens_dev \
  -p 5432:5432 \
  -d postgres:16-alpine
```

## Step 2: Create Database

### Connect to PostgreSQL
```bash
# macOS/Linux
psql postgres

# Or connect as postgres user
sudo -u postgres psql
```

### Create Database and User
```sql
-- Create user
CREATE USER motolens WITH PASSWORD 'motolens_dev_password';

-- Create database
CREATE DATABASE motolens_dev OWNER motolens;

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE motolens_dev TO motolens;

-- Exit
\q
```

### Verify Connection
```bash
psql -U motolens -d motolens_dev -h localhost
# Enter password when prompted: motolens_dev_password
```

## Step 3: Install Node.js Dependencies

```bash
cd /Users/kiwana/projects/moto-lens/backend

# Install all dependencies (including Prisma)
npm install

# This will install:
# - @prisma/client (Database ORM client)
# - prisma (CLI tool - dev dependency)
# - bcryptjs (Password hashing)
# - jsonwebtoken (JWT tokens)
# - express-rate-limit (Rate limiting)
# - express-validator (Input validation)
# - helmet (Security headers)
# - nodemailer (Email service)
# - uuid (Unique ID generation)
```

## Step 4: Configure Environment Variables

```bash
# Copy the example environment file
cp .env.example .env

# Edit .env and update these critical values:
nano .env
```

**Required Environment Variables:**
```env
# Database connection
DATABASE_URL=postgresql://motolens:motolens_dev_password@localhost:5432/motolens_dev?schema=public

# JWT secrets (generate with: openssl rand -base64 32)
JWT_SECRET=your_generated_secret_here
JWT_REFRESH_SECRET=your_generated_refresh_secret_here

# Email configuration (for password reset emails)
EMAIL_HOST=smtp.gmail.com
EMAIL_USER=your-email@gmail.com
EMAIL_PASSWORD=your-app-specific-password
```

**Generate Secure JWT Secrets:**
```bash
# Generate JWT access token secret
openssl rand -base64 32

# Generate JWT refresh token secret
openssl rand -base64 32

# Copy these into your .env file
```

## Step 5: Run Prisma Migrations

```bash
# Generate Prisma Client (reads schema.prisma)
npx prisma generate

# Create initial migration
npx prisma migrate dev --name init

# This will:
# 1. Create all database tables
# 2. Apply indexes and constraints
# 3. Generate Prisma Client code
```

## Step 6: Verify Database Setup

```bash
# Open Prisma Studio (database GUI)
npx prisma studio

# This opens http://localhost:5555
# You should see all your tables:
# - users
# - user_profiles
# - user_sessions
# - login_history
# - password_reset_tokens
# - email_verification_tokens
# - vin_scan_history
# - api_usage
# - security_events
```

## Step 7: Seed Database (Optional)

Create a seed script for testing:

```bash
# Create seed file
touch prisma/seed.js
```

**prisma/seed.js:**
```javascript
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  // Create test admin user
  const hashedPassword = await bcrypt.hash('Admin123!', 12);

  const admin = await prisma.user.upsert({
    where: { email: 'admin@motolens.com' },
    update: {},
    create: {
      email: 'admin@motolens.com',
      username: 'admin',
      passwordHash: hashedPassword,
      firstName: 'Admin',
      lastName: 'User',
      role: 'ADMIN',
      emailVerified: true,
      emailVerifiedAt: new Date(),
    },
  });

  console.log('Seed data created:', admin);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
```

**Run seed:**
```bash
node prisma/seed.js
```

## Troubleshooting

### Connection Issues

**Error: Connection refused**
```bash
# Check if PostgreSQL is running
brew services list  # macOS
sudo systemctl status postgresql  # Linux

# Restart PostgreSQL
brew services restart postgresql@16  # macOS
sudo systemctl restart postgresql  # Linux
```

**Error: Authentication failed**
```bash
# Reset password
sudo -u postgres psql
ALTER USER motolens WITH PASSWORD 'motolens_dev_password';
```

### Prisma Issues

**Error: Prisma Client not generated**
```bash
# Regenerate Prisma Client
npx prisma generate
```

**Error: Migration failed**
```bash
# Reset database (WARNING: Deletes all data!)
npx prisma migrate reset

# Or drop and recreate manually
psql -U motolens -d postgres
DROP DATABASE motolens_dev;
CREATE DATABASE motolens_dev OWNER motolens;
\q

# Then re-run migrations
npx prisma migrate dev
```

## Production Deployment

### Using Railway

1. Create Railway account: https://railway.app
2. Add PostgreSQL service
3. Copy DATABASE_URL from Railway dashboard
4. Update production .env with Railway DATABASE_URL

### Using Heroku

```bash
# Install Heroku CLI
brew tap heroku/brew && brew install heroku  # macOS

# Add Heroku Postgres
heroku addons:create heroku-postgresql:mini

# Get DATABASE_URL
heroku config:get DATABASE_URL
```

### Using AWS RDS

1. Create RDS PostgreSQL instance
2. Configure security groups (allow port 5432)
3. Update DATABASE_URL with RDS endpoint
4. Run migrations from local machine

## Database Maintenance

### Backup Database
```bash
# Local backup
pg_dump -U motolens motolens_dev > backup_$(date +%Y%m%d).sql

# Restore backup
psql -U motolens -d motolens_dev < backup_20260205.sql
```

### View Database Schema
```bash
npx prisma db pull  # Pull existing schema
npx prisma studio   # Visual database browser
```

### Reset Database (Development Only)
```bash
# WARNING: Deletes all data!
npx prisma migrate reset
```

## Next Steps

After completing database setup:

1. ✅ Database is running
2. ✅ Tables are created
3. ✅ Prisma Client is generated
4. 🔄 Proceed to implement JWT utilities (Phase 14.2)
5. 🔄 Create authentication routes (Phase 14.5)

## Useful Commands

```bash
# Start PostgreSQL
brew services start postgresql@16  # macOS

# Connect to database
psql -U motolens -d motolens_dev

# Run migrations
npx prisma migrate dev

# Generate Prisma Client
npx prisma generate

# Open database GUI
npx prisma studio

# View database logs
tail -f /usr/local/var/log/postgresql@16.log  # macOS

# Check Prisma version
npx prisma --version
```

## Resources

- [Prisma Documentation](https://www.prisma.io/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Prisma Schema Reference](https://www.prisma.io/docs/reference/api-reference/prisma-schema-reference)
- [Railway PostgreSQL](https://docs.railway.app/databases/postgresql)

---

*Last Updated: February 5, 2026*
*For issues, check TROUBLESHOOTING section or ask in project discussions*
