# Firebase Setup - Quick Reference Card

## 🚀 Quick Setup (5 Steps)

### 1️⃣ Create Firebase Project
```
https://console.firebase.google.com/
→ Add project → Name: flutter-messaging-app
```

### 2️⃣ Install & Configure
```powershell
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
cd C:\Users\Mohamed\.gemini\antigravity\scratch\flutter_messaging_app\messaging_app
flutterfire configure
```

### 3️⃣ Enable Services
- ✅ **Authentication** → Email/Password
- ✅ **Firestore Database** → Test mode
- ✅ **Storage** → Test mode

### 4️⃣ Deploy Security Rules
**Firestore Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    match /chats/{chatId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participantIds;
      match /messages/{messageId} {
        allow read, create: if request.auth != null;
      }
    }
  }
}
```

**Storage Rules:**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    match /chats/{chatId}/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 5️⃣ Test
```powershell
# Run app
flutter run -d chrome

# Create test user in Firebase Console:
# Email: test@example.com
# Password: test123456

# Try logging in!
```

---

## 📁 Files Created by Setup

After `flutterfire configure`:
- ✅ `lib/firebase_options.dart`
- ✅ `android/app/google-services.json`
- ✅ `ios/Runner/GoogleService-Info.plist`

---

## 🔧 Common Commands

```powershell
# Configure Firebase
flutterfire configure

# Run on Chrome
flutter run -d chrome

# Run on Android
flutter run -d android

# Clean build
flutter clean && flutter pub get && flutter run

# Check setup
flutter doctor
```

---

## ✅ Verification Checklist

- [ ] Firebase project created
- [ ] FlutterFire CLI installed
- [ ] `flutterfire configure` completed
- [ ] `firebase_options.dart` exists
- [ ] Authentication enabled (Email/Password)
- [ ] Firestore database created
- [ ] Storage enabled
- [ ] Security rules deployed
- [ ] Test user created
- [ ] Login works in app
- [ ] User document appears in Firestore

---

## 🐛 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| Firebase not initialized | Check `firebase_options.dart` exists |
| Login fails | Verify Email/Password enabled in console |
| Permission denied | Check security rules are published |
| FlutterFire not found | Add to PATH: `$env:USERPROFILE\AppData\Local\Pub\Cache\bin` |

---

## 📚 Full Documentation

For detailed instructions, see:
- [FIREBASE_SETUP.md](file:///C:/Users/Mohamed/.gemini/antigravity/scratch/flutter_messaging_app/messaging_app/FIREBASE_SETUP.md) - Complete guide
- [QUICKSTART.md](file:///C:/Users/Mohamed/.gemini/antigravity/scratch/flutter_messaging_app/messaging_app/QUICKSTART.md) - Quick start guide

---

## 🎯 What's Next?

After Firebase setup:
1. Test login with test user
2. Implement registration screen
3. Build chat list screen
4. Create messaging interface
5. Add profile management

---

**Firebase Console:** https://console.firebase.google.com/
**Your Project:** `flutter-messaging-app`
