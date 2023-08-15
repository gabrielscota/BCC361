import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rock_paper_scissors_frontend/socket_service.dart';

import 'models/models.dart';

class RoomPage extends StatefulWidget {
  final RoomModel room;

  const RoomPage({
    Key? key,
    required this.room,
  }) : super(key: key);

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  late final Stream<RoomModel> roomResponseStream;

  late int currentRound;
  late String selectedMove;

  @override
  void initState() {
    super.initState();

    roomResponseStream = SocketService.joinedRoomResponseStream;

    currentRound = 0;
    selectedMove = '';
  }

  Future<void> startGame() async {
    try {
      SocketService.play(roomId: widget.room.id);
    } catch (_) {}
  }

  Future<void> makeMove({required String move}) async {
    if (selectedMove.isNotEmpty) return;

    setState(() {
      selectedMove = move;
    });

    await Future.delayed(const Duration(seconds: 1));

    SocketService.makeMove(roomId: widget.room.id, move: move);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => SocketService.leaveRoom(roomId: widget.room.id),
          ),
          title: Text(widget.room.name),
        ),
        body: StreamBuilder<RoomModel>(
          stream: roomResponseStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.status == RoomStatus.playing) {
                if (selectedMove.isNotEmpty && snapshot.data!.matches.last.roundsWinners.length > currentRound) {
                  currentRound = snapshot.data!.matches.last.roundsWinners.length;
                  selectedMove = '';
                }

                final filteredRoundsWinners =
                    snapshot.data!.matches.last.roundsWinners.where((element) => element != 'draw').toList();

                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Jogo em andamento',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            'Partida: ${snapshot.data!.matches.length}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 18,
                                width: 18,
                                decoration: BoxDecoration(
                                  color: filteredRoundsWinners.isNotEmpty &&
                                          filteredRoundsWinners[0] != SocketService.player.id
                                      ? Colors.purple.shade800
                                      : filteredRoundsWinners.isNotEmpty &&
                                              filteredRoundsWinners[0] == SocketService.player.id
                                          ? Colors.teal.shade800
                                          : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                height: 18,
                                width: 18,
                                decoration: BoxDecoration(
                                  color: filteredRoundsWinners.length > 1 &&
                                          filteredRoundsWinners[1] != SocketService.player.id
                                      ? Colors.purple.shade800
                                      : filteredRoundsWinners.length > 1 &&
                                              filteredRoundsWinners[1] == SocketService.player.id
                                          ? Colors.teal.shade800
                                          : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                height: 18,
                                width: 18,
                                decoration: BoxDecoration(
                                  color: filteredRoundsWinners.length > 2 &&
                                          filteredRoundsWinners[2] != SocketService.player.id
                                      ? Colors.purple.shade800
                                      : filteredRoundsWinners.length > 2 &&
                                              filteredRoundsWinners[2] == SocketService.player.id
                                          ? Colors.teal.shade800
                                          : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 24),
                                    child: Text(
                                      snapshot.data!.players
                                          .where((element) => element.id != SocketService.player.id)
                                          .first
                                          .name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.purple.shade800,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Transform.translate(
                                    offset: const Offset(-100, 0),
                                    child: Transform.rotate(
                                      angle: 3.14,
                                      child: Image.asset(
                                        'assets/images/rock.png',
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Aguardando oponente...',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 24),
                                    child: Text(
                                      'Você',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.teal.shade800,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: selectedMove.isNotEmpty
                                      ? Transform.translate(
                                          offset: const Offset(100, 0),
                                          child: Transform.rotate(
                                            angle: 0,
                                            child: Image.asset(
                                              'assets/images/$selectedMove.png',
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      OutlinedButton(
                                        onPressed: () => makeMove(move: 'rock'),
                                        style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                          backgroundColor:
                                              selectedMove == 'rock' ? Colors.teal.withOpacity(.2) : Colors.transparent,
                                          side: BorderSide(
                                            color: selectedMove == 'rock' ? Colors.teal : Colors.grey.shade300,
                                            width: selectedMove == 'rock' ? 2 : 1,
                                          ),
                                          fixedSize: const Size(136, 40),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.filter_vintage_rounded,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Pedra',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      OutlinedButton(
                                        onPressed: () => makeMove(move: 'paper'),
                                        style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                          backgroundColor: selectedMove == 'paper'
                                              ? Colors.orange.withOpacity(.2)
                                              : Colors.transparent,
                                          side: BorderSide(
                                            color: selectedMove == 'paper' ? Colors.orange : Colors.grey.shade300,
                                            width: selectedMove == 'paper' ? 2 : 1,
                                          ),
                                          fixedSize: const Size(136, 40),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.article_rounded,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Papel',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      OutlinedButton(
                                        onPressed: () => makeMove(move: 'scissors'),
                                        style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                          backgroundColor: selectedMove == 'scissors'
                                              ? Colors.cyan.withOpacity(.2)
                                              : Colors.transparent,
                                          side: BorderSide(
                                            color: selectedMove == 'scissors' ? Colors.cyan : Colors.grey.shade300,
                                            width: selectedMove == 'scissors' ? 2 : 1,
                                          ),
                                          fixedSize: const Size(136, 40),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.cut_rounded,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Tesoura',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              if (snapshot.data!.status == RoomStatus.preparing) {
                currentRound = 0;
                selectedMove = '';

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person_rounded, color: Colors.purple),
                                const SizedBox(width: 8),
                                Text(
                                  snapshot.data!.players.first.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.purple,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '  vs  ',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  snapshot.data!.players.last.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.teal,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.person_rounded, color: Colors.teal),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: startGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow_rounded),
                          const SizedBox(width: 8),
                          Text(
                            'Começar jogo',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              if (snapshot.data!.status == RoomStatus.waiting) {
                currentRound = 0;
                selectedMove = '';

                return Center(
                  child: Text(
                    'Aguardando outro jogador...',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              }

              if (snapshot.data!.status == RoomStatus.finished) {
                currentRound = 0;
                selectedMove = '';

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Jogo finalizado!',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 64),
                      Text(
                        'Vencedor:',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        snapshot.data!.players
                            .where((element) => element.id == snapshot.data!.matches.last.winner)
                            .first
                            .name,
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.w400,
                          color: Colors.teal.shade800,
                        ),
                      ),
                      const SizedBox(height: 64),
                      ElevatedButton(
                        onPressed: startGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.play_arrow_rounded),
                            const SizedBox(width: 8),
                            Text(
                              'Jogar novamente',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const Center();
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
