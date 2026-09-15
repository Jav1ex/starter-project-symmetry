import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { initializeTestEnvironment } from '@firebase/rules-unit-testing';
import { Timestamp, serverTimestamp, setLogLevel } from 'firebase/firestore';

// Expected PERMISSION_DENIED responses would otherwise be printed as SDK errors.
setLogLevel('silent');

const backendDir = resolve(dirname(fileURLToPath(import.meta.url)), '..');

export const PROJECT_ID = 'news-app-rules-test';
export const BUCKET = 'back-pruebasymmetry.firebasestorage.app';

/**
 * Boots a rules test environment against the running emulators.
 * Host and port are read from the FIRESTORE_EMULATOR_HOST and
 * FIREBASE_STORAGE_EMULATOR_HOST variables that `firebase emulators:exec` exports.
 */
export function createTestEnvironment() {
  return initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: { rules: readFileSync(resolve(backendDir, 'firestore.rules'), 'utf8') },
    storage: { rules: readFileSync(resolve(backendDir, 'storage.rules'), 'utf8') },
  });
}

export function thumbnailUrlFor(fileName) {
  const encodedPath = encodeURIComponent(`media/articles/${fileName}`);
  return `https://firebasestorage.googleapis.com/v0/b/${BUCKET}/o/${encodedPath}?alt=media&token=test-token`;
}

/** A document that satisfies every constraint in docs/DB_SCHEMA.md. */
export function validArticle(overrides = {}) {
  return {
    title: 'City council approves new bike lanes',
    description: 'Twelve kilometres of protected lanes will be built downtown by 2027.',
    content: 'The city council voted 9-2 on Tuesday to approve the plan.',
    author: 'Nelson Rojas',
    thumbnailURL: thumbnailUrlFor('bike-lanes.jpg'),
    thumbnailPath: 'media/articles/bike-lanes.jpg',
    publishedAt: Timestamp.fromDate(new Date('2026-09-15T10:00:00Z')),
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
    ...overrides,
  };
}

/** Returns a copy of `article` without the given field. */
export function without(article, field) {
  const copy = { ...article };
  delete copy[field];
  return copy;
}

export function stringOfLength(length) {
  return 'x'.repeat(length);
}

/** A tiny but valid-looking payload; rules only inspect contentType and size. */
export function fakeImageBytes(byteLength = 1024) {
  return new Uint8Array(byteLength);
}
