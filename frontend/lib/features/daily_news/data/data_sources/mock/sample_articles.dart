import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';

/// Journalist articles used while the real backend is not wired in.
///
/// The set deliberately covers every rendering variant the UI must handle:
/// with and without thumbnail, with and without summary, long and short
/// bodies, and two different authors so ownership can be exercised.
abstract final class SampleArticles {
  static const String authorAdaId = 'sample-uid-ada';
  static const String authorGraceId = 'sample-uid-grace';

  static String sampleImageUrl(int seed) =>
      'https://picsum.photos/seed/news-$seed/800/600';

  static List<ArticleEntity> build() {
    final base = DateTime.utc(2026, 9, 15, 8);
    return [
      ArticleEntity(
        id: 'sample-1',
        source: ArticleSource.user,
        category: NewsCategory.general,
        title: 'City council approves twelve kilometres of protected bike lanes',
        description:
            'The plan passed 9-2 and construction starts downtown next spring.',
        content: 'After two years of consultations, the city council voted on '
            'Tuesday to approve a network of protected bike lanes that will '
            'connect the riverside with the university district.\n\n'
            'Council member Ines Duarte called the vote "a turning point for '
            'how this city moves". Opponents argued the plan removes two '
            'hundred parking spaces. Works begin in March and are expected '
            'to take eighteen months.',
        author: 'Ada Lovelace',
        authorId: authorAdaId,
        imageUrl: sampleImageUrl(1),
        imagePath: 'media/articles/sample-1.jpg',
        publishedAt: base,
      ),
      ArticleEntity(
        id: 'sample-2',
        source: ArticleSource.user,
        category: NewsCategory.business,
        title: 'Local bakery wins national sourdough award',
        content: 'A family bakery on Elm Street took first prize at the national '
            'artisan bread championship with a 48-hour fermented sourdough. '
            'The owners say the secret is a starter that has been alive since '
            '1994.',
        author: 'Grace Hopper',
        authorId: authorGraceId,
        imageUrl: sampleImageUrl(2),
        imagePath: 'media/articles/sample-2.jpg',
        publishedAt: base.subtract(const Duration(hours: 5)),
      ),
      ArticleEntity(
        id: 'sample-3',
        source: ArticleSource.user,
        category: NewsCategory.general,
        title: 'Opinion: why the new transit fare needs a second look',
        description: 'A flat fare sounds fair until you look at who rides the longest.',
        content: 'The transit authority presents the flat fare as a simplification. '
            'For riders in the outer districts it is a 40 percent increase.\n\n'
            'This column walks through the numbers the authority did not '
            'publish and proposes a distance-capped alternative that keeps '
            'revenue neutral.',
        author: 'Ada Lovelace',
        authorId: authorAdaId,
        publishedAt: base.subtract(const Duration(days: 1, hours: 2)),
      ),
      ArticleEntity(
        id: 'sample-4',
        source: ArticleSource.user,
        category: NewsCategory.science,
        title: 'Weekend weather: clear skies and a cold front on Sunday',
        content: 'Expect sunshine on Saturday with highs near 22 degrees. A cold '
            'front arrives Sunday afternoon bringing scattered showers.',
        author: 'Grace Hopper',
        authorId: authorGraceId,
        publishedAt: base.subtract(const Duration(days: 2)),
      ),
      ArticleEntity(
        id: 'sample-5',
        source: ArticleSource.user,
        category: NewsCategory.technology,
        title: 'Inside the makerspace that repairs one thousand appliances a year',
        description: 'Volunteers, soldering irons and a strict no-landfill policy.',
        content: 'Every Thursday evening the community makerspace opens its doors '
            'to anyone with a broken toaster, lamp or laptop. Last year its '
            'volunteers repaired 1,043 items.\n\n'
            'The group is now lobbying for a municipal right-to-repair '
            'ordinance.',
        author: 'Ada Lovelace',
        authorId: authorAdaId,
        imageUrl: sampleImageUrl(5),
        imagePath: 'media/articles/sample-5.jpg',
        publishedAt: base.subtract(const Duration(days: 3, hours: 6)),
      ),
    ];
  }
}
