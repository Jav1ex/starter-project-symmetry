import 'dart:io';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/draft_local_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/saved_draft_model.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/saved_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/draft_repository.dart';

class DraftRepositoryImpl implements DraftRepository {
  final DraftLocalDataSource _local;
  final bool Function(String path) _fileExists;

  /// [fileExists] is only overridden by tests; on a device it asks the file
  /// system, because the picker's copy of a photo can be cleaned up between
  /// two visits to the Write screen.
  DraftRepositoryImpl(this._local, {bool Function(String path)? fileExists})
      : _fileExists = fileExists ?? _existsOnDisk;

  static bool _existsOnDisk(String path) => File(path).existsSync();

  @override
  Future<SavedDraft?> loadDraft() async {
    final stored = _local.read();
    if (stored == null) return null;

    final image = stored.image;
    final draft = image != null && !_fileExists(image.path) ? stored.copyWith(clearImage: true) : stored.toEntity();
    if (draft.isEmpty) {
      await _local.delete();
      return null;
    }
    return draft;
  }

  @override
  Future<DataState<void>> saveDraft(SavedDraft draft) async {
    try {
      await _local.write(SavedDraftModel.fromEntity(draft));
      return const DataSuccess(null);
    } catch (_) {
      return const DataFailed(Failure.unknown("Your draft couldn't be saved."));
    }
  }

  @override
  Future<DataState<void>> clearDraft() async {
    try {
      await _local.delete();
      return const DataSuccess(null);
    } catch (_) {
      return const DataFailed(Failure.unknown("Your draft couldn't be cleared."));
    }
  }
}
