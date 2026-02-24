-- AlterTable Subscription: add address snapshot
ALTER TABLE "Subscription" ADD COLUMN IF NOT EXISTS "addressLabel" TEXT;
ALTER TABLE "Subscription" ADD COLUMN IF NOT EXISTS "addressLine" TEXT;

-- AlterTable Order: add address snapshot
ALTER TABLE "Order" ADD COLUMN IF NOT EXISTS "addressLabel" TEXT;
ALTER TABLE "Order" ADD COLUMN IF NOT EXISTS "addressLine" TEXT;
