import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  Future<String> uploadFile(File file) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child('eventos/${file.path}');
    UploadTask uploadTask = ref.putFile(file);

    final snapshot = await uploadTask.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    return urlDownload;
  }
}
