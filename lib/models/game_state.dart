import 'player.dart';

/// rounds[roundIndex][playerIndex] = score (null = not yet entered)
class GameState {
  final List<Player> players;
  final List<List<int?>> rounds;
  final int currentRound;
  final int liveRound;

  const GameState({
    required this.players,
    required this.rounds,
    required this.currentRound,
    required this.liveRound,
  });

  bool get isViewingLive => currentRound == liveRound;

  List<int> get totals => List.generate(
        players.length,
        (i) => rounds.fold(0, (sum, r) => sum + (r[i] ?? 0)),
      );

  int get maxTotal {
    final t = totals;
    return t.isEmpty ? 0 : t.reduce((a, b) => a > b ? a : b);
  }

  bool get currentRoundComplete =>
      rounds[currentRound].every((s) => s != null);

  GameState copyWith({
    List<Player>? players,
    List<List<int?>>? rounds,
    int? currentRound,
    int? liveRound,
  }) {
    return GameState(
      players: players ?? this.players,
      rounds: rounds ?? this.rounds,
      currentRound: currentRound ?? this.currentRound,
      liveRound: liveRound ?? this.liveRound,
    );
  }
}
