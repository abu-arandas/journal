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

   Follow the setup guide in [FIREBASE_SETUP.md](FIREBASE_SETUP.md) to enable cloud sync.

---

## 📱 App Screens

### 🚪 Login & Authentication
The app provides multiple authentication options:
- PIN code setup and entry
- Biometric authentication (fingerprint and face ID)
- Optional email-based authentication via Firebase

### 🏠 Home Screen
The home screen features a tab-based interface with:
- Timeline view of recent journal entries
- Calendar view for date-based navigation
- Statistics view for mood insights and journaling analytics
- Quick-add button for creating new entries

### ✏️ Journal Entry Screen
Create and edit journal entries with:
- Title and content fields with rich text formatting
- Mood selection from customizable emoji set
- Tag selection for categorizing entries
- Image attachment capabilities
- Markdown formatting support

### 🗓️ Calendar View
Navigate your journal entries by:
- Monthly calendar with indicators for days with entries
- Mood indicators for quick mood tracking
- Day, week, and month views

### 📊 Statistics Screen
Gain insights into your journaling habits with:
- Mood distribution charts
- Word count trends
- Journaling streak statistics
- Tag frequency analysis

### ⚙️ Settings Screen
Customize your journaling experience with:
- Theme selection (light/dark mode)
- Language options
- Security preferences
- Notification settings
- Cloud sync configuration
- Data export options

### ☁️ Cloud Sync
Backup your journal entries with:
- Firebase Firestore integration
- Real-time syncing across devices
- Offline capability with sync when online

### 📤 Export
Export your journal in various formats:
- Markdown (.md)
- JSON (.json)
- Text (.txt)
- HTML (.html)
- Customizable date ranges and filters

---

## 🔐 Security Features

The app prioritizes your privacy and security:

1. **Local Authentication**
   - PIN code protection
   - Biometric authentication
   - Automatic lock after inactivity

2. **Data Encryption**
   - AES 256-bit encryption for all journal entries
   - Secure storage of encryption keys
   - End-to-end encryption for cloud sync

3. **Privacy Controls**
   - Option to disable screenshots
   - Secure app lock when backgrounded
   - Privacy screen when app is minimized

---

## 🌐 Localization

The app currently supports the following languages:
- English
- Spanish
- French

To add a new language, update the translations in `lib/core/localization/app_translations.dart`.

---

## 🧪 Testing

Run the tests with:

```bash
flutter test
```

The app includes:
- Unit tests for models and services
- Widget tests for UI components
- Integration tests for workflows

---

## 📚 Dependencies

- [GetX](https://pub.dev/packages/get) - State management and routing
- [sqflite](https://pub.dev/packages/sqflite) - Local database
- [flutter_markdown](https://pub.dev/packages/flutter_markdown) - Markdown rendering
- [table_calendar](https://pub.dev/packages/table_calendar) - Calendar widget
- [fl_chart](https://pub.dev/packages/fl_chart) - Charts and graphs
- [image_picker](https://pub.dev/packages/image_picker) - Image selection
- [local_auth](https://pub.dev/packages/local_auth) - Biometric authentication
- [encrypt](https://pub.dev/packages/encrypt) - Data encryption
- [firebase_core](https://pub.dev/packages/firebase_core) - Firebase integration
- [cloud_firestore](https://pub.dev/packages/cloud_firestore) - Cloud database

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

## 📞 Contact

Your Name - [@your_twitter](https://twitter.com/your_twitter) - email@example.com

Project Link: [https://github.com/yourusername/flutter-journal-app](https://github.com/yourusername/flutter-journal-app)

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
