# Firebase Integration Guide

To enable cloud synchronization, your Flutter Journal App needs to be connected to Firebase. Follow these steps to set up Firebase in your project:

## Step 1: Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click on "Add project" and follow the prompts to create a new project
3. Give your project a name (e.g., "Journal App")
4. You can enable Google Analytics if you want
5. Click "Create project" and wait for the project to be created

## Step 2: Register Your App with Firebase

### For Android:

1. In the Firebase Console, click on your project
2. Click the Android icon (</>) to add an Android app
3. Enter your app's package name: `com.example.journal` (or your actual package name)
4. Enter your app nickname: "Journal App"
5. Enter your SHA-1 key (optional for basic setup)
6. Click "Register app"
7. Download the `google-services.json` file
8. Move the `google-services.json` file to the `android/app` directory in your Flutter project

### For iOS:

1. In the Firebase Console, click on your project
2. Click the iOS icon (</>) to add an iOS app
3. Enter your iOS bundle ID (from your Xcode project)
4. Enter your app nickname: "Journal App"
5. Enter your App Store ID (optional)
6. Click "Register app"
7. Download the `GoogleService-Info.plist` file
8. Move the `GoogleService-Info.plist` file to the `ios/Runner` directory in your Flutter project

## Step 3: Configure Your Flutter Project

### Android Configuration:

1. Update your project-level `build.gradle` (`android/build.gradle`):

```groovy
buildscript {
    dependencies {
        // Add this line
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

2. Update your app-level `build.gradle` (`android/app/build.gradle`):

```groovy
apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply plugin: 'com.google.gms.google-services'  // Add this line
```

### iOS Configuration:

1. Update your `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure() // Add this line
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Step 4: Enable Authentication Methods

1. In the Firebase Console, go to "Authentication"
2. Click on "Get started"
3. Enable the authentication methods you want to use:
   - Email/Password
   - Anonymous
   - Google Sign-In
   - Others as needed

## Step 5: Create Firestore Database

1. In the Firebase Console, go to "Firestore Database"
2. Click on "Create database"
3. Choose either "Start in production mode" or "Start in test mode" (for development)
4. Select a location for your database
5. Click "Enable"

### Set Up Firestore Security Rules

1. Go to the "Rules" tab
2. Set up basic security rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /entries/{entryId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

## Step 6: Set Up Firebase Storage (for Images)

1. In the Firebase Console, go to "Storage"
2. Click on "Get started"
3. Choose either "Start in production mode" or "Start in test mode" (for development)
4. Select a location for your storage
5. Click "Next"
6. Click "Done"

### Set Up Storage Security Rules

1. Go to the "Rules" tab
2. Set up basic security rules:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/entries/{entryId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Step 7: Run Your App

Now your Flutter Journal App should be properly configured to use Firebase. Run the app, and the cloud sync features should work as expected.

---

## Troubleshooting

If you encounter issues with Firebase integration:

1. **Dependency conflicts**: Make sure your Firebase package versions are compatible with your Flutter version.
2. **Platform-specific errors**: Double-check the configuration steps for the platform where you're encountering issues.
3. **Authentication errors**: Verify that you've properly enabled the authentication methods you're trying to use.
4. **Firestore or Storage permissions**: Review your security rules to ensure they match your access patterns.
5. **Google Play Services**: Ensure Google Play Services are installed and up-to-date on Android test devices.

For more detailed information, refer to the [Firebase Flutter documentation](https://firebase.google.com/docs/flutter/setup).
