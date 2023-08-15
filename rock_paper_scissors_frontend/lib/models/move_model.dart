class MoveModel {
  final String playerId;
  final String move;

  MoveModel({
    required this.playerId,
    required this.move,
  });

  factory MoveModel.fromJson(Map<String, dynamic> json) {
    return MoveModel(
      playerId: json['playerId'],
      move: json['move'],
    );
  }
}
