-- Complete Fix: Convert TEXT columns to ENUM types AND create enum types
-- This handles the case where columns were created as TEXT but Prisma expects ENUM
--
-- Run this in Supabase Dashboard → SQL Editor
-- ⚠️ IMPORTANT: This will modify column types - backup your data first!

-- ========================================
-- STEP 1: Create ALL enum types (if missing)
-- ========================================

DO $$ BEGIN
  CREATE TYPE "Role" AS ENUM ('CUSTOMER', 'ADMIN', 'PARTIAL_ADMIN', 'OPS', 'BILLING', 'AGENT');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE "ServiceType" AS ENUM ('WASH_FOLD', 'WASH_IRON', 'STEAM_IRON', 'DRY_CLEAN', 'HOME_LINEN', 'SHOES', 'ADD_ONS');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE "OrderStatus" AS ENUM ('BOOKING_CONFIRMED', 'PICKUP_SCHEDULED', 'PICKED_UP', 'IN_PROCESSING', 'READY', 'OUT_FOR_DELIVERY', 'DELIVERED', 'CANCELLED');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE "OrderType" AS ENUM ('INDIVIDUAL', 'SUBSCRIPTION', 'BOTH');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE "PricingMode" AS ENUM ('PER_KG');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE "PaymentProvider" AS ENUM ('RAZORPAY', 'CASH', 'UPI', 'CARD', 'NONE');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE "PaymentStatus" AS ENUM ('PENDING', 'CAPTURED', 'FAILED');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE "InvoiceOrderMode" AS ENUM ('INDIVIDUAL', 'SUBSCRIPTION_ONLY', 'BOTH');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE "InvoiceType" AS ENUM ('ACKNOWLEDGEMENT', 'FINAL', 'SUBSCRIPTION');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE "InvoiceStatus" AS ENUM ('DRAFT', 'ISSUED', 'VOID');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE "SubscriptionVariant" AS ENUM ('SINGLE', 'COUPLE', 'FAMILY');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE "RedemptionMode" AS ENUM ('MULTI_USE', 'SINGLE_USE');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE "FeedbackType" AS ENUM ('ORDER', 'GENERAL');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE "FeedbackStatus" AS ENUM ('NEW', 'REVIEWED', 'RESOLVED');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE "InvoiceItemType" AS ENUM ('SERVICE', 'DRYCLEAN_ITEM', 'ADDON', 'FEE', 'DISCOUNT');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

-- ========================================
-- STEP 2: Check current column types
-- ========================================

-- This shows what type each column currently is
SELECT 
  table_name,
  column_name,
  data_type,
  udt_name,
  CASE 
    WHEN data_type = 'USER-DEFINED' THEN 'ENUM (Good!)'
    WHEN data_type = 'character varying' OR data_type = 'text' THEN 'TEXT (Needs conversion!)'
    ELSE data_type
  END as column_type_status
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('feedback', '"Order"', 'invoice', '"User"', '"OrderItem"')
  AND column_name IN ('type', 'status', 'role', 'serviceType', 'orderType', 'paymentStatus', 'variant')
ORDER BY table_name, column_name;

-- ========================================
-- STEP 3: Convert TEXT columns to ENUM (if needed)
-- ========================================
-- ⚠️ UNCOMMENT these lines ONLY if STEP 2 shows columns are TEXT type
-- ⚠️ This will convert existing TEXT values to ENUM values

-- Convert feedback.type from TEXT to ENUM
-- ALTER TABLE "Feedback" ALTER COLUMN type TYPE "FeedbackType" USING type::"FeedbackType";

-- Convert feedback.status from TEXT to ENUM  
-- ALTER TABLE "Feedback" ALTER COLUMN status TYPE "FeedbackStatus" USING status::"FeedbackStatus";

-- Convert "Order".status from TEXT to ENUM
-- ALTER TABLE "Order" ALTER COLUMN status TYPE "OrderStatus" USING status::"OrderStatus";

-- Convert "Order".orderType from TEXT to ENUM
-- ALTER TABLE "Order" ALTER COLUMN "orderType" TYPE "OrderType" USING "orderType"::"OrderType";

-- Convert "Order".serviceType from TEXT to ENUM
-- ALTER TABLE "Order" ALTER COLUMN "serviceType" TYPE "ServiceType" USING "serviceType"::"ServiceType";

-- Convert invoice.type from TEXT to ENUM
-- ALTER TABLE "Invoice" ALTER COLUMN type TYPE "InvoiceType" USING type::"InvoiceType";

-- Convert invoice.status from TEXT to ENUM
-- ALTER TABLE "Invoice" ALTER COLUMN status TYPE "InvoiceStatus" USING status::"InvoiceStatus";

-- Convert "User".role from TEXT to ENUM
-- ALTER TABLE "User" ALTER COLUMN role TYPE "Role" USING role::"Role";

-- ========================================
-- STEP 4: Verify enum types exist
-- ========================================

SELECT 
  typname as enum_name,
  string_agg(enumlabel, ', ' ORDER BY enumsortorder) as values
FROM pg_enum
JOIN pg_type ON pg_enum.enumtypid = pg_type.oid
WHERE typname IN (
  'Role', 'ServiceType', 'OrderStatus', 'OrderType', 'PricingMode',
  'PaymentProvider', 'PaymentStatus', 'InvoiceOrderMode', 'InvoiceType',
  'InvoiceStatus', 'SubscriptionVariant', 'RedemptionMode', 'FeedbackType',
  'FeedbackStatus', 'InvoiceItemType'
)
GROUP BY typname
ORDER BY typname;
