/**
 * Offline Storage Utilities
 * Uses IndexedDB for draft report storage
 */
import { openDB, DBSchema, IDBPDatabase } from 'idb';

interface DraftReport {
  id?: number;
  timestamp: number;
  data: {
    category?: string;
    severity?: string;
    summary?: string;
    details?: string;
    anonymous?: boolean;
    county?: string;
    district?: string;
    latitude?: number;
    longitude?: number;
    witness_count?: number;
    files?: Array<{
      name: string;
      type: string;
      size: number;
      data: ArrayBuffer;
    }>;
  };
}

interface TalkamDB extends DBSchema {
  drafts: {
    key: number;
    value: DraftReport;
    indexes: { 'by-timestamp': number };
  };
}

let dbPromise: Promise<IDBPDatabase<TalkamDB>> | null = null;

function getDB(): Promise<IDBPDatabase<TalkamDB>> {
  if (!dbPromise) {
    dbPromise = openDB<TalkamDB>('talkam-liberia', 1, {
      upgrade(db) {
        const draftStore = db.createObjectStore('drafts', {
          keyPath: 'id',
          autoIncrement: true,
        });
        draftStore.createIndex('by-timestamp', 'timestamp');
      },
    });
  }
  return dbPromise;
}

export const offlineStorage = {
  /**
   * Save a draft report
   */
  async saveDraft(data: DraftReport['data']): Promise<number> {
    const db = await getDB();
    const draft: DraftReport = {
      timestamp: Date.now(),
      data,
    };
    const id = await db.add('drafts', draft);
    return id as number;
  },

  /**
   * Get all drafts
   */
  async getDrafts(): Promise<DraftReport[]> {
    const db = await getDB();
    return db.getAll('drafts');
  },

  /**
   * Get a specific draft by ID
   */
  async getDraft(id: number): Promise<DraftReport | undefined> {
    const db = await getDB();
    return db.get('drafts', id);
  },

  /**
   * Delete a draft
   */
  async deleteDraft(id: number): Promise<void> {
    const db = await getDB();
    await db.delete('drafts', id);
  },

  /**
   * Clear all drafts
   */
  async clearDrafts(): Promise<void> {
    const db = await getDB();
    await db.clear('drafts');
  },

  /**
   * Convert File to ArrayBuffer for storage
   */
  async fileToArrayBuffer(file: File): Promise<ArrayBuffer> {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => resolve(reader.result as ArrayBuffer);
      reader.onerror = reject;
      reader.readAsArrayBuffer(file);
    });
  },

  /**
   * Convert ArrayBuffer back to File
   */
  arrayBufferToFile(buffer: ArrayBuffer, name: string, type: string): File {
    return new File([buffer], name, { type });
  },
};














