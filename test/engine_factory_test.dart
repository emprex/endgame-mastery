import 'package:endgame_mastery/core/engine/chess_engine.dart';
import 'package:endgame_mastery/core/engine/engine_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'engine factory creates a usable platform engine',
    () async {
      final ChessEngine engine =
          createChessEngine();

      await engine.initialize();

      await engine.dispose();
    },
  );
}
