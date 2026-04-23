-- Fix Supabase Storage Bucket Policies for "assets" bucket
-- This resolves: "new row violates row-level security policy" error during uploads
--
-- Run this in Supabase Dashboard → SQL Editor
-- Reference: https://supabase.com/docs/guides/storage#security

-- IMPORTANT: The API uses service_role key which should bypass RLS automatically.
-- If you're still getting RLS errors, run ALL statements below.

-- 1. First, drop any existing restrictive policies
DROP POLICY IF EXISTS "Enable inserts (authenticated)" ON storage.objects;
DROP POLICY IF EXISTS "Enable updates (authenticated)" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated uploads to assets bucket" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated updates to assets bucket" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated deletes from assets bucket" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read access to assets bucket" ON storage.objects;

-- 2. Create permissive policies for authenticated users (includes service_role)
CREATE POLICY "Enable insert for authenticated users"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'assets');

CREATE POLICY "Enable update for authenticated users"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'assets')
WITH CHECK (bucket_id = 'assets');

CREATE POLICY "Enable delete for authenticated users"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'assets');

CREATE POLICY "Enable read access for all users"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'assets');

-- 3. Grant full access to service_role (this should make it bypass RLS)
GRANT ALL ON storage.objects TO service_role;
GRANT ALL ON storage.buckets TO service_role;

-- 4. Verify the bucket exists and is public
SELECT name, public FROM storage.buckets WHERE name = 'assets';

-- 5. Verify policies were created
SELECT 
  policyname,
  cmd,
  roles,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'objects'
  AND schemaname = 'storage'
ORDER BY policyname;
