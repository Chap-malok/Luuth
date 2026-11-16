import 'game_state.dart';

enum LuuthMoveEventType {
  initialPickup,
  stoneMovement,
  relayPickup,
}

class LuuthMoveEvent {
  final LuuthMoveEventType type;
  final int? fromPit;
  final int? toPit;
  final int? pitIndex;
  final List<int> boardState;
  final int stonesInHand;

  LuuthMoveEvent({
    required this.type,
    required this.boardState,
    required this.stonesInHand,
    this.fromPit,
    this.toPit,
    this.pitIndex,
  });
}

class LuuthMoveResult {
  final GameState? state;
  final String? error;
  final List<LuuthMoveEvent> events;

  const LuuthMoveResult.success(this.state, this.events)
      : error = null;

  const LuuthMoveResult.failure(this.error)
      : state = null,
        events = const [];

  bool get isValid => state != null;

  // Compatibility with the existing game_screen.dart.
  List<List<int>> get frames =>
      events.map((event) => event.boardState).toList();
}

class GameEngine {
  static LuuthMoveResult playMove(
    GameState currentState,
    int selectedPit,
  ) {
    if (selectedPit < 0 || selectedPit >= 14) {
      return const LuuthMoveResult.failure('Invalid pit.');
    }

    if (!currentState.ownsPit(
      selectedPit,
      currentState.currentPlayer,
    )) {
      return const LuuthMoveResult.failure(
        'You can only select pits on your side.',
      );
    }

    if (currentState.pits[selectedPit] == 0) {
      return const LuuthMoveResult.failure(
        'This pit is empty. Select another pit.',
      );
    }

    final pits = List<int>.from(currentState.pits);
    final events = <LuuthMoveEvent>[];

    int stonesInHand = pits[selectedPit];

    // Pick up stones from the selected pit.
    pits[selectedPit] = 0;

    events.add(
      LuuthMoveEvent(
        type: LuuthMoveEventType.initialPickup,
        pitIndex: selectedPit,
        boardState: List<int>.from(pits),
        stonesInHand: stonesInHand,
      ),
    );

    int currentIndex = selectedPit;

    final visitedPositions = <String>{};

    while (true) {
      // Distribute stones anticlockwise.
      while (stonesInHand > 0) {
        final previousIndex = currentIndex;

        currentIndex = (currentIndex - 1 + 14) % 14;

        pits[currentIndex]++;
        stonesInHand--;

        events.add(
          LuuthMoveEvent(
            type: LuuthMoveEventType.stoneMovement,
            fromPit: previousIndex,
            toPit: currentIndex,
            boardState: List<int>.from(pits),
            stonesInHand: stonesInHand,
          ),
        );
      }

      // Relay sowing when the last stone lands in an
      // already occupied pit.
      if (pits[currentIndex] > 1) {
        final position = '${pits.join(',')}|$currentIndex';

        if (!visitedPositions.add(position)) {
          return const LuuthMoveResult.failure(
            'A repeating relay sequence was detected. '
            'The game rule needs clarification.',
          );
        }

        stonesInHand = pits[currentIndex];
        pits[currentIndex] = 0;

        events.add(
          LuuthMoveEvent(
            type: LuuthMoveEventType.relayPickup,
            pitIndex: currentIndex,
            boardState: List<int>.from(pits),
            stonesInHand: stonesInHand,
          ),
        );

        continue;
      }

      break;
    }

    final nextPlayer =
        currentState.currentPlayer == LuuthPlayer.player1
            ? LuuthPlayer.player2
            : LuuthPlayer.player1;

    return LuuthMoveResult.success(
      GameState(
        pits: pits,
        currentPlayer: nextPlayer,
      ),
      events,
    );
  }
}