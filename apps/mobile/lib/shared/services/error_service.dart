import 'package:firebase_auth/firebase_auth.dart';

class AppException implements Exception {
  final String userMessage;
  final String? technicalDetail;

  AppException(this.userMessage, {this.technicalDetail});

  @override
  String toString() => userMessage;
}

String friendlyErrorMessage(Object error) {
  if (error is AppException) return error.userMessage;

  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return 'Authentication error. Please try again.';
    }
  }

  if (error is FirebaseException) {
    switch (error.code) {
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again.';
      case 'permission-denied':
        return 'You don\'t have permission for this action.';
      case 'not-found':
        return 'The requested data was not found.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  final msg = error.toString();
  if (msg.contains('SocketException') || msg.contains('network')) {
    return 'No internet connection. Please check your network.';
  }

  return 'Something went wrong. Please try again.';
}
