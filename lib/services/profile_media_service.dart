import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class ProfileMediaService {
  ProfileMediaService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadProfilePhoto({
    required String uid,
    required Uint8List bytes,
  }) async {
    final reference = _storage.ref('profilePhotos/$uid/profile.jpg');
    await reference.putData(
      bytes,
      SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public,max-age=3600',
      ),
    );
    return reference.getDownloadURL();
  }

  Future<String> uploadProfessionalCredential({
    required String uid,
    required String categoryId,
    required Uint8List bytes,
  }) async {
    final reference =
        _storage.ref('professionalCredentials/$uid/$categoryId.jpg');
    await reference.putData(
      bytes,
      SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'private,max-age=300',
      ),
    );
    return reference.getDownloadURL();
  }
}
