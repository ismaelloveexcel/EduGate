// lib/shared/services/pin_service.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';

class PinService {
  /// Hash a PIN using SHA-256 with a fixed salt.
  /// In production, consider a stronger KDF (bcrypt, argon2).
  static String hashPin(String pin) {
    // TODO: Use a per-child random salt stored separately for production
    const salt = 'edugate_pin_salt_v1';
    final bytes = utf8.encode('$salt:$pin');
    return sha256.convert(bytes).toString();
  }

  static bool verifyPin(String pin, String pinHash) {
    return hashPin(pin) == pinHash;
  }
}
