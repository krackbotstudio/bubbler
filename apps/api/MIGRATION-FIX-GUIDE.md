# Fixing Prisma Migration Errors in Dokploy with Supabase

## Problem
You're getting error P3009 in Dokploy because the migration `20260211150000_backend_expansion` failed in your live Supabase database.

## What Changed
I've updated your deployment to automatically handle failed migrations:

1. **Updated `entrypoint.sh`** - Now automatically attempts to resolve the known failed migration
2. **Added `scripts/resolve-migrations.sh`** - Manual resolution script for troubleshooting
3. **Updated `Dockerfile`** - Includes the resolution script in the container

## Solutions

### Option 1: Automatic Resolution (Recommended)
The updated `entrypoint.sh` will now automatically:
1. Try to run migrations
2. If it fails, mark `20260211150000_backend_expansion` as resolved
3. Retry the migrations

**Just redeploy your application in Dokploy** - the fix is already in place.

### Option 2: Manual Resolution via Dokploy Terminal

If the automatic resolution doesn't work, access your container terminal in Dokploy and run:

```bash
# Navigate to app directory
cd /app/apps/api

# Run the resolution script
sh /app/scripts/resolve-migrations.sh
```

Or manually:

```bash
# Mark the failed migration as resolved
npx prisma migrate resolve --rolled-back "20260211150000_backend_expansion" --schema=src/infra/prisma/schema.prisma

# Mark it as applied
npx prisma migrate resolve --applied "20260211150000_backend_expansion" --schema=src/infra/prisma/schema.prisma

# Run remaining migrations
npx prisma migrate deploy --schema=src/infra/prisma/schema.prisma
```

### Option 3: Direct Database Fix (Advanced)

If you need to check what's in your Supabase database:

1. **Connect to Supabase SQL Editor** at https://cybtuiabjajslbhnukhd.supabase.co
2. **Check migration status**:
   ```sql
   SELECT * FROM "_prisma_migrations" ORDER BY started_at DESC LIMIT 10;
   ```
3. **Delete the failed migration record** (if needed):
   ```sql
   DELETE FROM "_prisma_migrations" 
   WHERE migration_name = '20260211150000_backend_expansion';
   ```
4. **Then redeploy** or run migrations manually

## Understanding the Issue

The migration `20260211150000_backend_expansion` failed because:
- It started but didn't complete successfully
- Prisma marks it as "failed" in the `_prisma_migrations` table
- Prisma won't run new migrations until failed ones are resolved

The resolution commands tell Prisma:
1. `--rolled-back` - Clear the failed state
2. `--applied` - Mark it as already done (since it partially ran)

## Verification

After deployment, verify migrations worked:

```bash
# In Dokploy terminal
cd /app/apps/api
npx prisma migrate status --schema=src/infra/prisma/schema.prisma
```

You should see: "All migrations are already applied"

## Important Notes

⚠️ **Your Supabase Connection**: Your `.env` file shows you're using a live Supabase database:
```
DATABASE_URL=postgresql://postgres.cybtuiabjajslbhnukhd:...@aws-1-ap-southeast-1.pooler.supabase.com:6543/postgres
```

Make sure this is the correct connection string for your production database in Dokploy's environment variables.

## Need More Help?

If other migrations fail, use this pattern for ANY failed migration:

```bash
# Replace MIGRATION_NAME with the actual failed migration folder name
npx prisma migrate resolve --rolled-back "MIGRATION_NAME" --schema=src/infra/prisma/schema.prisma
npx prisma migrate resolve --applied "MIGRATION_NAME" --schema=src/infra/prisma/schema.prisma
npx prisma migrate deploy --schema=src/infra/prisma/schema.prisma
```

Common migration names:
- `20260211150000_backend_expansion`
- `20260213100000_add_segmented_pricing`
- `20260213120000_segment_category_table`
- `20260213180000_add_branches`
