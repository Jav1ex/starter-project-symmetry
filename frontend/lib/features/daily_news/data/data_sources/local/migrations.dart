import 'package:floor/floor.dart';

/// Schema history of the on-device database.
///
/// v1 stored provider articles in an `article` table keyed by an integer id.
/// v2 replaces it with `saved_article`, keyed by the article's string id and
/// able to hold articles from both sources. Bookmarks from v1 are dropped: the
/// old rows had no stable id to migrate them by.
/// v3 adds the `category` column; existing rows default to `general`.
final Migration _migration1to2 = Migration(1, 2, (database) async {
  await database.execute('DROP TABLE IF EXISTS `article`');
  await database.execute(
    'CREATE TABLE IF NOT EXISTS `saved_article` ('
    '`id` TEXT NOT NULL, '
    '`source` TEXT NOT NULL, '
    '`title` TEXT NOT NULL, '
    '`content` TEXT NOT NULL, '
    '`description` TEXT, '
    '`author` TEXT NOT NULL, '
    '`authorId` TEXT, '
    '`imageUrl` TEXT, '
    '`imagePath` TEXT, '
    '`url` TEXT, '
    '`publishedAt` INTEGER NOT NULL, '
    'PRIMARY KEY (`id`))',
  );
});

final Migration _migration2to3 = Migration(2, 3, (database) async {
  await database.execute(
    "ALTER TABLE `saved_article` ADD COLUMN `category` TEXT NOT NULL DEFAULT 'general'",
  );
});

final List<Migration> migrations = [_migration1to2, _migration2to3];
