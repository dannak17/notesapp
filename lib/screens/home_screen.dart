import '../services/ai_service.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NoteService _noteService = NoteService();
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();
  final AIService _aiService = AIService();

  final TextEditingController _title = TextEditingController();
  final TextEditingController _content = TextEditingController();

  Uint8List? _selectedImage;

  Future<void> _pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _selectedImage = bytes;
      });
    }
  }

  Future<void> _addNote() async {
    if (_title.text.isEmpty || _content.text.isEmpty) return;

    String? imageUrl;

    if (_selectedImage != null) {
      imageUrl = await _storageService.uploadImage(_selectedImage!);
    }

    final note = Note(
      id: '',
      title: _title.text.trim(),
      content: _content.text.trim(),
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
    );

    await _noteService.addNote(note);

    _title.clear();
    _content.clear();

    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _resumirNota(String texto) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final resumen = await _aiService.resumirTexto(texto);

    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("summary generate by IA"),
        content: Text(resumen ?? "Cannot generate summary."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Notas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _authService.logout(),
          )
        ],
      ),
      body: Column(
        children: [
        
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _title,
                  decoration: const InputDecoration(
                    labelText: "Título",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _content,
                  decoration: const InputDecoration(
                    labelText: "Contenido",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 10),

                if (_selectedImage != null)
                  Column(
                    children: [
                      Image.memory(_selectedImage!, height: 120),
                      const SizedBox(height: 8),
                    ],
                  ),

                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.image),
                      onPressed: _pickImage,
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _addNote,
                      child: const Text("Guardar"),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<List<Note>>(
              stream: _noteService.getNotes(),
              builder: (context, snapshot) {

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No hay notas aún"),
                  );
                }

                final notes = snapshot.data!;

                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];

                    return Card(
                      margin: const EdgeInsets.all(8),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(note.content),
                            const SizedBox(height: 8),

                            if (note.imageUrl != null)
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(8),
                                child: Image.network(
                                  note.imageUrl!,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),

                            const SizedBox(height: 10),

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () =>
                                      _resumirNota(
                                          note.content),
                                  child: const Text(
                                      "Resumir con IA"),
                                ),
                                IconButton(
                                  icon:
                                      const Icon(Icons.delete),
                                  onPressed: () =>
                                      _noteService
                                          .deleteNote(note.id),
                                ),
                              ],
                            ),
                          ],
                        ),
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