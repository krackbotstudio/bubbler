# Build stage: from monorepo root context
FROM node:20-alpine AS builder
WORKDIR /app

# Enable turbo build or default npm
COPY package.json package-lock.json* ./
COPY packages ./packages
COPY apps/admin-web ./apps/admin-web

# Install all dependencies
RUN npm ci

# Next.js standalone output expects to run standard next build
RUN npm run build:admin

# Production stage
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# Copy necessary standalone files
COPY --from=builder /app/apps/admin-web/public ./apps/admin-web/public
COPY --from=builder /app/apps/admin-web/.next/standalone ./
COPY --from=builder /app/apps/admin-web/.next/static ./apps/admin-web/.next/static

WORKDIR /app/apps/admin-web

# Run the standalone server.js
CMD ["node", "server.js"]
