# Firebase Setup

One developer (likely Dev A) does this once, then shares the config files with the rest of the team via a secure channel (Discord DM, WhatsApp, etc.) — **never** commit the config files to git.

## 1. Create the Firebase project

1. Go to <https://console.firebase.google.com> → **Add project**
2. Name: `dart-project-bank` (or similar)
3. Disable Google Analytics (not needed for this project)
4. Create

## 2. Enable services

### Authentication
- Sidebar → **Authentication → Get started**
- **Sign-in method** tab → enable **Email/Password** (the first toggle, leave Email link off)
- Save

### Cloud Firestore
- Sidebar → **Firestore Database → Create database**
- Start in **production mode**
- Pick the region closest to your team
- Once created, go to **Rules** and paste:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users: only the owner can read/write their own doc
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;

      // Transactions subcollection: only the owner
      match /transactions/{txId} {
        allow read, write: if request.auth != null && request.auth.uid == uid;
      }
    }

    // Quiz questions: anyone signed in can read; nobody writes from the client
    match /quiz_questions/{qId} {
      allow read: if request.auth != null;
      allow write: if false;
    }
  }
}
```

- Publish

## 3. Add the apps

### Android
1. Project settings → **Add app → Android**
2. Package name: `com.blane47.dart_project`
3. Download `google-services.json` → place in `android/app/google-services.json`
4. **Do NOT commit it.** It's already in `.gitignore`.

### iOS
1. Project settings → **Add app → iOS**
2. Bundle ID: `com.blane47.dartProject`
3. Download `GoogleService-Info.plist` → place in `ios/Runner/GoogleService-Info.plist`
4. **Do NOT commit it.**

## 4. Install the Flutter packages

```bash
flutter pub add firebase_core firebase_auth cloud_firestore
flutter pub add flutter_riverpod go_router
cd ios && pod install && cd ..
```

## 5. Initialize Firebase in the app

Use FlutterFire CLI for the easy path:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=dart-project-bank
```

This generates `lib/firebase_options.dart` — **add it to `.gitignore`** because it contains your Firebase API keys.

Then in `lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: DartProjectApp()));
}
```

## 6. Seed the quiz questions (one-time)

In the Firebase console → Firestore → create the `quiz_questions` collection and add documents with this shape:

```json
{
  "question": "What's the safest way to share your bank account number?",
  "choices": ["Email", "Text message", "Through the bank's app", "Social media DM"],
  "correctIndex": 2,
  "funFact": "Most banks never ask for your password — anyone who does is a scammer."
}
```

Add 10–15 questions to start. The quiz UI picks 5 at random per game.

## 7. Share config

DM the team:
- `google-services.json` (for Android)
- `GoogleService-Info.plist` (for iOS)
- `lib/firebase_options.dart`

Each dev drops these into their local checkout and they're good to go.
