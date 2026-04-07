import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/player.dart';

class DatabaseService {
  static Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'scorepad.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE players (
            id      INTEGER PRIMARY KEY AUTOINCREMENT,
            name    TEXT    NOT NULL,
            color_hex INTEGER NOT NULL,
            position INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE scores (
            player_id   INTEGER NOT NULL,
            round_index INTEGER NOT NULL,
            score       INTEGER NOT NULL,
            PRIMARY KEY (player_id, round_index)
          )
        ''');
        await db.execute('''
          CREATE TABLE meta (
            key   TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // ── Players ────────────────────────────────────────────────────────────────

  Future<void> savePlayers(List<Player> players) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('players');
      for (final p in players) {
        await txn.insert('players', p.toMap());
      }
    });
  }

  Future<List<Player>> loadPlayers() async {
    final db = await database;
    final rows = await db.query('players', orderBy: 'position ASC');
    return rows.map(Player.fromMap).toList();
  }

  // ── Scores ─────────────────────────────────────────────────────────────────

  Future<void> saveScore({
    required int playerId,
    required int roundIndex,
    required int score,
  }) async {
    final db = await database;
    await db.insert(
      'scores',
      {'player_id': playerId, 'round_index': roundIndex, 'score': score},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Returns rounds[roundIndex][playerIndex] = score or null.
  Future<List<List<int?>>> loadRounds(
      List<Player> players, int liveRound) async {
    final db = await database;
    final rows = await db.query('scores');

    // Build a map of (playerId, roundIndex) -> score
    final Map<(int, int), int> scoreMap = {};
    for (final row in rows) {
      scoreMap[(row['player_id'] as int, row['round_index'] as int)] =
          row['score'] as int;
    }

    final rounds = List.generate(liveRound + 1, (r) {
      return List.generate(players.length, (i) {
        final id = players[i].id;
        if (id == null) return null;
        return scoreMap[(id, r)];
      });
    });
    return rounds;
  }

  Future<void> clearScores() async {
    final db = await database;
    await db.delete('scores');
  }

  // ── Meta ───────────────────────────────────────────────────────────────────

  Future<void> setMeta(String key, String value) async {
    final db = await database;
    await db.insert(
      'meta',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getMeta(String key) async {
    final db = await database;
    final rows =
        await db.query('meta', where: 'key = ?', whereArgs: [key]);
    if (rows.isEmpty) return null;
    return rows.first['value'] as String;
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('players');
      await txn.delete('scores');
      await txn.delete('meta');
    });
  }
}
