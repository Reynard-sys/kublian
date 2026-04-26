# 🧠 Kublian — Project Status & Progress Report
> **Team:** ResistHounds · **Hackathon:** InnOlympics 2026 · **Track:** Health — Philippines
> **Last updated:** April 26, 2026

---

## 📌 What Is Kublian?

Kublian is a **Flutter mobile app** for anonymous mental health peer support, built for Filipino users. It connects people in distress with AI-powered anonymous volunteer personas backed by Gemini 2.5 Flash. The system has three tiers:

```
User (fully anonymous)
  → matched by Gemini AI to →
Volunteer AI Persona (anonymous alias, real human traits)
  → supervised by →
Professional Doctor (reads sessions + summaries; can join escalated sessions)
```

- **MVP Flutter build** → User side only (all screens below)
- **Volunteer interface** → Figma prototype only (not coded)
- **Doctor dashboard** → Figma prototype only (not coded)

---

## ✅ What We Have Implemented Successfully

### 🔥 Firebase Infrastructure (100% Complete)

| Item | Status |
|---|---|
| Firebase project created (`kublian`) | ✅ Done |
| Android app registered (`com.resisthounds.kublian`) | ✅ Done |
| `google-services.json` placed in `android/app/` | ✅ Done |
| SHA-1 debug fingerprint added | ✅ Done |
| Firebase Blaze plan activated (linked to GCP credits) | ✅ Done |
| Container image cleanup policy set (1 day) | ✅ Done |
| **Google Sign-In** auth provider enabled | ✅ Done |
| **Anonymous Sign-In** auth provider enabled | ✅ Done |
| Firestore database created (`asia-southeast1`) | ✅ Done |
| Firestore in Production mode (rules-controlled) | ✅ Done |
| FlutterFire CLI configured (`lib/firebase_options.dart` generated) | ✅ Done |

---

### 📋 Firestore Security Rules (100% Complete)

Full production-grade rules are **written and published**. Key behaviors:

- `users/{userId}` — owner read/write only
- `users/{userId}/journal/{entryId}` — owner read/write only, **no exceptions**
- `sessions/{sessionId}` — user can read **only while `active` or `closing`**; locked after close
- `sessions/{sessionId}/messages/{messageId}` — user read/write during active session only
- `summaries/{summaryId}` — **users cannot read their own summaries**; owner write limited to `volunteerRating` + `volunteerFeedback` fields only (enforced via `affectedKeys().hasOnly()`)
- `volunteers/{volunteerId}` — any authenticated user can read; professionals-only write
- `hospitals/{cityId}` — **fully public** (no auth required, critical for crisis screen)
- `professionals/{profId}` — any authenticated user can read

---

### 🗂️ Firestore Indexes (100% Complete)

| Collection | Fields | Status |
|---|---|---|
| `sessions` | `userId` ASC, `startedAt` DESC | ✅ Enabled |
| `sessions` | `status` ASC, `startedAt` DESC | ✅ Enabled |
| `summaries` | `userId` ASC, `createdAt` DESC | ✅ Enabled |
| `journal` | `createdAt` | ✅ Auto single-field index |

---

### ☁️ Cloud Functions — `kublian-functions/` (100% Complete & Deployed)

All three functions are **deployed** to `asia-southeast1` (Node.js 20, firebase-functions v7).

#### `deleteMessagesOnSessionClose`
- **Trigger:** Firestore `onUpdate` on `sessions/{sessionId}`
- **What it does:** When `status` changes to `"closed"`, batch-deletes the entire `messages` subcollection
- **Why:** Makes chat **fully ephemeral** — messages are not stored after a session ends
- **Status:** ✅ Live & Active

#### `syncEscalationAlert`
- **Trigger:** Firestore `onUpdate` on `sessions/{sessionId}`
- **What it does:** When `escalationLevel` changes `0 → 1`, writes an alert to Realtime Database for the doctor dashboard
- **Status:** ✅ Deployed (functionally inactive — doctor dashboard is Figma-only)
- **Note:** Safe to leave; causes zero side effects

#### `deleteUserData`
- **Trigger:** Firebase Auth `onDelete` (account deletion)
- **What it does:** Full GDPR-style purge — deletes user doc, all journal entries, all summaries, all session records
- **Status:** ✅ Live & Active

---

### 🌱 Firestore Seed Data (100% Complete)

All static collections are seeded and live in Firestore:

#### `volunteers` — 5 documents (v_001–v_005)
| ID | Alias | Role | Specialties |
|---|---|---|---|
| v_001 | CalmRiver | Certified Peer Supporter | anxiety, academic-stress, burnout |
| v_002 | StillWater | Certified Peer Supporter | grief, loss, loneliness |
| v_003 | QuietPine | Certified Peer Supporter | relationships, family-conflict, self-worth |
| v_004 | MorningFog | Certified Peer Supporter | depression, isolation, hopelessness |
| v_005 | EmberLight | Licensed Psychiatrist | trauma, panic-attacks, crisis-support |

#### `hospitals` — 7 city documents
Seeded for: **Taguig, Makati, Quezon City, Mandaluyong, Pasig, Manila, + default**

#### `professionals` — 1 document
Dr. Demo account — document ID = Firebase Auth UID of the demo doctor account.

---

### 🎯 Flutter Services Layer — `lib/core/services/` (100% Complete)

All business logic services are written. **No UI screens are wired yet** — services are ready and waiting.

#### `AuthService` ✅
- `signInWithGoogle()` — full Google OAuth flow via Firebase
- `signInAnonymously()` — anonymous fallback
- `signOut()` — signs out from both Google + Firebase Auth
- `authStateChanges` stream — for `StreamBuilder` auth gating in `main.dart`

#### `UserService` ✅
- `generateAlias()` — generates random `AdjectiveNounNN` aliases (e.g., `StarlingMist42`)
- `createUserProfile()` — creates `users/{uid}` document on first sign-in
- `getUserProfile()` — fetches user doc
- `userProfileExists()` — checks if onboarding was done
- `updateActiveSession()` / `clearActiveSession()` — session state management
- `blockVolunteer()` — adds to `blockedVolunteers` array via `arrayUnion`

#### `VolunteerService` ✅
- `getAvailableVolunteers(blockedIds)` — fetches from Firestore `volunteers` where `availability == 'available'`, excludes blocked
- `getVolunteerById(id)` — single volunteer fetch
- `highestRatedFallback()` — returns highest-rated non-blocked volunteer (used when Gemini returns bad ID)
- **Fallback:** All methods fall back to `lib/dummy_data/volunteers.dart` (6 local volunteers, v_001–v_006) if Firestore is unreachable

#### `GeminiService` ✅ *(Uses `gemini-2.5-flash`)*
- `matchVolunteer(intakeForm, volunteerPool)` — sends intake form + volunteer pool to Gemini; returns single volunteer ID
- `generateChatResponse(messages, volunteer, previousSummary)` — powers the volunteer chat persona; full Taglish system prompt with escalation triggers (`[TRIGGER_ESCALATE_L1]`, `[TRIGGER_ESCALATE_L2]`)
- `generateSessionSummary(messages, volunteer)` — generates warm 3–4 sentence handover note after session ends
- **System prompt features:** Taglish tone, 2–4 sentence cap, empathy-first, role adherence (Peer/Psychometrician/Psychiatrist modes), grounding exercises, escalation protocol, anti-disclosure rules

#### `SessionService` ✅
- `createSession()` — creates `sessions/{id}` doc + marks `activeSessionId` on user profile
- `sendMessage()` — writes to `sessions/{id}/messages/{msgId}`
- `getMessages()` — one-shot fetch of all session messages (ordered)
- `messagesStream()` — real-time Firestore stream for chat UI
- `setEscalationLevel()` — updates `escalationLevel` (0/1/2)
- `endSessionUserInitiated()` — full graceful close flow:
  1. Lock session to `"closing"`
  2. Fetch full chat history
  3. Call `GeminiService.generateSessionSummary()`
  4. Write to `summaries` collection
  5. Save summary context to user doc (`lastSessionSummary`)
  6. Set status → `"closed"` (triggers Cloud Function)
  7. Returns `{summaryId, geminiSummary}` in-memory for UI display
- `submitPostSessionRating()` — updates ONLY `volunteerRating` + `volunteerFeedback` on summary doc

#### `JournalService` ✅
- `addEntry()` — writes `users/{uid}/journal/{entryId}` with mood score, mood tag, text, timestamp
- `getEntries()` — real-time stream, newest-first
- `deleteEntry()` — deletes by entry ID

#### `HospitalService` ✅
- `getHospitalsForCity(city)` — fetches hospitals for city slug from Firestore
- Falls back to `hospitals/default` doc if city not found
- Falls back to **hard-coded static list** if Firestore is completely unreachable (critical for crisis screen)
- Cities supported: Taguig, Makati, Quezon City, Mandaluyong, Pasig, Manila

---

### 📦 Flutter App Foundation ✅

- `main.dart` — Firebase initialized, auth state gate wired via `StreamBuilder<User?>`
- **Splash screen** — shows while auth resolves (`_SplashScreen`)
- **Auth gate** — routes to Home (if logged in) or Sign In (if not)
- **Theme** — dark mode, seed color `#6B5EA8`, `Outfit` font family, Material 3
- `firebase_options.dart` — generated by FlutterFire CLI, multi-platform

---

### 📦 Flutter Dependencies (All Installed)

```yaml
firebase_core: ^3.0.0        # Firebase init
firebase_auth: ^5.0.0        # Auth
cloud_firestore: ^5.0.0      # Database
google_sign_in: ^6.0.0       # Google OAuth
google_generative_ai: ^0.4.7 # Gemini AI
flutter_chat_ui: ^1.6.0      # Chat bubble UI
flutter_chat_types: ^3.6.0   # Chat message types
flutter_svg: ^2.0.0          # SVG assets
lottie: ^3.0.0               # Animations
intl: ^0.19.0                # Date formatting
uuid: ^4.0.0                 # UUID generation
```

---

### 🗃️ Dummy / Fallback Data ✅

`lib/dummy_data/volunteers.dart` — 6 volunteers (v_001–v_006, extending v_005 with a Psychometrician `SteadyCompass`). Mirrors Firestore exactly. Used as automatic fallback by `VolunteerService` when Firestore is empty or unreachable.

---

## 🚧 What Still Needs to Be Built (Flutter Frontend)

The **entire UI layer** is missing. All services are ready — they just need screens wired to them.

### Screens Required

| Screen | Key Service(s) | Status |
|---|---|---|
| **Sign In** | `AuthService.signInWithGoogle()`, `.signInAnonymously()` | ❌ Not built |
| **Onboarding / Alias Setup** | `UserService.createUserProfile()`, `.generateAlias()` | ❌ Not built |
| **Home** | `UserService.getUserProfile()`, route to all features | ❌ Not built |
| **Pre-Session Intake Form** | `GeminiService.matchVolunteer()`, `VolunteerService.getAvailableVolunteers()` | ❌ Not built |
| **Volunteer Matching Screen** | Waiting animation while Gemini processes | ❌ Not built |
| **Volunteer Info Card** | `VolunteerService.getVolunteerById()` | ❌ Not built |
| **Chat Screen** | `SessionService` (create, send, stream), `GeminiService.generateChatResponse()`, escalation buttons | ❌ Not built |
| **Session End / Summary** | `SessionService.endSessionUserInitiated()`, in-memory summary display | ❌ Not built |
| **Post-Session Rating** | `SessionService.submitPostSessionRating()` | ❌ Not built |
| **Mood Journal** | `JournalService` (add, stream, delete) | ❌ Not built |
| **Resources / Hotlines** | Static data + `HospitalService.getHospitalsForCity()` | ❌ Not built |
| **Crisis / Escalation Screen** | `SessionService.setEscalationLevel(2)`, `HospitalService` | ❌ Not built |
| **Passive Resources** | Breathing exercise UI, 5-4-3-2-1 grounding (no session needed) | ❌ Not built |

---

## 🔌 Backend Gaps Still Needed

The backend is largely complete, but a few things are still missing or incomplete:

### ❌ Not Done Yet

| Item | Priority | Notes |
|---|---|---|
| **`professionals` collection rules** are currently read-only for any authenticated user | Medium | Should be restricted further if real doctor accounts are deployed |
| **`volunteers` Firestore collection** only has 5 docs (v_001–v_005) | Low | v_006 `SteadyCompass` exists only in local dummy data, not yet seeded to Firestore |
| **Firestore rules for volunteer write** by professionals | Low | Currently `allow write: if isProfessional()` — untested since Figma only |
| **`syncEscalationAlert` function** writes to Realtime Database but no Flutter code ever reads from RTDB | Low | Safe to ignore for MVP; clean up post-hackathon |
| **Volunteer `role` field** missing from Firestore seed | Medium | Dummy data has `role` field but seeded Firestore docs may not — needs verification |
| **Session force-close** (`endType: 'force'`) — no service method exists yet | Medium | Only `soft` close is implemented. Force-close (app kill/back) needs `endType: 'force'` handling |
| **Message trim for long sessions** | Low | `GeminiService.generateChatResponse()` passes full history — should trim to last 20 messages to avoid token overflow |
| **Gemini API key injection** | High | Currently uses `String.fromEnvironment('GEMINI_API_KEY')` — must be passed via `--dart-define=GEMINI_API_KEY=...` at build time. No key = silent failure |
| **iOS Firebase setup** | Low | `google-services.json` is Android only. `GoogleService-Info.plist` not confirmed for iOS |

---

## 🗺️ Data Flow Summary

```
[Sign In] → AuthService.signInWithGoogle()
     ↓
[Onboarding check] → UserService.userProfileExists()
     ↓ (if new user)
[Alias Setup] → UserService.generateAlias() + createUserProfile()
     ↓
[Home Screen]
     ↓
[Pre-Session Intake Form]
     ↓
[Gemini Matching] → VolunteerService.getAvailableVolunteers()
                  → GeminiService.matchVolunteer()
                  → VolunteerService.getVolunteerById()
     ↓
[Volunteer Info Card]
     ↓
[Chat Screen] → SessionService.createSession()
             → SessionService.messagesStream()
             → GeminiService.generateChatResponse()  [each message]
             → SessionService.sendMessage()
     ↓ (user taps End Session)
[Session Close] → SessionService.endSessionUserInitiated()
               → GeminiService.generateSessionSummary()  [summary written to Firestore]
               → Cloud Function: deleteMessagesOnSessionClose  [messages purged]
     ↓
[Post-Session Rating] → SessionService.submitPostSessionRating()
     ↓
[Summary Card] → (in-memory from endSessionUserInitiated return value — no Firestore read)
```

---

## 📁 File Structure

```
kublian/
├── lib/
│   ├── main.dart                        ✅ Firebase init + auth gate
│   ├── firebase_options.dart            ✅ FlutterFire generated
│   ├── core/
│   │   └── services/
│   │       ├── auth_service.dart        ✅ Google + anonymous sign-in
│   │       ├── user_service.dart        ✅ Profile CRUD + alias gen
│   │       ├── volunteer_service.dart   ✅ Pool fetch + fallback
│   │       ├── gemini_service.dart      ✅ Matching + chat + summary
│   │       ├── session_service.dart     ✅ Full session lifecycle
│   │       ├── journal_service.dart     ✅ Private journal CRUD
│   │       └── hospital_service.dart   ✅ City-based hospital fetch
│   └── dummy_data/
│       └── volunteers.dart              ✅ 6 fallback volunteers
├── kublian-functions/
│   └── functions/
│       └── index.js                    ✅ 3 Cloud Functions deployed
├── pubspec.yaml                         ✅ All deps installed
├── firebase.json                        ✅ FlutterFire config
├── KUBLIAN_FIREBASE_COMPLETE.md         ✅ Firebase setup reference
└── android/
    └── app/
        └── google-services.json         ✅ Present
```

---

## ⚠️ Critical Before Demo

1. **Pass Gemini API key at build time:**
   ```bash
   flutter run --dart-define=GEMINI_API_KEY=your_key_here
   ```
2. **Seed v_006 (`SteadyCompass`) to Firestore** — currently only in local dummy data
3. **Add `role` field to Firestore volunteer docs** if not already present
4. **Build all UI screens** — services are ready, no screens are wired yet
5. **Test `deleteMessagesOnSessionClose`** with a full session end flow end-to-end

---

*Kublian — ResistHounds — InnOlympics 2026*
