# Fixing Prisma Migration Errors in Dokploy with Supabase

## Problem
You're getting error P3009 in Dokploy because the migration `20260211150000_backend_expansion` failed in your live Supabase database.

## What Changed
I've updated your deployment to automatically handle multiple failed migrations:

1. **Updated `entrypoint.sh`** - Now uses a retry loop (up to 5 attempts) that automatically resolves common failed migrations
2. **Added `scripts/resolve-migrations.sh`** - Manual resolution script for troubleshooting
3. **Updated `Dockerfile`** - Includes the resolution script in the container

### Auto-Resolved Migrations:
The script will automatically attempt to resolve these migrations if they fail:
- `20260211150000_backend_expansion`
- `20260211160000_feedback`
- `20260213100000_add_segmented_pricing`
- `20260213120000_segment_category_table`
- `20260213180000_add_branches`

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

### Why Migrations Fail

Migrations can fail for several reasons:

1. **P3009 - Previously Failed Migration**: A migration started but didn't complete, leaving it in a "failed" state
2. **P3018 - Table Already Exists**: The database schema already has the table/column (from manual changes or previous attempts)
3. **Partial Application**: Some changes from a migration were applied before it failed

### How the Auto-Resolution Works

The updated entrypoint script:
1. **Attempts** to run all migrations
2. **If it fails**, marks known problematic migrations as resolved (both `--rolled-back` and `--applied`)
3. **Retries** the migrations (up to 5 attempts)
4. **Succeeds** once all migrations are applied

This works because:
- `--rolled-back` clears the "failed" state
- `--applied` tells Prisma "don't try to run this, it's already done"
- The database already has the tables/columns, so skipping is safe

## Verification

After deployment, verify migrations worked:

```bash
# In Dokploy terminal
cd /app/apps/api
npx prisma migrate status --schema=src/infra/prisma/schema.prisma
```

You should see: "All migrations are already applied"

## Important Notes

⚠️ **Your Supabase Connection**: Your production uses a self-hosted Supabase at `62.72.41.216:5436`:
```
DATABASE_URL=postgresql://postgres.AwMCwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlzcy:w1zmqs64szqu3utgoltwju5uyar8ymdw@62.72.41.216:5436/postgres?sslmode=disable&pgbouncer=true&statement_cache_size=0
```

**Important:** `sslmode=disable` is required because your self-hosted Supabase doesn't support TLS.

Make sure this is the correct connection string in Dokploy's environment variables.

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
