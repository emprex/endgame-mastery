sealed class EngineException
    implements Exception {
  const EngineException(
    this.message,
  );

  final String message;

  @override
  String toString() {
    return '$runtimeType: $message';
  }
}

class EngineInitializationException
    extends EngineException {
  const EngineInitializationException(
    super.message,
  );
}

class EngineSearchException
    extends EngineException {
  const EngineSearchException(
    super.message,
  );
}

class EngineTimeoutException
    extends EngineException {
  const EngineTimeoutException(
    super.message,
  );
}

class EngineDisposedException
    extends EngineException {
  const EngineDisposedException()
      : super(
          'The chess engine has already been disposed.',
        );
}
