# family_expense_tracker

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Environment Setup

To get the `family_expense_tracker` project up and running on your local machine, follow these steps:

### 1. Install Flutter

If you don't have Flutter installed, follow the official Flutter installation guide for your operating system:
[https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)

After installation, run `flutter doctor` in your terminal to check for any dependencies you need to install or configure.

### 2. Clone the Repository

```bash
git clone <repository_url>
cd family_expense_tracker
```

### 3. Get Dependencies

Navigate to the `family_expense_tracker` directory and run:

```bash
flutter pub get
```

### 4. Google Sheets API Setup

This application uses Google Sheets as its backend. You need to set up a Google Cloud Project and enable the Google Sheets API.

#### 4.1 Create a Google Cloud Project

1.  Go to the [Google Cloud Console](https://console.cloud.google.com/).
2.  Create a new project or select an existing one.

#### 4.2 Enable Google Sheets API

1.  In the Google Cloud Console, navigate to "APIs & Services" > "Library".
2.  Search for "Google Sheets API" and enable it.

#### 4.3 Create OAuth 2.0 Client IDs

The application uses Google Sign-In for authentication. You need to create OAuth 2.0 Client IDs for Android and iOS.

1.  In the Google Cloud Console, navigate to "APIs & Services" > "Credentials".
2.  Click "CREATE CREDENTIALS" > "OAuth client ID".
3.  **For Android:**
    *   Select "Android" as the Application type.
    *   Provide a name (e.g., "Android Client").
    *   Enter your package name (e.g., `com.example.family_expense_tracker`). You can find this in `android/app/build.gradle` under `applicationId`.
    *   Enter your SHA-1 signing-certificate fingerprint. You can get this by running:
        ```bash
        keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
        ```
        (For release builds, you'll need to use your release keystore.)
    *   Click "CREATE".
4.  **For iOS:**
    *   Select "iOS" as the Application type.
    *   Provide a name (e.g., "iOS Client").
    *   Enter your Bundle ID (e.g., `com.example.familyExpenseTracker`). You can find this in Xcode under your project's General settings.
    *   Click "CREATE".
5.  **Download `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS):**
    *   For Android, download `google-services.json` from your Firebase project (if you're using Firebase) or directly from the Google Cloud Console. Place it in `android/app/`.
    *   For iOS, download `GoogleService-Info.plist` from your Firebase project or Google Cloud Console. Place it in `ios/Runner/`.

### 5. Run the Application

```bash
flutter run
```

This will launch the application on your connected device or emulator.
