class DomainException implements Exception {
  final String message;
  final dynamic originalError;

  DomainException(this.message, [this.originalError]);

  @override
  String toString() => 'DomainException: $message ${originalError != null ? '($originalError)' : ''}';
}

class FetchFailure extends DomainException {
  FetchFailure(super.message, [super.originalError]);
}

class SaveFailure extends DomainException {
  SaveFailure(super.message, [super.originalError]);
}

class DeleteFailure extends DomainException {
  DeleteFailure(super.message, [super.originalError]);
}

class NotFoundException extends DomainException {
  NotFoundException(super.message);
}
