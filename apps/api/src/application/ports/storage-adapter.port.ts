import type { Readable } from 'stream';

export interface StorageAdapter {
  /**
   * Store a file; path is relative (e.g. "branding/logo.png").
   * @returns Optional public URL when using cloud storage (e.g. Supabase). Use this URL in DB so assets persist across restarts/deploys.
   */
  putObject(path: string, buffer: Buffer, contentType: string): Promise<string | void>;
  /** Get a read stream for the file, or null if not found. */
  getObjectStream(path: string): Promise<Readable | null>;
  /** Optional: read full file into buffer (for small files). */
  readFile?(path: string): Promise<Buffer | null>;
}
