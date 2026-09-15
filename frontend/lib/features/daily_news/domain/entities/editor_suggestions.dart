import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';

/// What the desk editor proposes for a draft: alternative headlines, a
/// teaser and the category that fits best. The journalist picks; nothing is
/// applied without a tap.
class EditorSuggestions extends Equatable {
  final List<String> headlines;
  final String summary;
  final NewsCategory category;

  const EditorSuggestions({
    required this.headlines,
    required this.summary,
    required this.category,
  });

  bool get hasSummary => summary.trim().isNotEmpty;

  @override
  List<Object?> get props => [headlines, summary, category];
}
