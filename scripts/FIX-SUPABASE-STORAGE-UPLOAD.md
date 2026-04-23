# Fix Supabase Storage Upload Error

## Problem
```
Status: 400
Code: ERR_BAD_REQUEST
API Code: ERROR
Supabase storage upload failed: new row violates row-level security policy
```

## Root Cause
Supabase Storage bucket has Row Level Security (RLS) policies that are blocking uploads, even when using the `service_role` key.

## Solution (Choose ONE method)

### Method 1: Quick Fix via Supabase Dashboard (Recommended)

1. **Go to Supabase Dashboard**
   - https://supabase.com/dashboard
   - Select your project: `cybtuiabjajslbhnukhd`

2. **Navigate to Storage**
   - Click **Storage** in left sidebar
   - Click on the **assets** bucket

3. **Go to Policies**
   - Click **Policies** tab

4. **Add Policy for Inserts**
   - Click **New policy**
   - Select **For full customization** → **Continue**
   - Configure:
     - **Policy name**: `Enable inserts (authenticated)`
     - **Allowed operation**: `INSERT`
     - **Target roles**: `authenticated`
     - **Policy definition**: `true`
   - Click **Review** → **Save policy**

5. **Add Policy for Updates**
   - Click **New policy**
   - Select **For full customization** → **Continue**
   - Configure:
     - **Policy name**: `Enable updates (authenticated)`
     - **Allowed operation**: `UPDATE`
     - **Target roles**: `authenticated`
     - **Policy definition**: `true`
   - Click **Review** → **Save policy**

6. **Verify**
   - Try uploading a logo again from admin dashboard
   - Should work now! ✅

---

### Method 2: SQL Script (Advanced)

1. **Go to Supabase Dashboard**
   - https://supabase.com/dashboard
   - Select your project

2. **Open SQL Editor**
   - Click **SQL Editor** in left sidebar
   - Click **New query**

3. **Run the Fix Script**
   - Copy contents of `scripts/fix-supabase-storage-policies.sql`
   - Paste into SQL Editor
   - Click **Run** (Ctrl+Enter)

4. **Verify**
   - Check the output shows policies were created
   - Try uploading a logo again

---

### Method 3: Disable RLS Temporarily (Fastest but Less Secure)

⚠️ **Warning**: This disables security on the storage bucket. Only use for testing!

1. **Go to Supabase Dashboard** → **SQL Editor**

2. **Run this command**:
   ```sql
   -- Disable RLS on storage.objects (NOT RECOMMENDED FOR PRODUCTION)
   ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;
   ```

3. **Test upload**

4. **Re-enable RLS and add proper policies** (use Method 1 or 2)

---

## Why This Happens

The API uses `SUPABASE_SERVICE_ROLE_KEY` which should bypass RLS automatically. However, if:
- The bucket was created with strict RLS policies
- Or policies were manually configured
- Or the service_role isn't properly configured

Then uploads will fail with "row-level security policy" errors.

## Verification

After applying the fix, test the upload:

1. **Go to admin dashboard** → Branding page
2. **Click "Upload logo"**
3. **Select an image**
4. **Should see**: ✅ "Logo uploaded" success message
5. **Check API logs**: No errors

## Expected Behavior

With proper policies in place:
- ✅ Logo uploads work
- ✅ App icon uploads work
- ✅ UPI QR uploads work
- ✅ Carousel images upload work
- ✅ Branch logo uploads work
- ✅ All files are publicly accessible via CDN

## Additional Notes

- The bucket should be **Public** (check in Storage → assets → Settings)
- The `service_role` key has full access by default, but RLS can still interfere
- If issues persist, rotate the `service_role` key in Supabase Dashboard → Settings → API

## References

- [Supabase Storage Security Docs](https://supabase.com/docs/guides/storage/security)
- [Supabase RLS Policies](https://supabase.com/docs/guides/database/row-level-security)
- [Storage API Reference](https://supabase.com/docs/reference/javascript/storage-from-upload)
