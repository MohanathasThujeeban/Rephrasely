# Rephrasely

A cross-platform mobile application that provides advanced text summarization and paraphrasing using Natural Language Processing (NLP) and Machine Learning.

## Features

- 🔐 **Authentication**: Email/Password, Google, and Facebook sign-in
- 📝 **Text Summarization**: AI-powered text summarization (Coming Soon)
- ✏️ **Paraphrasing**: Intelligent text rewriting (Coming Soon)
- 📊 **Text Analysis**: Structure and style analysis (Coming Soon)
- 📱 **Cross-Platform**: Android, iOS, Web, Windows, macOS, Linux support
- 🎨 **Modern UI**: Beautiful, responsive design with smooth animations

## Tech Stack

- **Flutter**: Cross-platform mobile app development
- **Dart**: Programming language for Flutter
- **Firebase Authentication**: User sign-in and security
- **Firebase Firestore**: Data storage and management
- **Firebase Cloud Storage**: File uploads and storage
- **Google Sign-In**: Google authentication
- **Facebook Login**: Facebook authentication
- **Provider**: State management
- **Google Fonts**: Typography

## Setup Instructions

### Prerequisites

1. Flutter SDK (latest stable version)
2. Dart SDK
3. Firebase account
4. Google Cloud Console account (for Google Sign-In)
5. Facebook Developer account (for Facebook Login)

### Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication with Email/Password, Google, and Facebook providers
3. Create a Firestore database
4. Add your app to the Firebase project for each platform you want to support
5. Download the configuration files:
   - `google-services.json` for Android (place in `android/app/`)
   - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)
6. Run `flutterfire configure` to generate `firebase_options.dart` or manually update the file with your Firebase configuration

### Google Sign-In Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create OAuth 2.0 credentials for your app
3. Add the SHA-1 fingerprint for Android
4. Configure the OAuth consent screen

### Facebook Login Setup

1. Create a Facebook app at [Facebook Developers](https://developers.facebook.com/)
2. Add Facebook Login product
3. Configure the app with your package name and key hashes
4. Update `android/app/src/main/res/values/strings.xml` with your Facebook app ID

### Installation

1. Clone the repository:
   ```bash
   git clone [repository-url]
   cd rephrasely
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase (replace placeholder values in `lib/firebase_options.dart`)

4. Add required assets:
   - Add Google sign-in icon at `assets/icons/google.png`
   - Add app icons and images as needed

5. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── constants/
│   └── app_constants.dart      # App-wide constants and styling
├── models/
│   ├── user_model.dart         # User data model
│   └── auth_result.dart        # Authentication result enums
├── providers/
│   └── auth_provider.dart      # Authentication state management
├── screens/
│   ├── welcome_screen.dart     # Onboarding/welcome screen
│   ├── login_screen.dart       # Login screen
│   ├── register_screen.dart    # Registration screen
│   ├── forgot_password_screen.dart # Password reset screen
│   ├── home_screen.dart        # Main app screen
│   └── auth_wrapper.dart       # Authentication routing wrapper
├── services/
│   └── auth_service.dart       # Firebase authentication service
├── widgets/
│   ├── custom_button.dart      # Reusable button components
│   └── custom_text_field.dart  # Reusable input components
├── firebase_options.dart       # Firebase configuration
└── main.dart                   # App entry point
```

## Current Status

✅ **Completed:**
- Authentication system (Email, Google, Facebook)
- Modern UI design with animations
- User registration and login
- Password reset functionality
- User profile management
- State management with Provider
- Firebase integration

🚧 **In Development:**
- Text summarization API integration
- Paraphrasing functionality
- Text analysis features
- User history and preferences
- Backend NLP services

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
