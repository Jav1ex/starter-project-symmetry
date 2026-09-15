// Callable Cloud Function that exposes the editorial assistant to the app.
// The Anthropic key lives in a Firebase secret; the app never sees it.

import Anthropic from '@anthropic-ai/sdk';
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { defineSecret } from 'firebase-functions/params';
import { AssistantError, assist } from './assist.js';

const anthropicApiKey = defineSecret('ANTHROPIC_API_KEY');

export const assistArticle = onCall(
  {
    region: 'us-central1',
    secrets: [anthropicApiKey],
    timeoutSeconds: 60,
    memory: '256MiB',
  },
  async (request) => {
    const client = new Anthropic({ apiKey: anthropicApiKey.value() });
    try {
      return await assist({ auth: request.auth, data: request.data }, client);
    } catch (error) {
      if (error instanceof AssistantError) throw new HttpsError(error.code, error.message);
      throw new HttpsError('internal', 'The editor hit an unexpected problem.');
    }
  },
);
