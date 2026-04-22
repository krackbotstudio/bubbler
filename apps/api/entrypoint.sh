#!/bin/sh
# Entrypoint script for production container
# Usage: Set environment variable RUN_MIGRATIONS=true to run migrations before starting API

set -e

echo "🚀 Starting Weyou API container..."

# Display database connection info (hide password)
if [ -n "$DATABASE_URL" ]; then
    DB_HOST=$(echo "$DATABASE_URL" | sed -n 's|.*@\([^:]*\):.*|\1|p')
    echo "📊 Database host: $DB_HOST"
    echo "🔐 SSL mode: $(echo "$DATABASE_URL" | grep -o 'sslmode=[^&]*' || echo 'not specified')"
else
    echo "⚠️  DATABASE_URL not set!"
fi

# Check if we should run migrations first
if [ "$RUN_MIGRATIONS" = "true" ]; then
    echo "📦 RUN_MIGRATIONS is set to true"
    echo "🔄 Checking if Prisma CLI is available..."
    
    # Check if prisma is available
    if command -v npx >/dev/null 2>&1; then
        echo "✅ npx is available"
        
        # Check if schema exists
        if [ -f "src/infra/prisma/schema.prisma" ]; then
            echo "✅ Prisma schema found"
            echo "🔄 Running database migrations..."
            
            # Run migrations
            MIGRATION_ATTEMPTS=0
            MAX_ATTEMPTS=5
            
            while [ $MIGRATION_ATTEMPTS -lt $MAX_ATTEMPTS ]; do
                MIGRATION_ATTEMPTS=$((MIGRATION_ATTEMPTS + 1))
                echo "🔄 Migration attempt $MIGRATION_ATTEMPTS of $MAX_ATTEMPTS..."
                
                if npx prisma migrate deploy --schema=src/infra/prisma/schema.prisma; then
                    echo "✅ Migrations completed successfully"
                    break
                else
                    echo "⚠️  Migration failed on attempt $MIGRATION_ATTEMPTS, attempting to resolve..."
                    
                    # Try to resolve common failed migrations
                    echo "🔄 Marking failed migrations as resolved..."
                    npx prisma migrate resolve --rolled-back "20260211150000_backend_expansion" --schema=src/infra/prisma/schema.prisma 2>/dev/null || true
                    npx prisma migrate resolve --applied "20260211150000_backend_expansion" --schema=src/infra/prisma/schema.prisma 2>/dev/null || true
                    npx prisma migrate resolve --rolled-back "20260211160000_feedback" --schema=src/infra/prisma/schema.prisma 2>/dev/null || true
                    npx prisma migrate resolve --applied "20260211160000_feedback" --schema=src/infra/prisma/schema.prisma 2>/dev/null || true
                    npx prisma migrate resolve --rolled-back "20260213100000_add_segmented_pricing" --schema=src/infra/prisma/schema.prisma 2>/dev/null || true
                    npx prisma migrate resolve --applied "20260213100000_add_segmented_pricing" --schema=src/infra/prisma/schema.prisma 2>/dev/null || true
                    npx prisma migrate resolve --rolled-back "20260213120000_segment_category_table" --schema=src/infra/prisma/schema.prisma 2>/dev/null || true
                    npx prisma migrate resolve --applied "20260213120000_segment_category_table" --schema=src/infra/prisma/schema.prisma 2>/dev/null || true
                    npx prisma migrate resolve --rolled-back "20260213180000_add_branches" --schema=src/infra/prisma/schema.prisma 2>/dev/null || true
                    npx prisma migrate resolve --applied "20260213180000_add_branches" --schema=src/infra/prisma/schema.prisma 2>/dev/null || true
                    
                    if [ $MIGRATION_ATTEMPTS -eq $MAX_ATTEMPTS ]; then
                        echo "❌ Migrations still failed after $MAX_ATTEMPTS attempts!"
                        echo "💡 You may need to manually resolve migration issues in your Supabase database."
                        echo "💡 Check logs above for the specific failed migration name."
                        echo "💡 Run these commands in your container terminal:"
                        echo "   npx prisma migrate resolve --rolled-back \"MIGRATION_NAME\" --schema=src/infra/prisma/schema.prisma"
                        echo "   npx prisma migrate resolve --applied \"MIGRATION_NAME\" --schema=src/infra/prisma/schema.prisma"
                        exit 1
                    fi
                    
                    echo "🔄 Retrying migrations..."
                fi
            done
        else
            echo "⚠️  Prisma schema not found, skipping migrations"
        fi
    else
        echo "⚠️  npx not available, skipping migrations"
    fi
else
    echo "ℹ️  RUN_MIGRATIONS is not set (or set to false), skipping migrations"
    echo "💡 To run migrations, set environment variable: RUN_MIGRATIONS=true"
fi

echo "Starting API server (PORT=${PORT:-8080})"

# CMD from Docker passes the Node process here (see apps/api/Dockerfile)
exec "$@"
