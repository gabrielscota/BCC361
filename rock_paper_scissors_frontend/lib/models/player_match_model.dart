import 'models.dart';

class PlayerMatchModel {
  final String id;
  final List<MoveModel> moves;
  final int score;

  PlayerMatchModel({
    required this.id,
    this.moves = const [],
    this.score = 0,
  });

  factory PlayerMatchModel.fromJson(Map<String, dynamic> json) {
    return PlayerMatchModel(
      id: json['playerId'],
      moves: json['moves'] != null ? (json['moves'] as List).map((json) => MoveModel.fromJson(json)).toList() : [],
      score: json['score'],
    );
  }
}
