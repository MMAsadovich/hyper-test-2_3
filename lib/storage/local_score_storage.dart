import 'package:shared_preferences/shared_preferences.dart';

class LocalScoreStorage {
  static const _keyBest = 'best_score';

  Future<int> getBest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyBest) ?? 0;
  }

  Future<void> setBest(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyBest, value);
  }
}
