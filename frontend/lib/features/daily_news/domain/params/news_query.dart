import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';

/// Filters for the provider's top-headlines feed.
class NewsQuery extends Equatable {
  final NewsCategory category;

  /// Two-letter ISO country code. The app is US/English-only by design, so
  /// this stays at its default; it remains a query field because the
  /// provider requires it.
  final String country;

  const NewsQuery({
    this.category = NewsCategory.general,
    this.country = 'us',
  });

  @override
  List<Object?> get props => [category, country];
}
