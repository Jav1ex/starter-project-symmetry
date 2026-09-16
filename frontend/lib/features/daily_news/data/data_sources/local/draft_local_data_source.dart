import 'dart:convert';

import 'package:news_app_clean_architecture/features/daily_news/data/models/saved_draft_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists one draft per account as a JSON string in the platform key-value
/// store; the scope (the account id) is part of the key.
class DraftLocalDataSource {
  final SharedPreferences _preferences;

  DraftLocalDataSource(this._preferences);

  static const String key = 'draft.article';

  static String scopedKey(String scope) => '$scope.$key';

  /// `null` when nothing is stored or the stored text is not a draft document.
  SavedDraftModel? read(String scope) {
    final raw = _preferences.getString(scopedKey(scope));
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? SavedDraftModel.fromJson(decoded) : null;
    } on FormatException {
      return null;
    }
  }

  Future<void> write(String scope, SavedDraftModel model) =>
      _preferences.setString(scopedKey(scope), jsonEncode(model.toJson()));

  Future<void> delete(String scope) => _preferences.remove(scopedKey(scope));
}
