-- Check if enum types exist in the database
-- Run this in Supabase Dashboard → SQL Editor

-- List ALL enum types in the database
SELECT 
  typname as enum_name,
  enumlabel as value,
  enumsortorder
FROM pg_enum
JOIN pg_type ON pg_enum.enumtypid = pg_type.oid
ORDER BY typname, enumsortorder;

-- Check specifically for the problematic enums
SELECT 
  typname,
  CASE 
    WHEN COUNT(*) > 0 THEN 'EXISTS ✅'
    ELSE 'MISSING ❌'
  END as status
FROM pg_type
WHERE typname IN ('FeedbackType', 'OrderStatus', 'InvoiceType')
  AND typtype = 'e'
GROUP BY typname;

-- If the above shows MISSING, check if columns use TEXT instead of ENUM
SELECT 
  table_name,
  column_name,
  data_type,
  udt_name
FROM information_schema.columns
WHERE table_schema = 'public'
  AND (table_name = 'feedback' OR table_name = 'order' OR table_name = 'invoice')
  AND column_name IN ('type', 'status')
ORDER BY table_name, column_name;
