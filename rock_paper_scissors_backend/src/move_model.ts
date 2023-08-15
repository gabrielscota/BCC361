class MoveModel {
  playerId: string;
  move: string;

  constructor(playerId: string, move: string) {
    this.playerId = playerId;
    this.move = move;
  }
}

export default MoveModel;
