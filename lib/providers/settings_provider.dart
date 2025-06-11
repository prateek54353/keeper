import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NotesView { list, grid }
enum SortBy { modificationDate, creationDate }

class SettingsProvider extends ChangeNotifier {
  static const String _fontSizeKey = 'fontSize';
  static const String _viewModeKey = 'viewMode';
  static const String _sortByKey = 'sortBy';

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // Default values
  double _fontSize = 16.0;
  NotesView _viewMode = NotesView.list;
  SortBy _sortBy = SortBy.modificationDate;

  // Getters
  double get fontSize => _fontSize;
  NotesView get viewMode => _viewMode;
  SortBy get sortBy => _sortBy;
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
} 