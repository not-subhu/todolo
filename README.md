# KawaiiQuest ✨

> *"Your anime senpai-powered productivity companion"*

A gamified todo list app for students — built with Flutter, powered by Gemini AI, and sprinkled with kawaii magic.

---

## Features

### 🎮 Gamification
- Complete tasks and habits → earn coins
- Spend coins in the **Rewards Shop** (boba tea, gaming sessions, nap time, and more)
- Level up your profile (Sleepy Student → Legend of the School)
- Daily streaks with longest-streak tracking

### ✨ AI-Powered (Gemini)
- **AI Task Parser**: Paste a paragraph yap → Gemini extracts a full task list
- **Smart Pestering Notifications**: Anime-coded AI-generated reminders that escalate
- **Motivation Captions**: AI writes personal messages from your anime guide character

### 🌸 Pestering System
- Automatic in-app notifications that pester you when tasks are pending
- Adjustable interval (5–120 mins)
- Anime-coded language with kaomoji: *(；´д｀)ゞ ٩(ఠ益ఠ)۶ (◕‿◕✿)*
- Can be toggled off in Settings

### 📅 Task Management (Todoist-inspired)
- Add tasks manually or via AI parsing
- Priority levels (Low / Medium / High / Urgent)
- Due dates and times
- Sync from Todoist (API token)

### 🔥 Habits
- Daily habit tracking with streaks
- Emoji + category system
- Check-in earns coins

### 🏆 Leaderboard
- GitHub Gist-based leaderboard — share a Gist ID with your friend group
- Submit your score with a GitHub Personal Access Token

### (◕‿◕✿) Motivation Screen
- Anime girl mascot + AI-generated personal message
- "Time is passing" reminder with year progress bar
- All your stats in one place

---

## Setup

### Running on Replit (web preview)
The app runs as a Flutter web app for preview. Full mobile features (notifications, background tasks) work only on the APK.

### Building the APK

#### Option A: GitHub Actions (Recommended)
1. Push this code to a GitHub repository
2. Create a tag: `git tag v1.0.0 && git push origin v1.0.0`
3. GitHub Actions automatically builds and releases the APK
4. Download from the **Releases** page

#### Option B: Local build
```bash
flutter build apk --release
# APK: build/app/outputs/flutter-apk/app-release.apk
```

---

## Configuration

All settings are in the **Profile & Settings** tab:

| Setting | How to get it |
|---------|--------------|
| **Gemini API Key** | [Google AI Studio](https://aistudio.google.com) → Get API Key (free) |
| **Todoist Token** | Todoist Settings → Integrations → API token |
| **GitHub Gist ID** | Create a public Gist at [gist.github.com](https://gist.github.com), copy the ID from the URL |

---

## Stack

- **Flutter 3.32** — cross-platform (Android APK + web preview)
- **Provider** — state management
- **SharedPreferences** — local data storage (cross-platform)
- **Gemini 2.0 Flash** — AI features
- **GitHub Gist API** — leaderboard storage
- **Todoist REST API** — task sync
- **flutter_animate** — animations
- **google_fonts** — Nunito typeface

---

## Leaderboard Setup (for friend groups)

1. One person creates a public Gist at gist.github.com with any content
2. Copy the Gist ID from the URL (looks like `abc123def456...`)
3. Share it with your group
4. Everyone enters the same Gist ID in Settings → Leaderboard
5. To submit a score, create a GitHub Personal Access Token with `gist` scope

---

*がんばって！(◕‿◕✿)*
