-- Fix ALL Missing PostgreSQL Enum Types
-- This resolves: "type public.<EnumName> does not exist" errors
--
-- Error: PostgreSQL error code 42704 (undefined_object)
-- Cause: Prisma schema has enum types that weren't created in the database
--
-- Run this in Supabase Dashboard → SQL Editor
-- This script is IDEMPOTENT - safe to run multiple times

-- 1. Role enum
DO $$ BEGIN
  CREATE TYPE "Role" AS ENUM (
    'CUSTOMER',
    'ADMIN',
    'PARTIAL_ADMIN',
    'OPS',
    'BILLING',
    'AGENT'
  );
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- 2. ServiceType enum
DO $$ BEGIN
  CREATE TYPE "ServiceType" AS ENUM (
    'WASH_FOLD',
    'WASH_IRON',
    'STEAM_IRON',
    'DRY_CLEAN',
    'HOME_LINEN',
    'SHOES',
    'ADD_ONS'
  );
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- 3. OrderStatus enum
DO $$ BEGIN
  CREATE TYPE "OrderStatus" AS ENUM (
    'BOOKING_CONFIRMED',
    'PICKUP_SCHEDULED',
    'PICKED_UP',
    'IN_PROCESSING',
    'READY',
    'OUT_FOR_DELIVERY',
    'DELIVERED',
    'CANCELLED'
  );
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- 4. OrderType enum
DO $$ BEGIN
  CREATE TYPE "OrderType" AS ENUM (
    'INDIVIDUAL',
    'SUBSCRIPTION',
    'BOTH'
  );
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- 5. PricingMode enum
DO $$ BEGIN
  CREATE TYPE "PricingMode" AS ENUM ('PER_KG');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- 6. PaymentProvider enum
DO $$ BEGIN
  CREATE TYPE "PaymentProvider" AS ENUM (
    'RAZORPAY',
    'CASH',
    'UPI',
    'CARD',
    'NONE'
  );
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- 7. PaymentStatus enum
DO $$ BEGIN
  CREATE TYPE "PaymentStatus" AS ENUM (
    'PENDING',
    'CAPTURED',
    'FAILED'
  );
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- 8. InvoiceOrderMode enum
DO $$ BEGIN
  CREATE TYPE "InvoiceOrderMode" AS ENUM (
    'INDIVIDUAL',
    'SUBSCRIPTION_ONLY',
    'BOTH'
  );
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- 9. InvoiceType enum
DO $$ BEGIN
  CREATE TYPE "InvoiceType" AS ENUM (
    'ACKNOWLEDGEMENT',
    'FINAL',
    'SUBSCRIPTION'
  );
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- 10. InvoiceStatus enum
DO $$ BEGIN
  CREATE TYPE "InvoiceStatus" AS ENUM (
    'DRAFT',
    'ISSUED',
    'VOID'
  );
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- 11. SubscriptionVariant enum
DO $$ BEGIN
  CREATE TYPE "SubscriptionVariant" AS ENUM (
    'SINGLE',
    'COUPLE',
    'FAMILY'
  );
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- 12. RedemptionMode enum
DO $$ BEGIN
  CREATE TYPE "RedemptionMode" AS ENUM (
    'MULTI_USE',
    'SINGLE_USE'
  );
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- 13. FeedbackType enum
DO $$ BEGIN
  CREATE TYPE "FeedbackType" AS ENUM (
    'ORDER',
    'GENERAL'
  );
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- 14. FeedbackStatus enum
DO $$ BEGIN
  CREATE TYPE "FeedbackStatus" AS ENUM (
    'NEW',
    'REVIEWED',
    'RESOLVED'
  );
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- 15. InvoiceItemType enum
DO $$ BEGIN
  CREATE TYPE "InvoiceItemType" AS ENUM (
    'SERVICE',
    'DRYCLEAN_ITEM',
    'ADDON',
    'FEE',
    'DISCOUNT'
  );
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- Verify ALL enums were created
SELECT 
  typname as enum_name,
  string_agg(enumlabel, ', ' ORDER BY enumsortorder) as enum_values
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
