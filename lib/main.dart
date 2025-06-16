import 'package:flutter/material.dart';
import 'package:keeper/screens/google_sign_in_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:keeper/providers/settings_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase with web-specific options
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyB-gvU4ranCjgb9fwiSLQBpOjMvj3Zpf90",
          authDomain: "keeper-c767f.firebaseapp.com",
          projectId: "keeper-c767f",
          storageBucket: "keeper-c767f.firebasestorage.app",
          messagingSenderId: "120371881170",
          appId: "1:120371881170:web:890416038feee6bb27390b",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
    
    // Enable Firestore persistence
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    runApp(ChangeNotifierProvider<SettingsProvider>(
      create: (context) {
        final settingsProvider = SettingsProvider();
        settingsProvider.init(); // Initialize settings asynchronously
        return settingsProvider;
      },
      child: const MyApp(),
    ));
  } catch (e) {
    // Show error UI if Firebase initialization fails
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text(
                'Failed to initialize app: $e',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Keeper',
      themeMode: settings.appThemeMode == AppThemeMode.system
          ? ThemeMode.system
          : settings.appThemeMode == AppThemeMode.light
              ? ThemeMode.light
              : ThemeMode.dark,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: settings.amoledPalette
            ? ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
                background: Colors.black, // True black for AMOLED
                surface: Colors.black,
              )
            : ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: Colors.white,
          ),
        ),
      ),
      home: const GoogleSignInWrapper(),
    );
  }
}