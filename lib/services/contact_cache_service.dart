// services/contact_cache_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/contact_logic.dart';

class ContactCacheService {
  // Timestamp keys for last successful API calls
  static const String _lastPrimaryFetchKey = 'last_primary_fetch_timestamp';
  static const String _lastAllFetchKey = 'last_all_fetch_timestamp';
  static const String _hasInitialDataKey = 'has_initial_contact_data';

  /// Check if we've already loaded initial data
  static Future<bool> hasInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasInitialDataKey) ?? false;
  }

  /// Set initial data flag
  static Future<void> setHasInitialData(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasInitialDataKey, value);
  }

  /// Save the timestamp of the last successful API fetch
  static Future<void> saveLastFetchTimestamp(ContactType type) async {
    final prefs = await SharedPreferences.getInstance();
    // Ensure correct ISO 8601 format with 'Z' for UTC
    final now = DateTime.now().toUtc().toIso8601String();
    final key = type == ContactType.primary ? _lastPrimaryFetchKey : _lastAllFetchKey;
    await prefs.setString(key, now);
    print('Saved timestamp: $now for $key');
  }

  /// Get the timestamp of the last successful API fetch
  static Future<String?> getLastFetchTimestamp(ContactType type) async {
    final prefs = await SharedPreferences.getInstance();
    final key = type == ContactType.primary ? _lastPrimaryFetchKey : _lastAllFetchKey;
    return prefs.getString(key);
  }

  /// Clear all cached timestamps (useful for debugging or reset functionality)
  static Future<void> clearTimestamps() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastPrimaryFetchKey);
    await prefs.remove(_lastAllFetchKey);
    await prefs.remove(_hasInitialDataKey);
  }
}