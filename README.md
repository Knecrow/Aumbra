<div align="center">

![Aumbra Banner](assets/banner.jpg)

# ⚔️ Aumbra
### Awaken Your Destiny — Solo Leveling Inspired Self-Improvement RPG

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Google Gemini](https://img.shields.io/badge/Powered%20By-Google%20Gemini%20AI-8E75B2?style=for-the-badge&logo=google&logoColor=white)](https://ai.google.dev/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)

<p align="center">
  Transform your daily habits, workouts, and self-discipline into an epic Hunter leveling journey. Aumbra gamifies personal development through dynamic quest systems, AI-powered mentor feedback, stat progression, and a dark Solo Leveling aesthetic.
</p>

</div>

---

## 🌟 Key Features

- 📜 **Daily Hunter Quest System**: Turn real-life daily goals (fitness, coding, reading, mindfulness) into XP-rewarding quests.
- ⚡ **Real-Time Stat Progression**: Level up core attributes (**STR**, **AGI**, **INT**, **VIT**, **STA**) as you complete habits and maintain streaks.
- 🤖 **Gemini AI Quest Master**: Intelligent feedback, quest generation, and personalized motivational dialogue powered by Google Generative AI.
- 📊 **Visual Growth Analytics**: Track XP momentum, level trends, and completion consistency with animated `fl_chart` dashboards.
- ☁️ **Cloud Sync & Offline Persistence**: Firebase Cloud Firestore sync paired with local SQLite offline caching.
- 👑 **Hunter Rank & Awakening Milestones**: Advance from E-Rank novice to S-Rank Shadow Monarch as you conquer your daily objectives.

---

## 🛠️ Tech Stack & Architecture

- **Frontend & Mobile**: [Flutter](https://flutter.dev) (Dart 3.x)
- **State Management**: `provider`
- **Backend & Cloud**: Firebase (Auth, Cloud Firestore)
- **Local Database**: SQLite (`sqflite`), `shared_preferences`
- **AI Engine**: `google_generative_ai` (Gemini Pro)
- **Data Visualization**: `fl_chart`
- **UI System**: Custom Dark Hunter HUD, Google Fonts (`Outfit`), custom neon animations

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.2.0`)
- A [Firebase Project](https://console.firebase.google.com/) configured for Flutter
- Google Gemini API Key

### Installation

```bash
# 1. Clone repository
git clone https://github.com/Knecrow/Aumbra.git
cd Aumbra

# 2. Install dependencies
flutter pub get

# 3. Configure Firebase & AI
# Place your google-services.json (Android) / GoogleService-Info.plist (iOS)

# 4. Launch the application
flutter run
```

---

## 📄 License
This project is licensed under the MIT License - see the `LICENSE` file for details.
