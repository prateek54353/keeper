import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NotesView { list, grid }
enum SortBy { modificationDate, creationDate }

class SettingsProvider extends ChangeNotifier {
  static const String _fontSizeKey = 'fontSize';
  static const String _viewModeKey = 'viewMode';
  static const String _sortByKey = 'sortBy';
  static const String _fontFamilyKey = 'fontFamily';

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // List of currently available popular Google Fonts (must match FontSelectionScreen)
  final List<String> _availableFonts = [
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Oswald',
  ];

  // Default values
  double _fontSize = 16.0;
  NotesView _viewMode = NotesView.list;
  SortBy _sortBy = SortBy.modificationDate;
  String _fontFamily = 'Roboto'; // Default font to the first available

  // Getters
  double get fontSize => _fontSize;
  NotesView get viewMode => _viewMode;
  SortBy get sortBy => _sortBy;
  String get fontFamily => _fontFamily;
  bool get isInitialized => _isInitialized;

  // Initialize settings
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
    _isInitialized = true;
    notifyListeners();
  }

  // Load settings from SharedPreferences
  void _loadSettings() {
    _fontSize = _prefs.getDouble(_fontSizeKey) ?? 16.0;
    _viewMode = NotesView.values[_prefs.getInt(_viewModeKey) ?? 0];
    _sortBy = SortBy.values[_prefs.getInt(_sortByKey) ?? 0];

    String? loadedFont = _prefs.getString(_fontFamilyKey);
    if (loadedFont != null && _availableFonts.contains(loadedFont)) {
      _fontFamily = loadedFont;
    } else {
      // Default to the first available font if the loaded font is null or not in the available list
      _fontFamily = _availableFonts.first;
      _prefs.setString(_fontFamilyKey, _availableFonts.first);
    }
  }

  // Setters
  set fontSize(double value) {
    _fontSize = value;
    _prefs.setDouble(_fontSizeKey, value);
    notifyListeners();
  }

  set viewMode(NotesView value) {
    _viewMode = value;
    _prefs.setInt(_viewModeKey, value.index);
    notifyListeners();
  }

  set sortBy(SortBy value) {
    _sortBy = value;
    _prefs.setInt(_sortByKey, value.index);
    notifyListeners();
  }

  set fontFamily(String value) {
    _fontFamily = value;
    _prefs.setString(_fontFamilyKey, value);
    notifyListeners();
  }
} 