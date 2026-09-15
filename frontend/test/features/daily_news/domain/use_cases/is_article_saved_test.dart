import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/is_article_saved.dart';

import '../../../../helpers/mocks.dart';

void main() {
  test('forwards the id and the answer', () async {
    final saved = MockSavedArticleRepository();
    when(() => saved.isSaved('a')).thenAnswer((_) async => const DataSuccess(true));

    final result = await IsArticleSavedUseCase(saved)('a');

    expect(result.dataOrNull, isTrue);
  });
}
