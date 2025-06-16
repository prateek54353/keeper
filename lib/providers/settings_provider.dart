import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

enum NotesView { list, grid }
enum SortBy { modificationDate, creationDate }
enum AppThemeMode { system, light, dark }

class SettingsProvider extends ChangeNotifier {
  static const String _fontSizeKey = 'fontSize';
  static const String _viewModeKey = 'viewMode';
  static const String _sortByKey = 'sortBy';
  static const String _fontFamilyKey = 'fontFamily';
  static const String _appThemeModeKey = 'appThemeMode';
  static const String _amoledPaletteKey = 'amoledPalette';
  static const String _materialThemeKey = 'materialTheme';
  static const String _downloadedFontsKey = 'downloadedFonts';

  static const List<String> _availableFonts = [
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Oswald',
  ];

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  final ValueNotifier<double> _fontSize = ValueNotifier(16.0);
  final ValueNotifier<NotesView> _viewMode = ValueNotifier(NotesView.list);
  final ValueNotifier<SortBy> _sortBy = ValueNotifier(SortBy.modificationDate);
  final ValueNotifier<String> _fontFamily = ValueNotifier('Roboto');
  final ValueNotifier<AppThemeMode> _appThemeMode = ValueNotifier(AppThemeMode.system);
  final ValueNotifier<bool> _amoledPalette = ValueNotifier(false);
  final ValueNotifier<bool> _materialTheme = ValueNotifier(false);
  final ValueNotifier<Set<String>> _downloadedFonts = ValueNotifier({'Roboto'});

  double get fontSize => _fontSize.value;
  NotesView get viewMode => _viewMode.value;
  SortBy get sortBy => _sortBy.value;
  String get fontFamily => _fontFamily.value;
  AppThemeMode get appThemeMode => _appThemeMode.value;
  bool get amoledPalette => _amoledPalette.value;
  bool get materialTheme => _materialTheme.value;
  bool get isInitialized => _isInitialized;
  List<String> get availableFonts => _availableFonts;
  Set<String> get downloadedFonts => _downloadedFonts.value;

  bool isFontDownloaded(String fontName) => _downloadedFonts.value.contains(fontName);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
    _isInitialized = true;
    notifyListeners();
  }

  void _loadSettings() {
    _fontSize.value = _prefs.getDouble(_fontSizeKey) ?? 16.0;
    _viewMode.value = NotesView.values[_prefs.getInt(_viewModeKey) ?? 0];
    _sortBy.value = SortBy.values[_prefs.getInt(_sortByKey) ?? 0];
    _appThemeMode.value = AppThemeMode.values[_prefs.getInt(_appThemeModeKey) ?? 0];
    _amoledPalette.value = _prefs.getBool(_amoledPaletteKey) ?? false;
    _materialTheme.value = _prefs.getBool(_materialThemeKey) ?? false;

    final List<String> savedFonts = _prefs.getStringList(_downloadedFontsKey) ?? ['Roboto'];
    _downloadedFonts.value = savedFonts.toSet();

    String? loadedFont = _prefs.getString(_fontFamilyKey);
    if (loadedFont != null && _availableFonts.contains(loadedFont)) {
      _fontFamily.value = loadedFont;
    } else {
      _fontFamily.value = _availableFonts.first;
      _prefs.setString(_fontFamilyKey, _availableFonts.first);
    }
  }

  Future<void> downloadFont(String fontName) async {
    if (!_availableFonts.contains(fontName)) {
      throw Exception('Invalid font name');
    }

    if (_downloadedFonts.value.contains(fontName)) {
      return;
    }

    try {
      await GoogleFonts.pendingFonts([fontName]);
      
      _downloadedFonts.value = {..._downloadedFonts.value, fontName};
      await _prefs.setStringList(_downloadedFontsKey, _downloadedFonts.value.toList());
      
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to download font: $e');
    }
  }

  set fontSize(double value) {
    _fontSize.value = value;
    _prefs.setDouble(_fontSizeKey, value);
    notifyListeners();
  }

  set viewMode(NotesView value) {
    _viewMode.value = value;
    _prefs.setInt(_viewModeKey, value.index);
    notifyListeners();
  }

  set sortBy(SortBy value) {
    _sortBy.value = value;
    _prefs.setInt(_sortByKey, value.index);
    notifyListeners();
  }

  set fontFamily(String value) {
    if (!_downloadedFonts.value.contains(value)) {
      throw Exception('Font not downloaded');
    }
    _fontFamily.value = value;
    _prefs.setString(_fontFamilyKey, value);
    notifyListeners();
  }

  set appThemeMode(AppThemeMode value) {
    _appThemeMode.value = value;
    _prefs.setInt(_appThemeModeKey, value.index);
    notifyListeners();
  }

  set amoledPalette(bool value) {
    _amoledPalette.value = value;
    _prefs.setBool(_amoledPaletteKey, value);
    notifyListeners();
  }

  set materialTheme(bool value) {
    _materialTheme.value = value;
    _prefs.setBool(_materialThemeKey, value);
    notifyListeners();
  }

  @override
  void dispose() {
    _fontSize.dispose();
    _viewMode.dispose();
    _sortBy.dispose();
    _fontFamily.dispose();
    _appThemeMode.dispose();
    _amoledPalette.dispose();
    _materialTheme.dispose();
    _downloadedFonts.dispose();
    super.dispose();
  }
} 