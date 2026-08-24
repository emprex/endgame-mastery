# Endgame Mastery

**Endgame Mastery** is a Flutter-based interactive chess endgame learning application designed to teach endgame concepts through structured lessons, guided practice, proof sessions, and engine-backed gameplay.

The project is being developed as a commercial-quality, cross-platform product for **Android, iOS, and Web**, with an offline-first architecture.

> The goal is not to build a chessboard with Stockfish attached. The goal is to build an interactive endgame coach.

## Product Vision

The learning flow is structured around five stages:

```text
LEARN
→ PRACTICE
→ PROVE
→ RESULT
→ NEXT
```

The first curriculum focuses on:

```text
Pawn Endgames
→ Key Squares
```

Pedagogical design is inspired by classical endgame teaching, including Mark Dvoretsky's *Endgame Manual*. Endgame Mastery is an independent project and is not affiliated with the author or publisher.

A core architectural principle is:

```text
Stockfish is infrastructure, not the teacher.
```

The long-term teaching model is designed to combine:

```text
verified curriculum theory
+
tablebase truth
+
Stockfish evaluation
```

without using engine evaluation as a substitute for endgame theory.

## Current Status

### Phase 1 — Chessboard Foundation ✅

Implemented and validated:

- responsive 8×8 chessboard
- arbitrary FEN loading
- legal move validation with `package:chess`
- click-click movement
- drag-and-drop
- legal target highlighting
- selected-square state
- last-move highlighting
- board flipping
- reset
- vector chess pieces
- check detection
- promotion to Q/R/B/N
- checkmate, stalemate, and draw handling
- game-over overlay
- responsive Web layout

### Phase 2 — Stockfish Web ✅

Stockfish 18 Lite runs in a WebWorker through a clean engine abstraction.

Validated behavior includes:

- asynchronous engine search
- immediate human move repaint
- interaction lock while the engine is searching
- stale-response rejection
- reset during calculation
- timeout recovery
- successive engine searches
- engine promotion
- legality validation before engine moves are applied

The engine layer is deliberately separated from the chessboard UI.

### Phase 3 — Curriculum Foundation ✅

A data-driven teaching architecture now exists independently from the board and engine layers.

Implemented:

- lesson domain model
- theoretical position outcomes
- side-to-move-aware theoretical truth
- semantic pedagogical overlays
- Key Squares concept rule
- FEN pawn locator
- TeachingState
- curriculum validation
- conservative unsupported/unknown behavior for unverified theory

The first verified Key Squares lesson preserves the critical distinction:

```text
8/3k4/8/3K4/3P4/8/8/8 w - - 0 1
→ Draw

8/3k4/8/3K4/3P4/8/8/8 b - - 0 1
→ White wins
```

with key squares:

```text
c6 d6 e6
```

The white king on `d5` is not itself on a key square.

### Phase 4 — Lesson Session Domain 🚧

Completed so far:

- **4.1** Lesson session state machine
- **4.2** Explicit proof/session outcome model
- **4.3** Proof evaluation against verified curriculum truth

The current lifecycle is modeled independently from Flutter widgets and Stockfish:

```text
Learn → Practice → Prove → Result → Completed
```

Proof evaluation distinguishes between:

```text
TheoreticalResult
= verified curriculum truth

LessonSessionOutcome
= result actually achieved by the learner
```

Unknown theoretical positions remain explicitly unsupported rather than being guessed.

## Architecture

The application keeps gameplay, engine infrastructure, curriculum truth, and teaching state separate.

```text
                         CURRICULUM
                             |
                     LessonDefinition
                             |
              +--------------+--------------+
              |                             |
     Theoretical truth                Concept rules
              |                             |
  LessonPositionOutcome            KeySquaresRule
              |                             |
              |                       FenPawnLocator
              |                             |
              |                PedagogicalOverlayEngine
              |                             |
              +--------------+--------------+
                             |
                       TeachingState


BoardScreen
    |
GameEngineController
    |
    +-- ChessController
    |
    +-- ChessEngine
             |
        Engine Factory
          /       \
       Web        Native
        |           |
StockfishWebEngine  LegalMoveTestEngine
        |
     WebWorker
        |
Stockfish 18 Lite WASM
```

This separation allows chess theory to remain testable and independent from engine behavior or presentation code.

## Engineering Principles

- **Verified theory over guesses** — unsupported endgame positions stay unknown until validated.
- **Side to move is part of theoretical truth** — identical piece placement can have a different result depending on whose move it is.
- **Stockfish is not pedagogical truth** — engine evaluation does not replace endgame theory.
- **FENs are validated carefully** — curriculum positions are tested piece by piece.
- **Small incremental phases** — each architecture block is tested before integration.
- **UI and domain separation** — pedagogical rules do not live inside `BoardScreen`.
- **Cross-platform design** — Android, iOS, and Web remain first-class targets.

## Testing

The project has automated tests covering the chessboard, engine orchestration, curriculum model, overlays, concept rules, teaching state, lesson session lifecycle, proof outcomes, and proof evaluation.

At the end of Phase 4.3, the suite passes **102 tests**.

Typical quality gate:

```bash
flutter analyze
flutter test
```

A release Web build is used after meaningful integration work:

```bash
flutter build web --release --no-wasm-dry-run
```

## Tech Stack

- Flutter 3.47
- Dart 3.13
- `package:chess`
- Stockfish 18 Lite
- WebAssembly
- WebWorker-based Web engine execution
- immutable/domain-driven curriculum models
- Flutter test suite

## Repository Structure

Key areas:

```text
lib/
├── core/
│   ├── chess/
│   ├── engine/
│   └── game/
│
├── features/
│   ├── board/
│   └── lessons/
│       ├── data/
│       ├── domain/
│       ├── overlay/
│       ├── rules/
│       ├── session/
│       ├── teaching/
│       └── validation/
│
└── main.dart
```

## Roadmap

Near-term development:

- Phase 4.4 — curriculum navigation / next lesson
- Phase 4.5 — session integration contract
- pedagogical UI integration
- Learn / Practice / Prove / Result screens
- visual semantic overlays on the chessboard
- hints and move explanations
- broader Pawn Endgames curriculum
- tablebase integration
- native Stockfish integration for Android/iOS
- persistent learner progress

## Portfolio Context

This repository demonstrates work across several engineering areas:

- Flutter application architecture
- chess rules and state management
- asynchronous engine integration
- WebAssembly/WebWorker integration
- domain-driven curriculum modeling
- immutable state machines
- correctness-focused test design
- educational UX architecture
- separation of engine analysis from verified domain truth

The project is under active development.
