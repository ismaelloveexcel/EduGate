import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edugate/shared/services/error_service.dart';

void main() {
  group('friendlyErrorMessage', () {
    test('returns message for AppException', () {
      final error = AppException('Custom message');
      expect(friendlyErrorMessage(error), 'Custom message');
    });

    test('returns friendly message for generic error', () {
      expect(friendlyErrorMessage(Exception('random')), 'Something went wrong. Please try again.');
    });

    test('returns network message for socket errors', () {
      expect(
        friendlyErrorMessage(Exception('SocketException: Connection refused')),
        'No internet connection. Please check your network.',
      );
    });
  });
}
