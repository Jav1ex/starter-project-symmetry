import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';

void main() {
  group('UserEntity.preferredName', () {
    test('uses the display name when present', () {
      const user = UserEntity(id: '1', displayName: ' Ada ', email: 'ada@example.com');
      expect(user.preferredName, 'Ada');
    });

    test('falls back to the email local part', () {
      const user = UserEntity(id: '1', displayName: '  ', email: 'ada@example.com');
      expect(user.preferredName, 'ada');
    });

    test('falls back to a neutral label without name or email', () {
      const user = UserEntity(id: '1');
      expect(user.preferredName, 'Journalist');
    });

    test('ignores an email without an @', () {
      const user = UserEntity(id: '1', email: 'not-an-email');
      expect(user.preferredName, 'Journalist');
    });
  });

  test('hasPhoto is false for a null or blank url', () {
    expect(const UserEntity(id: '1').hasPhoto, isFalse);
    expect(const UserEntity(id: '1', photoUrl: ' ').hasPhoto, isFalse);
    expect(const UserEntity(id: '1', photoUrl: 'https://x/y.png').hasPhoto, isTrue);
  });

  test('copyWith keeps the id and replaces the given fields', () {
    const user = UserEntity(id: '1', displayName: 'Ada');
    final copy = user.copyWith(displayName: 'Grace', photoUrl: 'p');

    expect(copy.id, '1');
    expect(copy.displayName, 'Grace');
    expect(copy.photoUrl, 'p');
  });

  test('equality is by value', () {
    expect(const UserEntity(id: '1', email: 'a'), const UserEntity(id: '1', email: 'a'));
    expect(const UserEntity(id: '1'), isNot(const UserEntity(id: '2')));
  });
}
