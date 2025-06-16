import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../wardrobe/wardrobe_page.dart';
import '../virtual_try_on/virtual_try_on_page.dart';
import '../home/home_page.dart';


class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  String? _selectedCommunity;
  String _displayName = '';
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, String>> _communities = [
    {
      'name': 'Minimalist Style',
      'desc': 'Clean, simple, and timeless outfits.',
    },
    {
      'name': 'Streetwear Lovers',
      'desc': 'Urban, bold, and trendy street fashion.',
    },
    {
      'name': 'Vintage Finds',
      'desc': 'Retro and classic fashion enthusiasts.',
    },
    {
      'name': 'Formal Fashion',
      'desc': 'Elegant and professional looks.',
    },
    {
      'name': 'Sporty Squad',
      'desc': 'Activewear and athleisure fans.',
    },
  ];
  final Map<String, List<Map<String, dynamic>>> _posts = {};
  final Set<String> _joinedCommunities = {};
  final Set<String> _favoritedPosts = {};
  String _searchQuery = '';

  // Consistent colors
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color softCream = Color(0xFFFAF9F7);

  @override
  void dispose() {
    _displayNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _joinCommunity(String community) {
    setState(() {
      _joinedCommunities.add(community);
      _selectedCommunity = community;
      _posts.putIfAbsent(community, () => []);
    });
  }

  void _setDisplayName() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Display Name', style: GoogleFonts.poppins()),
        content: TextField(
          controller: _displayNameController,
          decoration: const InputDecoration(hintText: 'Enter display name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _displayName = _displayNameController.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _shareOutfit() async {
    if (_selectedCommunity == null || !_joinedCommunities.contains(_selectedCommunity)) return;
    String? outfitType;
    String? outfitName;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Share Outfit', style: GoogleFonts.poppins()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: outfitType,
              hint: const Text('Select Outfit Source'),
              items: [
                DropdownMenuItem(value: 'tryon', child: Text('Virtual Try-On')),
                DropdownMenuItem(value: 'wardrobe', child: Text('Wardrobe')),
              ],
              onChanged: (v) => outfitType = v,
            ),
            TextField(
              decoration: const InputDecoration(hintText: 'Outfit Name'),
              onChanged: (v) => outfitName = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (outfitType != null && outfitName != null && outfitName!.isNotEmpty) {
                setState(() {
                  _posts[_selectedCommunity]!.add({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'user': _displayName.isNotEmpty ? _displayName : 'User',
                    'type': outfitType,
                    'name': outfitName,
                    'favorites': 0,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(String postId) {
    setState(() {
      if (_favoritedPosts.contains(postId)) {
        _favoritedPosts.remove(postId);
      } else {
        _favoritedPosts.add(postId);
      }
    });
  }

  List<Map<String, String>> get _filteredCommunities {
    if (_searchQuery.isEmpty) return _communities;
    return _communities
        .where((c) =>
            c['name']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c['desc']!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Widget _buildCommunityCard(Map<String, String> community) {
    final joined = _joinedCommunities.contains(community['name']);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: joined ? primaryBlue.withOpacity(0.2) : Colors.transparent,
          width: 1.2,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: primaryBlue,
          child: Icon(Icons.people_rounded, color: Colors.white),
        ),
        title: Text(
          community['name']!,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: darkGray,
          ),
        ),
        subtitle: Text(
          community['desc']!,
          style: GoogleFonts.poppins(
            color: mediumGray,
            fontSize: 13,
          ),
        ),
        trailing: joined
            ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentYellow,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: () {
                  setState(() {
                    _selectedCommunity = community['name'];
                  });
                },
                child: Text(
                  _selectedCommunity == community['name'] ? 'Joined' : 'Join',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              )
            : OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryBlue,
                  side: BorderSide(color: primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: () => _joinCommunity(community['name']!),
                child: Text(
                  'Join',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
        onTap: joined
            ? () {
                setState(() {
                  _selectedCommunity = community['name'];
                });
              }
            : null,
      ),
    );
  }

  Widget _buildCommunityList() {
    final communities = _filteredCommunities;
    if (communities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 32),
        child: Text(
          'No communities found.',
          style: GoogleFonts.poppins(color: mediumGray),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: communities.length,
      itemBuilder: (context, idx) => _buildCommunityCard(communities[idx]),
    );
  }

  Widget _buildPostsSection() {
    if (_selectedCommunity == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 32),
        child: Text(
          'Join a community to get started!',
          style: GoogleFonts.poppins(),
        ),
      );
    }
    final posts = _posts[_selectedCommunity] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Community: $_selectedCommunity',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: darkGray,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Share Outfit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: _shareOutfit,
            ),
          ],
        ),
        const SizedBox(height: 12),
        posts.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Text(
                    'No posts yet. Share your first outfit!',
                    style: GoogleFonts.poppins(color: mediumGray),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: posts.length,
                itemBuilder: (context, idx) {
                  final post = posts[idx];
                  final postId = post['id'] as String;
                  final isFav = _favoritedPosts.contains(postId);
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: Icon(
                        post['type'] == 'tryon'
                            ? Icons.camera_alt_rounded
                            : Icons.checkroom_rounded,
                        color: post['type'] == 'tryon'
                            ? primaryBlue
                            : accentYellow,
                        size: 28,
                      ),
                      title: Text(
                        post['name'],
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'by ${post['user']}',
                        style: GoogleFonts.poppins(),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? accentRed : mediumGray,
                        ),
                        onPressed: () => _toggleFavorite(postId),
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: 'Search communities...',
            hintStyle: GoogleFonts.poppins(
              color: mediumGray,
              fontSize: 15,
            ),
            prefixIcon: Icon(Icons.search_rounded, color: primaryBlue),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear_rounded, color: mediumGray),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ),
    );
  }

  int _selectedBottomNavIndex = 3;

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: _selectedBottomNavIndex,
          onTap: (index) {
            if (index == _selectedBottomNavIndex) return;
            setState(() => _selectedBottomNavIndex = index);
            if (index == 0) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false,
              );
            } else if (index == 1) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const WardrobePage()),
                (route) => false,
              );
            } else if (index == 2) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const VirtualTryOnPage()),
                (route) => false,
              );
            } else if (index == 3) {
              // Stay on CommunityPage
            }
            // Tambahkan navigasi ke Profile jika sudah ada page-nya
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: primaryBlue,
          unselectedItemColor: mediumGray,
          selectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: _getResponsiveFontSize(12),
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: _getResponsiveFontSize(12),
          ),
          iconSize: _isSmallScreen() ? 20 : 24,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checkroom_rounded),
              label: 'Wardrobe',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_rounded),
              label: 'Try-On',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_rounded),
              label: 'Community',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
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
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: Material(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
                );
              },
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
        ),
        title: Text(
          'Community',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: _setDisplayName,
            tooltip: 'Set Display Name',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              if (_selectedCommunity == null)
                _buildCommunityList()
              else
                _buildPostsSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Tambahkan helper untuk responsive font size & screen size
  double _getScreenWidth() => MediaQuery.of(context).size.width;
  bool _isSmallScreen() => _getScreenWidth() < 360;
  double _getResponsiveFontSize(double baseSize) {
    if (_isSmallScreen()) return baseSize * 0.9;
    return baseSize;
  }
}
