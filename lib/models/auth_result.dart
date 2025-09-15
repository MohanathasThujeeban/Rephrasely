enum AuthResult {
  success,
  emailAlreadyInUse,
  weakPassword,
  userNotFound,
  wrongPassword,
  invalidEmail,
  userDisabled,
  tooManyRequests,
  operationNotAllowed,
  networkError,
  cancelled,
  unknown,
}

class AuthException implements Exception {
  final String message;
  final AuthResult result;

  const AuthException(this.message, this.result);

  @override
  String toString() => 'AuthException: $message';
}
