import dotenv from 'dotenv';
dotenv.config();

import { neon } from '@neondatabase/serverless';
import { neonConfig } from '@neondatabase/serverless';
import { drizzle } from 'drizzle-orm/neon-http';

const databaseUrl = process.env.DATABASE_URL;

const useNeonLocal =
  process.env.NEON_LOCAL === 'true' ||
  databaseUrl?.includes('@neon-local:5432') ||
  databaseUrl?.includes('@localhost:5432');

if (useNeonLocal) {
  neonConfig.fetchEndpoint =
    process.env.NEON_LOCAL_FETCH_ENDPOINT ||
    (databaseUrl?.includes('@localhost:5432')
      ? 'http://localhost:5432/sql'
      : 'http://neon-local:5432/sql');
  neonConfig.useSecureWebSocket = false;
  neonConfig.poolQueryViaFetch = true;
}

const sql = neon(databaseUrl);

const db = drizzle(sql);

export { db, sql };