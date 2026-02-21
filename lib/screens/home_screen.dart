import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/note_service.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final NoteService _noteService = NoteService();
  final TextEditingController _controller = TextEditingController();

  void _addNote() {
    if (_controller.text.isEmpty) return;

    final note = Note(
      id: '',
      title: _controller.text,
      content: '',
      createdAt: DateTime.now(),
    );

    _noteService.addNote(note);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Escribe una nota',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addNote,
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Note>>(
              stream: _noteService.getNotes(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final notes = snapshot.data!;

                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return ListTile(
                      title: Text(note.title),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _noteService.deleteNote(note.id);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}