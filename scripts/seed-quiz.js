// One-time quiz seeder. Reads docs/quiz-seed.json and writes each question to
// the `quiz_questions` collection using the Firebase Admin SDK (which bypasses
// security rules).
//
// Setup:
//   1. Firebase console -> Project Settings -> Service Accounts ->
//      "Generate new private key". Save it as scripts/service-account.json
//      (already gitignored — never commit it).
//   2. From the repo root:  cd scripts && npm install && node seed-quiz.js
const admin = require("firebase-admin");
const questions = require("../docs/quiz-seed.json");

admin.initializeApp({
  credential: admin.credential.cert(require("./service-account.json")),
});

const db = admin.firestore();

(async () => {
  // Skip if the collection is already populated, so re-running is safe.
  const existing = await db.collection("quiz_questions").limit(1).get();
  if (!existing.empty) {
    console.log("quiz_questions already has data — skipping seed.");
    process.exit(0);
  }

  for (const q of questions) {
    await db.collection("quiz_questions").add(q);
    console.log("Added:", q.question);
  }
  console.log(`Done — ${questions.length} questions seeded.`);
  process.exit(0);
})();
