import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class StorageService {
  /// Converts an image file to a Base64 encoded string.
  Future<String?> convertImageToBase64(XFile image) async {
    try {
      final fileBytes = await image.readAsBytes();
      final base64String = base64Encode(fileBytes);
      return base64String;
    } catch (e) {
      print('Error converting image to Base64: $e');
      return null;
    }
  }
}
