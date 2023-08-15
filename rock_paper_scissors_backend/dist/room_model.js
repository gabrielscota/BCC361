"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
class RoomModel {
    constructor(id, name, creatorId) {
        this.id = id;
        this.name = name;
        this.creatorId = creatorId;
        this.status = 'waiting';
        this.players = [];
        this.spectators = [];
    }
    isFull() {
        return this.players.length === 2;
    }
}
exports.default = RoomModel;
