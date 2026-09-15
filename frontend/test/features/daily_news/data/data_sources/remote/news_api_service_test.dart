import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late NewsApiService service;

  const apiKey = 'test-key';
  const country = 'us';
  const category = 'general';

  final requestOptions = RequestOptions(path: '/top-headlines');

  Response<Map<String, dynamic>> responseWith(Map<String, dynamic>? body) {
    return Response(data: body, statusCode: 200, requestOptions: requestOptions);
  }

  void stubGet(Response<Map<String, dynamic>> response) {
    when(
      () => dio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((_) async => response);
  }

  Future<List<ArticleModel>> fetch() {
    return service.getNewsArticles(
      apiKey: apiKey,
      country: country,
      category: category,
    );
  }

  setUp(() {
    dio = MockDio();
    service = NewsApiService(dio);
  });

  group('getNewsArticles', () {
    test('calls the top-headlines endpoint with the expected query', () async {
      stubGet(responseWith({'articles': []}));

      await fetch();

      final captured = verify(
        () => dio.get<Map<String, dynamic>>(
          captureAny(),
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      ).captured;

      expect(captured[0], '$newsAPIBaseURL/top-headlines');
      expect(captured[1], {
        'apiKey': apiKey,
        'country': country,
        'category': category,
      });
    });

    test('maps every article in the payload to an ArticleModel', () async {
      stubGet(
        responseWith({
          'articles': [
            {
              'author': 'Ada',
              'title': 'First',
              'description': 'd1',
              'url': 'https://example.com/1',
              'urlToImage': 'https://example.com/1.jpg',
              'publishedAt': '2026-09-15T10:00:00Z',
              'content': 'c1',
            },
            {'title': 'Second'},
          ],
        }),
      );

      final articles = await fetch();

      expect(articles, hasLength(2));
      expect(articles.first.author, 'Ada');
      expect(articles.first.urlToImage, 'https://example.com/1.jpg');
      expect(articles.last.title, 'Second');
      expect(articles.last.author, '');
    });

    test('falls back to the default image when urlToImage is missing', () async {
      stubGet(responseWith({'articles': [{'title': 'No image'}]}));

      final articles = await fetch();

      expect(articles.single.urlToImage, kDefaultImage);
    });

    test('returns an empty list when the payload has no articles key', () async {
      stubGet(responseWith({'status': 'ok'}));

      expect(await fetch(), isEmpty);
    });

    test('returns an empty list when the body is null', () async {
      stubGet(responseWith(null));

      expect(await fetch(), isEmpty);
    });

    test('ignores entries that are not JSON objects', () async {
      stubGet(responseWith({'articles': ['garbage', 42, {'title': 'Valid'}]}));

      final articles = await fetch();

      expect(articles.single.title, 'Valid');
    });

    test('lets DioException propagate to the caller', () async {
      final failure = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionTimeout,
      );
      when(
        () => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(failure);

      expect(fetch(), throwsA(same(failure)));
    });
  });
}
