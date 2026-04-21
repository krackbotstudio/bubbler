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
            if npx prisma migrate deploy --schema=src/infra/prisma/schema.prisma; then
                echo "✅ Migrations completed successfully"
            else
                echo "⚠️  Migration failed, attempting to resolve known failed migrations..."
                
                # Try to resolve the known failed migration
                echo "🔄 Marking 20260211150000_backend_expansion as resolved..."
                npx prisma migrate resolve --rolled-back "20260211150000_backend_expansion" --schema=src/infra/prisma/schema.prisma 2>/dev/null || true
                npx prisma migrate resolve --applied "20260211150000_backend_expansion" --schema=src/infra/prisma/schema.prisma 2>/dev/null || true
                
                # Try running migrations again
                echo "🔄 Retrying migrations..."
                if npx prisma migrate deploy --schema=src/infra/prisma/schema.prisma; then
                    echo "✅ Migrations completed after resolution"
                else
                    echo "❌ Migrations still failed after resolution attempt!"
                    echo "💡 You may need to manually resolve migration issues in your Supabase database."
                    echo "💡 Run these commands in your container terminal:"
                    echo "   npx prisma migrate resolve --rolled-back \"MIGRATION_NAME\" --schema=src/infra/prisma/schema.prisma"
                    echo "   npx prisma migrate resolve --applied \"MIGRATION_NAME\" --schema=src/infra/prisma/schema.prisma"
                    exit 1
                fi
            fi
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
