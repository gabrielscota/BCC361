import express from 'express';
import http from 'http';
import { Server } from 'socket.io';
import { v4 as uuidv4 } from 'uuid';
import MatchModel from './match_model';
import MoveModel from './move_model';
import PlayerMatchModel from './player_match_model';
import PlayerModel from './player_model';
import RoomModel from './room_model';

const app = express();
const PORT = 3000;

const server = http.createServer(app);
const io = new Server(server);

const availableRooms: RoomModel[] = [];
export { availableRooms };

const matches: MatchModel[] = [];
export { matches };

const players: PlayerModel[] = [];
export { players };

io.on('connection', (socket) => {
  const playerId = `player-${uuidv4()}`;
  const player = new PlayerModel(playerId, socket.handshake.query.userName as string);
  players.push(player);
  socket.emit('player-connected', player);

  console.log('Usuário conectado:', player);
  
  socket.join('lobby');
  io.to('lobby').emit('available-rooms', availableRooms);
  io.to('lobby').emit('players-online', players.length);

  socket.on('create-room', (roomName) => {
    const roomId = uuidv4();

    const room = new RoomModel(roomId, roomName, playerId);
    availableRooms.push(room);
    
    room.players.push(players.find((player) => player.id === playerId) as PlayerModel);
    
    socket.join(`room-${room.id}`);
    io.to(`room-${room.id}`).emit('room-created', room);
    
    io.to('lobby').emit('available-rooms', availableRooms);
    
    console.log(`Usuário ${playerId} criou a sala ${room.name}`);
    console.log(availableRooms);
  });

  socket.on('join-room', (roomId) => {
    const room = availableRooms.find((room) => room.id === roomId);

    if (room && !room.isFull()) {
      room.players.push(players.find((player) => player.id === playerId) as PlayerModel);

      if(room.isFull()) {
        room.status = 'preparing';
      }

      socket.join(`room-${room.id}`);
      io.to(`room-${room.id}`).emit('room-joined', room);
      
      io.to('lobby').emit('available-rooms', availableRooms);
      
      console.log(`Usuário ${playerId} entrou na sala ${room.name}`);
      console.log(availableRooms);
    }
  });

  socket.on('leave-room', (roomId) => {
    const roomIndex = availableRooms.findIndex((room) => room.id === roomId);

    if (roomIndex !== -1) {
      const room = availableRooms[roomIndex];
      const isCreator = room.creatorId === playerId;
      
      if (isCreator) {
        const otherPlayers = room.players.filter((player) => player.id !== playerId);
        io.to(`room-${room.id}`).emit('room-disbanded', room);
        otherPlayers.forEach((player) => {
          io.to(player.id).emit('room-left', room);
        });
  
        availableRooms.splice(roomIndex, 1);
      } else {
        room.players = room.players.filter((player) => player.id !== playerId);
        
        if(!room.isFull()) {
          room.status = 'waiting';
        }
        
        io.to(`room-${room.id}`).emit('room-left', room);
      }
      
      io.to('lobby').emit('available-rooms', availableRooms);

      console.log(`Usuário ${playerId} saiu da sala ${room.name}`);
      console.log(availableRooms);
    }
  });

  socket.on('start-game', (roomId) => {
    const room = availableRooms.find((room) => room.id === roomId);

    if (room) {
      room.status = 'playing';
      const match = new MatchModel(uuidv4());
      match.players = room.players.map((player) => new PlayerMatchModel(player.id));
      room.matches.push(match);
      io.to(`room-${room.id}`).emit('game-started', room);

      io.to('lobby').emit('available-rooms', availableRooms);
      
      console.log(`Partida iniciada na sala ${room.name}`);
      console.log(availableRooms);
    }
  });

  socket.on('make-move', (roomId, playerId, move) => {
    const room = availableRooms.find((room) => room.id === roomId);
  
    if (room && room.status === 'playing') {
      const match = room.matches[room.matches.length - 1];
      const playerIndex = match.players.findIndex((player) => player.playerId === playerId);    
      match.players[playerIndex].moves.push(new MoveModel(playerId, move));
  
      if (match.players[0].moves.length === match.players[1].moves.length) {
        const player1Move = match.players[0].moves[match.players[0].moves.length - 1].move;
        const player2Move = match.players[1].moves[match.players[1].moves.length - 1].move;
        
        if(player1Move === player2Move) {
          match.roundsWinners.push('draw');
          io.to(`room-${room.id}`).emit('round-result', 'draw', room);
        } else if (
          (player1Move === 'rock' && player2Move === 'scissors') ||
          (player1Move === 'scissors' && player2Move === 'paper') ||
          (player1Move === 'paper' && player2Move === 'rock')
        ) {
          match.roundsWinners.push(match.players[0].playerId);
          io.to(`room-${room.id}`).emit('round-result', 'player1win', room);
        } else {
          match.roundsWinners.push(match.players[1].playerId);
          io.to(`room-${room.id}`).emit('round-result', 'player2win', room);
        }

        const roundsWinners = match.roundsWinners.filter((winner) => winner !== 'draw');
        if (roundsWinners.length === 3 || roundsWinners.length === 2 && roundsWinners[0] === roundsWinners[1]) {
          const player1Score = roundsWinners.filter((winner) => winner === match.players[0].playerId).length;
          const player2Score = roundsWinners.filter((winner) => winner === match.players[1].playerId).length;
          match.winner = player1Score > player2Score ? match.players[0].playerId : match.players[1].playerId;
          room.status = 'finished';
          io.to(`room-${room.id}`).emit('match-result', match.winner, room);
        }
      }
    }
  });

  socket.on('disconnect', () => {
    const roomsToRemove = availableRooms.filter((room) => room.creatorId === playerId);

    roomsToRemove.forEach((room) => {
      const otherPlayers = room.players.filter((player) => player.id !== playerId);
      io.to(`room-${room.id}`).emit('room-disbanded');
      otherPlayers.forEach((player) => {
        io.to(player.id).emit('room-left');
      });
    });
    
    roomsToRemove.forEach((room) => {
      const roomIndex = availableRooms.findIndex((availableRoom) => availableRoom.id === room.id);
      availableRooms.splice(roomIndex, 1);
    });
    
    const playerIndex = players.findIndex((player) => player.id === playerId);
    players.splice(playerIndex, 1);

    io.to('lobby').emit('available-rooms', availableRooms);
    io.to('lobby').emit('players-online', players.length);
    
    console.log('Usuário desconectado:', socket.id);
  });
});

server.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});
