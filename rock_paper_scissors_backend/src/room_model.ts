import MatchModel from "./match_model";
import PlayerModel from "./player_model";

class RoomModel {
  id: string;
  name: string;
  creatorId: string;
  status: string;
  players: PlayerModel[];
  matches: MatchModel[];

  constructor(id: string, name: string, creatorId: string) {
    this.id = id;
    this.name = name;
    this.creatorId = creatorId;
    this.status = 'waiting';
    this.players = [];
    this.matches = [];
  }

  isFull(): boolean {
    return this.players.length === 2;
  }
}

export default RoomModel;
