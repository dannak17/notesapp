import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';

class NoteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addNote(Note note) async {
    await _db.collection('notes').add(note.toMap());
  }

  Stream<List<Note>> getNotes() {
    return _db
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Note.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Future<void> deleteNote(String id) async {
    await _db.collection('notes').doc(id).delete();
  }
}