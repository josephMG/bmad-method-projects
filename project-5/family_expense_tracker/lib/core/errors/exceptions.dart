class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException([this.message = 'You are not authorized to perform this action.']);

  @override
  String toString() => 'UnauthorizedException: $message';
}
