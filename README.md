# Keeper App

A modern Flutter notes application with Firebase integration, offering a seamless and customizable note-taking experience. This app focuses on robust authentication, personalized display settings, and a clean, intuitive user interface.

## Features

-   **Email Verification**: Secure user authentication with Firebase's built-in email verification. Includes a modern verification screen, auto-refresh for status checking, and the ability to resend verification emails.
-   **Customizable Settings**:
    -   **Font Size Control**: Adjust note text font size from 12pt to 24pt.
    -   **View Mode Toggle**: Switch between List and Grid views for notes.
    -   **Sort Options**: Organize notes by modification date or creation date.
    -   **Persistent Storage**: Settings are saved using `SharedPreferences`.
    -   **Provider for State Management**: Efficiently manages app-wide settings.
-   **Dynamic Notes Display**:
    -   **Responsive Grid View**: Notes are displayed in a visually appealing and adaptive grid layout.
    -   **Enhanced Note Cards**: Beautifully designed note cards for both list and grid views.
    -   **Firestore Integration**: Notes are stored and synchronized with Firestore, supporting sorting and persistent data.
-   **Authentication**: Firebase Authentication for user registration and login.
-   **Cloud Firestore**: Backend for storing and retrieving user notes securely.
-   **Clean Code Architecture**:
    -   Refactored codebase, removing legacy OTP systems and unused dependencies.
    -   Improved Firebase Functions and security rules.
    -   Addressed various linting errors.
-   **Material 3 Design**: Modern UI/UX with Material 3 design elements.
-   **Error Handling & Loading States**: Robust error handling and clear loading indicators for a smooth user experience.

## Technologies Used

-   **Flutter**: UI Toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
-   **Firebase**:
    -   **Firebase Authentication**: For user sign-up, sign-in, and email verification.
    -   **Cloud Firestore**: NoSQL document database for storing notes.
    -   **Firebase Storage**: (If used for attachments, otherwise can be removed from this list)
-   **Provider**: For state management within the Flutter application.
-   **SharedPreferences**: For local persistence of user settings.
-   **Google Fonts**: For custom typography.

## Installation

To get a local copy up and running, follow these simple steps.

### Prerequisites

-   [Flutter SDK](https://flutter.dev/docs/get-started/install)
-   [Firebase CLI](https://firebase.google.com/docs/cli)

### Setup

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/your-username/keeper.git
    cd keeper
    ```

2.  **Install Flutter dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Set up Firebase**:
    -   Create a new Firebase project in the [Firebase Console](https://console.firebase.google.com/).
    -   Add a new Flutter app to your Firebase project. Follow the instructions to register your app and download the configuration files (`google-services.json` for Android, `GoogleService-Info.plist` for iOS).
    -   Place `google-services.json` in `android/app/` and `GoogleService-Info.plist` in `ios/Runner/`.
    -   Enable Email/Password authentication in Firebase Authentication.
    -   Set up Cloud Firestore: Start in production mode and add security rules as needed for your application.
    -   (Optional) If you plan to use Firebase Storage for attachments, enable it in your Firebase project.

4.  **Run the application**:
    ```bash
    flutter run
    ```

## Usage

-   **Register/Login**: Create an account or log in using your email and password.
-   **Email Verification**: Follow the on-screen prompts to verify your email address.
-   **Create Notes**: Add new notes using the intuitive interface.
-   **Customize Settings**: Navigate to the settings page to adjust font size, change view mode (list/grid), and sort notes.
-   **Logout**: Securely log out from the settings page.

## Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## License

Distributed under the MIT License. See `LICENSE` for more information. (Note: You may need to create a `LICENSE` file if one doesn't exist).
