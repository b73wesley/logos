import 'package:shared_preferences/shared_preferences.dart';

// This class will handle user preferences
// For example, theme settings, language preferences, etc.
class Preferences {
  // Singleton instance
  static final Preferences _instance = Preferences._internal();

  late SharedPreferences _prefs;

  factory Preferences() {
    return _instance;
  }

  Preferences._internal();

  // Initialize SharedPreferences
  static Future<void> init() async {
    _instance._prefs = await SharedPreferences.getInstance();
  }

  // Method to reset preferences to default values
  void resetPreferences() {}
}
