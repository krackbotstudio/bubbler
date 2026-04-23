-- Complete ENUM Conversion Script
-- Run this in Supabase Dashboard → SQL Editor
-- This will convert TEXT columns to ENUM types to match your Prisma schema

BEGIN;

-- Step 1: Check if ENUM types exist, create them if they don't
DO $$
BEGIN
    -- Create FeedbackType if not exists
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'feedbacktype') THEN
        CREATE TYPE "FeedbackType" AS ENUM ('ORDER', 'GENERAL');
    END IF;

    -- Create FeedbackStatus if not exists
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'feedbackstatus') THEN
        CREATE TYPE "FeedbackStatus" AS ENUM ('NEW', 'REVIEWED', 'RESOLVED');
    END IF;

    -- Create InvoiceType if not exists
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'invoicetype') THEN
        CREATE TYPE "InvoiceType" AS ENUM ('ACKNOWLEDGEMENT', 'FINAL', 'SUBSCRIPTION');
    END IF;

    -- Create InvoiceStatus if not exists
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'invoicestatus') THEN
        CREATE TYPE "InvoiceStatus" AS ENUM ('DRAFT', 'ISSUED', 'VOID');
    END IF;

    -- Create OrderStatus if not exists
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'orderstatus') THEN
        CREATE TYPE "OrderStatus" AS ENUM ('BOOKING_CONFIRMED', 'PICKUP_SCHEDULED', 'PICKED_UP', 'IN_PROCESSING', 'READY', 'OUT_FOR_DELIVERY', 'DELIVERED', 'CANCELLED');
    END IF;

    -- Create OrderType if not exists
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ordertype') THEN
        CREATE TYPE "OrderType" AS ENUM ('INDIVIDUAL', 'SUBSCRIPTION', 'BOTH');
    END IF;

    -- Create ServiceType if not exists
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'servicetype') THEN
        CREATE TYPE "ServiceType" AS ENUM ('WASH_FOLD', 'WASH_IRON', 'STEAM_IRON', 'DRY_CLEAN', 'HOME_LINEN', 'SHOES', 'ADD_ONS');
    END IF;
END $$;

-- Step 2: Convert TEXT columns to ENUM types
-- Feedback table
ALTER TABLE "Feedback" ALTER COLUMN type TYPE "FeedbackType" USING type::"FeedbackType";
ALTER TABLE "Feedback" ALTER COLUMN status TYPE "FeedbackStatus" USING status::"FeedbackStatus";

-- Invoice table
ALTER TABLE "Invoice" ALTER COLUMN type TYPE "InvoiceType" USING type::"InvoiceType";
ALTER TABLE "Invoice" ALTER COLUMN status TYPE "InvoiceStatus" USING status::"InvoiceStatus";

-- Order table
ALTER TABLE "Order" ALTER COLUMN status TYPE "OrderStatus" USING status::"OrderStatus";
ALTER TABLE "Order" ALTER COLUMN "orderType" TYPE "OrderType" USING "orderType"::"OrderType";
ALTER TABLE "Order" ALTER COLUMN "serviceType" TYPE "ServiceType" USING "serviceType"::"ServiceType";

-- Step 3: Verify the conversion
SELECT 
  table_name,
  column_name,
  data_type,
  udt_name,
  CASE 
    WHEN data_type = 'USER-DEFINED' THEN 'ENUM ✅'
    WHEN data_type = 'character varying' OR data_type = 'text' THEN 'TEXT ❌'
    ELSE data_type
  END as status
FROM information_schema.columns
WHERE table_schema = 'public'
  AND (
    (table_name = 'Feedback' AND column_name IN ('type', 'status'))
    OR (table_name = 'Invoice' AND column_name IN ('type', 'status'))
    OR (table_name = 'Order' AND column_name IN ('status', 'orderType', 'serviceType'))
  )
ORDER BY table_name, column_name;

COMMIT;
