import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../wardrobe/wardrobe_page.dart';
import '../virtual_try_on/virtual_try_on_page.dart';
import '../home/home_page.dart';
import 'community_detail_page.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with TickerProviderStateMixin<CommunityPage> {
  String? _selectedCommunity;
  String _displayName = '';
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _communities = [
    {
      'name': 'Minimalist Style',
      'desc': 'Clean, simple, and timeless fashion statements',
      'color': const Color(0xFF4A90E2),
      'icon': Icons.auto_awesome_outlined,
      'tags': ['Simple', 'Clean', 'Timeless'],
      'category': 'Style',
      'members': 1250,
    },
    {
      'name': 'Streetwear Lovers',
      'desc': 'Urban, bold, and trendy street fashion culture',
      'color': const Color(0xFFD0021B),
      'icon': Icons.sports_basketball_rounded,
      'tags': ['Urban', 'Bold', 'Trendy'],
      'category': 'Street',
      'members': 2430,
    },
    {
      'name': 'Vintage Finds',
      'desc': 'Retro and classic fashion treasures from the past',
      'color': const Color(0xFFF5A623),
      'icon': Icons.history_rounded,
      'tags': ['Retro', 'Classic', 'Unique'],
      'category': 'Vintage',
      'members': 890,
    },
    {
      'name': 'Formal Fashion',
      'desc': 'Elegant and professional looks for every occasion',
      'color': const Color(0xFF2C3E50),
      'icon': Icons.business_center_rounded,
      'tags': ['Elegant', 'Professional', 'Classy'],
      'category': 'Formal',
      'members': 1680,
    },
    {
      'name': 'Sporty Squad',
      'desc': 'Activewear and athleisure lifestyle enthusiasts',
      'color': const Color(0xFF27AE60),
      'icon': Icons.fitness_center_rounded,
      'tags': ['Active', 'Sporty', 'Healthy'],
      'category': 'Sport',
      'members': 3200,
    },
    {
      'name': 'Color Pop',
      'desc': 'Vibrant colors and bold fashion combinations',
      'color': const Color(0xFFE74C3C),
      'icon': Icons.palette_rounded,
      'tags': ['Colorful', 'Vibrant', 'Bold'],
      'category': 'Style',
      'members': 750,
    },
    {
      'name': 'Bohemian Vibes',
      'desc': 'Free-spirited, artistic and unconventional fashion',
      'color': const Color(0xFF8E44AD),
      'icon': Icons.nature_people_rounded,
      'tags': ['Boho', 'Artistic', 'Free-spirit'],
      'category': 'Boho',
      'members': 920,
    },
    {
      'name': 'K-Fashion Hub',
      'desc': 'Korean fashion trends and K-pop inspired outfits',
      'color': const Color(0xFFFF6B9D),
      'icon': Icons.favorite_rounded,
      'tags': ['Korean', 'K-pop', 'Trendy'],
      'category': 'Asian',
      'members': 4500,
    },
    {
      'name': 'Cottagecore Aesthetic',
      'desc': 'Romantic, countryside inspired fashion and lifestyle',
      'color': const Color(0xFF7CB342),
      'icon': Icons.local_florist_rounded,
      'tags': ['Romantic', 'Countryside', 'Soft'],
      'category': 'Aesthetic',
      'members': 1100,
    },
    {
      'name': 'Gothic Fashion',
      'desc': 'Dark, mysterious and alternative fashion styles',
      'color': const Color(0xFF424242),
      'icon': Icons.nightlife_rounded,
      'tags': ['Dark', 'Alternative', 'Mysterious'],
      'category': 'Alternative',
      'members': 680,
    },
    {
      'name': 'Sustainable Style',
      'desc': 'Eco-friendly and ethical fashion choices',
      'color': const Color(0xFF4CAF50),
      'icon': Icons.eco_rounded,
      'tags': ['Eco-friendly', 'Sustainable', 'Ethical'],
      'category': 'Sustainable',
      'members': 1580,
    },
    {
      'name': 'Plus Size Fashion',
      'desc': 'Stylish and confident looks for all body sizes',
      'color': const Color(0xFFFF9800),
      'icon': Icons.favorite_border_rounded,
      'tags': ['Inclusive', 'Body-positive', 'Confident'],
      'category': 'Inclusive',
      'members': 2200,
    },
    {
      'name': 'Luxury Brands',
      'desc': 'High-end designer fashion and luxury lifestyle',
      'color': const Color(0xFF9C27B0),
      'icon': Icons.diamond_rounded,
      'tags': ['Designer', 'Luxury', 'High-end'],
      'category': 'Luxury',
      'members': 890,
    },
    {
      'name': 'Budget Fashion',
      'desc': 'Affordable style tips and budget-friendly finds',
      'color': const Color(0xFF00BCD4),
      'icon': Icons.savings_rounded,
      'tags': ['Affordable', 'Budget', 'Thrifty'],
      'category': 'Budget',
      'members': 3100,
    },
    {
      'name': 'Punk & Grunge',
      'desc': 'Edgy, rebellious and alternative fashion styles',
      'color': const Color(0xFF795548),
      'icon': Icons.music_note_rounded,
      'tags': ['Edgy', 'Rebellious', 'Grunge'],
      'category': 'Alternative',
      'members': 540,
    },
  ];

  final Map<String, List<Map<String, dynamic>>> _posts = {};
  final Set<String> _joinedCommunities = {};
  String _searchQuery = '';
  String _selectedCategory = 'All';
  int _selectedBottomNavIndex = 3;

  // Consistent colors
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color softCream = Color(0xFFFAF9F7);

  List<String> get _categories {
    final categories = _communities.map((c) => c['category'] as String).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Helper methods for responsive design
  double _getScreenWidth() => MediaQuery.of(context).size.width;
  bool _isSmallScreen() => _getScreenWidth() < 360;
  bool _isTablet() => _getScreenWidth() > 600;

  double _getResponsiveFontSize(double baseSize) {
    if (_isSmallScreen()) return baseSize * 0.9;
    if (_isTablet()) return baseSize * 1.1;
    return baseSize;
  }

  double _getHorizontalPadding() {
    if (_isSmallScreen()) return 16.0;
    if (_isTablet()) return 32.0;
    return 20.0;
  }

  void _joinCommunity(String community) {
    HapticFeedback.mediumImpact();
    setState(() {
      _joinedCommunities.add(community);
      _selectedCommunity = community;
      _posts.putIfAbsent(community, () => []);
    });

    // Navigate to community detail page
    final communityData = _communities.firstWhere(
      (c) => c['name'] == community,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CommunityDetailPage(
              community: communityData,
              displayName: _displayName,
            ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Successfully joined $community!',
          style: GoogleFonts.poppins(
            fontSize: _getResponsiveFontSize(14),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(_getHorizontalPadding()),
      ),
    );
  }

  void _setDisplayName() async {
    HapticFeedback.lightImpact();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Set Display Name',
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(18),
                    fontWeight: FontWeight.w700,
                    color: darkGray,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose how you want to appear in the community',
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(14),
                    color: mediumGray,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _displayNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your display name',
                    hintStyle: GoogleFonts.poppins(color: mediumGray),
                    prefixIcon: Icon(Icons.badge_rounded, color: primaryBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: mediumGray.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryBlue, width: 2),
                    ),
                    filled: true,
                    fillColor: lightGray,
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    color: mediumGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _displayName = _displayNameController.text.trim();
                  });
                  Navigator.pop(context);
                  if (_displayName.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Display name set to: $_displayName',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: accentYellow,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'Save',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _getHorizontalPadding()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Discover Communities',
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(24),
              fontWeight: FontWeight.w800,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find your fashion tribe and connect with like-minded enthusiasts',
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(14),
              color: mediumGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search communities, styles, or interests...',
                hintStyle: GoogleFonts.poppins(
                  color: mediumGray,
                  fontSize: _getResponsiveFontSize(15),
                ),
                prefixIcon: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.search_rounded,
                    color: primaryBlue,
                    size: 24,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
              ),
              style: GoogleFonts.poppins(
                fontSize: _getResponsiveFontSize(16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, userSnapshot) {
        final user = userSnapshot.data;
        if (user == null) {
          return _buildStatsRow(joinedCount: 0);
        }
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('komunitas').snapshots(),
          builder: (context, komunitasSnapshot) {
            if (!komunitasSnapshot.hasData) {
              return _buildStatsRow(joinedCount: 0);
            }
            final komunitasDocs = komunitasSnapshot.data!.docs;
            return FutureBuilder<List<DocumentSnapshot>>(
              future: Future.wait(
                komunitasDocs.map((doc) =>
                  doc.reference.collection('members').doc(user.uid).get()
                ),
              ),
              builder: (context, memberSnapshot) {
                if (!memberSnapshot.hasData) {
                  return _buildStatsRow(joinedCount: 0);
                }
                final joinedCount = memberSnapshot.data!
                    .where((doc) => doc.exists)
                    .length;
                return _buildStatsRow(joinedCount: joinedCount);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStatsRow({required int joinedCount}) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: _getHorizontalPadding(),
        vertical: 12,
      ),
      padding: EdgeInsets.all(_isSmallScreen() ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryBlue.withOpacity(0.1),
            accentYellow.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryBlue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Communities',
              '${_communities.length}',
              Icons.groups_rounded,
              primaryBlue,
            ),
          ),
          // _buildDivider(),
          // Expanded(
          //   child: _buildStatItem(
          //     'Joined',
          //     '$joinedCount',
          //     Icons.check_circle_rounded,
          //     accentRed,
          //   ),
          // ),
          _buildDivider(),
          Expanded(
            child: _buildStatItem(
              'Active',
              'Today',
              Icons.trending_up_rounded,
              accentYellow,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(_isSmallScreen() ? 8 : 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: _isSmallScreen() ? 20 : 22),
        ),
        SizedBox(height: _isSmallScreen() ? 6 : 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: _getResponsiveFontSize(16),
            fontWeight: FontWeight.w800,
            color: darkGray,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: _getResponsiveFontSize(11),
            color: mediumGray,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: _isSmallScreen() ? 50 : 55,
      width: 1,
      margin: EdgeInsets.symmetric(horizontal: _isSmallScreen() ? 12 : 16),
      color: mediumGray.withOpacity(0.2),
    );
  }

  List<Map<String, dynamic>> get _filteredCommunities {
    var filtered = _communities.where((c) {
      // Category filter
      if (_selectedCategory != 'All' && c['category'] != _selectedCategory) {
        return false;
      }
      
      // Search filter
      if (_searchQuery.isEmpty) return true;
      
      final query = _searchQuery.toLowerCase();
      return c['name']!.toLowerCase().contains(query) ||
             c['desc']!.toLowerCase().contains(query) ||
             c['category']!.toLowerCase().contains(query) ||
             (c['tags'] as List<String>).any((tag) => tag.toLowerCase().contains(query));
    }).toList();
    
    // Sort by members count (popular first)
    filtered.sort((a, b) => (b['members'] as int).compareTo(a['members'] as int));
    return filtered;
  }

  Widget _buildCategoryChips() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _getHorizontalPadding()),
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              selected: isSelected,
              label: Text(
                category,
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(13),
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : primaryBlue,
                ),
              ),
              backgroundColor: Colors.white,
              selectedColor: primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? primaryBlue : primaryBlue.withOpacity(0.3),
                ),
              ),
              onSelected: (selected) {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommunityList() {
    final communities = _filteredCommunities;
    if (communities.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: _getHorizontalPadding()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _selectedCategory == 'All' ? 'All Communities' : '$_selectedCategory Communities',
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(18),
                  fontWeight: FontWeight.w800,
                  color: darkGray,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${communities.length} found',
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(11),
                    fontWeight: FontWeight.w700,
                    color: primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: communities.length,
            itemBuilder: (context, index) => _buildCommunityListItem(communities[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityListItem(Map<String, dynamic> community) {
    final joined = _joinedCommunities.contains(community['name']);
    final isSelected = _selectedCommunity == community['name'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? community['color'].withOpacity(0.15)
                : primaryBlue.withOpacity(0.05),
            blurRadius: isSelected ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isSelected
              ? community['color'].withOpacity(0.3)
              : joined
              ? primaryBlue.withOpacity(0.2)
              : Colors.transparent,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        onTap: () async {
          HapticFeedback.lightImpact();
          final isJoined = await isUserJoined(community['name']);
          if (isJoined) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommunityDetailPage(
                  community: community,
                  displayName: _displayName,
                ),
              ),
            );
          } else {
            await toggleJoinCommunity(community['name']);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommunityDetailPage(
                  community: community,
                  displayName: _displayName,
                ),
              ),
            );
          }
        },
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                community['color'],
                community['color'].withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            community['icon'],
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                community['name'],
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(16),
                  fontWeight: FontWeight.w700,
                  color: darkGray,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: community['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                community['category'],
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(10),
                  fontWeight: FontWeight.w600,
                  color: community['color'],
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              community['desc'],
              style: GoogleFonts.poppins(
                fontSize: _getResponsiveFontSize(13),
                color: mediumGray,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.people_rounded, size: 14, color: mediumGray),
                const SizedBox(width: 4),
                Text(
                  '${community['members']} members',
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(11),
                    color: mediumGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    children: (community['tags'] as List<String>)
                        .take(3)
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: community['color'].withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: community['color'].withOpacity(0.2),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                tag,
                                style: GoogleFonts.poppins(
                                  fontSize: _getResponsiveFontSize(9),
                                  fontWeight: FontWeight.w600,
                                  color: community['color'],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: _buildJoinButton(community, community['name']),
      ),
    );
  }

  Widget _buildJoinButton(Map<String, dynamic> community, String komunitasId) {
    return FutureBuilder<bool>(
      future: isUserJoined(komunitasId),
      builder: (context, snapshot) {
        final isJoined = snapshot.data ?? false;
        return GestureDetector(
          onTap: () => toggleJoinCommunity(komunitasId),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: _isSmallScreen() ? 10 : 12,
              vertical: _isSmallScreen() ? 5 : 6,
            ),
            decoration: BoxDecoration(
              color: isJoined ? primaryBlue : community['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isJoined
                    ? primaryBlue.withOpacity(0.3)
                    : community['color'].withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isJoined ? Icons.check_rounded : Icons.add_rounded,
                  color: isJoined ? Colors.white : community['color'],
                  size: _isSmallScreen() ? 14 : 16,
                ),
                const SizedBox(width: 4),
                Text(
                  isJoined ? 'Joined' : 'Join',
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(10),
                    fontWeight: FontWeight.w700,
                    color: isJoined ? Colors.white : community['color'],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _getHorizontalPadding()),
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: mediumGray.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(Icons.search_off_rounded, size: 48, color: mediumGray),
          ),
          const SizedBox(height: 24),
          Text(
            'No communities found',
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(18),
              fontWeight: FontWeight.w700,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search terms or browse all available communities.',
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(14),
              color: mediumGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: _selectedBottomNavIndex,
          onTap: (index) {
            if (index == _selectedBottomNavIndex) return;
            HapticFeedback.lightImpact();
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
                MaterialPageRoute(
                  builder: (context) => const VirtualTryOnPage(),
                ),
                (route) => false,
              );
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: primaryBlue,
          unselectedItemColor: mediumGray,
          selectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: _getResponsiveFontSize(12),
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: _getResponsiveFontSize(12),
          ),
          iconSize: 24,
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

  Future<void> saveAllCommunitiesToFirestore() async {
    for (final community in _communities) {
      await FirebaseFirestore.instance.collection('komunitas').add({
        'name': community['name'],
        'desc': community['desc'],
        'color': community['color'].value,
        'icon': community['icon'].codePoint,
        'tags': community['tags'],
        'category': community['category'],
        'members': community['members'],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Semua komunitas berhasil disimpan ke Firestore!'))
    );
  }

  Future<void> toggleJoinCommunity(String komunitasId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final displayName = _displayName.isNotEmpty
        ? _displayName
        : (user.displayName?.isNotEmpty == true
            ? user.displayName
            : (user.email?.split('@').first ?? 'Anon'));

    final memberRef = FirebaseFirestore.instance
        .collection('komunitas')
        .doc(komunitasId)
        .collection('members')
        .doc(user.uid);

    final memberDoc = await memberRef.get();

    if (memberDoc.exists) {
      await memberRef.delete(); // Leave
      setState(() {
        _joinedCommunities.remove(komunitasId);
      });
    } else {
      await memberRef.set({
        'displayName': displayName,
        'joinedAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        _joinedCommunities.add(komunitasId);
      });
    }
  }

  Future<bool> isUserJoined(String komunitasId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final doc = await FirebaseFirestore.instance
        .collection('komunitas')
        .doc(komunitasId)
        .collection('members')
        .doc(user.uid)
        .get();
    return doc.exists;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softCream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryBlue),
        title: Text(
          'Community',
          style: GoogleFonts.poppins(
            color: primaryBlue,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildSearchSection(),
            const SizedBox(height: 16),
            _buildStatsHeader(),
            const SizedBox(height: 16),
            _buildCategoryChips(),
            const SizedBox(height: 16),
            _buildCommunityList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
