# Implementation Handoff Prompt

Copy everything below the `---` into a **new Claude Code session** opened with this repo as the working directory. The `agave` and `design-motion-principles` skills must be installed at `~/.claude/skills/` (already done if you're on Blane47's machine).

---

I'm building a Flutter mobile banking app for a school project (team of 3). The repo is scaffolded with `flutter create` and feature folders are stubbed. Now I need you to build it out.

**Use the `agave` skill for every UI decision and `design-motion-principles` for every animation.** This is non-negotiable — the lecturer cares about working features, but a polished look will lift the grade.

## Visual direction (locked in)

**Modern fintech — think Revolut, Monzo, Cash App.**
- Dark mode primary (`#0A0A0F` background, `#1A1A24` surface)
- Vibrant accent: electric purple `#7C3AED` with gradient pairs (`#7C3AED → #EC4899`)
- Typography: Inter or SF Pro, bold weights for numbers
- Generous spacing (8px grid)
- Atmospheric gradient blooms behind the balance card
- Mixed-size metrics (large balance number, small currency code)
- Fluid micro-interactions (every tap responds, every transition feels intentional)
- Glass-blur cards on the dashboard

## Tech stack (locked in)

- Flutter 3.41+ with Dart 3.11+
- **Riverpod** for state management
- **GoRouter** for navigation
- **Firebase Auth** for sign-up/sign-in/sign-out/password reset
- **Cloud Firestore** for balance, transactions, quiz questions
- Material 3 base, customized by agave

## Features required (from lecturer)

1. Sign up, sign in, sign out
2. Good UI
3. Balance visible with hide/show toggle
4. Firebase for auth and password recovery
5. Simulated deposit screen
6. Simple quiz game with fun facts about the banking app

## Team split (so you don't trample others' work)

- **Dev A** — `lib/features/auth/` + Firebase service setup
- **Dev B** — `lib/features/dashboard/`, `lib/features/deposit/`, `lib/features/transactions/`
- **Dev C** — `lib/features/quiz/`, `lib/features/settings/`, `lib/features/onboarding/`

Tell me which dev I am at the start of every session and I'll only touch those folders + `lib/shared/`.

## What to build first (recommended order)

1. **Theme + shared widgets** (`lib/shared/theme/`, `lib/shared/widgets/`) — defines `AppColors`, `AppTextStyles`, reusable `PrimaryButton`, `GlassCard`, `BalanceText` — agave skill informs every decision
2. **Firebase setup** (`lib/shared/services/firebase_auth_service.dart`, `firestore_service.dart`) — wrappers that the auth UI calls
3. **Auth flow** (Dev A) — sign up, sign in, forgot password screens
4. **GoRouter setup** (`lib/main.dart`) — auth-protected routes
5. **Dashboard** (Dev B) — balance card with hide/show, quick actions, recent transactions list
6. **Deposit** (Dev B) — form with success animation (design-motion-principles makes this feel good)
7. **Transactions** (Dev B) — filterable list
8. **Quiz** (Dev C) — question card, choice buttons, score reveal, fun-fact dialog
9. **Settings + Onboarding** (Dev C) — sign out, swipeable intro

## Constraints

- **Never commit** `google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart` with real values — use `.gitignore`
- **Always run `flutter analyze`** before committing — no analyzer warnings
- **Always run `dart format .`** before committing
- Use **`const` constructors** wherever possible (Flutter performance)
- All UI text strings live in `lib/shared/strings.dart` (easier to proofread)

## What "done" looks like (per feature)

A feature is shippable when:
1. It works end-to-end against real Firebase (not mocks)
2. `flutter analyze` passes with zero warnings
3. The UI passes the **agave 7-question Senior Designer Filter** in `~/.claude/skills/agave/SKILL.md`
4. Any motion passes the **design-motion-principles audit**
5. It looks correct on both a small Android emulator (Pixel 4a) and a tall iOS simulator (iPhone 15 Pro)

## First thing to do

Read this whole document, then **start with the theme and shared widgets** (step 1). Show me the design before building features on top of it.
