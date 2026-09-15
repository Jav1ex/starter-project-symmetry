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
  AUTHOR_UID,
  OTHER_UID,
  createTestEnvironment,
  stringOfLength,
  thumbnailUrlFor,
  validArticle,
  without,
} from './helpers.js';

let testEnv;

/** The article document as seen by the signed-in author. */
function articleRef(id = 'article-1') {
  return doc(testEnv.authenticatedContext(AUTHOR_UID).firestore(), 'articles', id);
}

function asOther(id = 'article-1') {
  return doc(testEnv.authenticatedContext(OTHER_UID).firestore(), 'articles', id);
}

function asAnonymous(id = 'article-1') {
  return doc(testEnv.unauthenticatedContext().firestore(), 'articles', id);
}

/** Writes a valid article bypassing rules, so update/delete tests start from real data. */
async function seedArticle(id = 'article-1', overrides = {}) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'articles', id), {
      ...validArticle(overrides),
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
  it('allows anyone, signed in or not, to read a single article', async () => {
    await seedArticle();
    await assertSucceeds(getDoc(asAnonymous()));
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

  it('accepts an article without a summary', async () => {
    await assertSucceeds(setDoc(articleRef(), validArticle({ description: null })));
  });

  it('accepts an article without a thumbnail when both fields are null', async () => {
    await assertSucceeds(
      setDoc(articleRef(), validArticle({ thumbnailURL: null, thumbnailPath: null })),
    );
  });

  for (const category of ['business', 'technology', 'science', 'health', 'sports', 'entertainment']) {
    it(`accepts the "${category}" category`, async () => {
      await assertSucceeds(setDoc(articleRef(), validArticle({ category })));
    });
  }
});

describe('articles: create requires the signed-in author', () => {
  it('rejects a create without a signed-in user', async () => {
    await assertFails(setDoc(asAnonymous(), validArticle()));
  });

  it('rejects an authorId that is not the caller', async () => {
    await assertFails(setDoc(articleRef(), validArticle({ authorId: OTHER_UID })));
  });

  it('rejects an empty authorId', async () => {
    await assertFails(setDoc(articleRef(), validArticle({ authorId: '' })));
  });
});

describe('articles: create rejects malformed shape', () => {
  for (const field of [
    'title',
    'description',
    'content',
    'author',
    'authorId',
    'category',
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

  it('rejects a category outside the list', async () => {
    await assertFails(setDoc(articleRef(), validArticle({ category: 'gossip' })));
  });
});

describe('articles: create rejects invalid strings', () => {
  it('rejects an empty title', async () => {
    await assertFails(setDoc(articleRef(), validArticle({ title: '' })));
  });

  it('rejects a title longer than 150 characters', async () => {
    await assertFails(setDoc(articleRef(), validArticle({ title: stringOfLength(151) })));
  });

  it('rejects an empty description (use null to omit it)', async () => {
    await assertFails(setDoc(articleRef(), validArticle({ description: '' })));
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

  it('rejects a URL without a path, and a path without a URL', async () => {
    await assertFails(setDoc(articleRef(), validArticle({ thumbnailPath: null })));
    await assertFails(setDoc(articleRef(), validArticle({ thumbnailURL: null })));
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
  it('allows the author to edit content when updatedAt is refreshed from the server', async () => {
    await seedArticle();
    await assertSucceeds(
      updateDoc(articleRef(), { content: 'Corrected body.', updatedAt: serverTimestamp() }),
    );
  });

  it('allows the author to drop the thumbnail', async () => {
    await seedArticle();
    await assertSucceeds(
      updateDoc(articleRef(), {
        thumbnailURL: null,
        thumbnailPath: null,
        updatedAt: serverTimestamp(),
      }),
    );
  });

  it('rejects an update by somebody who is not the author', async () => {
    await seedArticle();
    await assertFails(
      updateDoc(asOther(), { content: 'Vandalised.', updatedAt: serverTimestamp() }),
    );
  });

  it('rejects an update without a signed-in user', async () => {
    await seedArticle();
    await assertFails(
      updateDoc(asAnonymous(), { content: 'Vandalised.', updatedAt: serverTimestamp() }),
    );
  });

  it('rejects handing the article to another author', async () => {
    await seedArticle();
    await assertFails(
      updateDoc(articleRef(), { authorId: OTHER_UID, updatedAt: serverTimestamp() }),
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
  it('allows the author to delete their article', async () => {
    await seedArticle();
    await assertSucceeds(deleteDoc(articleRef()));
  });

  it('rejects a delete by somebody else or by an anonymous caller', async () => {
    await seedArticle();
    await assertFails(deleteDoc(asOther()));
    await assertFails(deleteDoc(asAnonymous()));
  });
});

describe('other collections', () => {
  it('denies writes to collections that are not part of the schema', async () => {
    const db = testEnv.authenticatedContext(AUTHOR_UID).firestore();
    await assertFails(setDoc(doc(db, 'users', 'u1'), { name: 'Mallory' }));
  });

  it('denies reads from collections that are not part of the schema', async () => {
    const db = testEnv.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(db, 'users', 'u1')));
  });
});
