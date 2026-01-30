
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

// Upload profile image
  Future<String?> uploadProfileImage({required String? imageFile, required String userId}) async {
    try {
      if (imageFile?.trim().isEmpty ?? true) {
        debugPrint('❌ Image file path is empty');
        return null;
      }

      final pickedImg = File(imageFile??'');

      // Check if file exists
      if (!pickedImg.existsSync()) {
        debugPrint('❌ Image file does not exist: $imageFile');
        return null;
      }


      final String fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Reference to storage location: profile_images/{userId}/{fileName}
      final Reference ref = _storage
          .ref()
          .child('profile_images')
          .child(userId)
          .child(fileName);

      debugPrint('📤 Uploading to: ${ref.fullPath}');

      // Upload file
      final UploadTask uploadTask = ref.putFile(pickedImg, SettableMetadata(contentType: 'image/jpeg'));

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('✅ Image uploaded successfully: $downloadUrl');
      debugPrint('📂 Full path: ${ref.fullPath}');

      return downloadUrl;

    } on FirebaseException catch (e) {
      debugPrint('Firebase Storage Error: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }


  // Upload with progress
  Future<String?> uploadProfileImageWithProgress({required File imageFile, required String userId, required Function(double) onProgress,}) async {
    try {
      final String fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('profile_images').child(fileName);

      final UploadTask uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Listen to progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
        debugPrint('📤 Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
      });

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;

    } catch (e) {
      debugPrint('❌ Error uploading image: $e');
      return null;
    }
  }

  // Delete old profile image
  Future<void> deleteImage(String? imageUrl) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('❌ User not authenticated');
        return;
      }

      if (imageUrl?.trim().isNotEmpty ?? false) {
        final Reference ref = _storage.refFromURL(imageUrl!);

        debugPrint('🗑️ Deleting: ${ref.fullPath}');

        // Verify path structure before deletion
        final pathParts = ref.fullPath.split('/');
        if (pathParts.length == 3 &&
            pathParts[0] == 'profile_images' &&
            pathParts[1] == user.uid) {
          await ref.delete();
          debugPrint('✅ Image deleted successfully');
        } else {
          debugPrint('⚠️ Invalid path structure: ${ref.fullPath}');
          debugPrint('   Expected: profile_images/${user.uid}/{fileName}');
        }
      }
    } on FirebaseException catch (e) {
      debugPrint('❌ Firebase Error: ${e.code} - ${e.message}');
    } catch (e) {
      debugPrint('❌ Error deleting image: $e');
    }
  }

}