import 'models.dart';

enum RoomStatus { waiting, playing, preparing, finished }

class RoomModel {
  final String id;
  final String name;
  final String creatorId;
  final RoomStatus status;
  final List<PlayerModel> players;
  final List<MatchModel> matches;

  RoomModel({
    required this.id,
    required this.name,
    required this.creatorId,
    this.status = RoomStatus.waiting,
    this.players = const [],
    this.matches = const [],
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'],
      name: json['name'],
      creatorId: json['creatorId'],
      status: RoomStatus.values.firstWhere((status) => status.name == json['status']),
      players:
          json['players'] != null ? (json['players'] as List).map((json) => PlayerModel.fromJson(json)).toList() : [],
      matches:
          json['matches'] != null ? (json['matches'] as List).map((json) => MatchModel.fromJson(json)).toList() : [],
    );
  }

  bool isFull() => players.length == 2;
}
