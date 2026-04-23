-- Convert TEXT columns to ENUM types
-- This fixes the Prisma errors where columns are TEXT but schema expects ENUM
--
-- Run this in Supabase Dashboard → SQL Editor
-- ⚠️ IMPORTANT: This modifies column types. Your existing data will be converted automatically.

-- Convert Feedback.type from TEXT to FeedbackType ENUM
ALTER TABLE "Feedback" ALTER COLUMN type TYPE "FeedbackType" USING type::"FeedbackType";

-- Convert Feedback.status from TEXT to FeedbackStatus ENUM
ALTER TABLE "Feedback" ALTER COLUMN status TYPE "FeedbackStatus" USING status::"FeedbackStatus";

-- Convert Invoice.type from TEXT to InvoiceType ENUM
ALTER TABLE "Invoice" ALTER COLUMN type TYPE "InvoiceType" USING type::"InvoiceType";

-- Convert Invoice.status from TEXT to InvoiceStatus ENUM
ALTER TABLE "Invoice" ALTER COLUMN status TYPE "InvoiceStatus" USING status::"InvoiceStatus";

-- Convert Order.status from TEXT to OrderStatus ENUM
ALTER TABLE "Order" ALTER COLUMN status TYPE "OrderStatus" USING status::"OrderStatus";

-- Convert Order.orderType from TEXT to OrderType ENUM
ALTER TABLE "Order" ALTER COLUMN "orderType" TYPE "OrderType" USING "orderType"::"OrderType";

-- Convert Order.serviceType from TEXT to ServiceType ENUM
ALTER TABLE "Order" ALTER COLUMN "serviceType" TYPE "ServiceType" USING "serviceType"::"ServiceType";

-- Verify the conversion
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
    OR (table_name = 'User' AND column_name = 'role')
  )
ORDER BY table_name, column_name;
