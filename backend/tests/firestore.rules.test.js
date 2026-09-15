import { after, before, beforeEach, describe, it } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  Timestamp,
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  serverTimestamp,
  setDoc,
  updateDoc,
} from 'firebase/firestore';
import {
  createTestEnvironment,
  stringOfLength,
  thumbnailUrlFor,
  validArticle,
  without,
} from './helpers.js';

let testEnv;

function articleRef(id = 'article-1') {
  return doc(testEnv.unauthenticatedContext().firestore(), 'articles', id);
}

/** Writes a valid article bypassing rules, so update/delete tests start from real data. */
async function seedArticle(id = 'article-1') {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'articles', id), {
      ...validArticle(),
      createdAt: Timestamp.fromDate(new Date('2026-09-01T00:00:00Z')),
      updatedAt: Timestamp.fromDate(new Date('2026-09-01T00:00:00Z')),
    });
  });
}

before(async () => {
  testEnv = await createTestEnvironment();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

after(async () => {
  await testEnv.cleanup();
});

describe('articles: read', () => {
  it('allows anyone to read a single article', async () => {
    await seedArticle();
    await assertSucceeds(getDoc(articleRef()));
  });

  it('allows anyone to list the collection', async () => {
    await seedArticle();
    const db = testEnv.unauthenticatedContext().firestore();
    await assertSucceeds(getDocs(collection(db, 'articles')));
  });
});

describe('articles: create with a valid document', () => {
  it('accepts a document that satisfies the schema', async () => {
    await assertSucceeds(setDoc(articleRef(), validArticle()));
  });

  it('accepts a backdated publishedAt (journalists can schedule or backdate)', async () => {
    const article = validArticle({
      publishedAt: Timestamp.fromDate(new Date('2020-01-01T00:00:00Z')),
    });
    await assertSucceeds(setDoc(articleRef(), article));
  });

  it('accepts fields at their maximum length', async () => {
    const article = validArticle({
      title: stringOfLength(150),
      description: stringOfLength(300),
      content: stringOfLength(20000),
      author: stringOfLength(80),
    });
    await assertSucceeds(setDoc(articleRef(), article));
  });
});

describe('articles: create rejects malformed shape', () => {
  for (const field of [
    'title',
    'description',
    'content',
    'author',
    'thumbnailURL',
    'thumbnailPath',
    'publishedAt',
    'createdAt',
    'updatedAt',
  ]) {
    it(`rejects a document missing "${field}"`, async () => {
      await assertFails(setDoc(articleRef(), without(validArticle(), field)));
    });
  }

  it('rejects unknown extra fields', async () => {
    await assertFails(setDoc(articleRef(), validArticle({ likes: 0 })));
  });
});

describe('articles: create rejects invalid strings', () => {
  it('rejects an empty title', async () => {
    await assertFails(setDoc(articleRef(), validArticle({ title: '' })));
  });

  it('rejects a title longer than 150 characters', async () => {
    await assertFails(setDoc(articleRef(), validArticle({ title: stringOfLength(151) })));
  });

  it('rejects a description longer than 300 characters', async () => {
    await assertFails(
      setDoc(articleRef(), validArticle({ description: stringOfLength(301) })),
    );
  });

  it('rejects content longer than 20000 characters', async () => {
    await assertFails(setDoc(articleRef(), validArticle({ content: stringOfLength(20001) })));
  });

  it('rejects an author longer than 80 characters', async () => {
    await assertFails(setDoc(articleRef(), validArticle({ author: stringOfLength(81) })));
  });

  it('rejects a title that is not a string', async () => {
    await assertFails(setDoc(articleRef(), validArticle({ title: 42 })));
  });
});

describe('articles: create rejects invalid thumbnails', () => {
  it('rejects a thumbnailURL hosted outside Firebase Storage', async () => {
    await assertFails(
      setDoc(articleRef(), validArticle({ thumbnailURL: 'https://example.com/photo.jpg' })),
    );
  });

  it('rejects a thumbnailURL pointing outside media/articles/', async () => {
    const outsideFolder = thumbnailUrlFor('photo.jpg').replace(
      'media%2Farticles%2F',
      'media%2Favatars%2F',
    );
    await assertFails(setDoc(articleRef(), validArticle({ thumbnailURL: outsideFolder })));
  });

  it('rejects a thumbnailURL without the alt=media download flag', async () => {
    const noAltMedia = thumbnailUrlFor('photo.jpg').replace('?alt=media&token=test-token', '');
    await assertFails(setDoc(articleRef(), validArticle({ thumbnailURL: noAltMedia })));
  });

  it('rejects a thumbnailPath outside media/articles/', async () => {
    await assertFails(
      setDoc(articleRef(), validArticle({ thumbnailPath: 'media/avatars/photo.jpg' })),
    );
  });

  it('rejects a thumbnailPath with a nested sub-folder', async () => {
    await assertFails(
      setDoc(articleRef(), validArticle({ thumbnailPath: 'media/articles/2026/photo.jpg' })),
    );
  });
});

describe('articles: create rejects forged timestamps', () => {
  it('rejects a client-supplied createdAt', async () => {
    const forged = validArticle({ createdAt: Timestamp.fromDate(new Date('2000-01-01')) });
    await assertFails(setDoc(articleRef(), forged));
  });

  it('rejects a client-supplied updatedAt', async () => {
    const forged = validArticle({ updatedAt: Timestamp.fromDate(new Date('2000-01-01')) });
    await assertFails(setDoc(articleRef(), forged));
  });

  it('rejects publishedAt that is not a timestamp', async () => {
    await assertFails(setDoc(articleRef(), validArticle({ publishedAt: '2026-09-15' })));
  });
});

describe('articles: update', () => {
  it('allows editing content when updatedAt is refreshed from the server', async () => {
    await seedArticle();
    await assertSucceeds(
      updateDoc(articleRef(), { content: 'Corrected body.', updatedAt: serverTimestamp() }),
    );
  });

  it('rejects an update that does not refresh updatedAt', async () => {
    await seedArticle();
    await assertFails(updateDoc(articleRef(), { content: 'Corrected body.' }));
  });

  it('rejects an update that changes createdAt', async () => {
    await seedArticle();
    await assertFails(
      updateDoc(articleRef(), {
        createdAt: Timestamp.fromDate(new Date('2030-01-01')),
        updatedAt: serverTimestamp(),
      }),
    );
  });

  it('rejects an update that breaks a schema constraint', async () => {
    await seedArticle();
    await assertFails(
      updateDoc(articleRef(), { title: stringOfLength(151), updatedAt: serverTimestamp() }),
    );
  });

  it('rejects an update that adds an unknown field', async () => {
    await seedArticle();
    await assertFails(updateDoc(articleRef(), { views: 1, updatedAt: serverTimestamp() }));
  });
});

describe('articles: delete', () => {
  it('allows deleting an article', async () => {
    await seedArticle();
    await assertSucceeds(deleteDoc(articleRef()));
  });
});

describe('other collections', () => {
  it('denies writes to collections that are not part of the schema', async () => {
    const db = testEnv.unauthenticatedContext().firestore();
    await assertFails(setDoc(doc(db, 'users', 'u1'), { name: 'Mallory' }));
  });

  it('denies reads from collections that are not part of the schema', async () => {
    const db = testEnv.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(db, 'users', 'u1')));
  });
});
