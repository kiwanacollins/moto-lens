/*
  Warnings:

  - You are about to drop the `email_verification_tokens` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "email_verification_tokens" DROP CONSTRAINT "email_verification_tokens_userId_fkey";

-- DropTable
DROP TABLE "email_verification_tokens";
