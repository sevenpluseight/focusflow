import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusflow/models/distraction_log_model.dart';
import 'package:focusflow/services/distraction_service.dart';
import 'package:focusflow/services/storage_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pixelarticons/pixelarticons.dart';

class DistractionProvider with ChangeNotifier {
  final _distractionService = DistractionService();
  final _storageService = StorageService();
  final notesController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  XFile? _imageFile;
  XFile? get imageFile => _imageFile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<String> categories = [
    'Social Media',
    'Email',
    'Games',
    'Family/Friends',
    'Snack/Drink',
    'Other',
  ];

  Stream<List<DistractionLogModel>> get distractionLogsStream {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    return _db
        .collection('users')
        .doc(user.uid)
        .collection('distractionLogs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DistractionLogModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<DistractionLogModel>> getDistractionLogsStreamForUser(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('distractionLogs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DistractionLogModel.fromFirestore(doc))
            .toList());
  }

  DistractionProvider() {
    notesController.addListener(_onNotesChanged);
  }

  void _onNotesChanged() {
    if (notesController.text.isNotEmpty && _selectedCategory != 'Other') {
      _selectedCategory = 'Other';
      notifyListeners();
    }
  }

  void selectCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    // Resize the image to prevent it from exceeding Firestore's 1MB document limit
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 200, // More aggressive resize for debugging
      imageQuality: 80,
    );
    if (image != null) {
      _imageFile = image;
      notifyListeners();
    }
  }

  void clearImage() {
    _imageFile = null;
    notifyListeners();
  }

  void showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Pixel.cameraadd),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Pixel.imageplus),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> submitLog() async {
    if (_selectedCategory == null) {
      return "Please select a category.";
    }

    _isLoading = true;
    notifyListeners();

    String? errorMessage;

    try {
      String? imageBase64;
      if (_imageFile != null) {
        imageBase64 = await _storageService.convertImageToBase64(_imageFile!);
        if (imageBase64 == null) {
          // Explicitly check for conversion failure
          errorMessage = "Image conversion failed.";
        }
      }
      
      if (errorMessage == null) {
        final finalImageUrl = imageBase64 ?? 'none';
        await _distractionService.saveDistractionLog(
          category: _selectedCategory!,
          note: notesController.text.trim(),
          imageUrl: finalImageUrl,
        );
      }
    } catch (e) {
      debugPrint('Failed to log distraction: $e');
      errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return errorMessage;
  }

  void reset() {
    _selectedCategory = null;
    _imageFile = null;
    notesController.clear();
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    notesController.removeListener(_onNotesChanged);
    notesController.dispose();
    super.dispose();
  }
}