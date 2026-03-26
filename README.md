# Intro - Flutter Authentication App

A comprehensive Flutter project demonstrating Google Sign-In and Firebase Authentication integration with detailed setup instructions.

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Project Setup](#project-setup)
3. [Firebase Setup](#firebase-setup)
4. [Google Sign-In Configuration](#google-sign-in-configuration)
5. [SHA Key Generation](#sha-key-generation)
6. [Git & Security](#git--security)
7. [Implementation Guide](#implementation-guide)
8. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Ensure you have the following installed:

- **Flutter SDK** (latest stable version)
- **Dart SDK** (comes with Flutter)
- **Firebase CLI** - [Install here](https://firebase.google.com/docs/cli)
- **Android SDK Tools** (included with Android Studio)
- **Xcode** (for iOS development - macOS only)
- **Git**
- **Node.js** (for Firebase CLI)

### Installation Verification

```bash
flutter --version
dart --version
firebase --version
```

---

## Project Setup

### Step 1: Create Flutter Project

```bash
flutter create intro
cd intro
```

### Step 2: Update Project Configuration

#### Android (`android/app/build.gradle.kts`)

Ensure minimum SDK version is set to 24:

```kotlin
android {
    compileSdk = 35  // or higher
    
    defaultConfig {
        applicationId = "com.example.intro"
        minSdk = 24  // Important for Firebase & Google Sign-In
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }
}
```

#### iOS (`ios/Podfile`)

Ensure minimum iOS version is set:

```ruby
platform :ios, '14.0'  # or higher
```

### Step 3: Get Dependencies

```bash
flutter pub get
```

---

## Firebase Setup

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **Create a project**
3. Enter project name: `intro`
4. Accept terms and click **Continue**
5. Disable Google Analytics (optional) and click **Create project**
6. Wait for project creation to complete

### Step 2: Connect Flutter Project to Firebase CLI

```bash
# Login to Firebase
firebase login

# Initialize Firebase in your Flutter project
firebase init

# Select the following when prompted:
# - Database (Firestore): No
# - Emulator suite: No
# - Hosting: No
# - Storage: No
# - Functions: No
# - Extensions: No
# - Select hosting region: us-central1 (or your region)
```

### Step 3: iOS Setup (if developing for iOS)

```bash
cd ios
pod install
cd ..

# Run FlutterFire CLI for iOS
flutterfire configure --platforms=ios
```

### Step 4: Android Setup

Generate SHA keys first (see below), then continue with FlutterFire setup:

```bash
flutterfire configure --platforms=android
```

---

## Google Sign-In Configuration

### Step 1: Add Google Sign-In Package

```bash
flutter pub add google_sign_in
flutter pub add firebase_auth
flutter pub add firebase_core
```

### Step 2: Configure Android

#### Update `android/app/build.gradle.kts`

```kotlin
dependencies {
    // ... existing dependencies
    implementation("com.google.android.gms:play-services-auth:21.0.0")
    implementation("com.google.firebase:firebase-auth-ktx")
    implementation("com.google.firebase:firebase-core")
}
```

#### Update `android/build.gradle.kts`

```kotlin
buildscript {
    dependencies {
        // Add Google Services plugin
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

#### Update `android/app/build.gradle.kts` (top)

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")  // Add this line
    id("dev.flutter.flutter-gradle-plugin")
}
```

### Step 3: Configure iOS

Update `ios/Podfile`:

```ruby
post_install do |installer|
    installer.pods_project.targets.each do |target|
        flutter_additional_ios_build_settings(target)
        target.build_configurations.each do |config|
            config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
                '$(inherited)',
                'PERMISSION_CAMERA=1',
            ]
        end
    end
end
```

---

## SHA Key Generation

### Generate SHA-1 Debug Key

The debug SHA-1 is used for development and testing.

#### macOS/Linux:

```bash
keytool -list -v \
  -alias androiddebugkey \
  -keystore ~/.android/debug.keystore \
  -storepass android \
  -keypass android
```

**Example Output:**
```
SHA1: AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD
```

#### Windows (PowerShell):

```powershell
keytool -list -v `
  -alias androiddebugkey `
  -keystore %USERPROFILE%\.android\debug.keystore `
  -storepass android `
  -keypass android
```

### Generate SHA-1 Release Key

For production builds, generate a keystore:

```bash
keytool -genkey -v -keystore ~/my-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10950 \
  -alias my-key-alias
```

Store the keystore securely and **do not commit** to version control.

### Register SHA Keys in Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Project Settings** (gear icon)
4. Under **Your apps**, select the Android app
5. Scroll to **SHA certificate fingerprints**
6. Click **Add fingerprint**
7. Paste the SHA-1 key and click **Save**
8. Repeat for SHA-256 if needed

---

## Git & Security

### What NOT to Commit

Create/update `.gitignore` to exclude sensitive files:

```bash
# Firebase configuration files (auto-generated, contain secrets)
android/app/google-services.json

# iOS Firebase config (auto-generated, contains secrets)
ios/Runner/GoogleService-Info.plist

# Release keystore files
*.jks
*.keystore

# iOS Pods and build artifacts
ios/Pods/
ios/Pods.lock
Pods/
Podfile.lock

# Android build artifacts
**/build/
**/android/.gradle/
**/android/local.properties

# IDE
.vscode/
.idea/
*.iml
*.iws
*.ipr

# Dart/Flutter
.dart_tool/
pubspec.lock
.packages
.flutter-plugins
.flutter-plugins-dependencies
.fvm/
flutter_export_environment.sh
**/GeneratedPluginRegistrant.*

# Environment files
.env
.env.local
.env.*.local

# OS
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db

# Temporary files
*.swp
*.swo
*~
```

### Important Files to Commit

- ✅ `pubspec.yaml` - Dependency specifications
- ✅ `pubspec.lock` - Locked dependency versions (use `pubspec.lock`)
- ✅ Android manifest files (`AndroidManifest.xml`)
- ✅ iOS configuration files (non-secrets)
- ✅ Source code

### Important Files to NOT Commit

- ❌ `google-services.json` (contains API keys)
- ❌ `GoogleService-Info.plist` (contains API keys)
- ❌ `*.jks` / `*.keystore` (release keys)
- ❌ `local.properties` (local Android SDK paths)
- ❌ `.env` files with secrets

---

## Implementation Guide

### Step 1: Initialize Firebase in main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}
```

**Note:** `firebase_options.dart` is auto-generated by FlutterFire CLI.

### Step 2: Create Authentication Service

Create `lib/service/auth_service.dart`:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  // Listen to auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
```

### Step 3: Update Auth Screen to Use Real Authentication

Update `lib/auth_screen.dart`:

```dart
import 'package:intro/service/auth_service.dart';
import 'package:intro/home.dart';

// In _AuthScreenState class:

final AuthService _authService = AuthService();

Future<void> _handleGoogleSignIn() async {
  setState(() => _isLoading = true);

  try {
    final userCredential = await _authService.signInWithGoogle();
    
    if (userCredential != null && mounted) {
      final user = userCredential.user;
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            userName: user?.displayName ?? 'User',
            userEmail: user?.email ?? '',
            userImageUrl: user?.photoURL,
          ),
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed: $e')),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
```

### Step 4: Update Home Screen Logout

Update `lib/home.dart`:

```dart
import 'package:intro/auth_screen.dart';
import 'package:intro/service/auth_service.dart';

final AuthService _authService = AuthService();

void _handleLogout() async {
  await _authService.signOut();
  
  if (mounted) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }
}
```

---

## Troubleshooting

### Issue: "Google Sign-In fails with error code 12500"

**Solution:**
- Ensure SHA-1 fingerprint is registered in Firebase Console
- Check that `google-services.json` is in `android/app/`
- Verify Android package name matches Firebase project

### Issue: "PlatformException(sign_in_failed, ...)"

**Solution:**
- Clean and rebuild: `flutter clean && flutter pub get`
- Restart the emulator or physical device
- Check Firebase console for error details

### Issue: "google-services.json not found"

**Solution:**
```bash
flutterfire configure --platforms=android
```

### Issue: "Firebase not initialized" error

**Solution:**
- Ensure `Firebase.initializeApp()` is called before `runApp()`
- Add `WidgetsFlutterBinding.ensureInitialized()` before Firebase init

### Issue: iOS build fails with Firebase

**Solution:**
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
```

### Issue: "The app isn't configured correctly for Google Sign-In"

**Solution:**
1. Verify SHA-1 debug key is registered in Firebase
2. Check package name in `android/app/build.gradle.kts`
3. Ensure `google-services.json` plugin is applied in `android/app/build.gradle.kts`

---

## Quick Start Checklist

- [ ] Flutter project created
- [ ] Dependencies added (`google_sign_in`, `firebase_core`, `firebase_auth`)
- [ ] Firebase project created
- [ ] Firebase CLI initialized (`firebase init`)
- [ ] FlutterFire configured (`flutterfire configure`)
- [ ] SHA-1 debug key generated and registered
- [ ] Android build.gradle.kts updated with Google Play Services
- [ ] `google-services.json` placed in `android/app/`
- [ ] iOS setup complete (if iOS development)
- [ ] `.gitignore` configured to exclude sensitive files
- [ ] Auth service implemented
- [ ] UI updated with real authentication

---

## Resources

- [Flutter Firebase Plugin Documentation](https://firebase.flutter.dev/)
- [Google Sign-In Plugin](https://pub.dev/packages/google_sign_in)
- [Firebase Authentication Docs](https://firebase.google.com/docs/auth)
- [FlutterFire CLI Guide](https://firebase.flutter.dev/docs/cli/)
- [Android SHA Key Generation](https://developers.google.com/android/guides/client-auth)


