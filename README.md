<div align="center">
  <img src="assets/images/intervai_logo.png" alt="IntervAI logo" width="150" />

  # IntervAI

  ### Private, offline AI-powered interview preparation

  Practise realistic interviews, strengthen every answer, and review actionable feedback—without sending your interview data to the cloud.

  [![Offline Ready](https://img.shields.io/badge/Offline-Ready-19B394)](#how-it-works)
  [![Interview Modes](https://img.shields.io/badge/Interview%20Modes-4-1769FF)](#highlights)
  [![Question Bank](https://img.shields.io/badge/Question%20Bank-240%2B-7C3AED)](#highlights)
  [![Explainable Scoring](https://img.shields.io/badge/Scoring-Explainable-F59E0B)](#highlights)
</div>

---

## Why IntervAI?

Interview practice should feel realistic without sacrificing privacy. IntervAI provides a complete preparation workflow on the candidate's device: choose an interview, answer role-specific questions, receive explainable scores, identify weak topics, and revisit previous sessions.

The app is designed for students, job seekers, and anyone who wants repeatable interview practice without depending on a cloud API during a session.

## Product tour

<p align="center">
  <img src="docs/screenshots/sign-in.png" alt="IntervAI private sign-in screen" width="30%" />
  &nbsp;
  <img src="docs/screenshots/dashboard.png" alt="IntervAI candidate dashboard" width="30%" />
  &nbsp;
  <img src="docs/screenshots/interview-setup.png" alt="IntervAI interview setup screen" width="30%" />
</p>

<p align="center">
  <em>Private sign-in · Candidate dashboard · Flexible interview setup</em>
</p>

<details>
  <summary><strong>View the interview-readiness screen</strong></summary>
  <br />
  <p align="center">
    <img src="docs/screenshots/readiness.png" alt="IntervAI offline interview-readiness checks" width="360" />
  </p>
</details>

## Highlights

| Capability | What it provides |
| --- | --- |
| Multiple interview modes | Resume-based, technical, AI, and HR/behavioural practice |
| Role-specific preparation | Searchable domains including software engineering, data science, cybersecurity, and product roles |
| Adjustable sessions | Beginner, intermediate, or advanced difficulty with 5–60 questions |
| Explainable evaluation | Relevance, keyword coverage, clarity, fluency, filler-word usage, and STAR-structure scoring |
| Offline voice experience | On-device question narration plus local voice enrolment and verification |
| Readiness checks | Connectivity, camera, microphone, and interview-rule confirmation before a session |
| Local proctoring | Camera-based presence monitoring, app-switch detection, and a three-warning policy |
| Actionable reports | Per-answer scores, ideal-answer comparison, weak-topic detection, and improvement guidance |
| Private history | Candidate profile, completed sessions, and reports stored locally on the device |

## How it works

```text
Create or sign in to a local profile
                ↓
Choose interview type, role, difficulty, and length
                ↓
Complete offline readiness and voice-enrolment checks
                ↓
Answer role-specific questions with on-device narration
                ↓
Receive explainable feedback and a private local report
```

## Privacy first by design

- Interview configuration, answers, scores, and history remain on the device.
- Core interview selection and evaluation do not require a cloud API.
- Voice features use local audio capture; the app does not upload recordings for evaluation.
- The readiness flow asks the candidate to disable Wi-Fi and mobile data before starting.
- Android and iOS do not let ordinary apps disable connectivity silently, so IntervAI opens the system Internet controls and verifies the result when the user returns.

> IntervAI is an interview-practice and educational project. Its local account is designed for on-device profiles, not as a replacement for production-grade identity authentication.

## Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) compatible with Dart `^3.12.2`
- Android Studio/Xcode or a supported browser/desktop toolchain
- A physical device for the complete camera, microphone, and connectivity-readiness experience

### Run locally

```bash
git clone https://github.com/SRIHARSHA2108/IntervAI.git
cd IntervAI
flutter pub get
flutter run
```

### Build an Android release APK

```bash
flutter build apk --release
```

The generated APK is available at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

For a smaller APK per CPU architecture, use:

```bash
flutter build apk --release --split-per-abi
```

## Architecture

```text
lib/
├── main.dart                    # Application entry point
└── src/
    ├── app.dart                 # Authentication, dashboard, setup, interview, and report UI
    ├── camera_panel.dart        # Camera preview and local face-presence monitoring
    ├── interview_engine.dart    # Question selection and explainable answer scoring
    ├── models.dart              # Interview configuration and result models
    ├── question_bank.dart       # Bundled role-specific interview content
    ├── session_store.dart       # Device-local profile and session persistence
    └── voice_biometrics.dart    # Local voice capture, enrolment, and comparison
```

IntervAI deliberately uses a deterministic, explainable scoring engine. This makes every score suitable for demonstration, testing, and learning. A future embedded model can augment semantic relevance while preserving the existing `InterviewEngine` boundary.

## Quality checks

```bash
flutter analyze
flutter test
```

The test suite covers question selection, scoring behaviour, domain filtering, and the primary account-to-dashboard flow.

## Roadmap

- Embedded offline speech-to-text for spoken-answer transcription
- Richer locally generated coaching suggestions
- Exportable interview reports
- Expanded role and industry question libraries
- Accessibility and localisation improvements

## Contributing

Contributions are welcome. Fork the repository, create a focused branch, run the quality checks, and open a pull request with a clear explanation and screenshots for UI changes.

---

<div align="center">
  Built with Flutter for private, focused, and repeatable interview practice.
</div>
