class PlayerModel {
  final String id;
  final String name;

  PlayerModel({
    required this.id,
    required this.name,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'],
      name: json['name'],
    );
  }
}
