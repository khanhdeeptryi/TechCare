# TechCare Smart User Guide Agent

## Overview

This Cloud Function implements a Smart User Guide Agent using Firebase Genkit and Google's Gemini 1.5 Flash model. The agent helps users navigate and understand how to use the TechCare mobile application by providing step-by-step guidance based on the actual app implementation.

## Architecture

- **Framework**: Firebase Cloud Functions (Node.js 18)
- **AI Framework**: Firebase Genkit
- **AI Model**: Gemini 1.5 Flash (via Google AI)
- **Language**: TypeScript
- **Deployment**: Firebase Cloud Functions

## Detected App Flows

Based on deep analysis of the TechCare Flutter application, the following user flows have been identified and documented in the system prompt:

### 1. Authentication Flows
- **Sign Up**: Email/password registration with automatic login
- **Log In**: Email/password authentication with role-based routing
- **Password Reset**: Email-based password recovery

### 2. Booking Flows
- **Doctor Appointment Booking**:
  - Browse doctors with filters (location: 5 districts, specialty: 5 types)
  - Select date via calendar
  - Choose time slot (morning: 08:00-10:00, afternoon: 17:30-19:30, 10-min intervals)
  - Select patient profile
  - Confirm booking → Receive booking code (YMA + timestamp)
  
- **Clinic Appointment Booking**:
  - Browse clinics with filters
  - Select date and time
  - Confirm patient profile
  - Complete booking
  
- **Hospital Appointment Booking**:
  - Browse hospitals
  - Filter by location/department
  - Select date and time
  - Complete booking

### 3. Appointment Management
- **View Appointments**: List all appointments with status tracking
- **View Appointment Details**: Complete booking information
- **View Medical Records**: Diagnosis, prescriptions, test results

### 4. Communication Features
- **Chat with Doctor**: 
  - After booking completion
  - From home screen
  - From chat tab (conversation list)
  
- **Video Call with Doctor**:
  - Browse available doctors
  - Initiate video consultation

### 5. Health Profile Management
- **Update Personal Information**: Name, phone, DOB, address, emergency contact
- **Manage Health Profile**: Medical history, allergies, medications, blood type, vitals

### 6. Additional Services
- **Vaccination Scheduling**: Browse and book vaccination services
- **Lab Test Scheduling**: Browse and book lab tests

### 7. Account Features
- Update personal information
- View favorites (under development)
- Terms and conditions (under development)
- Community features (under development)
- Share app
- Customer support
- Logout

### 8. Search Functionality
- Search doctors by name
- Search by symptoms
- Search by specialty
- Search clinics and hospitals

## Key Technical Details Captured

- **User Roles**: Patient, Doctor, Clinic, Hospital
- **Navigation**: 5-tab bottom navigation (Home, Appointments, Medical Assistant, Chat, Account)
- **Booking Codes**: Auto-generated format YMA + timestamp
- **Time Slots**: 10-minute intervals to prevent overbooking
- **Conflict Prevention**: Real-time slot availability checking via Firestore
- **Data Storage**: Firebase Firestore with real-time snapshots
- **Authentication**: Firebase Authentication
- **Language**: Vietnamese (vi_VN) as default

## Files Structure

```
functions/
├── src/
│   ├── index.ts          # Cloud Function exports (callable & HTTP)
│   └── guideAgent.ts     # Genkit flow with system instructions
├── package.json          # Dependencies
├── tsconfig.json         # TypeScript configuration
├── .gitignore           # Git ignore rules
└── README.md            # This file
```

## Installation

1. Navigate to the functions directory:
```bash
cd functions
```

2. Install dependencies:
```bash
npm install
```

3. Set up Google AI API key (for Gemini):
```bash
firebase functions:config:set googleai.apikey="YOUR_API_KEY"
```

Or use environment variables in `.env`:
```
GOOGLE_AI_API_KEY=your_api_key_here
```

## Development

### Build TypeScript
```bash
npm run build
```

### Watch mode (auto-rebuild)
```bash
npm run build:watch
```

### Test locally with Firebase Emulator
```bash
npm run serve
```

## Deployment

Deploy to Firebase:
```bash
npm run deploy
```

Or deploy from project root:
```bash
firebase deploy --only functions
```

## Usage

### From Flutter App (Callable Function)

```dart
import 'package:cloud_functions/cloud_functions.dart';

Future<String> askGuideAgent(String question, List<Map<String, String>> history) async {
  try {
    final callable = FirebaseFunctions.instance.httpsCallable('guideAgent');
    final result = await callable.call({
      'userQuestion': question,
      'conversationHistory': history,
    });
    
    return result.data['answer'];
  } catch (e) {
    print('Error calling guide agent: $e');
    rethrow;
  }
}
```

### HTTP Endpoint (for testing)

```bash
curl -X POST https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/guideAgentHttp \
  -H "Content-Type: application/json" \
  -d '{
    "userQuestion": "How do I book a doctor appointment?",
    "conversationHistory": []
  }'
```

### Request Format

```json
{
  "userQuestion": "How do I update my profile?",
  "conversationHistory": [
    {
      "role": "user",
      "content": "Previous question"
    },
    {
      "role": "assistant",
      "content": "Previous answer"
    }
  ]
}
```

### Response Format

```json
{
  "success": true,
  "answer": "To update your profile:\n1. Tap the 'Tài khoản' (Account) tab\n2. Tap 'Hồ sơ y tế (Thông tin cá nhân)'..."
}
```

## Integration with Flutter App

The guide agent should be integrated into the "Trợ lý y khoa" (Medical Assistant) tab in the patient homepage:

1. Create a chat interface in the tab (index 2)
2. Call the `guideAgent` Cloud Function with user questions
3. Display responses in a conversational UI
4. Maintain conversation history for context

Example implementation location:
- File: `lib/homepage.dart`
- Tab index: 2 (currently shows placeholder text)

## System Prompt Features

The system instruction includes:

✅ **Comprehensive Coverage**: All major app flows documented
✅ **Step-by-Step Guidance**: Clear, numbered instructions
✅ **Vietnamese Terms**: Uses actual UI text from the app
✅ **Context Boundaries**: Explicitly limited to TechCare app features
✅ **User-Friendly**: Friendly tone, admits limitations
✅ **No Medical Advice**: Focuses only on app navigation

## Model Configuration

- **Model**: Gemini 1.5 Flash
- **Temperature**: 0.7 (balanced creativity and consistency)
- **Max Output Tokens**: 1024
- **Top P**: 0.9

## Error Handling

The function includes:
- Input validation
- Proper error messages
- Logging for debugging
- Graceful error responses

## Security Considerations

- Input validation on all requests
- CORS enabled for HTTP endpoint
- Firebase Authentication can be added for additional security
- Rate limiting recommended for production

## Future Enhancements

- Add Firebase Authentication check
- Implement rate limiting
- Add analytics/logging
- Support for multiple languages
- Integration with app usage analytics
- Personalized responses based on user history

## Support

For issues or questions about the guide agent implementation, refer to:
- Firebase Genkit documentation: https://firebase.google.com/docs/genkit
- Google AI documentation: https://ai.google.dev/

## License

This implementation is part of the TechCare project.
