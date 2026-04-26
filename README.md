# Kublian — Anonymous Mental Health Support Platform

> A digital refuge connecting individuals in need with compassionate mental health volunteers and licensed professionals — built on uncompromising privacy, precision matchmaking, and tiered anonymity.

---

## Table of Contents

- [Getting Started (Local Development)](#getting-started-local-development)
- [Overview](#overview)
- [Target Audience & Roles](#target-audience--roles)
  - [Users](#users)
  - [Volunteers](#volunteers)
  - [Professionals & Administrators](#professionals--administrators)
- [Core Features & Differentiators](#core-features--differentiators)
  - [Precision Matchmaking](#31-precision-matchmaking-tag-based-routing)
  - [AI-Driven Volunteer Screening](#32-intelligent-vetting-ai-driven-volunteer-screening)
  - [Tiered Anonymity Protocol](#33-tiered-anonymity-protocol)
  - [Zero-Footprint Conversations](#34-volatile-messaging-zero-footprint-conversations)
- [Conclusion](#conclusion)

---

## Getting Started (Local Development)

Follow these steps to run Kublian on your local machine.

### Prerequisites

Make sure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (Dart SDK is included)
- [Android Studio](https://developer.android.com/studio) or [Xcode](https://developer.apple.com/xcode/) (for device/emulator)
- A Google account to access Firebase and Google AI Studio

Verify your Flutter setup before continuing:

```bash
flutter doctor
```

---

### 1. Clone the Repository

```bash
git clone https://github.com/Reynard-sys/kublian.git
cd kublian
```

---

### 2. Install Dependencies

```bash
flutter pub get
```

---

### 3. Set Up Your Gemini API Key

Kublian uses **Google Gemini 2.5 Flash** for volunteer matching, chat persona, and session summaries. You need your own API key to run the AI features locally.

**Get a free key:**
1. Go to [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Sign in with your Google account
3. Click **"Create API key"** and copy it

**Create the secrets file:**

The file `secrets/gemini.local.json` is **git-ignored** and must be created manually. A template is already provided:

```bash
# Copy the example template
cp secrets/gemini.local.json.example secrets/gemini.local.json
```

Then open `secrets/gemini.local.json` and replace the placeholder with your actual key:

```json
{
  "GEMINI_API_KEY": "YOUR_GEMINI_API_KEY_HERE"
}
```

> ⚠️ **Never commit this file.** It is already listed in `.gitignore` — keep it that way.

---

### 4. Firebase Configuration

The Firebase project config (`lib/firebase_options.dart`) is already committed and works with the shared **Kublian** Firebase project. No extra setup is needed for the default dev environment.

If you are setting up your **own Firebase project** (e.g., for a fork or staging environment):

1. Install the [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/):
   ```bash
   dart pub global activate flutterfire_cli
   ```
2. Log in to Firebase:
   ```bash
   firebase login
   ```
3. Configure for your project:
   ```bash
   flutterfire configure
   ```

---

### 5. Run the App

Use the following command to run Kublian with your Gemini API key injected at build time:

```bash
flutter run --dart-define-from-file=secrets/gemini.local.json
```

To target a specific device:

```bash
# List available devices
flutter devices

# Run on a specific device
flutter run -d <device-id> --dart-define-from-file=secrets/gemini.local.json
```

**Example for Android emulator:**
```bash
flutter run -d emulator-5554 --dart-define-from-file=secrets/gemini.local.json
```

> 💡 **VS Code users:** Add the following to your `.vscode/launch.json` so you don't have to type the flag every time:
> ```json
> {
>   "version": "0.2.0",
>   "configurations": [
>     {
>       "name": "Kublian (dev)",
>       "request": "launch",
>       "type": "dart",
>       "args": ["--dart-define-from-file=secrets/gemini.local.json"]
>     }
>   ]
> }
> ```

---

### 6. (Optional) Deploy Cloud Functions

The three Firebase Cloud Functions (message deletion, escalation alerts, account data purge) live in `kublian-functions/functions/`.

```bash
cd kublian-functions
npm install
firebase deploy --only functions
```

> Requires the [Firebase CLI](https://firebase.google.com/docs/cli) and appropriate project permissions.

---

## Overview

**Kublian** is a pioneering mental health support application built on the belief that seeking help should be safe, immediate, and free from judgment. The platform connects users with mental health graduate volunteers and licensed professionals through a privacy-first architecture that actively dismantles the enduring stigma surrounding mental health care.

**Core philosophy:**
- Uncompromising privacy
- Precision matchmaking
- Tiered anonymity system

Users are empowered to take the first step toward healing entirely on their own terms.

---

## Target Audience & Roles

The platform serves three distinct user groups, each with tailored features and permissions.

---

### Users

The primary goal for users is to obtain **immediate, stigma-free access** to a listener. The platform ensures their privacy while providing essential support tools.

| Feature | Description |
|---|---|
| **Anonymous Onboarding** | Single-click login generating a randomized alias and avatar. Real names and emergency contacts are collected for safety but remain hidden on the front end. |
| **Pre-Session Form** | Captures the user's current state (mood selection, open prompt) to facilitate accurate routing to an appropriate volunteer. |
| **Session Control** | Easily accessible controls to end a chat or transition to professional aid at any time. |
| **Ephemeral Chat Interface** | Real-time text messaging that auto-deletes on the user's end once the session is formally closed — zero-footprint conversations. |
| **Post-Session Review** | 1–5 star rating and feedback box to evaluate volunteer empathy and helpfulness. |
| **Trust & Safety Controls** | One-tap **Report & Block** to immediately end a chat and flag policy-violating volunteers. |
| **Comprehensive Dashboard** | Daily mood tracker, therapeutic interventions, self-management resources, and an evidence-based self-care toolkit (breathing exercises, grounding techniques). |
| **Geo-Located Emergency Services** | Integration with local Municipal Health Units, psychiatric and general hospitals, and a network of licensed mental health practitioners. |

---

### Volunteers

Volunteers are the frontline listeners. They require tools to manage availability, guide conversations effectively, and document outcomes — without experiencing burnout.

| Feature | Description |
|---|---|
| **Availability Toggle & Skill Tags** | Online/offline switch coupled with selectable expertise tags (e.g., academic stress, grief, anxiety) to aid the matching process. |
| **In-Chat Resource Toolkit** | Quick-send buttons for pre-written grounding techniques, breathing exercises, and emergency hotline numbers. |
| **Post-Session Summarization** | Standardized template for writing brief session summaries. Saved to the user's takeaways and the backend database. |
| **Visible Credentials & Kudos** | Public profile displaying verified (yet anonymous) badges, average ratings, and received Kudos to establish trust before a session begins. |

---

### Professionals & Administrators

Professionals and administrators act as the platform's **safety net**, focusing on moderation, credential vetting, and intervention in severe cases.

| Feature | Description |
|---|---|
| **Backend Identity Verification** | Secure portal for manually verifying volunteer credentials before granting approval to take chats. |
| **Escalation Inbox** | Dedicated dashboard for reviewing chat transcripts or summaries of cases flagged as "severe" by the automated system or a volunteer. |

---

## Core Features & Differentiators

Kublian distinguishes itself from existing market offerings through a unique value proposition emphasizing **privacy-first design** and **AI-driven efficiency**.

---

### 3.1 Precision Matchmaking: Tag-Based Routing

Unlike generalized support applications, Kublian employs a **Niche-Based Matching Algorithm**. By cross-referencing:

- **Intake Tags** — user needs captured at the start of a session
- **Competency Tags** — volunteer-declared skill sets

...the system ensures users are paired with the most qualified support for their unique situation, maximizing the efficacy of every session.

---

### 3.2 Intelligent Vetting: AI-Driven Volunteer Screening

To maintain a high standard of care, Kublian integrates an **Automated Onboarding Engine** powered by Gemini AI:

- **Pre-Interview Synthesis** — AI conducts initial screening assessments, analyzing volunteer submissions for empathy levels, tone consistency, and adherence to safety protocols.
- **Smart Filtering** — Serves as a rigorous pre-human filter, ensuring human administrators spend time only on high-potential, high-quality candidates.

---

### 3.3 Tiered Anonymity Protocol

A core differentiator designed to dismantle the stigma surrounding mental health. The system employs a **Privacy-First Architecture** with granular visibility controls — encouraging radical honesty from users while maintaining professional accountability.

| Role | Visibility to User | Visibility to Volunteer | Visibility to Professional |
|---|---|---|---|
| **User** | — | Fully Anonymous | Anonymous *(unless crisis escalation)* |
| **Volunteer** | Fully Anonymous | — | Fully Visible |
| **Professional** | Fully Visible | Fully Visible | — |

---

### 3.4 Volatile Messaging: Zero-Footprint Conversations

Setting a new standard for data privacy, Kublian utilizes **Ephemeral (Self-Deleting) Chat**:

- Once a session concludes or a specific timeframe elapses, logs are **automatically purged** from the server.
- Unlike existing apps that store sensitive data indefinitely, this **Zero-Trace protocol** ensures that user vulnerability is never documented or weaponized.

---

## Conclusion

Kublian is a robust, privacy-centric mental health support platform designed to provide **immediate, effective, and stigma-free support** to those in need. By leveraging AI for efficient vetting, implementing a tiered anonymity protocol, and ensuring precise matchmaking, the platform maintains rigorous safety and quality standards while keeping the user experience compassionate, private, and empowering.

---

*Built with care. Designed for trust.*
