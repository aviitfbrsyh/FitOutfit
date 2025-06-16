import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import './outfit_result_page.dart';
import '../home/home_page.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage>
    with TickerProviderStateMixin {
  // Enhanced FitOutfit brand colors with better color harmony
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color secondaryBlue = Color(0xFF6BA3F0);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color softCream = Color(0xFFFAF9F7);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color shadowColor = Color(0x1A000000);

  late TabController _tabController;
  late AnimationController _fabController;
  late AnimationController _headerController;
  late Animation<double> _fabAnimation;
  late Animation<double> _headerAnimation;

  String _selectedCategory = 'All';
  bool _showAIRecommendations = false;
  String _selectedOccasion = '';
  String _selectedWeather = '';
  String _selectedStyle = '';

  final List<String> _categories = [
    'All',
    'Tops',
    'Bottoms',
    'Dresses',
    'Outerwear',
    'Accessories',
    'Shoes',
  ];
  final List<String> _occasions = [
    'Work/Office',
    'Casual Day',
    'Date Night',
    'Party/Event',
    'Formal Meeting',
    'Workout/Gym',
    'Travel/Vacation',
    'Home/Relaxing',
  ];
  final List<String> _weatherOptions = [
    'Sunny & Warm',
    'Rainy & Cool',
    'Cold & Windy',
    'Hot & Humid',
    'Mild & Pleasant',
  ];
  final List<String> _stylePreferences = [
    'Minimalist',
    'Bohemian',
    'Classic',
    'Trendy',
    'Edgy',
    'Romantic',
    'Sporty',
    'Professional',
  ];

  // Add search controller
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Make _wardrobeItems final but keep the list mutable
  final List<Map<String, dynamic>> _wardrobeItems = [
    {
      'id': '1',
      'name': 'Classic White Shirt',
      'category': 'Tops',
      'color': 'White',
      'brand': 'Zara',
      'description':
          'Crisp cotton button-down shirt perfect for professional settings',
      'image': null,
      'tags': ['professional', 'versatile', 'cotton', 'formal'],
      'lastWorn': '2 days ago',
      'favorite': false,
    },
    {
      'id': '2',
      'name': 'Black Skinny Jeans',
      'category': 'Bottoms',
      'color': 'Black',
      'brand': 'Levi\'s',
      'description': 'High-waisted skinny fit jeans with stretch comfort',
      'image': null,
      'tags': ['casual', 'stretchy', 'comfortable', 'versatile'],
      'lastWorn': '1 week ago',
      'favorite': true,
    },
    {
      'id': '3',
      'name': 'Floral Summer Dress',
      'category': 'Dresses',
      'color': 'Blue',
      'brand': 'H&M',
      'description': 'Light floral print midi dress with flowing silhouette',
      'image': null,
      'tags': ['summer', 'romantic', 'breathable', 'feminine'],
      'lastWorn': '3 days ago',
      'favorite': false,
    },
    {
      'id': '4',
      'name': 'Navy Blazer',
      'category': 'Outerwear',
      'color': 'Navy',
      'brand': 'Mango',
      'description': 'Tailored navy blazer with gold buttons',
      'image': null,
      'tags': ['professional', 'formal', 'structured', 'elegant'],
      'lastWorn': '5 days ago',
      'favorite': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );
    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutQuart),
    );

    _fabController.forward();
    _headerController.forward();

    // Add listener to tab controller to rebuild when tab changes
    _tabController.addListener(() {
      setState(() {
        // This will trigger a rebuild and update the FAB visibility
      });
    });

    // Add search listener
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fabController.dispose();
    _headerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softCream,
      body: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [_buildEnhancedSliverAppBar()],
        body: Column(
          children: [
            _buildEnhancedTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEnhancedWardrobeTab(),
                  _buildEnhancedAIAssistantTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      // Only show FAB when on My Collection tab (index 0)
      floatingActionButton:
          _tabController.index == 0
              ? _buildEnhancedFloatingActionButton()
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildEnhancedSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      collapsedHeight: 80, // Set a specific collapsed height
      pinned: true,
      floating: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        child: Material(
          color: pureWhite.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: darkGray,
                size: 20,
              ),
            ),
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          child: Material(
            color: pureWhite.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.more_vert_rounded, color: darkGray, size: 20),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final top = constraints.biggest.height;
          final isCollapsed = top <= 100; // Adjusted collapse threshold

          return FlexibleSpaceBar(
            background: AnimatedBuilder(
              animation: _headerAnimation,
              builder:
                  (context, child) => Transform.scale(
                    scale: 0.95 + (0.05 * _headerAnimation.value),
                    child: Opacity(
                      opacity: _headerAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              primaryBlue,
                              secondaryBlue,
                              primaryBlue.withValues(alpha: 0.8),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(isCollapsed ? 20 : 28),
                            bottomRight: Radius.circular(isCollapsed ? 20 : 28),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryBlue.withValues(
                                alpha: isCollapsed ? 0.15 : 0.3,
                              ),
                              blurRadius: isCollapsed ? 10 : 20,
                              offset: Offset(0, isCollapsed ? 5 : 10),
                            ),
                            BoxShadow(
                              color: shadowColor.withValues(
                                alpha: isCollapsed ? 0.1 : 0.2,
                              ),
                              blurRadius: isCollapsed ? 8 : 15,
                              offset: Offset(0, isCollapsed ? 3 : 5),
                            ),
                          ],
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              24,
                              20,
                              24,
                              isCollapsed ? 12 : 24,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Always show the header content, but adjust size when collapsed
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(
                                        isCollapsed ? 8 : 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: pureWhite.withValues(
                                          alpha: 0.25,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          isCollapsed ? 12 : 16,
                                        ),
                                        border: Border.all(
                                          color: pureWhite.withValues(
                                            alpha: 0.4,
                                          ),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: pureWhite.withValues(
                                              alpha: 0.1,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.checkroom_rounded,
                                        color: pureWhite,
                                        size: isCollapsed ? 20 : 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'My Wardrobe',
                                            style: GoogleFonts.poppins(
                                              fontSize: isCollapsed ? 20 : 28,
                                              fontWeight: FontWeight.w800,
                                              color: pureWhite,
                                              letterSpacing: -0.8,
                                              height: 1.0,
                                            ),
                                          ),
                                          if (!isCollapsed) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 3,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: pureWhite.withValues(
                                                      alpha: 0.2,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '${_wardrobeItems.length} items',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 11,
                                                      color: pureWhite,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Icon(
                                                  Icons.fiber_manual_record,
                                                  size: 4,
                                                  color: pureWhite.withValues(
                                                    alpha: 0.7,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Updated today',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color: pureWhite.withValues(
                                                      alpha: 0.9,
                                                    ),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        20,
        24,
        20,
        16,
      ), // Increased top margin for more spacing
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.6), // Reduced shadow opacity
            blurRadius: 8, // Reduced blur radius
            offset: const Offset(0, 2), // Reduced offset
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [primaryBlue, secondaryBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          labelColor: pureWhite,
          unselectedLabelColor: mediumGray,
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: -0.2,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: -0.2,
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          tabs: [
            Tab(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_rounded, size: 16),
                  const SizedBox(width: 8),
                  Text('My Collection'),
                ],
              ),
            ),
            Tab(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 16),
                  const SizedBox(width: 8),
                  Text('StyleMate AI'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndActions() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        12,
      ), // Reduced top margin since tab bar has margin now
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: pureWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search wardrobe...',
                  hintStyle: GoogleFonts.poppins(
                    color: mediumGray.withValues(alpha: 0.6),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: mediumGray,
                    size: 18,
                  ),
                  suffixIcon:
                      _searchQuery.isNotEmpty
                          ? IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color: mediumGray,
                              size: 16,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                          : Container(
                            margin: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primaryBlue, secondaryBlue],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.tune_rounded,
                              color: pureWhite,
                              size: 14,
                            ),
                          ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: darkGray,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentYellow, accentYellow.withValues(alpha: 0.8)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: accentYellow.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {},
                child: Icon(
                  Icons.grid_view_rounded,
                  color: pureWhite,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatsCards() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: _buildCompactStatCard(
              'Items',
              '${_wardrobeItems.length}',
              Icons.inventory_rounded,
              primaryBlue,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildCompactStatCard(
              'Favorites',
              '${_wardrobeItems.where((item) => item['favorite'] == true).length}',
              Icons.favorite_rounded,
              accentRed,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildCompactStatCard(
              'Categories',
              '${_categories.length - 1}',
              Icons.category_rounded,
              accentYellow,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.12),
                  color.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: darkGray,
                    letterSpacing: -0.3,
                    height: 1.0,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: mediumGray,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedCategoryFilter() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Categories',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: darkGray,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            // Changed from Container to SizedBox
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                final itemCount =
                    category == 'All'
                        ? _wardrobeItems.length
                        : _wardrobeItems
                            .where((item) => item['category'] == category)
                            .length;

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => setState(() => _selectedCategory = category),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryBlue : pureWhite,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? primaryBlue : lightGray,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  isSelected
                                      ? primaryBlue.withValues(alpha: 0.2)
                                      : shadowColor.withValues(alpha: 0.4),
                              blurRadius: isSelected ? 6 : 3,
                              offset: Offset(0, isSelected ? 2 : 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getCategoryIcon(category),
                              size: 14,
                              color: isSelected ? pureWhite : mediumGray,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              category,
                              style: GoogleFonts.poppins(
                                color: isSelected ? pureWhite : darkGray,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? pureWhite.withValues(alpha: 0.2)
                                        : lightGray,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$itemCount',
                                style: GoogleFonts.poppins(
                                  color:
                                      isSelected
                                          ? pureWhite.withValues(alpha: 0.9)
                                          : mediumGray,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedWardrobeGrid() {
    List<Map<String, dynamic>> filteredItems = _wardrobeItems;

    // Filter by category
    if (_selectedCategory != 'All') {
      filteredItems =
          filteredItems
              .where((item) => item['category'] == _selectedCategory)
              .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredItems =
          filteredItems.where((item) {
            final name = item['name'].toString().toLowerCase();
            final brand = (item['brand'] ?? '').toString().toLowerCase();
            final category = item['category'].toString().toLowerCase();
            final color = item['color'].toString().toLowerCase();
            final description = item['description'].toString().toLowerCase();
            final tags = (item['tags'] as List).join(' ').toLowerCase();

            return name.contains(_searchQuery) ||
                brand.contains(_searchQuery) ||
                category.contains(_searchQuery) ||
                color.contains(_searchQuery) ||
                description.contains(_searchQuery) ||
                tags.contains(_searchQuery);
          }).toList();
    }

    if (filteredItems.isEmpty) {
      return _buildEnhancedEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: filteredItems.length,
        itemBuilder:
            (context, index) =>
                _buildEnhancedWardrobeItem(filteredItems[index]),
      ),
    );
  }

  Widget _buildEnhancedWardrobeItem(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _showItemDetails(item),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced image section
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryBlue.withValues(alpha: 0.06),
                        accentYellow.withValues(alpha: 0.04),
                        accentRed.withValues(alpha: 0.03),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: pureWhite.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: shadowColor,
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            _getCategoryIcon(item['category']),
                            size: 28,
                            color: primaryBlue,
                          ),
                        ),
                      ),
                      // Favorite button
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _toggleFavorite(item['id']),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: pureWhite,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: shadowColor,
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                item['favorite']
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 14,
                                color:
                                    item['favorite'] ? accentRed : mediumGray,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Color indicator
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getColorFromName(item['color']),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: pureWhite, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: shadowColor,
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            item['color'],
                            style: GoogleFonts.poppins(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: _getTextColorForBackground(
                                _getColorFromName(item['color']),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Details section
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: darkGray,
                          letterSpacing: -0.2,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (item['brand'] != null &&
                          item['brand'].toString().isNotEmpty)
                        Text(
                          item['brand'],
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: mediumGray,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      const Spacer(),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryBlue.withValues(alpha: 0.1),
                                  primaryBlue.withValues(alpha: 0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item['category'],
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: primaryBlue,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 10,
                                color: mediumGray,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                item['lastWorn'],
                                style: GoogleFonts.poppins(
                                  fontSize: 8,
                                  color: mediumGray,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryBlue.withValues(alpha: 0.1),
                    accentYellow.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.checkroom_rounded,
                size: 80,
                color: primaryBlue.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No items in $_selectedCategory',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: darkGray,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Start building your digital wardrobe\nby adding your first $_selectedCategory item',
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: mediumGray,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primaryBlue, secondaryBlue]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _showAddItemDialog,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(
                  'Add Your First Item',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: pureWhite,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedFloatingActionButton() {
    return ScaleTransition(
      scale: _fabAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accentRed, accentRed.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: accentRed.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showAddItemDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, color: pureWhite, size: 24),
          label: Text(
            'Add Item',
            style: GoogleFonts.poppins(
              color: pureWhite,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }

  // Enhanced AI Assistant Tab
  Widget _buildEnhancedAIAssistantTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEnhancedAIAssistantHeader(),
          const SizedBox(height: 28),
          _buildEnhancedOccasionSelector(),
          const SizedBox(height: 24),
          _buildEnhancedWeatherSelector(),
          const SizedBox(height: 24),
          _buildEnhancedStyleSelector(),
          const SizedBox(height: 36),
          _buildEnhancedGenerateOutfitButton(),
          if (_showAIRecommendations) ...[
            const SizedBox(height: 36),
            _buildEnhancedAIRecommendations(),
          ],
        ],
      ),
    );
  }

  Widget _buildEnhancedAIAssistantHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentYellow.withValues(alpha: 0.12),
            primaryBlue.withValues(alpha: 0.08),
            accentRed.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: accentYellow.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentYellow.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: shadowColor,
            blurRadius: 16,
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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentYellow, accentYellow.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: accentYellow.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: pureWhite,
                  size: 32,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'StyleMate AI Assistant',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: darkGray,
                        letterSpacing: -0.6,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your Personal Fashion Curator',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: mediumGray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: pureWhite.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: pureWhite.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentYellow.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.tips_and_updates_rounded,
                    color: accentYellow,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Tell me your plans, and I\'ll create the perfect outfit from your wardrobe with professional styling tips.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: darkGray,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedOccasionSelector() {
    return _buildEnhancedSelectorSection(
      'Where are you going?',
      Icons.location_on_rounded,
      _occasions,
      _selectedOccasion,
      (occasion) => setState(() => _selectedOccasion = occasion),
      primaryBlue,
      // Add gradient background for this section
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryBlue.withValues(alpha: 0.08),
          secondaryBlue.withValues(alpha: 0.05),
          Colors.white,
        ],
      ),
    );
  }

  Widget _buildEnhancedWeatherSelector() {
    return _buildEnhancedSelectorSection(
      'What\'s the weather like?',
      Icons.wb_sunny_rounded,
      _weatherOptions,
      _selectedWeather,
      (weather) => setState(() => _selectedWeather = weather),
      accentYellow,
      // Add gradient background for this section
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accentYellow.withValues(alpha: 0.12),
          accentYellow.withValues(alpha: 0.06),
          Colors.white,
        ],
      ),
    );
  }

  Widget _buildEnhancedStyleSelector() {
    return _buildEnhancedSelectorSection(
      'What\'s your style vibe today?',
      Icons.palette_rounded,
      _stylePreferences,
      _selectedStyle,
      (style) => setState(() => _selectedStyle = style),
      accentRed,
      // Add gradient background for this section
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accentRed.withValues(alpha: 0.08),
          accentRed.withValues(alpha: 0.04),
          Colors.white,
        ],
      ),
    );
  }

  Widget _buildEnhancedSelectorSection(
    String title,
    IconData icon,
    List<String> options,
    String selected,
    Function(String) onSelect,
    Color accentColor, {
    Gradient? backgroundGradient, // Add optional background gradient parameter
  }) {
    return Container(
      // Add container with gradient background
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: backgroundGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.15),
                      accentColor.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: darkGray,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                options.map((option) {
                  final isSelected = selected == option;
                  return Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => onSelect(option),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          gradient:
                              isSelected
                                  ? LinearGradient(
                                    colors: [
                                      accentColor,
                                      accentColor.withValues(alpha: 0.8),
                                    ],
                                  )
                                  : null,
                          color: isSelected ? null : pureWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : lightGray,
                            width: isSelected ? 0 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  isSelected
                                      ? accentColor.withValues(alpha: 0.3)
                                      : shadowColor,
                              blurRadius: isSelected ? 16 : 8,
                              offset: Offset(0, isSelected ? 6 : 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (title.contains('weather')) ...[
                              Icon(
                                _getWeatherIcon(option),
                                size: 16,
                                color: isSelected ? pureWhite : mediumGray,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              option,
                              style: GoogleFonts.poppins(
                                color: isSelected ? pureWhite : darkGray,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedGenerateOutfitButton() {
    final canGenerate =
        _selectedOccasion.isNotEmpty &&
        _selectedWeather.isNotEmpty &&
        _selectedStyle.isNotEmpty;

    return Container(
      // Add container with gradient background for the button section
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF9B59B6).withValues(alpha: 0.08), // Purple accent
            const Color(0xFF3498DB).withValues(alpha: 0.06), // Blue accent
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF9B59B6).withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9B59B6).withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Add icon and title for this section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF9B59B6).withValues(alpha: 0.15),
                      const Color(0xFF3498DB).withValues(alpha: 0.10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: const Color(0xFF9B59B6),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Generate Your Perfect Look',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: darkGray,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              gradient:
                  canGenerate
                      ? LinearGradient(
                        colors: [accentRed, accentRed.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                      : null,
              color: canGenerate ? null : mediumGray.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              boxShadow:
                  canGenerate
                      ? [
                        // Main shadow for depth
                        BoxShadow(
                          color: accentRed.withValues(alpha: 0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                        // Secondary glow effect
                        BoxShadow(
                          color: accentRed.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                        // Subtle inner highlight
                        BoxShadow(
                          color: accentRed.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                        // Bottom emphasis shadow
                        BoxShadow(
                          color: shadowColor.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ]
                      : [
                        // Disabled state shadow
                        BoxShadow(
                          color: shadowColor.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
            ),
            child: ElevatedButton.icon(
              onPressed: canGenerate ? _generateAIRecommendations : null,
              icon: Icon(Icons.auto_awesome_rounded, size: 24),
              label: Text(
                'Generate Perfect Outfit',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: -0.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: pureWhite,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedAIRecommendations() {
    // Remove this entire method content - it should not show anything automatically
    return const SizedBox.shrink(); // Return empty widget instead
  }

  void _generateAIRecommendations() {
    HapticFeedback.mediumImpact();

    // Don't show any loading state, just navigate directly after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      // Check if widget is still mounted before using context
      if (!mounted) return;

      // Reset the flag and navigate immediately
      setState(() {
        _showAIRecommendations = false;
      });

      // Navigate to detailed outfit result page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => OutfitResultPage(
                outfitData: {
                  'name': 'Perfect Style Match',
                  'components': _wardrobeItems.take(3).toList(),
                  'rating': 4.9,
                  'matchScore': 95,
                },
                occasion: _selectedOccasion,
                weather: _selectedWeather,
                style: _selectedStyle,
              ),
        ),
      );
    });
  }

  void _addNewItem(Map<String, dynamic> newItem) {
    setState(() {
      // Generate new ID
      final newId = (int.parse(_wardrobeItems.last['id']) + 1).toString();
      newItem['id'] = newId;
      newItem['lastWorn'] = 'Never';
      newItem['favorite'] = false;

      _wardrobeItems.add(newItem);
    });
  }

  void _showAddItemDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddItemBottomSheet(onItemAdded: _addNewItem),
    );
  }

  Widget _buildEnhancedWardrobeTab() {
    return Column(
      children: [
        _buildSearchAndActions(),
        _buildEnhancedStatsCards(),
        _buildEnhancedCategoryFilter(),
        const SizedBox(height: 16),
        Expanded(child: _buildEnhancedWardrobeGrid()),
      ],
    );
  }

  void _showItemDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ItemDetailsBottomSheet(item: item),
    );
  }

  // Helper methods
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'All':
      case 'Tops':
        return Icons.checkroom_rounded;
      case 'Bottoms':
        return Icons.straighten_rounded;
      case 'Dresses':
        return Icons.woman_rounded;
      case 'Outerwear':
        return Icons.checkroom_rounded;
      case 'Accessories':
        return Icons.watch_rounded;
      case 'Shoes':
        return Icons.run_circle_rounded;
      default:
        return Icons.checkroom_rounded;
    }
  }

  IconData _getWeatherIcon(String weather) {
    switch (weather) {
      case 'Sunny & Warm':
        return Icons.wb_sunny_rounded;
      case 'Rainy & Cool':
        return Icons.umbrella_rounded;
      case 'Cold & Windy':
        return Icons.ac_unit_rounded;
      case 'Hot & Humid':
        return Icons.whatshot_rounded;
      case 'Mild & Pleasant':
        return Icons.thermostat_rounded;
      default:
        return Icons.wb_sunny_rounded;
    }
  }

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'white':
        return Colors.white;
      case 'black':
        return Colors.black;
      case 'blue':
        return Colors.blue;
      case 'navy':
        return const Color(0xFF001F3F);
      case 'red':
        return Colors.red;
      case 'yellow':
        return Colors.yellow;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'brown':
        return Colors.brown;
      case 'gray':
      case 'grey':
        return Colors.grey;
      case 'beige':
        return const Color(0xFFF5F5DC);
      default:
        return mediumGray;
    }
  }

  Color _getTextColorForBackground(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
  }

  void _toggleFavorite(String itemId) {
    setState(() {
      final itemIndex = _wardrobeItems.indexWhere(
        (item) => item['id'] == itemId,
      );
      if (itemIndex != -1) {
        _wardrobeItems[itemIndex]['favorite'] =
            !_wardrobeItems[itemIndex]['favorite'];
      }
    });
  }
}

class _AddItemBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onItemAdded;

  const _AddItemBottomSheet({required this.onItemAdded});

  @override
  State<_AddItemBottomSheet> createState() => _AddItemBottomSheetState();
}

class _AddItemBottomSheetState extends State<_AddItemBottomSheet> {
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color lightGray = Color(0xFFF8F9FA);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Tops';
  String _selectedColor = 'White';
  File? _selectedImage;
  final List<String> _selectedTags = [];

  final List<String> _categories = [
    'Tops',
    'Bottoms',
    'Dresses',
    'Outerwear',
    'Accessories',
    'Shoes',
  ];
  final List<String> _colors = [
    'White',
    'Black',
    'Blue',
    'Navy',
    'Red',
    'Yellow',
    'Green',
    'Purple',
    'Pink',
    'Brown',
    'Gray',
    'Beige',
  ];
  final List<String> _availableTags = [
    'professional',
    'casual',
    'formal',
    'trendy',
    'vintage',
    'comfortable',
    'stretchy',
    'breathable',
    'versatile',
    'statement',
    'classic',
    'summer',
    'winter',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 48,
            height: 6,
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              color: mediumGray.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryBlue, primaryBlue.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.add_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add New Item',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: darkGray,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Build your digital wardrobe',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: mediumGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: lightGray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: mediumGray,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImagePicker(),
                    const SizedBox(height: 32),
                    _buildTextField(
                      'Item Name',
                      _nameController,
                      'e.g., Classic White Button-Down Shirt',
                      Icons.label_rounded,
                    ),
                    const SizedBox(height: 20),
                    _buildCategoryDropdown(),
                    const SizedBox(height: 20),
                    _buildColorDropdown(),
                    const SizedBox(height: 20),
                    _buildTextField(
                      'Description',
                      _descriptionController,
                      'e.g., Crisp cotton button-down shirt perfect for professional settings',
                      Icons.description_rounded,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    _buildTagSelector(),
                    const SizedBox(height: 40),
                    _buildSaveButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Photo',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: darkGray,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryBlue.withValues(alpha: 0.1),
                accentYellow.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: mediumGray.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child:
              _selectedImage != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                  )
                  : Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _pickImage,
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: primaryBlue,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Add Photo',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: darkGray,
                            ),
                          ),
                          Text(
                            'Tap to take a photo or choose from gallery',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: mediumGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: darkGray,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: mediumGray.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            prefixIcon: Icon(icon, color: primaryBlue, size: 20),
            filled: true,
            fillColor: lightGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: primaryBlue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: darkGray,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '$label is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: darkGray,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: lightGray,
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.category_rounded,
                color: primaryBlue,
                size: 20,
              ),
              filled: true,
              fillColor: lightGray,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: primaryBlue, width: 2),
              ),
            ),
            items:
                _categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(
                          category,
                          style: GoogleFonts.poppins(color: darkGray),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (value) => setState(() => _selectedCategory = value!),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a category';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: darkGray,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: lightGray,
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedColor,
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _getColorValue(_selectedColor),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
              ),
              filled: true,
              fillColor: lightGray,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: primaryBlue, width: 2),
              ),
            ),
            items:
                _colors
                    .map(
                      (color) => DropdownMenuItem(
                        value: color,
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: _getColorValue(color),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              color,
                              style: GoogleFonts.poppins(color: darkGray),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (value) => setState(() => _selectedColor = value!),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a color';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTagSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags (Optional)',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: darkGray,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select tags that describe this item',
          style: GoogleFonts.poppins(fontSize: 12, color: mediumGray),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedTags.remove(tag);
                      } else {
                        _selectedTags.add(tag);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryBlue : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            isSelected
                                ? primaryBlue
                                : mediumGray.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isSelected ? Colors.white : darkGray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue, primaryBlue.withValues(alpha: 0.8)],
        ),

        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _saveItem,
        icon: Icon(Icons.save_rounded, color: Colors.white, size: 20),
        label: Text(
          'Save Item',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Color _getColorValue(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'white':
        return Colors.white;
      case 'black':
        return Colors.black;
      case 'blue':
        return Colors.blue;
      case 'navy':
        return const Color(0xFF001F3F);
      case 'red':
        return Colors.red;
      case 'yellow':
        return Colors.yellow;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'brown':
        return Colors.brown;
      case 'gray':
        return Colors.grey;
      case 'beige':
        return const Color(0xFFF5F5DC);
      default:
        return mediumGray;
    }
  }

  void _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.camera_alt_rounded, color: primaryBlue),
                  title: Text('Take Photo', style: GoogleFonts.poppins()),
                  onTap: () async {
                    Navigator.pop(context);
                    final picker = ImagePicker();
                    final image = await picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (image != null) {
                      setState(() => _selectedImage = File(image.path));
                    }
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo_library_rounded,
                    color: primaryBlue,
                  ),
                  title: Text(
                    'Choose from Gallery',
                    style: GoogleFonts.poppins(),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    final picker = ImagePicker();
                    final image = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      setState(() => _selectedImage = File(image.path));
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      // Create new item
      final newItem = {
        'name': _nameController.text.trim(),
        'category': _selectedCategory,
        'color': _selectedColor,
        'brand': '', // Set empty brand
        'description': _descriptionController.text.trim(),
        'image': _selectedImage?.path,
        'tags': List<String>.from(_selectedTags),
      };

      // Add item to wardrobe
      widget.onItemAdded(newItem);

      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Item Added Successfully!',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${_nameController.text} added to $_selectedCategory',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}

class _ItemDetailsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> item;

  const _ItemDetailsBottomSheet({required this.item});

  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color lightGray = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 48,
            height: 6,
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              color: mediumGray.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item['name'],
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: darkGray,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: lightGray,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item['favorite']
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: item['favorite'] ? accentRed : mediumGray,
                        ),
                      ),
                    ],
                  ),
                  if (item['brand'] != null &&
                      item['brand'].toString().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      item['brand'],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: mediumGray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Image placeholder
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryBlue.withValues(alpha: 0.1),
                          accentYellow.withValues(alpha: 0.1),
                        ],
                      ),

                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.checkroom_rounded,
                        size: 64,
                        color: primaryBlue.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Details
                  Text(
                    'Details',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: darkGray,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item['description'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: mediumGray,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Tags
                  if (item['tags'] != null && item['tags'].isNotEmpty) ...[
                    Text(
                      'Tags',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: darkGray,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          (item['tags'] as List)
                              .map(
                                (tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryBlue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    tag,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: primaryBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
