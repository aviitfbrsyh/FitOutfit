import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'news_detail_page.dart';

class FashionNewsSection {
  // FitOutfit Brand Colors
  static const Color primaryLavender = Color(0xFFE8E4F3);
  static const Color softBlue = Color(0xFFE8F4FD);
  static const Color darkPurple = Color(0xFF6B46C1);
  static const Color lightPurple = Color(0xFFAD8EE6);

  static Widget buildFashionNewsManagement(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final verticalPadding = isMobile ? 12.0 : (MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1024 ? 16.0 : 20.0);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(
            context,
            'Fashion News Management', 
            'Create and manage fashion news articles for users',
            Icons.newspaper_rounded,
          ),
          SizedBox(height: verticalPadding * 1.5),
          _buildNewsAnalyticsCards(context),
          SizedBox(height: verticalPadding),
          if (isMobile) ...[
            _buildAddNewsForm(context),
            SizedBox(height: verticalPadding),
            _buildNewsStats(context),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('fashion_news')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    SizedBox(height: verticalPadding), // padding hanya jika ada data
                    ...snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NewsDetailPage(
                                    title: data['title'] ?? '',
                                    imageUrl: data['imageUrl'] ?? '',
                                    content: data['content'] ?? '',
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['title'] ?? '',
                                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 8),
                                    if ((data['imageUrl'] ?? '').isNotEmpty)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          data['imageUrl'],
                                          height: 120,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    Text(
                                      (data['content'] ?? '').length > 120
                                          ? data['content']!.substring(0, 120) + '...'
                                          : data['content'] ?? '',
                                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Tombol hapus di pojok kanan atas
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete News'),
                                    content: const Text('Are you sure you want to delete this news article?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  // Hapus gambar dari storage jika ada
                                  if ((data['imageUrl'] ?? '').isNotEmpty) {
                                    try {
                                      final ref = FirebaseStorage.instance.refFromURL(data['imageUrl']);
                                      await ref.delete();
                                    } catch (e) {
                                      // Ignore error jika file tidak ada
                                    }
                                  }
                                  // Hapus dokumen dari Firestore
                                  await doc.reference.delete();
                                }
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildNewsTable(context),
                      SizedBox(height: verticalPadding),
                      _buildNewsEngagementChart(context),
                    ],
                  ),
                ),
                SizedBox(width: verticalPadding),
                Expanded(
                  child: Column(
                    children: [
                      _buildAddNewsForm(context),
                      SizedBox(height: verticalPadding),
                      _buildNewsStats(context),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  static Widget _buildPageHeader(BuildContext context, String title, String subtitle, IconData icon) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final isTablet = MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1024;
    final cardPadding = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);
    final borderRadius = isMobile ? 12.0 : (isTablet ? 16.0 : 20.0);

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isMobile 
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryLavender, softBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: darkPurple, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: darkPurple,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: isTablet ? 24 : 28,
                        fontWeight: FontWeight.w700,
                        color: darkPurple,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(isTablet ? 16 : 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryLavender, softBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: darkPurple,
                  size: isTablet ? 28 : 36,
                ),
              ),
            ],
          ),
    );
  }

  static Widget _buildNewsAnalyticsCards(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final horizontalPadding = isMobile ? 16.0 : (MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1024 ? 20.0 : 24.0);
    final verticalPadding = isMobile ? 12.0 : (MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1024 ? 16.0 : 20.0);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('fashion_news').snapshots(),
      builder: (context, snapshot) {
        final totalNews = snapshot.hasData ? snapshot.data!.docs.length.toString() : '...';
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isMobile ? 2 : 4,
          crossAxisSpacing: horizontalPadding,
          mainAxisSpacing: verticalPadding,
          childAspectRatio: isMobile ? 1.2 : 1.3,
          children: [
            _buildNewsOverviewCard(
              context,
              'Total News',
              totalNews,
              'articles published',
              Icons.article_rounded,
              const Color(0xFF6B46C1),
              '+12 this week',
            ),
            _buildNewsOverviewCard(
              context,
              'Weekly Views',
              '24.5K', // Ganti dengan data realtime jika ada
              'total views',
              Icons.visibility_rounded,
              const Color(0xFF0EA5E9),
              '+8.3% from last week',
            ),
            _buildNewsOverviewCard(
              context,
              'Engagement',
              '87%', // Ganti dengan data realtime jika ada
              'avg engagement rate',
              Icons.thumb_up_rounded,
              const Color(0xFF10B981),
              'Excellent performance',
            ),
            _buildNewsOverviewCard(
              context,
              'Trending',
              '5', // Ganti dengan data realtime jika ada
              'trending articles',
              Icons.trending_up_rounded,
              const Color(0xFFF59E0B),
              'Hot topics this week',
            ),
          ],
        );
      },
    );
  }

  static Widget _buildNewsOverviewCard(BuildContext context, String title, String value, String subtitle, IconData icon, Color color, String trend) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final cardPadding = isMobile ? 16.0 : (MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1024 ? 20.0 : 24.0);
    final borderRadius = isMobile ? 12.0 : (MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1024 ? 16.0 : 20.0);

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: isMobile ? 16 : 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 11 : 13,
                    fontWeight: FontWeight.w600,
                    color: darkPurple,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 8 : 10,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              trend,
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 7 : 9,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildNewsTable(BuildContext context) {
    final borderRadius = MediaQuery.of(context).size.width < 768 ? 12.0 : (MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1024 ? 16.0 : 20.0);
    final cardPadding = MediaQuery.of(context).size.width < 768 ? 16.0 : (MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1024 ? 20.0 : 24.0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Row(
              children: [
                Text(
                  'Recent Fashion News',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: darkPurple,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _showNewsFilters(context),
                  icon: const Icon(Icons.filter_list_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: primaryLavender,
                    foregroundColor: darkPurple,
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(3, (index) => _buildSimpleNewsRow(context, index)),
        ],
      ),
    );
  }

  static Widget _buildSimpleNewsRow(BuildContext context, int index) {
    final news = [
      {'title': 'Spring Fashion Trends 2024', 'views': '3.2K', 'status': 'Published'},
      {'title': 'Sustainable Fashion Guide', 'views': '2.8K', 'status': 'Featured'},
      {'title': 'Color Matching Tips', 'views': '1.9K', 'status': 'Draft'},
    ];
    
    final item = news[index];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item['title']!,
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            item['views']!,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: item['status'] == 'Published' ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item['status']!,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: item['status'] == 'Published' ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildAddNewsForm(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: _AddNewsForm(),
                  ),
                ),
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Add Fashion News Content'),
      ),
    );
  }

  static Widget _buildNewsStats(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final cardPadding = isMobile ? 16.0 : 24.0;
    final borderRadius = isMobile ? 12.0 : 20.0;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('fashion_news').snapshots(),
      builder: (context, snapshot) {
        final totalNews = snapshot.hasData ? snapshot.data!.docs.length.toString() : '...';
        return Container(
          padding: EdgeInsets.all(cardPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'News Performance',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: darkPurple,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatRow('Total Articles', totalNews),
              _buildStatRow('Total Views', '156.2K'), // Ganti jika ingin realtime
              _buildStatRow('Engagement Rate', '87%'), // Ganti jika ingin realtime
            ],
          ),
        );
      },
    );
  }

  static Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12)),
          Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  static Widget _buildNewsEngagementChart(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final cardPadding = isMobile ? 16.0 : 24.0;
    final borderRadius = isMobile ? 12.0 : 20.0;

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Engagement Trends',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: darkPurple,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 2),
                      FlSpot(1, 4),
                      FlSpot(2, 3),
                      FlSpot(3, 5),
                      FlSpot(4, 4),
                      FlSpot(5, 6),
                    ],
                    isCurved: true,
                    color: darkPurple,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _showNewsFilters(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter News'),
        content: const Text('Filter options here...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static void _publishNews(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('News published successfully!')),
    );
  }
}

class _AddNewsForm extends StatefulWidget {
  const _AddNewsForm({Key? key}) : super(key: key);

  @override
  State<_AddNewsForm> createState() => _AddNewsFormState();
}

class _AddNewsFormState extends State<_AddNewsForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _selectedImage;
  Uint8List? _webImage; // Untuk web

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _webImage = bytes;
        });
      } else {
        setState(() {
          _selectedImage = File(picked.path);
        });
      }
    }
  }

  Future<String?> _uploadImageToFirebase(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('news_pict/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = await storageRef.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  Future<String?> _uploadWebImageToFirebase(Uint8List imageBytes) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('news_pict/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = await storageRef.putData(imageBytes);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final cardPadding = isMobile ? 16.0 : 24.0;
    final borderRadius = isMobile ? 12.0 : 20.0;

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Fashion News',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: FashionNewsSection.darkPurple,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Article Title',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickImage,
            child: kIsWeb
                ? (_webImage == null
                    ? Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: FashionNewsSection.primaryLavender,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Center(
                          child: Text('Tap to upload poster/image'),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          _webImage!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ))
                : (_selectedImage == null
                    ? Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: FashionNewsSection.primaryLavender,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Center(
                          child: Text('Tap to upload poster/image'),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Content',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                String? imageUrl;
                if (kIsWeb && _webImage != null) {
                  imageUrl = await _uploadWebImageToFirebase(_webImage!);
                } else if (_selectedImage != null) {
                  imageUrl = await _uploadImageToFirebase(_selectedImage!);
                }
                await FirebaseFirestore.instance.collection('fashion_news').add({
                  'title': _titleController.text,
                  'content': _contentController.text,
                  'imageUrl': imageUrl ?? '',
                  'createdAt': FieldValue.serverTimestamp(),
                });
                FashionNewsSection._publishNews(context);
                Navigator.pop(context); // Tutup dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: FashionNewsSection.darkPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Publish'),
            ),
          ),
        ],
      ),
    );
  }
}
