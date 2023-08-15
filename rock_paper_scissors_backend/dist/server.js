"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.availableRooms = void 0;
const express_1 = __importDefault(require("express"));
const http_1 = __importDefault(require("http"));
const socket_io_1 = require("socket.io");
const uuid_1 = require("uuid");
const room_model_1 = __importDefault(require("./room_model"));
const app = (0, express_1.default)();
const PORT = 3000;
// app.use(function(req, res, next) {
//   res.header("Access-Control-Allow-Origin", "*");
//   res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
//   next();
// });
const server = http_1.default.createServer(app);
const io = new socket_io_1.Server(server);
// Lista de salas disponíveis do jogo (inicialmente vazia)
const availableRooms = [];
exports.availableRooms = availableRooms;
// Numero de jogadores conectados
let numPlayers = 0;
// Configuração do Socket.IO
io.on('connection', (socket) => {
    console.log('Novo usuário conectado:', socket.id);
    const playerId = `player-${(0, uuid_1.v4)()}`;
    socket.emit('player-id', playerId);
    numPlayers++;
    socket.join('lobby');
    io.to('lobby').emit('available-rooms', availableRooms);
    io.to('lobby').emit('players-online', numPlayers);
    // Evento para criar uma sala
    socket.on('create-room', (roomName) => {
        const roomId = (0, uuid_1.v4)();
        const room = new room_model_1.default(roomId, roomName, playerId);
        availableRooms.push(room);
        room.players.push(playerId);
        socket.join(`room-${room.id}`);
        io.to(`room-${room.id}`).emit('room-created', room);
        io.to('lobby').emit('available-rooms', availableRooms);
        console.log(`Usuário ${playerId} criou a sala ${room.name}`);
        console.log(availableRooms);
    });
    // Evento para entrar em uma sala
    socket.on('join-room', (roomId) => {
        const room = availableRooms.find((room) => room.id === roomId);
        if (room && !room.isFull()) {
            room.players.push(playerId);
            if (room.isFull()) {
                room.status = 'preparing';
            }
            socket.join(`room-${room.id}`);
            io.to(`room-${room.id}`).emit('room-joined', room);
            io.to('lobby').emit('available-rooms', availableRooms);
            console.log(`Usuário ${playerId} entrou na sala ${room.name}`);
            console.log(availableRooms);
        }
    });
    // Evento para sair de uma sala
    socket.on('leave-room', (roomId) => {
        const roomIndex = availableRooms.findIndex((room) => room.id === roomId);
        if (roomIndex !== -1) {
            const room = availableRooms[roomIndex];
            const isCreator = room.creatorId === playerId;
            if (isCreator) {
                const otherPlayers = room.players.filter((player) => player !== playerId);
                io.to(`room-${room.id}`).emit('room-disbanded');
                otherPlayers.forEach((player) => {
                    io.to(player).emit('room-left');
                });
                availableRooms.splice(roomIndex, 1);
            }
            else {
                room.players = room.players.filter((player) => player !== playerId);
                io.to(`room-${room.id}`).emit('room-left', room);
            }
            if (!room.isFull()) {
                room.status = 'waiting';
            }
            io.to('lobby').emit('available-rooms', availableRooms);
            console.log(`Usuário ${playerId} saiu da sala ${room.name}`);
            console.log(availableRooms);
        }
    });
    // Evento para iniciar uma partida
    socket.on('start-game', (roomId) => {
        const room = availableRooms.find((room) => room.id === roomId);
        if (room) {
            room.status = 'playing';
            io.to(`room-${room.id}`).emit('game-started', room);
            io.to('lobby').emit('available-rooms', availableRooms);
            console.log(`Partida iniciada na sala ${room.name}`);
            console.log(availableRooms);
        }
    });
    socket.on('disconnect', () => {
        numPlayers--;
        io.to('lobby').emit('players-online', numPlayers);
        console.log('Usuário desconectado:', socket.id);
    });
});
server.listen(PORT, () => {
    console.log(`Servidor rodando na porta ${PORT}`);
});
