import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart';

import 'models/models.dart';

class SocketService {
  static SocketService? _instance;

  SocketService._internal();

  factory SocketService() {
    _instance ??= SocketService._internal();

    return _instance!;
  }

  static late Socket _socket;
  Socket get socket => _socket;

  static String get userId => _socket.id ?? '';

  static String _userName = '';
  static String get userName => _userName;
  static void setUserName(String name) => _userName = name;

  static late PlayerModel _player;
  static PlayerModel get player => _player;

  static late StreamController<List<RoomModel>> _roomsResponseStreamController;
  static Stream<List<RoomModel>> get roomsResponseStream => _roomsResponseStreamController.stream.asBroadcastStream();

  static late StreamController<int> _numOfPlayersOnlineResponseStreamController;
  static Stream<int> get numOfPlayersOnlineResponseStream =>
      _numOfPlayersOnlineResponseStreamController.stream.asBroadcastStream();

  static late StreamController<RoomModel> _joinedRoomResponseStreamController;
  static Stream<RoomModel> get joinedRoomResponseStream => _joinedRoomResponseStreamController.stream;

  static late BuildContext context;

  static void init(BuildContext context) {
    if (_instance == null) {
      SocketService.context = context;

      _roomsResponseStreamController = StreamController<List<RoomModel>>();
      _numOfPlayersOnlineResponseStreamController = StreamController<int>();
      _joinedRoomResponseStreamController = StreamController<RoomModel>();

      _socket = io(
        '${dotenv.env['SERVER_URL']}:${dotenv.env['SOCKET_PORT']}',
        OptionBuilder().setTransports(['websocket']).disableAutoConnect().setQuery({'userName': _userName}).build(),
      );

      _socket.onConnect((_) => debugPrint('Conectado ao servidor'));

      _socket.onConnectError((data) {
        _roomsResponseStreamController.sink.addError('Erro ao conectar ao servidor.\nMotivo: [$data]');

        debugPrint('Erro na conexão com o servidor: $data');
      });

      _socket.onDisconnect((_) => debugPrint('Desconectado do servidor'));

      _socket.on('player-connected', (data) => _player = PlayerModel.fromJson(data));

      _socket.on('available-rooms', (rooms) {
        final List<RoomModel> roomsList = [];
        rooms.forEach((room) {
          roomsList.add(RoomModel.fromJson(room));
        });

        _roomsResponseStreamController.sink.add(roomsList);
      });

      _socket.on('players-online', (numPlayers) {
        final int numOfPlayersOnline = numPlayers;
        _numOfPlayersOnlineResponseStreamController.sink.add(numOfPlayersOnline);
      });

      _socket.on('room-created', (room) {
        final RoomModel roomModel = RoomModel.fromJson(room);

        _joinedRoomResponseStreamController = StreamController<RoomModel>();
        _joinedRoomResponseStreamController.sink.add(roomModel);

        if (context.mounted) {
          context.pushNamed(
            'room',
            pathParameters: {'id': roomModel.id},
            extra: roomModel,
          );
        }
      });

      _socket.on('room-joined', (room) {
        final RoomModel roomModel = RoomModel.fromJson(room);

        _joinedRoomResponseStreamController.sink.add(roomModel);

        if (context.mounted && roomModel.players.last.id == _player.id) {
          context.pushNamed(
            'room',
            pathParameters: {'id': roomModel.id},
            extra: roomModel,
          );
        }
      });

      _socket.on('room-left', (room) {
        final RoomModel roomModel = RoomModel.fromJson(room);

        if (roomModel.creatorId != _player.id) {
          _joinedRoomResponseStreamController = StreamController<RoomModel>();

          if (context.mounted) {
            context.pop();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.teal,
              content: Text(
                'O outro jogador saiu da sala.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
          );

          _joinedRoomResponseStreamController.sink.add(roomModel);
        }
      });

      _socket.on('room-disbanded', (room) {
        final RoomModel roomModel = RoomModel.fromJson(room);

        _joinedRoomResponseStreamController = StreamController<RoomModel>();

        if (context.mounted) {
          context.pop();

          if (roomModel.creatorId == _player.id) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.teal,
                content: Text(
                  'Você desfez a sala.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.teal,
                content: Text(
                  'Sala desfeita pelo criador da sala.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }
        }
      });

      _socket.on('game-started', (room) {
        final RoomModel roomModel = RoomModel.fromJson(room);

        _joinedRoomResponseStreamController.sink.add(roomModel);
      });

      _socket.on('round-result', (data) {
        final RoomModel roomModel = RoomModel.fromJson(data[1]);

        _joinedRoomResponseStreamController.sink.add(roomModel);

        final roundsWinners = roomModel.matches.last.roundsWinners;

        if (roundsWinners.last == SocketService.player.id && roundsWinners.last != 'draw') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Você venceu a rodada!',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              backgroundColor: Colors.teal.shade800,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (roundsWinners.last != SocketService.player.id && roundsWinners.last != 'draw') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Você perdeu a rodada!',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              backgroundColor: Colors.purple.shade800,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (roundsWinners.last == 'draw') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Empate!',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              backgroundColor: Colors.grey.shade800,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        debugPrint('Resultado da rodada: $data');
      });

      _socket.on('match-result', (data) {
        final RoomModel roomModel = RoomModel.fromJson(data[1]);

        _joinedRoomResponseStreamController.sink.add(roomModel);

        debugPrint('Resultado do jogo: $data');
      });

      _socket.connect();
    }
  }

  static void createRoom({required String roomName}) {
    _socket.emit('create-room', [roomName]);
  }

  static void joinRoom({required String roomId}) {
    _socket.emit('join-room', [roomId]);
  }

  static void leaveRoom({required String roomId}) {
    _socket.emit('leave-room', [roomId]);
  }

  static void play({required String roomId}) {
    _socket.emit('start-game', [roomId]);
  }

  static void makeMove({required String roomId, required String move}) {
    _socket.emit('make-move', [roomId, _player.id, move]);
  }

  static void dispose() {
    _socket.dispose();
    _socket.destroy();
    _socket.close();
    _socket.disconnect();
    _roomsResponseStreamController.close();
  }
}
