enum LuuthPlayer {
  player1,
  player2,
}

class GameState {
  final List<int> pits;
  final LuuthPlayer currentPlayer;

  GameState({
    required this.pits,
    required this.currentPlayer,
  });

  // Start a new game with four stones in each pit.
  factory GameState.initial() {
    return GameState(
      pits: List<int>.filled(14, 4),
      currentPlayer: LuuthPlayer.player1,
    );
  }

  // Player 1 owns the bottom seven pits.
  // Player 2 owns the top seven pits.
  bool ownsPit(int index, LuuthPlayer player) {
    if (player == LuuthPlayer.player1) {
      return index >= 7 && index <= 13;
    }

    return index >= 0 && index <= 6;
  }

  // Calculate the total stones on each player's side.
  int stonesOnSide(LuuthPlayer player) {
    if (player == LuuthPlayer.player1) {
      return pits.sublist(7, 14).fold(0, (a, b) => a + b);
    }

    return pits.sublist(0, 7).fold(0, (a, b) => a + b);
  }
}