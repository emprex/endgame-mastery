class EngineConfig {
  const EngineConfig({
    this.moveTime = const Duration(
      milliseconds: 250,
    ),
    this.depth,
  }) : assert(
          depth == null || depth > 0,
          'depth must be greater than zero',
        );

  final Duration moveTime;

  final int? depth;

  EngineConfig copyWith({
    Duration? moveTime,
    int? depth,
    bool clearDepth = false,
  }) {
    return EngineConfig(
      moveTime: moveTime ?? this.moveTime,
      depth: clearDepth
          ? null
          : depth ?? this.depth,
    );
  }
}
