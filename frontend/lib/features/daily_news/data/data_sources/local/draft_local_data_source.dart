import 'dart:convert';

import 'package:news_app_clean_architecture/features/daily_news/data/models/saved_draft_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the single draft as a JSON string in the platform key-value store.
class DraftLocalDataSource {
  final SharedPreferences _preferences;

  DraftLocalDataSource(this._preferences);

  static const String key = 'draft.article';

  /// `null` when nothing is stored or the stored text is not a draft document.
  SavedDraftModel? read() {
    final raw = _preferences.getString(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? SavedDraftModel.fromJson(decoded) : null;
    } on FormatException {
      return null;
    }
  }

  Future<void> write(SavedDraftModel model) => _preferences.setString(key, jsonEncode(model.toJson()));

  Future<void> delete() => _preferences.remove(key);
}
