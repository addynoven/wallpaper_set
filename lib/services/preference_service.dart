import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _categoryScorePrefix = 'category_score_';

  static PreferenceService? _instance;
  late SharedPreferences _prefs;

  PreferenceService._();

  static Future<PreferenceService> getInstance() async {
    if (_instance == null) {
      _instance = PreferenceService._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  /// Check if user has completed onboarding
  bool hasCompletedOnboarding() {
    return _prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  /// Mark onboarding as complete
  Future<void> setOnboardingComplete() async {
    await _prefs.setBool(_onboardingCompleteKey, true);
  }

  /// Save a category preference (liked = +1, disliked = -1)
  Future<void> saveCategoryPreference(
    String categoryId, {
    required bool liked,
  }) async {
    final key = '$_categoryScorePrefix$categoryId';
    final currentScore = _prefs.getInt(key) ?? 0;
    final newScore = liked ? currentScore + 1 : currentScore - 1;
    await _prefs.setInt(key, newScore);
  }

  /// Get score for a specific category
  int getCategoryScore(String categoryId) {
    return _prefs.getInt('$_categoryScorePrefix$categoryId') ?? 0;
  }

  /// Get all category scores as a map
  Map<String, int> getAllCategoryScores() {
    final scores = <String, int>{};
    for (final key in _prefs.getKeys()) {
      if (key.startsWith(_categoryScorePrefix)) {
        final categoryId = key.replaceFirst(_categoryScorePrefix, '');
        scores[categoryId] = _prefs.getInt(key) ?? 0;
      }
    }
    return scores;
  }

  /// Reset onboarding (for testing)
  Future<void> resetOnboarding() async {
    await _prefs.setBool(_onboardingCompleteKey, false);
    for (final key in _prefs.getKeys().toList()) {
      if (key.startsWith(_categoryScorePrefix)) {
        await _prefs.remove(key);
      }
    }
  }
}
