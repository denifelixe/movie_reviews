import 'package:flutter/material.dart';
import '../api_service.dart';

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
  bool _isFavorite = false;

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
