-- Check actual column types in the database
-- Run this in Supabase Dashboard → SQL Editor to verify if columns are ENUM or TEXT

SELECT 
  table_name,
  column_name,
  data_type,
  udt_name,
  CASE 
    WHEN data_type = 'USER-DEFINED' THEN 'ENUM ✅'
    WHEN data_type = 'character varying' OR data_type = 'text' THEN 'TEXT ❌ (needs conversion)'
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
