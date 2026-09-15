import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/saved_article_model.dart';

@dao
abstract class SavedArticleDao {
  @Query('SELECT * FROM saved_article ORDER BY publishedAt DESC')
  Future<List<SavedArticleModel>> getArticles();

  @Query('SELECT * FROM saved_article WHERE id = :id')
  Future<SavedArticleModel?> findById(String id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertArticle(SavedArticleModel article);

  @Query('DELETE FROM saved_article WHERE id = :id')
  Future<void> deleteById(String id);
}
