import MoveModel from "./move_model";

class PlayerMatchModel {
  playerId: string;
  moves: MoveModel[];
  score: number;

  constructor(playerId: string) {
    this.playerId = playerId;
    this.moves = [];
    this.score = 0;
  }
}

export default PlayerMatchModel;
