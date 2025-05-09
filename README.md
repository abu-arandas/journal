# Flutter Journal App

A beautiful, secure, and fully-featured Flutter Journal App designed for users who want to track their thoughts, experiences, and moods across days, months, and years. This project is perfect as a personal diary, gratitude journal, or mental health companion.

---

## 🚀 Features

### 📝 Journal Entries

* Create, read, update, and delete entries.
* Rich text editor with formatting options (bold, italics, underline).
* Attach images and tags to entries.
* Markdown support (optional).

### 🔒 Security

* Local authentication (PIN, fingerprint, face ID).
* End-to-end encryption for stored entries (AES).
* Secure cloud sync option (Firebase or custom backend).

### 📅 Calendar & Timeline Views

* Interactive calendar to view entries by date.
* Infinite scroll timeline for browsing past entries.
* Mood tracking overlay.

### 😊 Mood & Activity Tracking

* Choose mood from customizable emoji or icon sets.
* Tag activities for each entry (e.g., Work, Exercise, Relaxation).
* Mood analytics and insights.

### ☁️ Cloud Sync & Backup

* Optional Firebase integration.
* Daily automatic backup to Google Drive/iCloud.
* Export journal entries to PDF, Markdown, or plain text.

### 🎨 UI & UX

* Light and dark mode.
* Beautiful animations and transitions.
* Multiple themes to choose from.

### 🔔 Reminders & Notifications

* Daily journaling reminders.
* Custom notification scheduling.

### 🌍 Localization

* Multi-language support.
* RTL support for Arabic, Hebrew, etc.

### 📊 Insights

* Charts and stats for mood trends.
* Entry word count, journaling streaks.

### 🔧 Developer Features

* Modular code structure.
* GetX for state management.
* Firebase for backend (auth, Firestore, storage).
* Easy to extend and customize.

---

## 🧱 Project Structure

```
lib/
├── core/            # Utilities, themes, configs
├── data/            # Models, services, repositories
├── modules/         # Feature modules: journal, auth, settings, etc.
├── routes/          # Navigation config
├── widgets/         # Shared UI components
└── main.dart        # Entry point
```

---

## 🔨 Getting Started

1. **Clone the repo**

   ```bash
   git clone https://github.com/abu-arandas/flutter-journal-app.git
   ```
2. **Install dependencies**

   ```bash
   flutter pub get
   ```
3. **Run the app**

   ```bash
   flutter run
   ```
4. **Setup Firebase (Optional)**

    * Add your `google-services.json` (Android) or `GoogleService-Info.plist` (iOS).
    * Enable Firestore, Auth, and Storage in the Firebase console.

---

## 🧪 Testing

* Unit tests: `flutter test`
* Integration tests: coming soon

---

## 🙌 Contributing

Pull requests are welcome. For major changes, open an issue first to discuss what you would like to change.

---

## 📄 License

[MIT](LICENSE)

---

## 📱 Screenshots

*Coming soon!*

---

## ✨ Credits

Made with ❤️ using Flutter.

---

## 📬 Contact

Got questions or feedback?

* Email: [e00arandas@gmail.com](mailto:e00arandas@gmail.com)

---

> "What is not written down gets forgotten. What is written becomes a legacy."

Happy journaling! 📔
