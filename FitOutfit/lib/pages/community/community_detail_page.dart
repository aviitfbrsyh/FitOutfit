import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityDetailPage extends StatefulWidget {
  final Map<String, dynamic> community;
  final String displayName;

  const CommunityDetailPage({
    Key? key,
    required this.community,
    required this.displayName,
  }) : super(key: key);

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _editController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  List<Map<String, dynamic>> _posts = [];
  Set<String> _likedPosts = {};
  Set<String> _savedPosts = {};
  File? _selectedImage;
  Uint8List? _webImage;
  bool _isCreatingPost = false;
  String? _editingPostId;

  // Colors
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color softCream = Color(0xFFFAF9F7);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _generateSamplePosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _postController.dispose();
    _editController.dispose();
    super.dispose();
  }

  void _generateSamplePosts() {
    _posts = [
      {
        'id': '1',
        'author': 'StyleGuru',
        'content':
            'Just discovered this amazing ${widget.community['name'].toLowerCase()} look! What do you think?',
        'image': null,
        'webImage': null,
        'likes': 24,
        'timestamp': DateTime.now().subtract(Duration(hours: 2)),
        'isOwner': false,
      },
      {
        'id': '2',
        'author': widget.displayName.isNotEmpty ? widget.displayName : 'You',
        'content':
            'Loving the ${widget.community['tags'][0].toLowerCase()} vibes today! 🔥',
        'image': null,
        'webImage': null,
        'likes': 12,
        'timestamp': DateTime.now().subtract(Duration(hours: 5)),
        'isOwner': true,
      },
      {
        'id': '3',
        'author': 'FashionLover',
        'content':
            'Perfect ${widget.community['name'].toLowerCase()} outfit for the weekend!',
        'image': null,
        'webImage': null,
        'likes': 18,
        'timestamp': DateTime.now().subtract(Duration(days: 1)),
        'isOwner': false,
      },
    ];
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _webImage = bytes;
          _selectedImage = null;
        });
      } else {
        setState(() {
          _selectedImage = File(image.path);
          _webImage = null;
        });
      }
    }
  }

  Future<void> _createPost() async {
    if (_postController.text.trim().isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final komunitasId = widget.community['id'] ?? widget.community['name'];
    final displayName = widget.displayName.isNotEmpty
        ? widget.displayName
        : (user.displayName?.isNotEmpty == true
            ? user.displayName
            : (user.email?.split('@').first ?? 'Anon'));

    String? imageUrl;
    if (_selectedImage != null || _webImage != null) {
      imageUrl = await _uploadImageToStorage(komunitasId);
    }

    await FirebaseFirestore.instance
        .collection('komunitas')
        .doc(komunitasId)
        .collection('posts')
        .add({
      'authorId': user.uid,
      'authorName': displayName,
      'content': _postController.text.trim(),
      'imageUrl': imageUrl ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'likes': 0,
    });

    setState(() {
      _postController.clear();
      _selectedImage = null;
      _webImage = null;
      _isCreatingPost = false;
    });

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Post created successfully!'),
        backgroundColor: primaryBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _editPost(String postId) {
    final post = _posts.firstWhere((p) => p['id'] == postId);
    _editController.text = post['content'];
    setState(() {
      _editingPostId = postId;
    });
  }

  void _updatePost() {
    if (_editController.text.trim().isEmpty || _editingPostId == null) return;

    setState(() {
      final postIndex = _posts.indexWhere((p) => p['id'] == _editingPostId);
      if (postIndex != -1) {
        _posts[postIndex]['content'] = _editController.text.trim();
      }
      _editingPostId = null;
      _editController.clear();
    });

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Post updated successfully!'),
        backgroundColor: accentYellow,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deletePost(String postId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Delete Post',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
            content: Text('Are you sure you want to delete this post?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _posts.removeWhere((p) => p['id'] == postId);
                    _likedPosts.remove(postId);
                    _savedPosts.remove(postId);
                  });
                  Navigator.pop(context);
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Post deleted successfully!'),
                      backgroundColor: accentRed,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: accentRed),
                child: Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  void _toggleLike(String postId) {
    setState(() {
      final postIndex = _posts.indexWhere((p) => p['id'] == postId);
      if (postIndex != -1) {
        if (_likedPosts.contains(postId)) {
          _likedPosts.remove(postId);
          _posts[postIndex]['likes']--;
        } else {
          _likedPosts.add(postId);
          _posts[postIndex]['likes']++;
        }
      }
    });
    HapticFeedback.lightImpact();
  }

  void _toggleSave(String postId) {
    setState(() {
      if (_savedPosts.contains(postId)) {
        _savedPosts.remove(postId);
      } else {
        _savedPosts.add(postId);
      }
    });
    HapticFeedback.lightImpact();
  }

  void _showFullScreenImage(dynamic imageData, bool isWebImage) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            // Background tap to close
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black87,
              ),
            ),
            // Image
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  child: isWebImage
                      ? Image.memory(
                          imageData,
                          fit: BoxFit.contain,
                        )
                      : Image.file(
                          File(imageData),
                          fit: BoxFit.contain,
                        ),
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 40,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softCream,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildCommunityInfo(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildFYPFeed(), _buildMyPosts()],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildCreatePostFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: widget.community['color'],
      title: Text(
        widget.community['name'],
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildCommunityInfo() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.community['color'],
                      widget.community['color'].withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  widget.community['icon'],
                  color: Colors.white,
                  size: 32,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.community['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: darkGray,
                      ),
                    ),
                    Text(
                      widget.community['desc'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: mediumGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children:
                (widget.community['tags'] as List<String>)
                    .map(
                      (tag) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: widget.community['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: widget.community['color'],
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: primaryBlue,
        unselectedLabelColor: mediumGray,
        indicatorColor: primaryBlue,
        labelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        tabs: [Tab(text: 'For You'), Tab(text: 'My Posts')],
      ),
    );
  }

  Widget _buildFYPFeed() {
    final komunitasId = widget.community['id'] ?? widget.community['name'];
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('komunitas')
          .doc(komunitasId)
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No posts yet', style: GoogleFonts.poppins()),
          );
        }
        final posts = snapshot.data!.docs;
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final data = posts[index].data() as Map<String, dynamic>;
            final postId = posts[index].id;
            return _buildFirestorePostCard(data, postId);
          },
        );
      },
    );
  }

Widget _buildMyPosts() {
  return StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, userSnapshot) {
      if (userSnapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }
      final user = userSnapshot.data;
      if (user == null) {
        return Center(child: Text('Not logged in', style: GoogleFonts.poppins()));
      }
      final komunitasId = widget.community['id'] ?? widget.community['name'];
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('komunitas')
            .doc(komunitasId)
            .collection('posts')
            .where('authorId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.post_add_rounded, size: 64, color: mediumGray),
                  SizedBox(height: 16),
                  Text(
                    'No posts yet',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: darkGray,
                    ),
                  ),
                  Text(
                    'Create your first post to get started!',
                    style: GoogleFonts.poppins(fontSize: 14, color: mediumGray),
                  ),
                ],
              ),
            );
          }
          final posts = snapshot.data!.docs;
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final data = posts[index].data() as Map<String, dynamic>;
              final postId = posts[index].id;
              return _buildFirestorePostCard(data, postId);
            },
          );
        },
      );
    },
  );
}

  Widget _buildPostCard(Map<String, dynamic> post) {
    final isLiked = _likedPosts.contains(post['id']);
    final isSaved = _savedPosts.contains(post['id']);
    final isEditing = _editingPostId == post['id'];

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: widget.community['color'],
                  child: Text(
                    post['author'][0].toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['author'],
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: darkGray,
                        ),
                      ),
                      Text(
                        _formatTimestamp(post['timestamp']),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
                if (post['isOwner'])
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _editPost(post['id']);
                          break;
                        case 'delete':
                          _deletePost(post['id']);
                          break;
                      }
                    },
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_rounded,
                                  color: primaryBlue,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_rounded,
                                  color: accentRed,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                  ),
              ],
            ),
          ),

          // Post content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child:
                isEditing
                    ? Column(
                      children: [
                        TextField(
                          controller: _editController,
                          maxLines: null,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryBlue,
                                width: 2,
                              ),
                            ),
                          ),
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _updatePost,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Save',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    _editingPostId = null;
                                    _editController.clear();
                                  });
                                },
                                child: Text('Cancel'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                    : Text(
                      post['content'],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: darkGray,
                        height: 1.5,
                      ),
                    ),
          ),

          // Post image
          if (post['image'] != null || post['webImage'] != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: GestureDetector(
                onTap: () {
                  if (kIsWeb && post['webImage'] != null) {
                    _showFullScreenImage(post['webImage'], true);
                  } else if (post['image'] != null) {
                    _showFullScreenImage(post['image'], false);
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: kIsWeb && post['webImage'] != null
                      ? Image.memory(
                          post['webImage'],
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      : post['image'] != null
                          ? Image.file(
                              File(post['image']),
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            )
                          : Container(),
                ),
              ),
            ),

          // Post actions
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _toggleLike(post['id']),
                  child: Row(
                    children: [
                      Icon(
                        isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isLiked ? accentRed : mediumGray,
                        size: 24,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${post['likes']}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () => _toggleSave(post['id']),
                  child: Icon(
                    isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: isSaved ? accentYellow : mediumGray,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirestorePostCard(Map<String, dynamic> post, String postId) {
  final isOwner = FirebaseAuth.instance.currentUser?.uid == post['authorId'];
  final imageUrl = post['imageUrl'] ?? '';
  return Container(
    margin: EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: primaryBlue.withOpacity(0.08),
          blurRadius: 15,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: widget.community['color'],
                child: Text(
                  (post['authorName'] ?? 'U')[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['authorName'] ?? '',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: darkGray,
                      ),
                    ),
                    Text(
                      post['createdAt'] != null && post['createdAt'] is Timestamp
                          ? _formatTimestamp((post['createdAt'] as Timestamp).toDate())
                          : '',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
              if (isOwner)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') _deleteFirestorePost(postId);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_rounded, color: accentRed, size: 20),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        // Content
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            post['content'] ?? '',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: darkGray,
              height: 1.5,
            ),
          ),
        ),
        // Image
        if (imageUrl.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    child: Image.network(imageUrl, fit: BoxFit.cover),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

  Widget _buildCreatePostFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        setState(() {
          _isCreatingPost = !_isCreatingPost;
        });
        if (_isCreatingPost) {
          _showCreatePostDialog();
        }
      },
      backgroundColor: primaryBlue,
      icon: Icon(Icons.add_rounded, color: Colors.white),
      label: Text(
        'Create Post',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Text(
                    'Create New Post',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _postController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "What's on your mind?",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: primaryBlue,
                              width: 2,
                            ),
                          ),
                        ),
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () async {
                              await _pickImage();
                              setDialogState(() {}); // Update dialog state
                            },
                            icon: Icon(
                              _selectedImage != null || _webImage != null
                                  ? Icons.check_circle_rounded
                                  : Icons.image_rounded,
                              color:
                                  _selectedImage != null || _webImage != null
                                      ? Colors.green
                                      : primaryBlue,
                            ),
                            label: Text(
                              _selectedImage != null || _webImage != null
                                  ? 'Image Selected'
                                  : 'Add Image',
                              style: GoogleFonts.poppins(
                                color:
                                    _selectedImage != null || _webImage != null
                                        ? Colors.green
                                        : primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (_selectedImage != null || _webImage != null)
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedImage = null;
                                  _webImage = null;
                                });
                                setDialogState(() {}); // Update dialog state
                              },
                              icon: Icon(
                                Icons.close_rounded,
                                color: mediumGray,
                                size: 20,
                              ),
                              tooltip: 'Remove image',
                            ),
                        ],
                      ),
                      if (_webImage != null)
                        Container(
                          margin: EdgeInsets.only(top: 8),
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: MemoryImage(_webImage!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      if (_selectedImage != null && !kIsWeb)
                        Container(
                          margin: EdgeInsets.only(top: 8),
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(_selectedImage!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _isCreatingPost = false;
                          _selectedImage = null;
                          _webImage = null;
                          _postController.clear();
                        });
                      },
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _createPost();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Post',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<String?> _uploadImageToStorage(String komunitasId) async {
  if (_selectedImage == null && _webImage == null) return null;
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  final fileName = '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
  final ref = FirebaseStorage.instance
      .ref()
      .child('komunitas')
      .child(komunitasId)
      .child('posts')
      .child(fileName);

  UploadTask uploadTask;
  if (kIsWeb && _webImage != null) {
    uploadTask = ref.putData(_webImage!);
  } else if (_selectedImage != null) {
    uploadTask = ref.putFile(_selectedImage!);
  } else {
    return null;
  }

  final snapshot = await uploadTask.whenComplete(() {});
  return await snapshot.ref.getDownloadURL();
}

Future<void> _deleteFirestorePost(String postId) async {
  final komunitasId = widget.community['id'] ?? widget.community['name'];
  await FirebaseFirestore.instance
      .collection('komunitas')
      .doc(komunitasId)
      .collection('posts')
      .doc(postId)
      .delete();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Post deleted successfully!'),
      backgroundColor: accentRed,
      behavior: SnackBarBehavior.floating,
    ),
  );
} 
}
