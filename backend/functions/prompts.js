// Prompt building and answer parsing for the editorial assistant. Pure
// functions: no network, fully unit-tested.

import { CATEGORIES, LANGUAGES, TITLE_MAX } from './validate.js';

const EDITOR_VOICE =
  'You are the desk editor of a small, serious newspaper. You write in plain, ' +
  'concrete English, never sensational, never invent facts that are not in the ' +
  'article. Answer with JSON only, no prose, no code fences.';

/** System + user prompt for a task. */
export function buildPrompt({ task, title, content, language }) {
  const article = title ? `Title: ${title}\n\n${content}` : content;

  switch (task) {
    case 'suggest':
      return {
        system: EDITOR_VOICE,
        user:
          `A journalist drafted this article:\n\n${article}\n\n` +
          `Return JSON with exactly these keys:\n` +
          `"headlines": three alternative headlines, each under ${TITLE_MAX} characters, ` +
          `factual, no clickbait;\n` +
          `"summary": one or two sentences (under 300 characters) that a reader sees before opening ` +
          `the article;\n` +
          `"category": the single best fit from ${JSON.stringify(CATEGORIES)}.`,
      };
    case 'brief':
      return {
        system: EDITOR_VOICE,
        user:
          `Article:\n\n${article}\n\n` +
          `Return JSON {"bullets": [...]} with exactly three bullets. Each bullet is one short ` +
          `sentence stating a fact from the article. Together they let someone skip the article.`,
      };
    case 'plain':
      return {
        system: EDITOR_VOICE,
        user:
          `Article:\n\n${article}\n\n` +
          `Rewrite the whole article for a reader who is 90 years old: short sentences, everyday ` +
          `words, one idea per sentence, keep every fact and name, keep the same language as the ` +
          `article, keep paragraphs. Return JSON {"text": "..."}.`,
      };
    case 'translate':
      return {
        system: EDITOR_VOICE,
        user:
          `Article:\n\n${article}\n\n` +
          `Translate the whole article into ${LANGUAGES[language]}. Keep names, numbers and ` +
          `paragraph breaks; do not summarise. Return JSON {"text": "..."}.`,
      };
    default:
      throw new Error(`Unknown task ${task}`);
  }
}

/** Extracts the JSON object from a model answer, tolerating code fences. */
export function parseAnswer(task, text) {
  const trimmed = String(text ?? '').trim();
  const fenced = trimmed.match(/```(?:json)?\s*([\s\S]*?)```/i);
  const candidate = fenced ? fenced[1] : trimmed;
  const start = candidate.indexOf('{');
  const end = candidate.lastIndexOf('}');
  if (start < 0 || end < start) throw new Error('The model did not answer with JSON.');

  const parsed = JSON.parse(candidate.slice(start, end + 1));
  return normalise(task, parsed);
}

function normalise(task, parsed) {
  switch (task) {
    case 'suggest': {
      const headlines = asStringList(parsed.headlines).slice(0, 3).map((h) => h.slice(0, TITLE_MAX));
      if (headlines.length === 0) throw new Error('No headlines in the answer.');
      const category = CATEGORIES.includes(parsed.category) ? parsed.category : 'general';
      return { headlines, summary: asString(parsed.summary).slice(0, 300), category };
    }
    case 'brief': {
      const bullets = asStringList(parsed.bullets).slice(0, 3);
      if (bullets.length === 0) throw new Error('No bullets in the answer.');
      return { bullets };
    }
    case 'plain':
    case 'translate': {
      const text = asString(parsed.text);
      if (!text) throw new Error('No text in the answer.');
      return { text };
    }
    default:
      throw new Error(`Unknown task ${task}`);
  }
}

function asString(value) {
  return typeof value === 'string' ? value.trim() : '';
}

function asStringList(value) {
  return Array.isArray(value) ? value.map(asString).filter(Boolean) : [];
}
