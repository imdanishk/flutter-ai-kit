import 'strings.dart';

/// Validators return an error message, or null when the value is valid.
String? validateEmail(String value) {
  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
  return ok ? null : AppStrings.invalidEmail;
}

String? validatePassword(String value) =>
    value.length >= 8 ? null : AppStrings.passwordTooShort;

String? validateRequired(String value, String message) =>
    value.trim().isEmpty ? message : null;
