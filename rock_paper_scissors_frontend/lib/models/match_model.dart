import 'models.dart';

class MatchModel {
  final String id;
  final List<PlayerMatchModel> players;
  final List<String> roundsWinners;
  final String winner;

  MatchModel({
    required this.id,
    this.players = const [],
    this.roundsWinners = const [],
    this.winner = '',
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'],
      players: json['players'] != null
          ? (json['players'] as List).map((json) => PlayerMatchModel.fromJson(json)).toList()
          : [],
      roundsWinners: json['roundsWinners'] != null ? List<String>.from(json['roundsWinners']) : [],
      winner: json['winner'],
    );
  }
}
