
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload profile image
  Future<String?> uploadProfileImage({required String? imageFile, required String userId}) async {
    try {
      // Create unique file name
      final String fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Reference to storage location
      final Reference ref = _storage.ref().child('profile_images') .child(fileName);

      // Upload file
      if(imageFile?.trim().isEmpty??false) return null;

      final pickedImg = File(imageFile??'');

      final UploadTask uploadTask = ref.putFile(pickedImg, SettableMetadata(contentType: 'image/jpeg'));

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('✅ Image uploaded successfully: $downloadUrl');
      return downloadUrl;

    } on FirebaseException catch (e) {
      debugPrint('❌ Firebase Storage Error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('❌ Error uploading image: $e');
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
  // Future<void> deleteImage(String? imageUrl) async {
  //   try {
  //     if(imageUrl?.trim().isNotEmpty??false){
  //       final Reference ref = _storage.refFromURL(imageUrl??'');
  //       await ref.delete();
  //       debugPrint('Old image deleted successfully');
  //     }
  //
  //   } catch (e) {
  //     debugPrint('Error deleting image: $e');
  //   }
  // }

  Future<bool> deleteImage(String? imageUrl) async {
    try {
      if (imageUrl == null || imageUrl.isEmpty) return false;

      // Extract path from URL manually
      final Uri uri = Uri.parse(imageUrl);
      final String encodedPath = uri.pathSegments.last;
      final String decodedPath = Uri.decodeComponent(encodedPath.split('?').first);

      debugPrint('📁 Decoded Path: $decodedPath');

      // Delete using path instead of URL
      final Reference ref = FirebaseStorage.instance.ref().child(decodedPath);

      debugPrint('📁 Reference Path: ${ref.fullPath}');

      await ref.delete();
      debugPrint('✅ Deleted successfully');
      return true;

    } catch (e) {
      debugPrint('❌ Error: $e');
      return false;
    }
  }
}