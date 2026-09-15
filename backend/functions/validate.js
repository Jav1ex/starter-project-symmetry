// Input validation for the editorial assistant. Mirrors the article limits
// enforced by firestore.rules so the assistant never sees more than a
// publishable article.

export const TASKS = ['suggest', 'brief', 'plain', 'translate'];
export const CATEGORIES = [
  'general',
  'business',
  'technology',
  'science',
  'health',
  'sports',
  'entertainment',
];
export const TITLE_MAX = 150;
export const CONTENT_MAX = 20000;
export const LANGUAGES = { es: 'Spanish', en: 'English', pt: 'Portuguese', fr: 'French' };

export class ValidationError extends Error {
  constructor(message) {
    super(message);
    this.name = 'ValidationError';
  }
}

/** Returns a clean request or throws ValidationError. */
export function validateRequest(data) {
  if (!data || typeof data !== 'object') throw new ValidationError('Missing request body.');

  const { task, title, content, language } = data;
  if (!TASKS.includes(task)) throw new ValidationError(`task must be one of ${TASKS.join(', ')}.`);

  const cleanTitle = typeof title === 'string' ? title.trim() : '';
  if (cleanTitle.length > TITLE_MAX) throw new ValidationError(`title cannot exceed ${TITLE_MAX} characters.`);

  const cleanContent = typeof content === 'string' ? content.trim() : '';
  if (cleanContent.length === 0) throw new ValidationError('content is required.');
  if (cleanContent.length > CONTENT_MAX) {
    throw new ValidationError(`content cannot exceed ${CONTENT_MAX} characters.`);
  }

  const cleanLanguage = task === 'translate' ? (language ?? 'es') : undefined;
  if (task === 'translate' && !LANGUAGES[cleanLanguage]) {
    throw new ValidationError(`language must be one of ${Object.keys(LANGUAGES).join(', ')}.`);
  }

  return { task, title: cleanTitle, content: cleanContent, language: cleanLanguage };
}
