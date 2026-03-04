import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> uploadImage(Uint8List fileBytes) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}.jpg';

      final ref = _storage
          .ref()
          .child('notes_images')
          .child(user.uid)
          .child(fileName);

      await ref.putData(fileBytes);

      // 🔥 AQUÍ ESTÁ EL CAMBIO
      final bucket = _storage.app.options.storageBucket;

      final publicUrl =
          'https://storage.googleapis.com/$bucket/notes_images/${user.uid}/$fileName';

      return publicUrl;

    } catch (e) {
      print("UPLOAD ERROR: $e");
      return null;
    }
  }
}