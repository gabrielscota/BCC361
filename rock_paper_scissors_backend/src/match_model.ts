import PlayerMatchModel from "./player_match_model";

class MatchModel {
  id: string;
  players: PlayerMatchModel[];
  roundsWinners: string[];
  winner: string;

  constructor(id: string) {
    this.id = id;
    this.players = [];
    this.roundsWinners = [];
    this.winner = '';
  }
}

export default MatchModel;

