# Deployment Documentation

This document outlines the step-by-step process for deploying the Family Expense Tracker application to both iOS and Android platforms. It covers essential configurations, including Google OAuth setup for production environments, platform-specific build processes, and signing procedures.

## 1. Google OAuth Setup for Production

For production environments, it is crucial to configure your Google Cloud Project with the correct OAuth 2.0 Client IDs for both Android and iOS. This ensures that your application can securely authenticate users and access the Google Sheets API.

### 1.1 Google Cloud Console Configuration

1.  **Access Google Cloud Console:** Navigate to the [Google Cloud Console](https://console.cloud.google.com/).
2.  **Select Your Project:** Ensure you have selected the correct project associated with your application.
3.  **Credentials:** Go to "APIs & Services" > "Credentials".
4.  **Create OAuth Client IDs:**
    *   **Android:** Create an Android OAuth client ID. You will need your app's package name and SHA-1 signing-key certificate fingerprint. The SHA-1 fingerprint can be obtained by running `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android` for debug, or for release, use your release keystore.
    *   **iOS:** Create an iOS OAuth client ID. You will need your app's bundle ID. Download the `GoogleService-Info.plist` file.
5.  **Enable Google Sheets API:** Ensure that the "Google Sheets API" is enabled for your project under "APIs & Services" > "Enabled APIs & services".

## 2. Platform-Specific Configurations

### 2.1 Android Configuration

1.  **`google-services.json`:** Place the `google-services.json` file (obtained from Firebase or Google Cloud Console if you're using Firebase for other services) in the `android/app/` directory of your Flutter project. This file contains your Android OAuth client ID and other project configurations.
2.  **`build.gradle.kts` (App Level):**
    *   Ensure your `android/app/build.gradle.kts` file includes the Google Services plugin:
        ```kotlin
        plugins {
            id("com.android.application")
            id("kotlin-android")
            id("com.google.gms.google-services") // Add this line
        }
        ```
    *   Verify `defaultConfig` includes your `applicationId` (package name) matching your OAuth client ID configuration.

### 2.2 iOS Configuration

1.  **`GoogleService-Info.plist`:** Place the `GoogleService-Info.plist` file (downloaded from Google Cloud Console) in the `ios/Runner/` directory of your Flutter project. Make sure it's added to your Runner target in Xcode.
2.  **`Info.plist`:** Open `ios/Runner/Info.plist` and ensure it contains the `REVERSED_CLIENT_ID` from your `GoogleService-Info.plist`. This is typically handled automatically if you add `GoogleService-Info.plist` correctly in Xcode, but verify the `URL Types` section.
    ```xml
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID</string>
            </array>
        </dict>
    </array>
    ```
    Replace `YOUR_REVERSED_CLIENT_ID` with the actual value from your `GoogleService-Info.plist`.

## 3. Building for Release

### 3.1 Android

To build a release APK or App Bundle for Android, use the Flutter command-line tool:

-   **Build an App Bundle (recommended for Google Play Store):**
    ```bash
    flutter build appbundle --release
    ```
    The generated App Bundle will be located at `build/app/outputs/bundle/release/app-release.aab`.

-   **Build an APK:**
    ```bash
    flutter build apk --release
    ```
    The generated APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.

Before building, ensure you have signed your application. Refer to the [Flutter documentation on signing the Android app](https://docs.flutter.dev/deployment/android#sign-the-app) for detailed instructions on generating a keystore and configuring `key.properties`.

### 3.2 iOS

To build and archive your iOS application for distribution (e.g., to the App Store Connect), use Xcode:

1.  **Open Xcode Workspace:** Open `ios/Runner.xcworkspace` in Xcode.
2.  **Select Generic iOS Device:** In Xcode, select `Runner` in the project navigator, then choose `Generic iOS Device` as the target.
3.  **Product > Archive:** Go to `Product` > `Archive` from the Xcode menu bar.
4.  **Distribute App:** Once the archiving process is complete, the Xcode Organizer will open. From there, you can select "Distribute App" to upload your app to App Store Connect or export it for Ad Hoc distribution.

Ensure you have configured your signing certificates and provisioning profiles correctly in Xcode. Refer to the [Flutter documentation on building for iOS](https://docs.flutter.dev/deployment/ios) for more details.

## 4. Addressing Potential Platform-Specific Issues

-   **iOS `Info.plist` Caching:** Sometimes, changes to `Info.plist` might not be immediately picked up. Cleaning the build folder (`Product > Clean Build Folder` in Xcode) and restarting Xcode can resolve this.
-   **Android `gradlew clean`:** For Android build issues, running `flutter clean` and then `flutter pub get` followed by `flutter build <platform>` can often resolve problems.
-   **OAuth Consent Screen:** Ensure your OAuth consent screen is properly configured in the Google Cloud Console, especially for production, to avoid user-facing errors during authentication.
