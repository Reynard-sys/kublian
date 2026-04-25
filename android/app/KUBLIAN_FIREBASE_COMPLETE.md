# 🔥 Kublian — Firebase Complete Setup Status
*Handoff document for agentic Claude / team reference*
*Last updated: April 25, 2026*

---

## Project Info

| Field | Value |
|---|---|
| App Name | Kublian |
| Firebase Project ID | `kublian` |
| Team | ResistHounds |
| Hackathon | InnOlympics 2026 |
| Track | Health — Philippines |
| Flutter Package Name | `com.resisthounds.kublian` |
| Firestore Region | `asia-southeast1` (Singapore) |
| Functions Region | `asia-southeast1` |

---

## Architecture Overview

Kublian is a three-tier anonymous peer mental health support app.

```
User (fully anonymous to everyone)
  → matched by Gemini AI to →
Volunteer (anonymous to users, visible to other volunteers + doctors)
  → supervised by →
Professional Doctor (sees everything, anonymized user data only)
```

- **Doctor dashboard** is Figma prototype only — not built in Flutter
- **Volunteer interface** is Figma prototype only — not built in Flutter
- **MVP Flutter build** covers the User side only

---

## ✅ Firebase Setup — All Complete

### 1. Project & Apps
- [x] Firebase project created: `kublian`
- [x] Android app registered: `com.resisthounds.kublian`
- [x] `google-services.json` downloaded and placed in `android/app/`
- [x] SHA-1 debug fingerprint added (via keytool)
- [x] Upgraded to **Blaze plan** (linked to GCP credits — no direct billing)
- [x] Container image cleanup policy: **1 day**

### 2. Authentication
- [x] **Google Sign-In** enabled
- [x] **Anonymous Sign-In** enabled (fallback)

### 3. Firestore Database
- [x] Database created in `asia-southeast1`
- [x] Mode: Production (rules-controlled)
- [x] Edition: Standard

### 4. Firestore Indexes
- [x] `sessions` → `userId` ASC, `startedAt` DESC — **Enabled**
- [x] `sessions` → `status` ASC, `startedAt` DESC — **Enabled**
- [x] `summaries` → `userId` ASC, `createdAt` DESC — **Enabled**
- [x] `journal/createdAt` — handled by automatic single-field index (not manually created)

### 5. Firestore Security Rules
- [x] Rules written and published

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;

      match /journal/{entryId} {
        allow read, write: if request.auth != null
                           && request.auth.uid == userId;
      }
    }

    match /sessions/{sessionId} {
      allow read: if request.auth != null
                  && (request.auth.uid == resource.data.userId
                      || isProfessional());
      allow create: if request.auth != null
                    && request.auth.uid == request.resource.data.userId;
      allow update: if request.auth != null
                    && request.auth.uid == resource.data.userId;

      match /messages/{messageId} {
        allow read, write: if request.auth != null
                           && request.auth.uid ==
                              get(/databases/$(database)/documents/sessions/$(sessionId)).data.userId;
      }
    }

    match /summaries/{summaryId} {
      allow read: if request.auth != null
                  && (request.auth.uid == resource.data.userId
                      || isProfessional());
      allow create, update: if request.auth != null
                            && request.auth.uid == resource.data.userId;
    }

    match /volunteers/{volunteerId} {
      allow read: if request.auth != null;
      allow write: if isProfessional();
    }

    match /hospitals/{cityId} {
      allow read: if true;
      allow write: if false;
    }

    match /professionals/{profId} {
      allow read: if isProfessional();
      allow write: if false;
    }

    function isProfessional() {
      return request.auth != null
             && exists(/databases/$(database)/documents/professionals/$(request.auth.uid));
    }
  }
}
```

### 6. Cloud Functions
- [x] Firebase CLI installed
- [x] Functions project initialized (`kublian-functions/`)
- [x] Deployed to `asia-southeast1`
- [x] Container cleanup: 1 day

**Deployed functions:**

#### `deleteMessagesOnSessionClose`
Triggers when a session document's `status` field changes to `closed`.
Batch-deletes the entire `messages` subcollection for that session.
This is what makes chat ephemeral.

#### `syncEscalationAlert` *(deployed but inactive)*
Originally written to sync Button 1 alerts to Realtime Database for the
doctor dashboard. Doctor dashboard is Figma-only so this function will
never be triggered. Safe to leave deployed — causes no side effects.

#### `deleteUserData`
Triggers on Firebase Auth user deletion. Purges all associated Firestore
data: user document, journal entries, summaries, and session records.

**Current `functions/index.js`:**

```javascript
const functions = require('firebase-functions/v1');
const admin = require('firebase-admin');

const REGION = 'asia-southeast1';

admin.initializeApp({
  databaseURL: "https://kublian-default-rtdb.asia-southeast1.firebasedatabase.app"
});

const db = admin.firestore();
const rtdb = admin.database();

exports.deleteMessagesOnSessionClose = functions.region(REGION).firestore
  .document('sessions/{sessionId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before.status !== 'closed' && after.status === 'closed') {
      const messagesRef = db
        .collection('sessions')
        .doc(context.params.sessionId)
        .collection('messages');

      const snapshot = await messagesRef.get();
      if (snapshot.empty) return null;

      const batch = db.batch();
      snapshot.docs.forEach(doc => batch.delete(doc.ref));
      await batch.commit();
    }
    return null;
  });

exports.syncEscalationAlert = functions.region(REGION).firestore
  .document('sessions/{sessionId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const sessionId = context.params.sessionId;

    if (before.escalationLevel === 0 && after.escalationLevel === 1) {
      await rtdb.ref(`alerts/${sessionId}`).set({
        escalationLevel: 1,
        userAlias: after.userAlias || 'Anonymous',
        volunteerId: after.volunteerId,
        timestamp: Date.now(),
        resolved: false
      });
    }

    if (before.escalationLevel === 1 && after.escalationLevel === 0) {
      await rtdb.ref(`alerts/${sessionId}`).update({ resolved: true });
    }
    return null;
  });

exports.deleteUserData = functions.region(REGION).auth.user().onDelete(async (user) => {
  const uid = user.uid;
  const batch = db.batch();

  batch.delete(db.collection('users').doc(uid));

  const journal = await db.collection('users').doc(uid).collection('journal').get();
  journal.docs.forEach(doc => batch.delete(doc.ref));

  const summaries = await db.collection('summaries').where('userId', '==', uid).get();
  summaries.docs.forEach(doc => batch.delete(doc.ref));

  const sessions = await db.collection('sessions').where('userId', '==', uid).get();
  sessions.docs.forEach(doc => batch.delete(doc.ref));

  await batch.commit();
});
```

### 7. Realtime Database
- [x] **Skipped entirely** — doctor dashboard is Figma prototype only.
  No RTDB rules, no RTDB collections, no RTDB Flutter integration needed.

### 8. Flutter Connection
- [x] FlutterFire CLI installed
- [x] `flutterfire configure --project=kublian` run
- [x] `lib/firebase_options.dart` generated
- [x] `main.dart` updated with Firebase initialization
- [x] `pubspec.yaml` dependencies added
- [x] `flutter pub get` run successfully

---

## ✅ Firestore Data — All Seeded

### Collection: `professionals`
One document. Document ID = doctor demo account's Firebase Auth UID.

```json
{
  "name": "Dr. Demo",
  "role": "professional",
  "specialty": "general",
  "createdAt": "<timestamp>"
}
```

---

### Collection: `volunteers`
Five documents (v_001 through v_005).

**v_001**
```json
{
  "id": "v_001",
  "alias": "CalmRiver",
  "specialtyTags": ["anxiety", "academic-stress", "burnout"],
  "experienceTags": ["survived-burnout", "academic-pressure"],
  "rating": 4.9,
  "totalSessions": 87,
  "availability": "available",
  "feedbackSnippets": [
    "Very patient and non-judgmental.",
    "Helped me feel less alone.",
    "Asked the right questions."
  ]
}
```

**v_002**
```json
{
  "id": "v_002",
  "alias": "StillWater",
  "specialtyTags": ["grief", "loss", "loneliness"],
  "experienceTags": ["lost-a-loved-one", "long-distance-relationship"],
  "rating": 4.7,
  "totalSessions": 53,
  "availability": "available",
  "feedbackSnippets": [
    "Made me feel understood.",
    "Gentle and grounding presence."
  ]
}
```

**v_003**
```json
{
  "id": "v_003",
  "alias": "QuietPine",
  "specialtyTags": ["relationships", "family-conflict", "self-worth"],
  "experienceTags": ["family-estrangement", "breakup"],
  "rating": 4.8,
  "totalSessions": 61,
  "availability": "available",
  "feedbackSnippets": [
    "Didn't rush me.",
    "Gave practical grounding tips."
  ]
}
```

**v_004**
```json
{
  "id": "v_004",
  "alias": "MorningFog",
  "specialtyTags": ["depression", "isolation", "hopelessness"],
  "experienceTags": ["depression-recovery", "social-withdrawal"],
  "rating": 4.6,
  "totalSessions": 39,
  "availability": "available",
  "feedbackSnippets": [
    "Spoke from real experience.",
    "Helped me name what I was feeling."
  ]
}
```

**v_005**
```json
{
  "id": "v_005",
  "alias": "EmberLight",
  "specialtyTags": ["trauma", "panic-attacks", "crisis-support"],
  "experienceTags": ["panic-disorder", "trauma-recovery"],
  "rating": 4.9,
  "totalSessions": 112,
  "availability": "available",
  "feedbackSnippets": [
    "Calm under pressure.",
    "Knew exactly what to say."
  ]
}
```

---

### Collection: `hospitals`
Seven documents. Keyed by city slug.

**taguig**
```json
{
  "city": "Taguig",
  "hospitals": [
    { "name": "Philippine Heart Center", "address": "East Avenue, Diliman, QC (near BGC area)", "hotline": "(02) 8925-2401" },
    { "name": "National Center for Mental Health", "address": "Nueve de Febrero St, Mandaluyong", "hotline": "0917-899-8727" },
    { "name": "Makati Medical Center", "address": "2 Amorsolo St, Legazpi Village, Makati", "hotline": "(02) 8888-8999" },
    { "name": "Mind You Mental Health", "address": "BGC, Taguig (telepsychiatry available)", "hotline": "0917-572-2863" }
  ]
}
```

**makati**
```json
{
  "city": "Makati",
  "hospitals": [
    { "name": "Makati Medical Center", "address": "2 Amorsolo St, Legazpi Village, Makati", "hotline": "(02) 8888-8999" },
    { "name": "National Center for Mental Health", "address": "Nueve de Febrero St, Mandaluyong", "hotline": "0917-899-8727" },
    { "name": "The Medical City — Ortigas", "address": "Ortigas Ave, Pasig", "hotline": "(02) 8988-1000" }
  ]
}
```

**quezon_city**
```json
{
  "city": "Quezon City",
  "hospitals": [
    { "name": "National Center for Mental Health (NCMH)", "address": "Nueve de Febrero St, Mandaluyong", "hotline": "0917-899-8727" },
    { "name": "Philippine General Hospital — Psychiatry Dept", "address": "Taft Ave, Ermita, Manila", "hotline": "(02) 8554-8400" },
    { "name": "East Avenue Medical Center", "address": "East Ave, Diliman, QC", "hotline": "(02) 8928-0611" }
  ]
}
```

**mandaluyong**
```json
{
  "city": "Mandaluyong",
  "hospitals": [
    { "name": "National Center for Mental Health (NCMH)", "address": "Nueve de Febrero St, Mandaluyong", "hotline": "0917-899-8727" },
    { "name": "The Medical City — Ortigas", "address": "Ortigas Ave, Pasig", "hotline": "(02) 8988-1000" }
  ]
}
```

**pasig**
```json
{
  "city": "Pasig",
  "hospitals": [
    { "name": "The Medical City", "address": "Ortigas Ave, Pasig", "hotline": "(02) 8988-1000" },
    { "name": "National Center for Mental Health", "address": "Nueve de Febrero St, Mandaluyong", "hotline": "0917-899-8727" },
    { "name": "Rizal Medical Center", "address": "Pasig Blvd, Pasig", "hotline": "(02) 8671-9191" }
  ]
}
```

**manila**
```json
{
  "city": "Manila",
  "hospitals": [
    { "name": "Philippine General Hospital — Psychiatry Dept", "address": "Taft Ave, Ermita, Manila", "hotline": "(02) 8554-8400" },
    { "name": "National Center for Mental Health", "address": "Nueve de Febrero St, Mandaluyong", "hotline": "0917-899-8727" },
    { "name": "University of Santo Tomas Hospital", "address": "España Blvd, Manila", "hotline": "(02) 8731-3001" }
  ]
}
```

**default** *(fallback for any city not in the list)*
```json
{
  "city": "Metro Manila",
  "hospitals": [
    { "name": "National Center for Mental Health (NCMH)", "address": "Nueve de Febrero St, Mandaluyong", "hotline": "0917-899-8727" },
    { "name": "Philippine General Hospital — Psychiatry Dept", "address": "Taft Ave, Ermita, Manila", "hotline": "(02) 8554-8400" },
    { "name": "Makati Medical Center", "address": "2 Amorsolo St, Legazpi Village, Makati", "hotline": "(02) 8888-8999" }
  ]
}
```

---

## Data Model Reference

### `users/{userId}`
```json
{
  "uid": "firebase_auth_uid",
  "alias": "StarlingMist42",
  "ageGroup": "18-24",
  "cityLocation": "Taguig",
  "createdAt": "2026-04-25T10:00:00Z",
  "blockedVolunteers": [],
  "activeSessionId": null
}
```

### `users/{userId}/journal/{entryId}`
```json
{
  "id": "entry_001",
  "moodScore": 6,
  "moodTag": "anxious",
  "text": "Had a session today. Felt a little better after.",
  "createdAt": "2026-04-25T12:00:00Z"
}
```
> 🔒 Strictly private. Readable and writable ONLY by the owning user.
> No volunteer, doctor, or admin has access. Ever.

### `sessions/{sessionId}`
```json
{
  "id": "sess_x7k9m",
  "userId": "firebase_auth_uid",
  "userAlias": "StarlingMist42",
  "volunteerId": "v_003",
  "status": "active",
  "startedAt": "2026-04-25T10:15:00Z",
  "endedAt": null,
  "endType": null,
  "escalationLevel": 0,
  "intakeForm": {
    "moodScore": 4,
    "situationTags": ["relationships", "self-worth"],
    "supportType": "just-vent"
  },
  "summaryId": null
}
```
> `endType` values: `"soft"` (user ended normally) | `"force"` (user force-left)
> `escalationLevel` values: `0` (normal) | `1` (Button 1 — pro alert) | `2` (Button 2 — crisis)

### `sessions/{sessionId}/messages/{messageId}`
```json
{
  "id": "msg_001",
  "senderId": "user",
  "text": "I've been feeling really disconnected lately.",
  "timestamp": "2026-04-25T10:16:00Z"
}
```
> ⚠️ Ephemeral. Entire subcollection deleted by Cloud Function when
> session `status` → `"closed"`.

### `summaries/{summaryId}`
```json
{
  "id": "sum_a1b2c3",
  "sessionId": "sess_x7k9m",
  "userId": "firebase_auth_uid",
  "volunteerId": "v_003",
  "geminiSummary": "User expressed feelings of disconnection and low self-worth...",
  "volunteerRating": 5,
  "volunteerFeedback": "Really felt heard.",
  "flaggedForReview": false,
  "sharedWithVolunteerId": null,
  "createdAt": "2026-04-25T11:00:00Z"
}
```

---

## Flutter pubspec.yaml Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
  google_sign_in: ^6.0.0

  # AI
  google_generative_ai: ^0.4.0

  # Chat UI
  flutter_chat_ui: ^1.6.0
  flutter_chat_types: ^3.6.0

  # UI
  flutter_svg: ^2.0.0
  lottie: ^3.0.0
  intl: ^0.19.0
  uuid: ^4.0.0
```

> ⛔ `firebase_database` and `firebase_messaging` are NOT included —
> Realtime Database and FCM are not used in the Flutter MVP.

---

## Gemini AI Usage

Three AI touchpoints in the app:

### 1. Volunteer Matching
Triggered after pre-session intake form submission.
Intake responses (mood score, situation tags, support type) are sent to
Gemini along with the full volunteer pool. Gemini returns the single
best-matched volunteer ID. Fallback: highest-rated volunteer not in
user's blocked list.

### 2. Chat Session Persona
Gemini powers the volunteer chat responses using a peer support system
prompt. Responds as a warm, non-clinical peer — not a therapist, not an
AI assistant. Full conversation history passed with each call (trimmed
to last 20 messages). Model: `gemini-2.0-flash`.

### 3. Post-Session Summary
Full session transcript sent to Gemini after session ends. Returns a
3–5 sentence warm summary of the session. Saved to `summaries`
collection and shown to the user as a summary card.

---

## MVP Flutter Screens (User Side Only)

| Screen | Purpose |
|---|---|
| Sign In | Google Sign-In via Firebase Auth |
| Home | Entry point — Start Session, Mood Journal, Resources |
| Pre-Session Form | Mood slider, situation tags, support type |
| Passive Resources | Breathing exercise, grounding techniques (no session needed) |
| Matching | Gemini processes intake, returns matched volunteer |
| Volunteer Info | Alias, specialty tags, rating, feedback — identity hidden |
| Chat | Gemini-powered peer chat, ephemeral messages |
| Post-Session | Star rating + feedback for volunteer |
| Summary | Gemini-generated session summary card + diary entry |
| Mood Journal | Private standalone journal — entries, mood tags |
| Resources | Static hotlines + city-based hospital list |

> Volunteer interface and Doctor dashboard = Figma prototype only.

---

## Emergency Protocol (Flutter Implementation Notes)

### Button 1 — Professional Alert
- Updates `sessions/{id}.escalationLevel` to `1`
- `syncEscalationAlert` Cloud Function triggers (deployed but doctor
  dashboard is Figma-only — alert fires but no Flutter screen receives it)
- For MVP demo: show an in-app confirmation to the volunteer that alert was sent

### Button 2 — Extreme Crisis
- Updates `sessions/{id}.escalationLevel` to `2`
- User screen immediately shows: crisis hotlines + city-based hospitals
- Volunteer screen shows 911 prompt
- Location consent dialog fires **only at this moment**
- Location used only to surface nearest hospitals — **never written to Firestore**

---

## Privacy Rules Summary

| Data | Who Can Access |
|---|---|
| User profile | Owner only |
| Mood journal | Owner only — no exceptions |
| Session messages | Owner only (deleted on close) |
| Session record | Owner + professionals |
| Summary | Owner + professionals |
| Volunteer profiles | Any authenticated user (read) |
| Hospital data | Public (no auth required) |
| Professionals list | Professionals only |

---

## What's NOT Built (Figma Prototype Only)

- Volunteer interface (availability toggle, case view, summary writing, emergency buttons)
- Doctor dashboard (session overview, escalation alerts, join session)
- Volunteer-to-volunteer peer support forum
- Volunteer onboarding and credential screening

---

## Remaining Optional Cleanup

The deployed `index.js` still contains `syncEscalationAlert` and the
RTDB `databaseURL` initialization. This is harmless — the function
won't trigger since no Flutter code writes `escalationLevel: 1` to
Firestore in a way that reaches it. Can be cleaned up post-hackathon.

---

*Kublian — ResistHounds — InnOlympics 2026*
*Firebase setup complete as of April 25, 2026*
