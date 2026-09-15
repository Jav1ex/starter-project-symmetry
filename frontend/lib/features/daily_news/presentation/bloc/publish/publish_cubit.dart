import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/local_image.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/pick_thumbnail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/publish_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/update_article.dart';

part 'publish_state.dart';

/// The write / edit form. Validation comes from [ArticleDraft] so the form,
/// the use case and the backend rules agree on what is acceptable.
class PublishCubit extends Cubit<PublishState> {
  final PublishArticleUseCase _publishArticle;
  final UpdateArticleUseCase _updateArticle;
  final PickThumbnailUseCase _pickThumbnail;

  PublishCubit(
    this._publishArticle,
    this._updateArticle,
    this._pickThumbnail, {
    ArticleEntity? original,
    DateTime? now,
  }) : super(
          original == null
              ? PublishState(publishedAt: now ?? DateTime.now())
              : PublishState(
                  original: original,
                  title: original.title,
                  description: original.description ?? '',
                  content: original.content,
                  category: original.category,
                  publishedAt: original.publishedAt,
                ),
        );

  void titleChanged(String value) => emit(_keepingErrors(title: value, titleError: null));

  void descriptionChanged(String value) =>
      emit(_keepingErrors(description: value, descriptionError: null));

  void contentChanged(String value) => emit(_keepingErrors(content: value, contentError: null));

  void categoryChanged(NewsCategory value) => emit(_keepingErrors(category: value));

  void removePhoto() =>
      emit(_keepingErrors(clearPickedImage: true, removedExistingImage: true));

  Future<void> pickPhoto() async {
    final result = await _pickThumbnail(const NoParams());
    if (isClosed) return;
    switch (result) {
      case DataSuccess(:final data):
        if (data != null) emit(_keepingErrors(pickedImage: data, removedExistingImage: false));
      case DataFailed(:final failure):
        emit(_keepingErrors(failure: failure));
    }
  }

  Future<void> submit() async {
    if (state.isSubmitting) return;

    final errors = state.draft.validate();
    if (errors.isNotEmpty) {
      emit(state.copyWith(
        status: PublishStatus.failure,
        titleError: _firstOf(errors, _titleErrors),
        descriptionError: _firstOf(errors, {ArticleValidationError.descriptionTooLong}),
        contentError: _firstOf(errors, _contentErrors),
      ));
      return;
    }

    emit(state.copyWith(status: PublishStatus.submitting));
    final result = await (state.isEditing ? _update() : _publish());
    if (isClosed) return;

    switch (result) {
      case DataSuccess(:final data):
        emit(state.copyWith(status: PublishStatus.success, result: data));
      case DataFailed(:final failure):
        emit(state.copyWith(status: PublishStatus.failure, failure: failure));
    }
  }

  /// A new article is dated at the moment it is published; edits keep the
  /// original date.
  Future<DataState<ArticleEntity>> _publish() => _publishArticle(PublishArticleParams(
        draft: state.draft.copyWith(publishedAt: DateTime.now()),
        thumbnail: state.pickedImage,
      ));

  Future<DataState<ArticleEntity>> _update() => _updateArticle(UpdateArticleParams(
        article: state.original!,
        draft: state.draft,
        newThumbnail: state.pickedImage,
        removeThumbnail: state.removedExistingImage && state.pickedImage == null,
      ));

  /// Field edits keep the other fields' errors; `copyWith` resets them.
  PublishState _keepingErrors({
    String? title,
    String? description,
    String? content,
    NewsCategory? category,
    DateTime? publishedAt,
    LocalImage? pickedImage,
    bool clearPickedImage = false,
    bool? removedExistingImage,
    Failure? failure,
    Object? titleError = _unset,
    Object? descriptionError = _unset,
    Object? contentError = _unset,
  }) {
    return state.copyWith(
      title: title,
      description: description,
      content: content,
      category: category,
      publishedAt: publishedAt,
      pickedImage: pickedImage,
      clearPickedImage: clearPickedImage,
      removedExistingImage: removedExistingImage,
      status: PublishStatus.editing,
      failure: failure,
      titleError: _resolve(titleError, state.titleError),
      descriptionError: _resolve(descriptionError, state.descriptionError),
      contentError: _resolve(contentError, state.contentError),
    );
  }

  /// Sentinel meaning "leave this error as it is".
  static const Object _unset = Object();

  static ArticleValidationError? _resolve(Object? given, ArticleValidationError? current) =>
      identical(given, _unset) ? current : given as ArticleValidationError?;

  static const _titleErrors = {
    ArticleValidationError.emptyTitle,
    ArticleValidationError.titleTooLong,
  };

  static const _contentErrors = {
    ArticleValidationError.emptyContent,
    ArticleValidationError.contentTooLong,
  };

  static ArticleValidationError? _firstOf(
    List<ArticleValidationError> errors,
    Set<ArticleValidationError> group,
  ) {
    for (final error in errors) {
      if (group.contains(error)) return error;
    }
    return null;
  }
}
