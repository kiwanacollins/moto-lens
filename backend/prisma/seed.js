/**
 * Prisma Database Seeding Script
 * Seeds the database with test users for development
 */

import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
    console.log('🌱 Starting database seed...');

    // Hash passwords
    const adminPasswordHash = await bcrypt.hash('Admin123', 10);
    const mechanicPasswordHash = await bcrypt.hash('Test123', 10);

    // Create Admin User
    const admin = await prisma.user.upsert({
        where: { email: 'admin@germancarmedic.com' },
        update: {},
        create: {
            email: 'admin@germancarmedic.com',
            username: 'admin',
            passwordHash: adminPasswordHash,
            firstName: 'Admin',
            lastName: 'User',
            role: 'ADMIN',
            subscriptionTier: 'ENTERPRISE',
            isActive: true,
            emailVerified: true,
            emailVerifiedAt: new Date(),
            profile: {
                create: {
                    bio: 'System Administrator',
                    language: 'en',
                    timezone: 'UTC',
                    emailNotifications: true,
                    marketingEmails: false,
                    businessCountry: 'DE',
                },
            },
        },
    });

    console.log('✅ Created admin user:', {
        email: admin.email,
        username: admin.username,
        password: 'Admin123',
    });

    // Create Test Mechanic User
    const mechanic = await prisma.user.upsert({
        where: { email: 'mechanic@germancarmedic.com' },
        update: {},
        create: {
            email: 'mechanic@germancarmedic.com',
            username: 'mechanic',
            passwordHash: mechanicPasswordHash,
            firstName: 'Test',
            lastName: 'Mechanic',
            phoneNumber: '+491234567890',
            garageName: 'Test Auto Repair',
            yearsExperience: 5,
            specializations: ['BMW', 'Mercedes', 'Audi', 'Volkswagen'],
            role: 'MECHANIC',
            subscriptionTier: 'PRO',
            isActive: true,
            emailVerified: true,
            emailVerifiedAt: new Date(),
            profile: {
                create: {
                    bio: 'Experienced German car specialist',
                    language: 'en',
                    timezone: 'Europe/Berlin',
                    emailNotifications: true,
                    marketingEmails: true,
                    businessAddress: '123 Auto Street',
                    businessCity: 'Berlin',
                    businessState: 'Berlin',
                    businessZip: '10115',
                    businessCountry: 'DE',
                },
            },
        },
    });

    console.log('✅ Created mechanic user:', {
        email: mechanic.email,
        username: mechanic.username,
        password: 'Test123',
    });

    // Create additional test user
    const testUser = await prisma.user.upsert({
        where: { email: 'test@example.com' },
        update: {},
        create: {
            email: 'test@example.com',
            username: 'testuser',
            passwordHash: mechanicPasswordHash,
            firstName: 'John',
            lastName: 'Doe',
            garageName: 'Quick Fix Garage',
            role: 'MECHANIC',
            subscriptionTier: 'FREE',
            isActive: true,
            emailVerified: true,
            emailVerifiedAt: new Date(),
            profile: {
                create: {
                    language: 'en',
                    timezone: 'UTC',
                    emailNotifications: true,
                    businessCountry: 'DE',
                },
            },
        },
    });

    console.log('✅ Created test user:', {
        email: testUser.email,
        username: testUser.username,
        password: 'Test123',
    });

    console.log('\n🎉 Database seeding completed successfully!\n');
    console.log('📝 Test Credentials:');
    console.log('─'.repeat(50));
    console.log('Admin User:');
    console.log('  Email: admin@germancarmedic.com');
    console.log('  Username: admin');
    console.log('  Password: Admin123');
    console.log('─'.repeat(50));
    console.log('Mechanic User:');
    console.log('  Email: mechanic@germancarmedic.com');
    console.log('  Username: mechanic');
    console.log('  Password: Test123');
    console.log('─'.repeat(50));
    console.log('Test User:');
    console.log('  Email: test@example.com');
    console.log('  Username: testuser');
    console.log('  Password: Test123');
    console.log('─'.repeat(50));
}

main()
    .then(async () => {
        await prisma.$disconnect();
    })
    .catch(async (e) => {
        console.error('❌ Error seeding database:', e);
        await prisma.$disconnect();
        process.exit(1);
    });
