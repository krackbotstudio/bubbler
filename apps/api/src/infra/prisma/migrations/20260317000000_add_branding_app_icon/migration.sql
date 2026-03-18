-- Add appIconUrl to BrandingSettings (used as mobile app icon and admin favicon)
ALTER TABLE "BrandingSettings" ADD COLUMN IF NOT EXISTS "appIconUrl" TEXT;
