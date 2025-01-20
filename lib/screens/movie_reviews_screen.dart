import 'package:flutter/material.dart';
import '../api_service.dart';
import 'add_edit_review_screen.dart';
import 'dart:convert';

class MovieReviewsScreen extends StatefulWidget {
  final String username;

  const MovieReviewsScreen({Key? key, required this.username})
      : super(key: key);

  @override
  _MovieReviewsScreenState createState() => _MovieReviewsScreenState();
}

class _MovieReviewsScreenState extends State<MovieReviewsScreen> {
  final _apiService = ApiService();
  List<dynamic> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final reviews = await _apiService.getReviews(widget.username);
    setState(() {
      _reviews = reviews;
    });
  }

  void _deleteReview(String id) async {
    final success = await _apiService.deleteReview(id);
    if (success) {
      _loadReviews();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus review')),
      );
    }
  }

  void _toggleLike(Map<String, dynamic> review) async {
    final success = await _apiService.updateReview(
      review['_id'],
      review['username'],
      review['title'],
      review['rating'],
      review['comment'],
      !(review['isLiked'] ?? false),
      review['imageBase64'],
    );

    if (success) {
      _loadReviews();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengubah status like')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review Film Saya'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddEditReviewScreen(username: widget.username),
                ),
              );
              if (result == true) _loadReviews();
            },
          ),
        ],
      ),
      body: _reviews.isEmpty
          ? Center(child: Text('Belum ada review. Tambahkan sekarang!'))
          : ListView.builder(
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final review = _reviews[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (review['imageBase64'] != null)
                        Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 300,
                            ),
                            child: Image.memory(
                              base64Decode(review['imageBase64']),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    review['isLiked'] == true
                                        ? Icons.thumb_up
                                        : Icons.thumb_up_outlined,
                                    color: review['isLiked'] == true
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                  onPressed: () => _toggleLike(review),
                                ),
                                Expanded(
                                  child: Text(
                                    review['title'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddEditReviewScreen(
                                          username: widget.username,
                                          review: review,
                                        ),
                                      ),
                                    );
                                    if (result == true) _loadReviews();
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _deleteReview(review['_id']),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 20),
                                SizedBox(width: 4),
                                Text(
                                  '${review['rating']}/10',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              review['comment'],
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
