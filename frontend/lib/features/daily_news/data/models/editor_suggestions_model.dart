import 'package:news_app_clean_architecture/features/daily_news/domain/entities/editor_suggestions.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';

/// The `suggest` answer of the assistant function.
class EditorSuggestionsModel extends EditorSuggestions {
  const EditorSuggestionsModel({
    required super.headlines,
    required super.summary,
    required super.category,
  });

  /// Tolerant of a sloppy answer: non-string items are dropped, an unknown
  /// category becomes `general`, a missing summary is empty.
  factory EditorSuggestionsModel.fromRawData(Map<String, dynamic> raw) {
    final headlines = raw['headlines'];
    return EditorSuggestionsModel(
      headlines: headlines is List
          ? headlines.whereType<String>().map((h) => h.trim()).where((h) => h.isNotEmpty).toList()
          : const [],
      summary: raw['summary'] is String ? (raw['summary'] as String).trim() : '',
      category: NewsCategory.fromApiValue(raw['category'] as String?),
    );
  }

  EditorSuggestions toEntity() =>
      EditorSuggestions(headlines: headlines, summary: summary, category: category);
}
