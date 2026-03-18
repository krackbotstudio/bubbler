import { readFileSync, readdirSync } from 'fs';
import { join } from 'path';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient({
  datasources: {
    db: { url: 'postgresql://postgres.63f4945d921d599f27ae4fdf5bada3f3:etisxghsmjkjn8c01gd3y42lituunf8m@187.127.128.214:5432/postgres?sslmode=disable' }
  }
});

const migrationsDir = 'apps/api/src/infra/prisma/migrations';
const dirs = readdirSync(migrationsDir).sort();

let ok = 0, skipped = 0, errored = 0;

for (const dir of dirs) {
  const sqlFile = join(migrationsDir, dir, 'migration.sql');
  let sql;
  try { sql = readFileSync(sqlFile, 'utf8'); } catch { continue; }

  // Split on semicolons followed by newline
  const statements = sql.split(/;\s*\n/).map(s => s.trim()).filter(s => s.length > 0 && !s.startsWith('--'));

  for (const stmt of statements) {
    if (!stmt) continue;
    try {
      await prisma.$executeRawUnsafe(stmt);
      ok++;
    } catch (e) {
      const msg = e.message || '';
      if (msg.includes('already exists') || msg.includes('duplicate') || msg.includes('multiple primary keys')) {
        skipped++;
      } else {
        console.error(`[${dir}] ERR: ${msg.substring(0, 150)}`);
        errored++;
      }
    }
  }
}

await prisma.$disconnect();
console.log(`Done. ok=${ok} skipped=${skipped} errored=${errored}`);
