# Firebase Setup Guide - Flutter Messaging App

Complete step-by-step guide to set up Firebase for your messaging app.

## 📊 Setup Process Flowchart

![Firebase Setup Process](/C:/Users/Mohamed/.gemini/antigravity/brain/ffbd93d1-77b5-49e8-98b3-730f78eb4a6b/firebase_setup_flowchart_1763886168432.png)

## 📋 Prerequisites

- ✅ Flutter project created (already done)
- ✅ Google account
- ✅ Internet connection

---

## Step 1: Create Firebase Project

### 1.1 Go to Firebase Console

1. Open your browser and go to: **https://console.firebase.google.com/**
2. Sign in with your Google account
3. Click **"Add project"** or **"Create a project"**

### 1.2 Configure Project

1. **Project name**: Enter `flutter-messaging-app` (or any name you prefer)
2. Click **"Continue"**
3. **Google Analytics**: Toggle OFF (optional, you can enable later)
4. Click **"Create project"**
5. Wait for project creation (takes ~30 seconds)
6. Click **"Continue"** when ready

---

## Step 2: Install FlutterFire CLI (Recommended Method)

### 2.1 Install FlutterFire CLI

Open PowerShell and run:

```powershell
# Activate FlutterFire CLI
dart pub global activate flutterfire_cli
```

### 2.2 Login to Firebase

```powershell
# Login to Firebase (opens browser)
firebase login
```

If `firebase` command is not found, install Firebase CLI:

```powershell
# Install Firebase CLI using npm
npm install -g firebase-tools

# Or download installer from:
# https://firebase.google.com/docs/cli#windows-npm
```

### 2.3 Configure Firebase for Flutter

Navigate to your project directory:

```powershell
cd C:\Users\Mohamed\.gemini\antigravity\scratch\flutter_messaging_app\messaging_app
```

Run FlutterFire configure:

```powershell
flutterfire configure
```

**Follow the prompts:**
1. Select your Firebase project: `flutter-messaging-app`
2. Select platforms: Choose **Android**, **iOS**, and **Web** (use arrow keys and space to select)
3. Press Enter

**This will automatically:**
- Create `lib/firebase_options.dart`
- Download `google-services.json` (Android)
- Download `GoogleService-Info.plist` (iOS)
- Configure web settings

---

## Step 3: Manual Setup (Alternative Method)

If FlutterFire CLI doesn't work, follow these manual steps:

### 3.1 Android Setup

1. In Firebase Console, click **"Add app"** → Select **Android** icon
2. **Android package name**: `com.example.messaging_app`
   - Find in: `android/app/build.gradle` → `applicationId`
3. **App nickname**: `Messaging App Android` (optional)
4. Click **"Register app"**
5. **Download** `google-services.json`
6. Place file in: `android/app/google-services.json`
7. Click **"Next"** → **"Continue to console"**

### 3.2 iOS Setup

1. Click **"Add app"** → Select **iOS** icon
2. **iOS bundle ID**: `com.example.messagingApp`
   - Find in: `ios/Runner.xcodeproj/project.pbxproj` → `PRODUCT_BUNDLE_IDENTIFIER`
3. **App nickname**: `Messaging App iOS` (optional)
4. Click **"Register app"**
5. **Download** `GoogleService-Info.plist`
6. Open Xcode: `open ios/Runner.xcworkspace`
7. Drag `GoogleService-Info.plist` into `Runner` folder in Xcode
8. Ensure **"Copy items if needed"** is checked
9. Click **"Finish"**

### 3.3 Web Setup

1. Click **"Add app"** → Select **Web** icon
2. **App nickname**: `Messaging App Web`
3. Click **"Register app"**
4. **Copy the Firebase configuration** (firebaseConfig object)
5. Open `web/index.html`
6. Add before `</body>`:

```html
<script type="module">
  import { initializeApp } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js";
  
  const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_PROJECT.firebaseapp.com",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_PROJECT.appspot.com",
    messagingSenderId: "YOUR_SENDER_ID",
    appId: "YOUR_APP_ID"
  };
  
  initializeApp(firebaseConfig);
</script>
```

### 3.4 Create firebase_options.dart

Create `lib/firebase_options.dart`:

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_PROJECT.firebaseapp.com',
    storageBucket: 'YOUR_PROJECT.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT.appspot.com',
    iosBundleId: 'com.example.messagingApp',
  );
}
```

---

## Step 4: Update main.dart

Your `main.dart` is already configured! It should have:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // This file is created by flutterfire configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // ... rest of your code
}
```

✅ **Already done in your project!**

---

## Step 5: Enable Firebase Services

### 5.1 Enable Authentication

1. In Firebase Console, go to **"Build"** → **"Authentication"**
2. Click **"Get started"**
3. Go to **"Sign-in method"** tab
4. Click **"Email/Password"**
5. **Enable** the toggle
6. Click **"Save"**

### 5.2 Create Firestore Database

1. Go to **"Build"** → **"Firestore Database"**
2. Click **"Create database"**
3. **Select location**: Choose closest to you (e.g., `us-central1`, `europe-west1`)
4. **Security rules**: Select **"Start in test mode"** (we'll update rules later)
5. Click **"Enable"**

### 5.3 Enable Storage

1. Go to **"Build"** → **"Storage"**
2. Click **"Get started"**
3. **Security rules**: Select **"Start in test mode"**
4. Click **"Next"**
5. **Storage location**: Use same as Firestore
6. Click **"Done"**

### 5.4 Enable Cloud Messaging (Optional)

1. Go to **"Build"** → **"Cloud Messaging"**
2. Click **"Get started"** (if shown)
3. Note: FCM is automatically enabled for new projects

---

## Step 6: Deploy Security Rules

### 6.1 Firestore Security Rules

1. Go to **"Firestore Database"** → **"Rules"** tab
2. Replace the content with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to check if user owns the document
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      // Anyone authenticated can read user profiles
      allow read: if isAuthenticated();
      // Users can only write their own profile
      allow write: if isOwner(userId);
    }
    
    // Chats collection
    match /chats/{chatId} {
      // Can read if user is a participant
      allow read: if isAuthenticated() && 
        request.auth.uid in resource.data.participantIds;
      
      // Can create new chats
      allow create: if isAuthenticated();
      
      // Can update if user is a participant
      allow update: if isAuthenticated() && 
        request.auth.uid in resource.data.participantIds;
      
      // Messages subcollection
      match /messages/{messageId} {
        // Can read messages if user is in the chat
        allow read: if isAuthenticated() && 
          request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participantIds;
        
        // Can create messages if user is in the chat
        allow create: if isAuthenticated() && 
          request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participantIds;
      }
    }
  }
}
```

3. Click **"Publish"**

### 6.2 Storage Security Rules

1. Go to **"Storage"** → **"Rules"** tab
2. Replace the content with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User profile photos
    match /users/{userId}/{allPaths=**} {
      // Anyone can read
      allow read: if request.auth != null;
      // Only owner can write
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Chat media (images, videos, files)
    match /chats/{chatId}/{allPaths=**} {
      // Anyone authenticated can read
      allow read: if request.auth != null;
      // Anyone authenticated can write (we'll validate in app logic)
      allow write: if request.auth != null;
    }
  }
}
```

3. Click **"Publish"**

---

## Step 7: Test Firebase Connection

### 7.1 Run the App

```powershell
# Navigate to project
cd C:\Users\Mohamed\.gemini\antigravity\scratch\flutter_messaging_app\messaging_app

# Run on Chrome (easiest for testing)
flutter run -d chrome
```

### 7.2 Check for Errors

Look for Firebase initialization in the console:
- ✅ Should see: "Firebase initialized successfully"
- ❌ If errors, check `firebase_options.dart` exists

### 7.3 Create Test User

**Option 1: Via Firebase Console**
1. Go to **Authentication** → **Users** tab
2. Click **"Add user"**
3. Email: `test@example.com`
4. Password: `test123456`
5. Click **"Add user"**

**Option 2: Via App (after implementing registration)**
- Use the registration screen to create a user

### 7.4 Test Login

1. Open the app
2. Enter email: `test@example.com`
3. Enter password: `test123456`
4. Click **"Sign In"**
5. ✅ Should navigate to chat list (currently shows "Coming Soon")

---

## Step 8: Verify Setup

### 8.1 Check Firebase Console

After successful login, verify in Firebase Console:

1. **Authentication** → **Users**: Should see your test user
2. **Firestore Database** → **Data**: Should see `users` collection with user document
3. Check user document has:
   - `email`
   - `displayName`
   - `isOnline: true`
   - `lastSeen` timestamp

### 8.2 Check App Logs

In your terminal/console, you should see:
```
✓ Firebase initialized
✓ User authenticated: test@example.com
```

---

## Step 9: Optional Configurations

### 9.1 Enable Offline Persistence (Firestore)

Already enabled by default in Flutter!

### 9.2 Configure Authentication Settings

1. Go to **Authentication** → **Settings**
2. **Authorized domains**: Add your domains if deploying to web
3. **User account management**: Configure email templates

### 9.3 Set Up Indexes (for complex queries)

Will be created automatically when needed, or manually in:
**Firestore Database** → **Indexes** tab

---

## Troubleshooting

### Issue: "Firebase not initialized"

**Solution:**
- Check `firebase_options.dart` exists
- Verify `await Firebase.initializeApp()` is called in `main.dart`
- Run `flutter clean` and `flutter pub get`

### Issue: "google-services.json not found"

**Solution:**
- Ensure file is in `android/app/` directory
- Check file name is exactly `google-services.json`
- Rebuild: `flutter clean && flutter run`

### Issue: "Authentication failed"

**Solution:**
- Verify Email/Password is enabled in Firebase Console
- Check user exists in Authentication → Users
- Verify password is correct (minimum 6 characters)

### Issue: "Permission denied" in Firestore

**Solution:**
- Check security rules are published
- Verify user is authenticated
- Check user has permission for the operation

### Issue: FlutterFire CLI not found

**Solution:**
```powershell
# Add Dart pub global to PATH
$env:Path += ";$env:USERPROFILE\AppData\Local\Pub\Cache\bin"

# Or reinstall
dart pub global activate flutterfire_cli
```

---

## Quick Reference Commands

```powershell
# Configure Firebase
flutterfire configure

# Run app on Chrome
flutter run -d chrome

# Run app on Android
flutter run -d android

# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Check for issues
flutter doctor
flutter analyze
```

---

## Next Steps After Setup

1. ✅ Firebase configured
2. ✅ Test user created
3. ✅ Login working
4. 🔨 Implement registration screen
5. 🔨 Implement chat list screen
6. 🔨 Implement messaging screen
7. 🔨 Implement profile screen

---

## Security Checklist

- [x] Firestore security rules deployed
- [x] Storage security rules deployed
- [x] Test mode disabled (rules are restrictive)
- [ ] Enable App Check (optional, for production)
- [ ] Set up billing alerts
- [ ] Configure backup (for production)

---

## Summary

Your Firebase setup is complete when:
- ✅ `firebase_options.dart` exists
- ✅ Authentication enabled
- ✅ Firestore database created
- ✅ Storage enabled
- ✅ Security rules deployed
- ✅ Test user can login
- ✅ User document created in Firestore

**You're ready to build the messaging features!** 🚀
