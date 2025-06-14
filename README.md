# Keeper

Keeper is a cross-platform note-taking application built with Flutter and Firebase. It allows users to securely store and manage their notes with real-time synchronization across devices.

## Features

*   **Secure Authentication:** User registration and login with email/username and password. Email verification for new accounts.
*   **Real-time Sync:** Notes and tasks are synchronized across all devices in real-time using Firebase Firestore.
*   **Offline Support:** Access and modify notes even when offline with Firestore persistence.
*   **Responsive UI:** The application adapts to different screen sizes, providing an optimal experience on mobile and desktop.
*   **Note Management:** Create, edit, and delete notes. Notes can be customized with various settings like font size, view mode (list/grid), and sorting options.
*   **Task Management:** Keep track of your to-do's with a dedicated tasks section.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

*   [Flutter SDK](https://flutter.dev/docs/get-started/install)
*   [Firebase CLI](https://firebase.google.com/docs/cli)
*   A Firebase project with Firestore and Authentication enabled.

### Installation

1.  Clone the repository:

    ```bash
    git clone https://github.com/YOUR_USERNAME/keeper.git
    cd keeper
    ```

2.  Install Flutter dependencies:

    ```bash
    flutter pub get
    ```

3.  Set up Firebase:

    *   Create a new Firebase project in the [Firebase Console](https://console.firebase.google.com/).
    *   Configure your Flutter project with Firebase. Follow the instructions [here](https://firebase.google.com/docs/flutter/setup).
    *   Make sure to enable Firestore and Authentication (Email/Password provider) in your Firebase project.

4.  Run the application:

    ```bash
    flutter run
    ```

## Project Structure

*   `lib/`: Contains the main source code of the Flutter application.
    *   `screens/`: Different screens/pages of the application.
    *   `widgets/`: Reusable UI widgets.
    *   `services/`: Firebase interaction logic (Firestore, Authentication).
    *   `providers/`: State management using ChangeNotifier.
*   `functions/`: Firebase Cloud Functions (if any, currently removed custom OTP).
*   `firestore.rules`: Firestore security rules.
*   `firestore.indexes.json`: Firestore indexes.
*   `firebase.json`: Firebase deployment configuration.
*   `.firebaserc`: Firebase project aliases.

## Contributing

Contributions are welcome! Please feel free to open issues or submit pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
