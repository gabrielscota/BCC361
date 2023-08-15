import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rock_paper_scissors_frontend/socket_service.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'models/models.dart';
import 'room_name_modal_bottom_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ScrollController scrollController;
  late final Stream<List<RoomModel>> roomsResponseStream;
  late final Stream<int> numOfPlayersOnlineResponseStream;

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController();

    SocketService.init(context);

    roomsResponseStream = SocketService.roomsResponseStream;
    numOfPlayersOnlineResponseStream = SocketService.numOfPlayersOnlineResponseStream;
  }

  Future<void> createRoom() async {
    try {
      String? roomName = await showModalBottomSheet<String>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(12),
          ),
        ),
        useSafeArea: true,
        builder: (context) {
          return CreateGameRoomModal(
            onRoomNameSubmitted: (name) {
              context.pop(name);
            },
          );
        },
      );

      if (roomName != null && mounted) {
        SocketService.createRoom(roomName: roomName);
      }
    } catch (_) {}
  }

  Future<void> joinRoom({required String roomId}) async {
    try {
      SocketService.joinRoom(roomId: roomId);
    } catch (_) {}
  }

  @override
  void dispose() {
    scrollController.dispose();

    SocketService.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pedra, Papel e Tesoura',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ElevatedButton(
          onPressed: createRoom,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade900,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add),
              const SizedBox(width: 8),
              Text(
                'Criar sala',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Colors.teal.shade800,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, ${SocketService.userName}!',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        StreamBuilder<int>(
                          stream: numOfPlayersOnlineResponseStream,
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.hasData && snapshot.data != null
                                  ? snapshot.data! == 1
                                      ? '${snapshot.data} jogador online'
                                      : '${snapshot.data} jogadores online'
                                  : '0 jogadores online',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                                color: Colors.grey.shade300,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      // IconButton(
                      //   onPressed: () => context.pushNamed('profile'),
                      //   icon: const Icon(
                      //     Icons.person,
                      //     color: Colors.white,
                      //   ),
                      // ),
                      IconButton(
                        onPressed: () => context.go('/'),
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Colors.white,
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
                    child: CupertinoScrollbar(
                      controller: scrollController,
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                        child: CustomScrollView(
                          controller: scrollController,
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            StreamBuilder<List<RoomModel>>(
                              stream: roomsResponseStream,
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return SliverFillRemaining(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${snapshot.error}',
                                          style: GoogleFonts.quicksand(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade700,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                if (snapshot.hasData) {
                                  if (snapshot.data!.isNotEmpty) {
                                    return SliverPadding(
                                      padding: const EdgeInsets.symmetric(vertical: 32),
                                      sliver: MultiSliver(
                                        children: [
                                          SliverToBoxAdapter(
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                                              child: Text(
                                                'Salas disponíveis',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey.shade900,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SliverList.separated(
                                            itemCount: snapshot.data!.length,
                                            itemBuilder: (context, index) => Container(
                                              padding: const EdgeInsets.all(24),
                                              margin: const EdgeInsets.symmetric(horizontal: 24),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          snapshot.data![index].name,
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons.circle,
                                                              size: 10,
                                                              color: snapshot.data![index].status.name == 'waiting'
                                                                  ? Colors.green
                                                                  : snapshot.data![index].status.name == 'preparing'
                                                                      ? Colors.yellow
                                                                      : Colors.red,
                                                            ),
                                                            const SizedBox(width: 8),
                                                            Text(
                                                              snapshot.data![index].status.name == 'waiting'
                                                                  ? 'Aguardando jogadores.. (${snapshot.data![index].players.length}/2)'
                                                                  : snapshot.data![index].status.name == 'preparing'
                                                                      ? 'Em preparação..'
                                                                      : 'Jogo em andamento..',
                                                              style: GoogleFonts.poppins(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w400,
                                                                color: Colors.grey.shade900,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Visibility(
                                                          visible: snapshot.data![index].isFull(),
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(top: 16),
                                                            child: Text.rich(
                                                              TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text: snapshot.data![index].players.first.name,
                                                                    style: GoogleFonts.poppins(
                                                                      fontSize: 14,
                                                                      fontWeight: FontWeight.w400,
                                                                      color: Colors.purple.shade800,
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                    text: '  X  ',
                                                                    style: GoogleFonts.poppins(
                                                                      fontSize: 14,
                                                                      fontWeight: FontWeight.w400,
                                                                      color: Colors.grey.shade900,
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                    text: snapshot.data![index].players.last.name,
                                                                    style: GoogleFonts.poppins(
                                                                      fontSize: 14,
                                                                      fontWeight: FontWeight.w400,
                                                                      color: Colors.teal.shade800,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          'ID da sala: ${snapshot.data![index].id.substring(0, 8)}...',
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w400,
                                                            color: Colors.grey.shade400,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  ElevatedButton(
                                                    onPressed: snapshot.data![index].status.name == 'waiting' &&
                                                            !snapshot.data![index].isFull()
                                                        ? () => joinRoom(roomId: snapshot.data![index].id)
                                                        : null,
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.grey.shade900,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const Icon(
                                                          Icons.login,
                                                          size: 16,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          'Entrar',
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
                                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return SliverFillRemaining(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Não há salas disponíveis no momento, crie uma!',
                                            style: GoogleFonts.quicksand(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade700,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                } else {
                                  return SliverFillRemaining(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const CircularProgressIndicator(),
                                        const SizedBox(height: 24),
                                        Text(
                                          'Conectando ao servidor..',
                                          style: GoogleFonts.quicksand(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
