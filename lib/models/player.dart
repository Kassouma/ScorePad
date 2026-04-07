import 'package:flutter/material.dart';

class Player {
  final int? id;
  final String name;
  final Color color;
  final int position;

  const Player({
    this.id,
    required this.name,
    required this.color,
    required this.position,
  });

  Player copyWith({int? id, String? name, Color? color, int? position}) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      position: position ?? this.position,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'color_hex': color.toARGB32(),
        'position': position,
      };

  factory Player.fromMap(Map<String, dynamic> map) => Player(
        id: map['id'] as int,
        name: map['name'] as String,
        color: Color(map['color_hex'] as int),
        position: map['position'] as int,
      );
}
