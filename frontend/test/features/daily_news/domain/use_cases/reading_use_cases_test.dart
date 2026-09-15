import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/in_memory_speech_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/speech_status.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/control_reading.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/read_aloud.dart';

void main() {
  late InMemorySpeechRepository speech;

  setUp(() => speech = InMemorySpeechRepository());
  tearDown(() => speech.dispose());

  test('ReadAloud trims the text, passes the rate and refuses blank text', () async {
    final useCase = ReadAloudUseCase(speech);

    expect((await useCase(const ReadAloudParams(text: '  Hello  ', rate: 1.2))).isSuccess, isTrue);
    expect(speech.spoken, ['Hello']);
    expect(speech.lastRate, 1.2);

    expect((await useCase(const ReadAloudParams(text: '   '))).failureOrNull?.type, FailureType.validation);
  });

  test('pause, resume and stop drive the status stream', () async {
    final statuses = <SpeechStatus>[];
    final sub = speech.watchStatus().listen(statuses.add);
    await Future<void>.delayed(Duration.zero);

    await ReadAloudUseCase(speech)(const ReadAloudParams(text: 'x'));
    await PauseReadingUseCase(speech)(const NoParams());
    await ResumeReadingUseCase(speech)(const NoParams());
    await StopReadingUseCase(speech)(const NoParams());
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(statuses, [
      SpeechStatus.idle,
      SpeechStatus.speaking,
      SpeechStatus.paused,
      SpeechStatus.speaking,
      SpeechStatus.idle,
    ]);
    expect(await WatchReadingStatusUseCase(speech)(const NoParams()).first, SpeechStatus.idle);
  });
}
