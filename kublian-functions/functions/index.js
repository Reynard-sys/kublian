const functions = require('firebase-functions/v1');
const admin = require('firebase-admin');

const REGION = 'asia-southeast1';

admin.initializeApp({
    databaseURL: "https://kublian-default-rtdb.asia-southeast1.firebasedatabase.app"
});

const db = admin.firestore();
const rtdb = admin.database();

// ── FUNCTION 1: Delete messages when session closes ──
// Triggered when a session document is updated
exports.deleteMessagesOnSessionClose = functions.region(REGION).firestore
    .document('sessions/{sessionId}')
    .onUpdate(async (change, context) => {
        const before = change.before.data();
        const after = change.after.data();

        // Only trigger when status changes TO 'closed'
        if (before.status !== 'closed' && after.status === 'closed') {
            console.log(`Session ${context.params.sessionId} closed — deleting messages`);

            const messagesRef = db
                .collection('sessions')
                .doc(context.params.sessionId)
                .collection('messages');

            const snapshot = await messagesRef.get();

            if (snapshot.empty) {
                console.log('No messages to delete.');
                return null;
            }

            // Batch delete (max 500 per batch — fine for hackathon sessions)
            const batch = db.batch();
            snapshot.docs.forEach(doc => batch.delete(doc.ref));
            await batch.commit();

            console.log(`Deleted ${snapshot.size} messages from session ${context.params.sessionId}`);
        }

        return null;
    });


// ── FUNCTION 2: Sync escalation alert to Realtime Database ──
// When Button 1 fires (escalationLevel set to 1), write to RTDB for
// instant doctor dashboard alert
exports.syncEscalationAlert = functions.region(REGION).firestore
    .document('sessions/{sessionId}')
    .onUpdate(async (change, context) => {
        const before = change.before.data();
        const after = change.after.data();

        const sessionId = context.params.sessionId;

        // Button 1 pressed — escalation triggered
        if (before.escalationLevel === 0 && after.escalationLevel === 1) {
            await rtdb.ref(`alerts/${sessionId}`).set({
                escalationLevel: 1,
                userAlias: after.userAlias || 'Anonymous',
                volunteerId: after.volunteerId,
                timestamp: Date.now(),
                resolved: false
            });
            console.log(`Alert written to RTDB for session ${sessionId}`);
        }

        // Alert resolved — a doctor joined
        if (before.escalationLevel === 1 && after.escalationLevel === 0) {
            await rtdb.ref(`alerts/${sessionId}`).update({ resolved: true });
            console.log(`Alert resolved for session ${sessionId}`);
        }

        return null;
    });


// ── FUNCTION 3: Delete all user data on account deletion ──
// Full data purge when a user deletes their account
exports.deleteUserData = functions.region(REGION).auth.user().onDelete(async (user) => {
    const uid = user.uid;
    console.log(`Deleting all data for user ${uid}`);

    const batch = db.batch();

    // Delete user document
    batch.delete(db.collection('users').doc(uid));

    // Delete journal entries
    const journal = await db.collection('users').doc(uid)
        .collection('journal').get();
    journal.docs.forEach(doc => batch.delete(doc.ref));

    // Delete summaries
    const summaries = await db.collection('summaries')
        .where('userId', '==', uid).get();
    summaries.docs.forEach(doc => batch.delete(doc.ref));

    // Delete session records (messages already gone via Function 1)
    const sessions = await db.collection('sessions')
        .where('userId', '==', uid).get();
    sessions.docs.forEach(doc => batch.delete(doc.ref));

    await batch.commit();
    console.log(`All data deleted for user ${uid}`);
});