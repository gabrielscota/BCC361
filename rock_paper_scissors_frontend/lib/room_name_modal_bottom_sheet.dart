import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateGameRoomModal extends StatefulWidget {
  final Function(String) onRoomNameSubmitted;

  const CreateGameRoomModal({super.key, required this.onRoomNameSubmitted});

  @override
  State<CreateGameRoomModal> createState() => _CreateGameRoomModalState();
}

class _CreateGameRoomModalState extends State<CreateGameRoomModal> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: const BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          const SizedBox(height: 32),
          TextFormField(
            autofocus: true,
            controller: _textEditingController,
            decoration: InputDecoration(
              labelText: 'Nome da sala',
              labelStyle: GoogleFonts.poppins(
                color: Colors.grey.shade900,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              String roomName = _textEditingController.text.trim();
              if (roomName.isNotEmpty) {
                widget.onRoomNameSubmitted(roomName);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor, digite o nome da sala')),
                );
              }
            },
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
                Text(
                  'Concluir',
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
}
