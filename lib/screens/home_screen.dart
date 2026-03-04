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

  final TextEditingController _title = TextEditingController();
  final TextEditingController _content = TextEditingController();

  Uint8List? _selectedImage;

  /// 📸 Seleccionar imagen (compatible con Web)
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

  /// 💾 Guardar nota con imagen opcional
  Future<void> _addNote() async {
    String? imageUrl;

    if (_selectedImage != null) {
      imageUrl = await _storageService.uploadImage(_selectedImage!);
    }

    final note = Note(
      id: '',
      title: _title.text,
      content: _content.text,
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
          /// 🔹 FORMULARIO
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: "Título"),
                ),
                TextField(
                  controller: _content,
                  decoration: const InputDecoration(labelText: "Contenido"),
                ),
                const SizedBox(height: 10),

                /// Mostrar imagen seleccionada antes de subir
                if (_selectedImage != null)
                  Image.memory(_selectedImage!, height: 120),

                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.image),
                      onPressed: _pickImage,
                    ),
                    ElevatedButton(
                      onPressed: _addNote,
                      child: const Text("Guardar"),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// 🔹 LISTA DE NOTAS
          Expanded(
            child: StreamBuilder<List<Note>>(
              stream: _noteService.getNotes(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final notes = snapshot.data!;

                if (notes.isEmpty) {
                  return const Center(
                      child: Text("No hay notas aún"));
                }

                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(note.title),
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(note.content),
                            if (note.imageUrl != null)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8),
                                child: Image.network(
                                  note.imageUrl!,
                                  height: 120,
                                ),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              _noteService.deleteNote(note.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}