import 'package:flutter/material.dart';
import '../api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddEditReviewScreen extends StatefulWidget {
  final String username;
  final Map<String, dynamic>? review;

  const AddEditReviewScreen({Key? key, required this.username, this.review})
      : super(key: key);

  @override
  _AddEditReviewScreenState createState() => _AddEditReviewScreenState();
}

class _AddEditReviewScreenState extends State<AddEditReviewScreen> {
  final _titleController = TextEditingController();
  final _ratingController = TextEditingController();
  final _commentController = TextEditingController();
  final _apiService = ApiService();
  final _imagePicker = ImagePicker();
  bool _isFavorite = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    if (widget.review != null) {
      _titleController.text = widget.review!['title'];
      _ratingController.text = widget.review!['rating'].toString();
      _commentController.text = widget.review!['comment'];
      _isFavorite = widget.review!['isFavorite'] ?? false;
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _saveReview() async {
    final title = _titleController.text.trim();
    final rating = int.tryParse(_ratingController.text) ?? 0;
    final comment = _commentController.text.trim();

    // Validasi input
    if (title.isEmpty || rating < 1 || rating > 10 || comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Data tidak valid. Judul, komentar, dan rating (1-10) harus diisi.')),
      );
      return;
    }

    bool success;
    if (widget.review == null) {
      // Tambah review baru
      success = await _apiService.addReview(
          widget.username, title, rating, comment, _isFavorite);
    } else {
      // Edit review
      success = await _apiService.updateReview(widget.review!['_id'],
          widget.username, title, rating, comment, _isFavorite);
    }

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan review')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.review != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditMode ? 'Edit Review' : 'Tambah Review')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_imageFile != null)
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _imageFile!,
                    height: double.infinity,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.photo_camera),
              label: Text('Pilih Gambar'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Judul Film'),
              readOnly: isEditMode,
            ),
            TextField(
              controller: _ratingController,
              decoration: InputDecoration(labelText: 'Rating (1-10)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(labelText: 'Komentar'),
              maxLines: 3,
            ),
            SwitchListTile(
              title: Text('Favorit'),
              value: _isFavorite,
              onChanged: (bool value) {
                setState(() {
                  _isFavorite = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveReview,
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
