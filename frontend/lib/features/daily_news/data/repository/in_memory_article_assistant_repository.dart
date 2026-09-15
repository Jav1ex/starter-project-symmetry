import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_lens.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/editor_suggestions.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_assistant_repository.dart';

/// Canned editor for tests and offline demos: derives believable answers
/// from the text itself, with a small latency so loading states show.
class InMemoryArticleAssistantRepository implements ArticleAssistantRepository {
  final Duration _latency;

  const InMemoryArticleAssistantRepository({Duration latency = const Duration(milliseconds: 500)})
      : _latency = latency;

  @override
  Future<DataState<EditorSuggestions>> suggest(ArticleDraft draft) async {
    await Future<void>.delayed(_latency);
    final first = _firstSentence(draft.trimmedContent);
    return DataSuccess(EditorSuggestions(
      headlines: [
        draft.trimmedTitle.isEmpty ? first : draft.trimmedTitle,
        'What the ${draft.category.label.toLowerCase()} desk is watching: $first',
        '$first, in brief',
      ].map((h) => h.length > 150 ? h.substring(0, 150) : h).toList(),
      summary: first.length > 300 ? first.substring(0, 300) : first,
      category: draft.category == NewsCategory.general ? NewsCategory.business : draft.category,
    ));
  }

  @override
  Future<DataState<ArticleLensResult>> apply(ArticleLens lens, ArticleEntity article) async {
    await Future<void>.delayed(_latency);
    final sentences = _sentences(article.content);
    return DataSuccess(switch (lens) {
      ArticleLens.brief => ArticleLensResult(lens: lens, bullets: sentences.take(3).toList()),
      ArticleLens.plain => ArticleLensResult(lens: lens, text: sentences.join('\n\n')),
    });
  }

  static List<String> _sentences(String text) => text
      .split(RegExp(r'(?<=[.!?])\s+'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  static String _firstSentence(String text) {
    final sentences = _sentences(text);
    return sentences.isEmpty ? 'Untitled' : sentences.first;
  }
}
