# TotalSkillz — Grade 12 Mathematics Platform

> **Built To Forge Greatness.**

![version](https://img.shields.io/badge/version-2.4.0-6C63FF?style=flat-square)
![platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Web-0A84FF?style=flat-square)
![flutter](https://img.shields.io/badge/Flutter-%5E3.11.1-54C5F8?style=flat-square&logo=flutter&logoColor=white)
![firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20Hosting-FFCA28?style=flat-square&logo=firebase&logoColor=black)
![node](https://img.shields.io/badge/Node.js-Express%205-339933?style=flat-square&logo=node.js&logoColor=white)
![pwa](https://img.shields.io/badge/PWA-enabled-5A0FC8?style=flat-square&logo=pwa&logoColor=white)
![license](https://img.shields.io/badge/license-ISC-lightgrey?style=flat-square)

TotalSkillz is a dual-platform educational product helping South African Grade 12 learners master Mathematics through interactive practice, smart review, timed exam simulation, and real NSC question banks — available as a **Progressive Web App** and a native **Flutter mobile app**.

<div align="center">
  <video src="https://github.com/user-attachments/assets/993189f6-4fa7-4d52-be80-29911ca32742"
         width="100%" controls>
  </video>
</div>

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Repository Structure](#repository-structure)
- [Getting Started](#getting-started)
  - [Web App](#web-app-setup)
  - [Flutter App](#flutter-app-setup)
- [Deployment](#deployment)
- [License](#license)

---

## Overview

The platform ships in two forms that share the same Firebase backend:

| Platform | Description |
|---|---|
| **Web App** (`/public`) | Vanilla JS + HTML/CSS PWA hosted on Firebase Hosting. Includes a Three.js landing experience, practice engine, exam simulator, formula vault, and admin panel. |
| **Flutter App** (`/mathgrade12_flutter`) | Native Android/iOS app (v2.4.0) with full feature parity, offline support, and a Material 3 dark/light theme system. |

---

## Features

### Learning & Practice
- **Topic-by-Topic Practice** — Drill Algebra, Functions, Calculus, Trigonometry, Sequences, Probability, Statistics, and Geometry.
- **Timed Exam Mode** — Simulate a 45-minute NSC exam with automatic marking and score breakdown.
- **Daily Challenges** — A fresh problem every day to build streaks and habits.
- **Masterclass Content** — Curated lesson content per topic with step-by-step expert derivations rendered in LaTeX.

### Live Classes & Expert Mastery
- **Workshop Tab** — Browse expert-authored masterclass sessions grouped by topic, with expandable step-by-step derivations and explanatory notes rendered in LaTeX.
- **Book a Class** — Request a 1-on-1 or group session via Google Classroom. Choose between a free trial (first 2 lectures) or a Standard Paid session (R200 / 2 hrs).
- **WhatsApp Booking** — Booking requests are sent directly to the tutor via WhatsApp with your name, subject (Paper 1 / Paper 2), preferred date & time, and specific topics pre-filled.

### Progress & Personalisation
- **Performance Dashboard** — Visual progress tracking with score history, topic heatmaps, and mastery indicators.
- **Onboarding Personalisation** — Set a target mark and flag weak areas so the app can prioritise content.
- **Leaderboard** — Community-wide rankings to motivate competitive learners.

### Resources
- **Formula Vault** — Full Grade 12 formula sheet with beautifully rendered LaTeX/KaTeX equations, sortable by topic.
- **Exam Paper Vault** — NSC past paper PDFs viewable in-app.
- **Examiner Insights** — Examiner data and common question patterns.
- **YouTube Video Recommendations** — Curated YouTube tutorial links surfaced per topic so learners can watch explanations without leaving the app.

### Auth & Accounts
- **Google Sign-In** — One-tap authentication via Firebase Auth.
- **Profile Management** — Edit display name, avatar, and preferences.
- **Bug Reporting** — In-app bug report submission backed by Firestore.

### Admin
- **Admin Panel** — Question bank management, user oversight, and content publishing (web + Flutter).

---

## Tech Stack

### Web App (`/public`)

| Layer | Technology |
|---|---|
| Structure | HTML5, Semantic markup |
| Styling | Vanilla CSS3, Glassmorphism, custom animations |
| Logic | Vanilla JavaScript (ES Modules) |
| 3D Effects | [Three.js](https://threejs.org/) |
| Math Rendering | KaTeX |
| Typography | Google Fonts (Inter) |
| PWA | Service Worker, Web App Manifest |
| Security | `helmet` (HTTP headers), `express-rate-limit` |
| Server | Node.js + Express 5 |

### Flutter App (`/mathgrade12_flutter`)

| Layer | Technology |
|---|---|
| Framework | Flutter 3 / Dart (SDK ^3.11.1) |
| State Management | `provider` ^6.1.2 |
| Navigation | `go_router` ^17.1.0 |
| Math Rendering | `flutter_math_fork` ^0.7.2 |
| PDF Viewer | `pdfx` ^2.9.0 |
| Local Storage | `shared_preferences` ^2.3.5 |
| Image Caching | `cached_network_image` ^3.4.1 |
| Typography | Inter (bundled font) |

### Backend & Cloud (Shared)

| Service | Purpose |
|---|---|
| Firebase Authentication | Google Sign-In, user session management |
| Cloud Firestore | Real-time NoSQL database — progress, settings, questions |
| Firebase Storage | Asset and file storage |
| Firebase Hosting | Web app global CDN delivery |
| Firestore Security Rules | Row-level access control (`firestore.rules`) |

---

## Repository Structure

```
Projects/
├── public/                     # Web App (PWA)
│   ├── index.html              # Landing page (Three.js experience)
│   ├── dashboard.html          # Progress dashboard
│   ├── practice.html           # Topic practice engine
│   ├── exam.html               # Timed exam simulator
│   ├── formula.html            # Formula vault (KaTeX)
│   ├── topics.html             # Topic browser
│   ├── vault.html              # NSC past papers
│   ├── examiner.html           # Examiner insights
│   ├── onboarding.html         # First-run personalisation
│   ├── admin.html              # Admin panel
│   ├── css/                    # Stylesheets
│   ├── js/                     # JS modules
│   ├── components/             # Shared UI components
│   ├── sw.js                   # Service Worker
│   └── manifest.json           # PWA manifest
│
├── mathgrade12_flutter/        # Flutter Mobile App (v2.4.0)
│   ├── lib/
│   │   ├── main.dart           # App entry point & provider setup
│   │   ├── router/             # go_router configuration
│   │   ├── screens/            # All app screens
│   │   │   ├── dashboard_screen.dart
│   │   │   ├── practice_screen.dart
│   │   │   ├── exam_screen.dart
│   │   │   ├── topics_screen.dart
│   │   │   ├── formula_screen.dart
│   │   │   ├── vault_screen.dart
│   │   │   ├── leaderboard_screen.dart
│   │   │   ├── live_classes_screen.dart
│   │   │   ├── settings_screen.dart
│   │   │   ├── support_screen.dart
│   │   │   ├── profile_edit_screen.dart
│   │   │   ├── onboarding_screen.dart
│   │   │   ├── examiner_screen.dart
│   │   │   ├── admin_screen.dart
│   │   │   └── auth/
│   │   ├── services/           # Business logic & Firebase services
│   │   ├── models/             # Data models
│   │   ├── theme/              # Light/dark theme definitions
│   │   └── widgets/            # Reusable UI components
│   ├── assets/
│   │   ├── questions.json      # Question bank
│   │   ├── examiner_data.json
│   │   ├── masterclass_data.json
│   │   └── topics_lessons.json
│   └── pubspec.yaml
│
├── backend/                    # Server-side utilities
├── problems/                   # PDF exam papers
├── server.js                   # Express server (security middleware)
├── firestore.rules             # Firestore security rules
├── storage.rules               # Firebase Storage rules
├── firebase.json               # Firebase Hosting config
├── generate_questions.js       # Question bank generation script
└── package.json
```

---

## Getting Started

### Prerequisites

- [Node.js](https://nodejs.org/) v18 or higher
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (^3.11.1)
- [Firebase CLI](https://firebase.google.com/docs/cli) (`npm install -g firebase-tools`)
- A Firebase project with Authentication, Firestore, and Hosting enabled

---

### Web App Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/sphe-hlongwa/Projects.git
   cd Projects
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure Firebase**
   - Update the Firebase config object inside the JS modules in `/public/js/`.
   - Ensure your Firebase project has Google Sign-In enabled.

4. **Run locally**
   ```bash
   npm start
   # → http://localhost:3000
   ```

---

### Flutter App Setup

1. **Navigate to the Flutter project**
   ```bash
   cd mathgrade12_flutter
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Run `flutterfire configure` and select your Firebase project, or place your `google-services.json` (Android) / `GoogleService-Info.plist` (iOS) in the appropriate directories.

4. **Run on a device or emulator**
   ```bash
   flutter run
   ```

5. **Build a release APK**
   ```bash
   flutter build apk --release
   ```

---

## Deployment

### Web App → Firebase Hosting

```bash
firebase deploy --only hosting
```

### Firestore Rules

```bash
firebase deploy --only firestore:rules
```

> See [`FIREBASE_SETUP.md`](./FIREBASE_SETUP.md) for detailed Firebase project configuration steps.

---

## License

This project is licensed under the **ISC License**.

---

*Built for the future of education in South Africa.*
