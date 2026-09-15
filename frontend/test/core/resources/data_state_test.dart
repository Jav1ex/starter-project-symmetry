import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';

void main() {
  const success = DataSuccess<int>(42);
  const failed = DataFailed<int>(Failure.network());

  group('DataSuccess', () {
    test('exposes the payload and no failure', () {
      expect(success.isSuccess, isTrue);
      expect(success.isFailure, isFalse);
      expect(success.dataOrNull, 42);
      expect(success.failureOrNull, isNull);
    });

    test('when() calls the success branch', () {
      final result = success.when(success: (d) => 'ok $d', failure: (f) => 'ko');
      expect(result, 'ok 42');
    });

    test('map() transforms the payload', () {
      expect(success.map((d) => d.toString()), const DataSuccess<String>('42'));
    });

    test('is equal by value', () {
      expect(success, const DataSuccess<int>(42));
      expect(success, isNot(const DataSuccess<int>(43)));
    });
  });

  group('DataFailed', () {
    test('exposes the failure and no payload', () {
      expect(failed.isSuccess, isFalse);
      expect(failed.isFailure, isTrue);
      expect(failed.dataOrNull, isNull);
      expect(failed.failureOrNull, const Failure.network());
    });

    test('when() calls the failure branch', () {
      final result = failed.when(success: (d) => 'ok', failure: (f) => f.type.name);
      expect(result, 'network');
    });

    test('map() keeps the failure untouched', () {
      final mapped = failed.map((d) => d.toString());
      expect(mapped, const DataFailed<String>(Failure.network()));
    });
  });

  group('Failure', () {
    test('named constructors set the matching type with a default message', () {
      expect(const Failure.network().type, FailureType.network);
      expect(const Failure.server().type, FailureType.server);
      expect(const Failure.notFound().type, FailureType.notFound);
      expect(const Failure.unauthenticated().type, FailureType.unauthenticated);
      expect(const Failure.invalidCredentials().type, FailureType.invalidCredentials);
      expect(const Failure.emailAlreadyInUse().type, FailureType.emailAlreadyInUse);
      expect(const Failure.weakPassword().type, FailureType.weakPassword);
      expect(const Failure.permissionDenied().type, FailureType.permissionDenied);
      expect(const Failure.cancelled().type, FailureType.cancelled);
      expect(const Failure.unknown().type, FailureType.unknown);
      expect(const Failure.network().message, isNotEmpty);
    });

    test('validation failures carry the given message', () {
      const failure = Failure.validation('Title is required.');
      expect(failure.type, FailureType.validation);
      expect(failure.message, 'Title is required.');
    });

    test('toString names the type and message', () {
      expect(const Failure.validation('x').toString(), 'Failure(validation: x)');
    });
  });
}
