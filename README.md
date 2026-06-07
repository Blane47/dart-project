# Dart Project — Mobile Banking App

A Flutter mobile banking app simulating the basic operations of a real bank, built for a school project by a team of 3.

> **Visual direction:** Modern fintech (Revolut / Monzo / Cash App). Dark mode primary, vibrant accent color, bold typography, fluid micro-interactions.
> **Grading priority:** All features must work end-to-end.

---

## Features

- **Auth** — sign up, sign in, sign out, password reset (Firebase)
- **Dashboard** — visible balance with hide/show toggle, quick actions, recent transactions
- **Deposit** — simulated deposit screen, success animation
- **Transactions** — history list with date filters
- **Quiz** — multiple-choice fun-facts game about the banking app, with score tracking
- **Settings** — edit profile, biometric toggle (optional), sign out
- **Onboarding** — 2–3 swipeable intro cards on first launch

## Tech stack

| Layer | Choice |
|---|---|
| Framework | Flutter 3.41+ (Dart 3.11+) |
| State management | Riverpod |
| Navigation | GoRouter |
| Auth | Firebase Auth |
| Database | Cloud Firestore |
| Theme | Material 3, dark mode primary |
| Lint | `package:flutter_lints` |

## Screens (MVP)

1. Splash / Onboarding (3 cards)
2. Sign Up
3. Sign In
4. Forgot Password (Firebase email reset)
5. Home / Dashboard (balance card with hide/show, quick actions, recent tx)
6. Deposit (amount + source, success animation)
7. Transactions (filterable list)
8. Quiz (multi-choice questions, fun-fact reveal, score)
9. Profile / Settings

---

## Team

| Dev | Owns |
|---|---|
| **Dev A** | Auth flow (sign up, sign in, forgot password) + Firebase setup |
| **Dev B** | Home + Deposit + Transactions |
| **Dev C** | Quiz + Settings + Onboarding |

### Workflow
- Each dev works on a branch: `feature/auth`, `feature/dashboard`, `feature/quiz`, etc.
- PRs to `main` require **one reviewer**
- Shared components go in `lib/shared/widgets/`
- Shared theme/colors in `lib/shared/theme/`
- Firebase service wrappers in `lib/shared/services/`

---

## Project structure

```
lib/
├── main.dart
├── features/
│   ├── auth/            ← Dev A
│   ├── dashboard/       ← Dev B
│   ├── deposit/         ← Dev B
│   ├── transactions/    ← Dev B
│   ├── quiz/            ← Dev C
│   ├── settings/        ← Dev C
│   └── onboarding/      ← Dev C
└── shared/
    ├── widgets/         ← reusable UI (BalanceCard, ActionButton, etc.)
    ├── theme/           ← AppColors, AppTextStyles
    ├── services/        ← FirebaseAuthService, FirestoreService
    └── models/          ← User, Transaction, QuizQuestion
```

---

## Setup (each developer)

```bash
# 1. Clone
git clone https://github.com/Blane47/dart-project.git
cd dart-project

# 2. Install Flutter dependencies
flutter pub get

# 3. Add Firebase config (see docs/FIREBASE_SETUP.md)
# - download google-services.json → android/app/
# - download GoogleService-Info.plist → ios/Runner/

# 4. Run
flutter run
```

---

## Firebase setup

A shared Firebase project (`dart-project-bank`) is used. One developer creates it and shares config files via Discord/WhatsApp — **never commit `google-services.json` or `GoogleService-Info.plist` to git** (both are in `.gitignore`).

Services enabled:
- **Authentication** — Email/Password provider
- **Cloud Firestore** — collections: `users`, `transactions`, `quiz_questions`

Firestore data model:
```
users/{uid}
  - email: string
  - fullName: string
  - balance: number
  - createdAt: timestamp

users/{uid}/transactions/{txId}
  - type: "deposit" | "withdrawal"
  - amount: number
  - date: timestamp
  - description: string

quiz_questions/{qId}
  - question: string
  - choices: [string, string, string, string]
  - correctIndex: number
  - funFact: string
```

---

## License

Educational use only.
