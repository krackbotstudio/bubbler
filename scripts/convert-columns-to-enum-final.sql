-- Convert TEXT columns to ENUM types with proper default handling
-- Run this in Supabase Dashboard → SQL Editor

-- Step 1: Drop existing defaults
ALTER TABLE "Feedback" ALTER COLUMN status DROP DEFAULT;
ALTER TABLE "Invoice" ALTER COLUMN status DROP DEFAULT;
ALTER TABLE "Order" ALTER COLUMN "orderType" DROP DEFAULT;
ALTER TABLE "Order" ALTER COLUMN "serviceType" DROP DEFAULT;

-- Step 2: Convert columns to ENUM types
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

-- Step 3: Re-add defaults with proper ENUM types
ALTER TABLE "Feedback" ALTER COLUMN status SET DEFAULT 'NEW'::"FeedbackStatus";
ALTER TABLE "Order" ALTER COLUMN "orderType" SET DEFAULT 'INDIVIDUAL'::"OrderType";

-- Step 4: Verify the conversion
SELECT 
  table_name,
  column_name,
  data_type,
  udt_name,
  column_default,
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
