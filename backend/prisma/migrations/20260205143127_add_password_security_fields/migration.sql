-- AlterTable
ALTER TABLE "users" ADD COLUMN     "accountLockedUntil" TIMESTAMP(3),
ADD COLUMN     "failedLoginAttempts" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "passwordHistory" TEXT[] DEFAULT ARRAY[]::TEXT[];
