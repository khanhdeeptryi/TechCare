import * as functions from 'firebase-functions';
import { appGuideFlow } from './guideAgent';

// Export the Genkit flow as a callable Cloud Function without authentication
export const guideAgent = functions
  .runWith({
    enforceAppCheck: false, // Disable App Check requirement
  })
  .https.onCall(async (data, context) => {
  try {
    // Log for debugging
    console.log('guideAgent called with data:', data);
    console.log('Context auth:', context.auth);

    // Validate input
    if (!data.userQuestion || typeof data.userQuestion !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'The function must be called with a valid userQuestion string.'
      );
    }

    // Note: Authentication is optional - context.auth will be null if user is not authenticated
    // If you want to require authentication, uncomment this:
    // if (!context.auth) {
    //   throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    // }

    // Extract user question and conversation history
    const { userQuestion, conversationHistory = [] } = data;

    // Call the Genkit flow
    const result = await appGuideFlow({
      userQuestion,
      conversationHistory,
    });

    // Return the answer
    return {
      success: true,
      answer: result.answer,
    };
  } catch (error) {
    console.error('Error in guideAgent function:', error);
    
    // Return error response
    throw new functions.https.HttpsError(
      'internal',
      'An error occurred while processing your request.',
      error instanceof Error ? error.message : String(error)
    );
  }
});

// Optional: HTTP endpoint version for testing
export const guideAgentHttp = functions.https.onRequest(async (req, res) => {
  // Enable CORS
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  // Handle preflight
  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  // Only allow POST
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  try {
    const { userQuestion, conversationHistory = [] } = req.body;

    if (!userQuestion || typeof userQuestion !== 'string') {
      res.status(400).json({ 
        error: 'Invalid request. userQuestion is required.' 
      });
      return;
    }

    // Call the Genkit flow
    const result = await appGuideFlow({
      userQuestion,
      conversationHistory,
    });

    res.status(200).json({
      success: true,
      answer: result.answer,
    });
  } catch (error) {
    console.error('Error in guideAgentHttp:', error);
    res.status(500).json({
      success: false,
      error: 'An error occurred while processing your request.',
      details: error instanceof Error ? error.message : String(error),
    });
  }
});
