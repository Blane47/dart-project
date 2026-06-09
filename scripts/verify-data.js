// Read-only verification: dumps the users collection + each user's transactions
// so we can confirm the app actually wrote to Firebase. Uses the same
// service-account.json as the seeder.
//
//   cd scripts && node verify-data.js
const admin = require("firebase-admin");

admin.initializeApp({
  credential: admin.credential.cert(require("./service-account.json")),
});

const db = admin.firestore();

(async () => {
  const users = await db.collection("users").get();
  console.log(`users: ${users.size} doc(s)`);
  for (const doc of users.docs) {
    const d = doc.data();
    console.log(
      `\n  uid=${doc.id}\n    email=${d.email}\n    displayName=${d.displayName}\n    balance=${d.balance}`,
    );
    const txs = await doc.ref
      .collection("transactions")
      .orderBy("createdAt", "desc")
      .get();
    console.log(`    transactions: ${txs.size}`);
    for (const t of txs.docs) {
      const td = t.data();
      console.log(
        `      - ${td.type} ${td.amount} (balanceAfter=${td.balanceAfter}) "${td.description}"`,
      );
    }
  }

  const quiz = await db.collection("quiz_questions").get();
  console.log(`\nquiz_questions: ${quiz.size} doc(s)`);
  process.exit(0);
})();
