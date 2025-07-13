import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/fashion_news_services.dart';
import '../../services/favorites_service.dart';

class NewsDetailPage extends StatefulWidget {
  final String docId; // Firestore document ID

  const NewsDetailPage({Key? key, required this.docId}) : super(key: key);

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color softCream = Color(0xFFFAF9F7);
  static const Color accentRed = Color(0xFFD0021B);
  
  bool _isInFavorites = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFavorite = await FavoritesService.isInFavorites(widget.docId);
    setState(() {
      _isInFavorites = isFavorite;
    });
  }

  Future<void> _toggleFavorite(Map<String, dynamic> newsData) async {
    try {
      final isFavorite = await FavoritesService.toggleFavorite(
        itemId: widget.docId,
        title: newsData['title'] ?? '',
        category: 'Articles',
        color: primaryBlue,
        icon: Icons.article_rounded,
        subtitle: FashionNewsServices.getPreviewContent(newsData['content'] ?? ''),
        imageUrl: newsData['imageUrl'] ?? '',
        stats: '${FashionNewsServices.getLikesCount(newsData)} likes',
        statsIcon: Icons.favorite_rounded,
        count: FashionNewsServices.getLikesCount(newsData),
        tags: ['fashion', 'news', 'article'],
        additionalData: {
          'content': newsData['content'],
          'createdAt': newsData['createdAt'],
        },
      );
      
      setState(() {
        _isInFavorites = isFavorite;
      });
    } catch (e) {
      print('Error toggling favorite: $e');
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update favorites'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? '';

    return Scaffold(
      backgroundColor: softCream,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FashionNewsServices.getNewsDetailStream(widget.docId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
            final title = (data['title'] ?? '').toString();
            final imageUrl = (data['imageUrl'] ?? '').toString();
            final content = (data['content'] ?? '').toString();
            final likedBy = List<String>.from(data['likedBy'] ?? []);
            final isLiked = likedBy.contains(userId);

            return Column(
              children: [
                // Custom AppBar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x114A90E2),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Back button
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: primaryBlue, size: 26),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        tooltip: 'Back',
                      ),
                      Expanded(
                        child: Text(
                          'Fashion News',
                          style: GoogleFonts.poppins(
                            color: primaryBlue,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Love button
                      IconButton(
                        icon: Icon(
                          _isInFavorites ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: _isInFavorites ? accentRed : Colors.grey,
                          size: 26,
                        ),
                        tooltip: _isInFavorites ? 'Remove from Favorites' : 'Add to Favorites',
                        onPressed: () => _toggleFavorite(data),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Judul
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: darkGray,
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Gambar utama
                          if (imageUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                imageUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 160,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image, color: Colors.grey, size: 48),
                                ),
                              ),
                            ),
                          const SizedBox(height: 18),
                          // Konten
                          Text(
                            content,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: mediumGray,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Jumlah like (opsional)
                          Row(
                            children: [
                              Icon(Icons.favorite_rounded, color: Colors.red, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                '${likedBy.length} likes',
                                style: GoogleFonts.poppins(
                                  color: mediumGray,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
