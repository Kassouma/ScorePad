import 'package:flutter/material.dart';

import '../constants/player_colors.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import '../services/database_service.dart';

class GameProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  // ── Setup state (mutable before game starts) ───────────────────────────────
  List<Player> setupPlayers = [];

  // ── In-game state ──────────────────────────────────────────────────────────
  GameState? _state;
  GameState? get state => _state;

  bool _loading = true;
  bool get loading => _loading;

  // ── Init ───────────────────────────────────────────────────────────────────

  Future<void> init() async {
    final players = await _db.loadPlayers();
    if (players.isEmpty) {
      setupPlayers = _defaultPlayers();
      _loading = false;
      notifyListeners();
      return;
    }

    final liveRoundStr = await _db.getMeta('live_round');
    final currentRoundStr = await _db.getMeta('current_round');
    final liveRound = int.tryParse(liveRoundStr ?? '0') ?? 0;
    final currentRound = int.tryParse(currentRoundStr ?? '0') ?? 0;

    final rounds = await _db.loadRounds(players, liveRound);

    _state = GameState(
      players: players,
      rounds: rounds,
      currentRound: currentRound,
      liveRound: liveRound,
    );
    _loading = false;
    notifyListeners();
  }

  // ── Setup actions ──────────────────────────────────────────────────────────

  void resetSetup() {
    setupPlayers = _defaultPlayers();
    notifyListeners();
  }

  void addSetupPlayer() {
    if (setupPlayers.length >= 8) return;
    final idx = setupPlayers.length;
    setupPlayers = [
      ...setupPlayers,
      Player(
        name: '',
        color: kPlayerColors[idx % kPlayerColors.length],
        position: idx,
      ),
    ];
    notifyListeners();
  }

  void removeSetupPlayer(int index) {
    if (setupPlayers.length <= 2) return;
    final updated = [...setupPlayers]..removeAt(index);
    setupPlayers = _reindexed(updated);
    notifyListeners();
  }

  void renameSetupPlayer(int index, String name) {
    final updated = [...setupPlayers];
    updated[index] = updated[index].copyWith(name: name);
    setupPlayers = updated;
    // no notifyListeners — text field manages itself
  }

  void reorderSetupPlayer(int oldIndex, int newIndex) {
    final updated = [...setupPlayers];
    if (newIndex > oldIndex) newIndex--;
    final player = updated.removeAt(oldIndex);
    updated.insert(newIndex, player);
    setupPlayers = _reindexed(updated);
    notifyListeners();
  }

  // ── Start game ─────────────────────────────────────────────────────────────

  Future<void> startGame() async {
    // Fill empty names with defaults
    final players = setupPlayers.asMap().entries.map((e) {
      final name =
          e.value.name.trim().isEmpty ? 'Player ${e.key + 1}' : e.value.name.trim();
      return e.value.copyWith(name: name, position: e.key);
    }).toList();

    await _db.clearAll();
    await _db.savePlayers(players);

    // Reload to get auto-generated IDs
    final saved = await _db.loadPlayers();

    await _db.setMeta('live_round', '0');
    await _db.setMeta('current_round', '0');

    _state = GameState(
      players: saved,
      rounds: [List.filled(saved.length, null)],
      currentRound: 0,
      liveRound: 0,
    );
    notifyListeners();
  }

  // ── Game actions ───────────────────────────────────────────────────────────

  Future<void> enterScore(int playerIndex, int sign, int value) async {
    final s = _state!;
    if (!s.isViewingLive) return;

    final delta = sign * value;
    final prev = s.rounds[s.liveRound][playerIndex] ?? 0;
    final newScore = prev + delta;

    final newRounds = _copyRounds(s.rounds);
    newRounds[s.liveRound][playerIndex] = newScore;

    final player = s.players[playerIndex];
    await _db.saveScore(
      playerId: player.id!,
      roundIndex: s.liveRound,
      score: newScore,
    );

    _state = s.copyWith(rounds: newRounds);
    notifyListeners();
  }

  Future<void> nextRound() async {
    final s = _state!;
    if (!s.isViewingLive || !s.currentRoundComplete) return;

    final newLive = s.liveRound + 1;
    final newRounds = _copyRounds(s.rounds)
      ..add(List.filled(s.players.length, null));

    await _db.setMeta('live_round', newLive.toString());
    await _db.setMeta('current_round', newLive.toString());

    _state = s.copyWith(
      rounds: newRounds,
      liveRound: newLive,
      currentRound: newLive,
    );
    notifyListeners();
  }

  void goToRound(int index) {
    if (_state == null) return;
    _state = _state!.copyWith(currentRound: index);
    notifyListeners();
  }

  void goToLive() {
    if (_state == null) return;
    _state = _state!.copyWith(currentRound: _state!.liveRound);
    notifyListeners();
  }

  Future<void> resetScores() async {
    final s = _state!;
    await _db.clearScores();
    await _db.setMeta('live_round', '0');
    await _db.setMeta('current_round', '0');

    _state = GameState(
      players: s.players,
      rounds: [List.filled(s.players.length, null)],
      currentRound: 0,
      liveRound: 0,
    );
    notifyListeners();
  }

  void backToSetup() {
    setupPlayers = List.from(_state?.players ?? _defaultPlayers());
    _state = null;
    notifyListeners();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  List<Player> _defaultPlayers() => [
        Player(name: 'Player 1', color: kPlayerColors[0], position: 0),
        Player(name: 'Player 2', color: kPlayerColors[1], position: 1),
      ];

  List<Player> _reindexed(List<Player> players) {
    return players
        .asMap()
        .entries
        .map((e) => e.value.copyWith(position: e.key))
        .toList();
  }

  List<List<int?>> _copyRounds(List<List<int?>> rounds) {
    return rounds.map((r) => List<int?>.from(r)).toList();
  }
}
