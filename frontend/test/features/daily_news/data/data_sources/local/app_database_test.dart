import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/migrations.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/saved_article_model.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../../helpers/fixtures.dart';

/// Exercises the real Floor database on the host through sqflite_ffi, so the
/// DAO queries, the type converters and the v1 -> v2 migration are verified
/// against SQLite rather than against mocks.
void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('SavedArticleDao', () {
    late AppDatabase database;

    setUp(() async {
      database = await $FloorAppDatabase.inMemoryDatabaseBuilder().build();
    });

    tearDown(() => database.close());

    test('round-trips an article through the converters', () async {
      final article = buildUserArticle(publishedAt: DateTime.utc(2026, 9, 15, 10, 30));

      await database.savedArticleDao.insertArticle(SavedArticleModel.fromEntity(article));
      final stored = await database.savedArticleDao.findById(article.id);

      expect(stored?.toEntity(), article);
      expect(stored?.source, ArticleSource.user);
      expect(stored?.publishedAt.isUtc, isTrue);
    });

    test('lists articles newest first', () async {
      final older = buildArticle(id: 'old', publishedAt: DateTime.utc(2026, 1, 1));
      final newer = buildArticle(id: 'new', publishedAt: DateTime.utc(2026, 6, 1));
      await database.savedArticleDao.insertArticle(SavedArticleModel.fromEntity(older));
      await database.savedArticleDao.insertArticle(SavedArticleModel.fromEntity(newer));

      final all = await database.savedArticleDao.getArticles();

      expect(all.map((a) => a.id), ['new', 'old']);
    });

    test('saving the same id twice replaces instead of failing', () async {
      final first = buildArticle(id: 'same', title: 'First');
      final second = buildArticle(id: 'same', title: 'Second');

      await database.savedArticleDao.insertArticle(SavedArticleModel.fromEntity(first));
      await database.savedArticleDao.insertArticle(SavedArticleModel.fromEntity(second));

      final all = await database.savedArticleDao.getArticles();
      expect(all.single.title, 'Second');
    });

    test('deleteById removes only the matching row', () async {
      await database.savedArticleDao.insertArticle(
        SavedArticleModel.fromEntity(buildArticle(id: 'a')),
      );
      await database.savedArticleDao.insertArticle(
        SavedArticleModel.fromEntity(buildArticle(id: 'b')),
      );

      await database.savedArticleDao.deleteById('a');

      expect(await database.savedArticleDao.findById('a'), isNull);
      expect(await database.savedArticleDao.findById('b'), isNotNull);
    });
  });

  group('migration 1 -> 2', () {
    late String path;

    setUp(() async {
      final directory = await Directory.systemTemp.createTemp('news_app_db_');
      path = '${directory.path}/app_database.db';
    });

    tearDown(() async {
      final file = File(path);
      if (await file.exists()) await file.delete();
    });

    test('drops the legacy table and creates saved_article', () async {
      final legacy = await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, _) => db.execute(
            'CREATE TABLE IF NOT EXISTS `article` (`id` INTEGER, `author` TEXT, '
            '`title` TEXT, PRIMARY KEY (`id`))',
          ),
        ),
      );
      await legacy.insert('article', {'id': 1, 'author': 'x', 'title': 'legacy'});
      await legacy.close();

      final migrated = await $FloorAppDatabase
          .databaseBuilder(path)
          .addMigrations(migrations)
          .build();

      final tables = await migrated.database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      );
      final names = tables.map((row) => row['name']).toSet();
      expect(names, contains('saved_article'));
      expect(names, isNot(contains('article')));

      await migrated.savedArticleDao.insertArticle(
        SavedArticleModel.fromEntity(buildArticle()),
      );
      expect(await migrated.savedArticleDao.getArticles(), hasLength(1));

      await migrated.close();
    });
  });
}
