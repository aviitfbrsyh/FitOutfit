import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AllFavoritesPage extends StatefulWidget {
  const AllFavoritesPage({super.key});

  @override
  State<AllFavoritesPage> createState() => _AllFavoritesPageState();
}

class _AllFavoritesPageState extends State<AllFavoritesPage> 
    with TickerProviderStateMixin {
  
  // === DESIGN CONSTANTS ===
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color lightBlue = Color(0xFFEBF3FF);
  static const Color lightYellow = Color(0xFFFFF8E8);
  static const Color softWhite = Color(0xFFFFFFFE);

  // === DESIGN MEASUREMENTS ===
  static const double searchHeight = 52.0;
  static const double tabHeight = 56.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;

  // === ANIMATIONS ===
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // === STATE VARIABLES ===
  int _selectedTab = 0;
  String _searchQuery = '';
  String _sortBy = 'recent';
  
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All', 'Wardrobe', 'Outfits', 'Articles', 'Try-Ons', 'Community', 'Shopping'
  ];

  // === LIFECYCLE ===
  @override
  void initState() {
    super.initState();
    _initAnimations();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  // === RESPONSIVE HELPERS ===
  double get _screenWidth => MediaQuery.of(context).size.width;
  double get _screenHeight => MediaQuery.of(context).size.height;
  
  bool get _isSmallScreen => _screenWidth < 360;
  bool get _isTablet => _screenWidth >= 600 && _screenWidth < 900;
  bool get _isDesktop => _screenWidth >= 900;
  
  // Responsive padding system
  double get _paddingXS => _isSmallScreen ? 12 : 16;
  double get _paddingS => _isSmallScreen ? 16 : (_isTablet ? 20 : 24);
  double get _paddingL => _isSmallScreen ? 24 : (_isTablet ? 32 : 40);
  
  // Responsive font sizes
  double _fontSizeXS(double base) => _responsiveSize(base * 0.8);
  double _fontSizeS(double base) => _responsiveSize(base * 0.9);
  double _fontSize(double base) => _responsiveSize(base);
  double _fontSizeL(double base) => _responsiveSize(base * 1.1);
  
  double _responsiveSize(double size) {
    if (_isSmallScreen) return size * 0.9;
    if (_isTablet) return size * 1.05;
    if (_isDesktop) return size * 1.1;
    return size;
  }

  // Grid calculations
  int get _gridColumns {
    if (_isDesktop) return 4;
    if (_isTablet) return 3;
    return 2;
  }

  double get _cardAspectRatio {
    if (_isSmallScreen) return 0.72;
    if (_isTablet) return 0.78;
    return 0.75;
  }

  // === BUILD METHODS ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlue,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(child: _buildSearchSection()),
              SliverToBoxAdapter(child: _buildCategoryTabs()),
              _buildFavoritesGrid(),
              SliverToBoxAdapter(child: SizedBox(height: _paddingL)),
            ],
          ),
        ),
      ),
    );
  }
// === SLIVER APP BAR (BLUE DOMINANT GRADIENT) ===
Widget _buildSliverAppBar() {
  final filteredCount = _getFilteredItems().length;
  final totalCount = _getAllItems().length;
  
  return SliverAppBar(
    expandedHeight: 130.0,
    floating: false,
    pinned: true,
    elevation: 0,
    backgroundColor: primaryBlue,
    automaticallyImplyLeading: false,
    surfaceTintColor: Colors.transparent,
    clipBehavior: Clip.hardEdge,
    centerTitle: true,
    
    flexibleSpace: FlexibleSpaceBar(
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryBlue,                    // Biru dominan (start)
              primaryBlue.withOpacity(0.9),   // Biru medium
              primaryBlue.withOpacity(0.8),   // Biru lighter
              Color(0xFF4A90E2).withOpacity(0.7), // Biru medium
              Color(0xFF5BA3F5).withOpacity(0.6), // Biru dengan hint kuning
              accentYellow.withOpacity(0.3),  // Kuning accent
              accentRed.withOpacity(0.2),     // Merah subtle
              primaryBlue.withOpacity(0.85),  // Back to biru (end)
            ],
            stops: const [0.0, 0.15, 0.3, 0.45, 0.6, 0.75, 0.9, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: _paddingS, vertical: 8),
            child: Column(
              children: [
                // Top Row: Back Button Only
                Row(
                  children: [
                    _buildBackButton(),
                    const Spacer(),
                  ],
                ),
                
                SizedBox(height: 8),
                
                // Title Section (Only visible when expanded)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon Container
                      Container(
                        width: 40,
                        height: 40,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: softWhite,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite_rounded,
                          color: accentRed,
                          size: 18,
                        ),
                      ),
                      
                      SizedBox(width: 12),
                      
                      // Title & Stats
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Main Title
                            Text(
                              'My Favorites',
                              style: GoogleFonts.poppins(
                                fontSize: _fontSizeL(20),
                                fontWeight: FontWeight.w800,
                                color: softWhite,
                                height: 1.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            SizedBox(height: 4),
                            
                            // Stats Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: softWhite.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: softWhite.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _searchQuery.isNotEmpty || _selectedTab > 0
                                    ? '$filteredCount of $totalCount items'
                                    : '$totalCount items • Updated 2025-06-13 18:25',
                                style: GoogleFonts.poppins(
                                  fontSize: _fontSizeXS(9),
                                  fontWeight: FontWeight.w600,
                                  color: softWhite,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      
      // COMPACT CENTERED TITLE THAT ONLY SHOWS WHEN COLLAPSED
      centerTitle: true,
      titlePadding: const EdgeInsets.only(
        bottom: 14,
        left: 60,
        right: 60,
      ),
      title: LayoutBuilder(
        builder: (context, constraints) {
          final expandRatio = constraints.maxHeight > kToolbarHeight ? 
                              (constraints.maxHeight - kToolbarHeight) / (130.0 - kToolbarHeight) : 0.0;
          
          final titleOpacity = expandRatio < 0.2 ? (1.0 - (expandRatio * 5)) : 0.0;
          
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: titleOpacity.clamp(0.0, 1.0),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: titleOpacity.clamp(0.85, 1.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: softWhite,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_rounded, 
                        color: accentRed, 
                        size: 12,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'My Favorites',
                        style: GoogleFonts.poppins(
                          fontSize: _fontSize(12),
                          fontWeight: FontWeight.w700,
                          color: darkGray,
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
  );
}

Widget _buildBackButton() {
  return GestureDetector(
    onTap: () => Navigator.pop(context),
    child: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: accentYellow,
        shape: BoxShape.circle,
        border: Border.all(
          color: accentYellow.withOpacity(0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentYellow.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Icon(
        Icons.arrow_back_ios_rounded,
        color: Colors.white,
        size: 16,
      ),
    ),
  );
}

  // === SEARCH SECTION (SYMMETRIC DESIGN) ===
  Widget _buildSearchSection() {
    return Container(
      padding: EdgeInsets.all(_paddingS),
      color: softWhite,
      child: Column(
        children: [
          _buildSearchBar(),
          SizedBox(height: _paddingXS),
          _buildFilterRow(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: searchHeight,
      decoration: BoxDecoration(
        color: lightGray,
        borderRadius: BorderRadius.circular(buttonBorderRadius),
        border: Border.all(
          color: _searchQuery.isNotEmpty 
              ? primaryBlue.withOpacity(0.3) 
              : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: _searchQuery.isNotEmpty ? [
          BoxShadow(
            color: primaryBlue.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.poppins(
          fontSize: _fontSize(14),
          fontWeight: FontWeight.w500,
          color: darkGray,
        ),
        decoration: InputDecoration(
          hintText: 'Search favorites by name, category...',
          hintStyle: GoogleFonts.poppins(
            color: mediumGray,
            fontSize: _fontSize(14),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Container(
            padding: EdgeInsets.all(_paddingXS),
            child: Icon(
              Icons.search_rounded, 
              color: _searchQuery.isNotEmpty ? primaryBlue : mediumGray, 
              size: _responsiveSize(20),
            ),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: _clearSearch,
                  child: Container(
                    padding: EdgeInsets.all(_paddingXS),
                    child: Container(
                      decoration: BoxDecoration(
                        color: accentRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded, 
                        color: accentRed, 
                        size: _responsiveSize(16),
                      ),
                    ),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: _paddingS, vertical: _paddingXS),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        Expanded(child: _buildSortButton()),
        if (_searchQuery.isNotEmpty || _selectedTab > 0) ...[
          SizedBox(width: _paddingXS),
          _buildClearButton(),
        ],
      ],
    );
  }

  Widget _buildSortButton() {
    return GestureDetector(
      onTap: _showSortOptions,
      child: Container(
        height: 40,
        padding: EdgeInsets.symmetric(horizontal: _paddingXS),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryBlue.withOpacity(0.12),
              primaryBlue.withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(buttonBorderRadius),
          border: Border.all(color: primaryBlue.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.tune_rounded, color: primaryBlue, size: _responsiveSize(16)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Sort: ${_getSortLabel()}',
                style: GoogleFonts.poppins(
                  color: primaryBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: _fontSizeS(12),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, color: primaryBlue, size: _responsiveSize(16)),
          ],
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    return GestureDetector(
      onTap: _clearAllFilters,
      child: Container(
        height: 40,
        padding: EdgeInsets.symmetric(horizontal: _paddingXS),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accentRed.withOpacity(0.12),
              accentRed.withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(buttonBorderRadius),
          border: Border.all(color: accentRed.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.clear_rounded, color: accentRed, size: _responsiveSize(14)),
            SizedBox(width: 6),
            Text(
              'Clear',
              style: GoogleFonts.poppins(
                color: accentRed,
                fontWeight: FontWeight.w600,
                fontSize: _fontSizeS(11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === CATEGORY TABS (PERFECTLY SPACED) ===
  Widget _buildCategoryTabs() {
    return Container(
      height: tabHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            lightYellow.withOpacity(0.4),
            lightYellow.withOpacity(0.2),
          ],
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: _paddingS, vertical: 8),
        itemCount: _categories.length,
        itemBuilder: (context, index) => _buildTabItem(index),
      ),
    );
  }

  Widget _buildTabItem(int index) {
    final isSelected = _selectedTab == index;
    final categoryCount = _getCategoryCount(index);
    
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        margin: EdgeInsets.only(right: _paddingXS * 0.75),
        padding: EdgeInsets.symmetric(horizontal: _paddingXS, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? LinearGradient(colors: [primaryBlue, primaryBlue.withOpacity(0.9)])
              : LinearGradient(colors: [softWhite, lightGray.withOpacity(0.5)]),
          borderRadius: BorderRadius.circular(buttonBorderRadius),
          border: Border.all(
            color: isSelected ? primaryBlue : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: primaryBlue.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _categories[index],
              style: GoogleFonts.poppins(
                color: isSelected ? softWhite : darkGray,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: _fontSizeS(12),
              ),
            ),
            if (categoryCount > 0) ...[
              SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? softWhite.withOpacity(0.25)
                      : accentYellow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$categoryCount',
                  style: GoogleFonts.poppins(
                    color: softWhite,
                    fontWeight: FontWeight.w700,
                    fontSize: _fontSizeXS(9),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // === FAVORITES GRID (PERFECTLY ALIGNED) ===
  Widget _buildFavoritesGrid() {
    final filteredItems = _getFilteredItems();
    
    if (filteredItems.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState());
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: _paddingS),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _gridColumns,
          crossAxisSpacing: _paddingS,
          mainAxisSpacing: _paddingS,
          childAspectRatio: _cardAspectRatio,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = filteredItems[index];
            return _buildFavoriteCard(item, index);
          },
          childCount: filteredItems.length,
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> item, int index) {
    return GestureDetector(
      onTap: () => _openItemDetail(item),
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 300 + (index * 50)),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (value * 0.2),
            child: Opacity(
              opacity: value,
              child: Container(
                decoration: BoxDecoration(
                  color: softWhite,
                  borderRadius: BorderRadius.circular(cardBorderRadius),
                  border: Border.all(
                    color: item['color'].withOpacity(0.15),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: item['color'].withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(flex: 3, child: _buildCardHeader(item)),
                    Expanded(flex: 2, child: _buildCardContent(item)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardHeader(Map<String, dynamic> item) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            item['color'].withOpacity(0.08),
            item['color'].withOpacity(0.04),
            softWhite.withOpacity(0.5),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(cardBorderRadius),
          topRight: Radius.circular(cardBorderRadius),
        ),
      ),
      child: Stack(
        children: [
          // Main Icon (Centered)
          Center(
            child: Container(
              padding: EdgeInsets.all(_paddingXS),
              decoration: BoxDecoration(
                color: item['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(buttonBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: item['color'].withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                item['icon'],
                color: item['color'],
                size: _responsiveSize(28),
              ),
            ),
          ),
          
          // Favorite Badge (Top Right)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: softWhite,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                Icons.favorite_rounded, 
                color: accentRed, 
                size: _responsiveSize(12),
              ),
            ),
          ),
          
          // Category Badge (Top Left)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item['color'],
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: item['color'].withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                item['category'].toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: _fontSizeXS(8),
                  fontWeight: FontWeight.w700,
                  color: softWhite,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent(Map<String, dynamic> item) {
    return Padding(
      padding: EdgeInsets.all(_paddingXS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            item['title'],
            style: GoogleFonts.poppins(
              fontSize: _fontSizeS(13),
              fontWeight: FontWeight.w700,
              color: darkGray,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          SizedBox(height: 4),
          
          // Subtitle
          Text(
            item['subtitle'],
            style: GoogleFonts.poppins(
              fontSize: _fontSizeXS(10),
              fontWeight: FontWeight.w500,
              color: mediumGray,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const Spacer(),
          
          // Bottom Row (Stats + Count)
          Row(
            children: [
              Icon(
                item['statsIcon'], 
                color: item['color'], 
                size: _responsiveSize(12),
              ),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  item['stats'],
                  style: GoogleFonts.poppins(
                    fontSize: _fontSizeXS(9),
                    fontWeight: FontWeight.w600,
                    color: item['color'],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentYellow, accentYellow.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: accentYellow.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  item['count'],
                  style: GoogleFonts.poppins(
                    fontSize: _fontSizeXS(8),
                    fontWeight: FontWeight.w800,
                    color: softWhite,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: _screenHeight * 0.5,
      padding: EdgeInsets.all(_paddingL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(_paddingL),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  mediumGray.withOpacity(0.08),
                  mediumGray.withOpacity(0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              _searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.favorite_border_rounded,
              size: _responsiveSize(48),
              color: mediumGray,
            ),
          ),
          
          SizedBox(height: _paddingS),
          
          Text(
            _searchQuery.isNotEmpty ? 'No results found' : 'No favorites yet',
            style: GoogleFonts.poppins(
              fontSize: _fontSizeL(18),
              fontWeight: FontWeight.w700,
              color: darkGray,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 8),
          
          Text(
            _searchQuery.isNotEmpty 
                ? 'Try adjusting your search terms or filters' 
                : 'Start adding items to your favorites collection',
            style: GoogleFonts.poppins(
              fontSize: _fontSize(14),
              fontWeight: FontWeight.w400,
              color: mediumGray,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          if (_searchQuery.isNotEmpty) ...[
            SizedBox(height: _paddingS),
            ElevatedButton.icon(
              onPressed: _clearAllFilters,
              icon: Icon(Icons.refresh_rounded, size: _responsiveSize(16)),
              label: Text(
                'Clear Search',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: _fontSize(13),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: softWhite,
                padding: EdgeInsets.symmetric(horizontal: _paddingS, vertical: _paddingXS),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(buttonBorderRadius),
                ),
                elevation: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // === HELPER METHODS - DATA ===
  List<Map<String, dynamic>> _getAllItems() {
    return [
      {
        'id': 'wardrobe_1',
        'category': 'wardrobe',
        'title': 'Vintage Leather Jacket',
        'subtitle': 'Premium brown leather • Zara',
        'color': primaryBlue,
        'icon': Icons.checkroom_outlined,
        'stats': 'Added 2 days ago',
        'statsIcon': Icons.schedule_rounded,
        'count': '42',
        'tags': ['leather', 'vintage', 'jacket', 'brown', 'zara'],
        'dateAdded': DateTime(2025, 6, 11),
      },
      {
        'id': 'outfit_1',
        'category': 'outfit',
        'title': 'Autumn Cozy Vibes',
        'subtitle': 'AI-curated casual look',
        'color': accentYellow,
        'icon': Icons.auto_awesome_outlined,
        'stats': '2.3K likes',
        'statsIcon': Icons.favorite_rounded,
        'count': '18',
        'tags': ['autumn', 'casual', 'cozy', 'ai', 'curated'],
        'dateAdded': DateTime(2025, 6, 10),
      },
      {
        'id': 'article_1',
        'category': 'article',
        'title': 'Spring Fashion Trends 2024',
        'subtitle': 'Complete style guide',
        'color': accentRed,
        'icon': Icons.article_outlined,
        'stats': '5 min read',
        'statsIcon': Icons.schedule_rounded,
        'count': '15',
        'tags': ['spring', 'trends', '2024', 'fashion', 'guide'],
        'dateAdded': DateTime(2025, 6, 12),
      },
      {
        'id': 'tryon_1',
        'category': 'try-on',
        'title': 'Virtual Summer Look',
        'subtitle': 'AR try-on session',
        'color': const Color(0xFF9C27B0),
        'icon': Icons.camera_alt_outlined,
        'stats': 'Perfect match 95%',
        'statsIcon': Icons.verified_rounded,
        'count': '23',
        'tags': ['summer', 'virtual', 'ar', 'try-on'],
        'dateAdded': DateTime(2025, 6, 9),
      },
      {
        'id': 'community_1',
        'category': 'community',
        'title': 'Minimalist Capsule Wardrobe',
        'subtitle': '@sarah_minimal inspiration',
        'color': const Color(0xFF00BCD4),
        'icon': Icons.people_outline,
        'stats': '1.2K followers',
        'statsIcon': Icons.group_rounded,
        'count': '31',
        'tags': ['minimalist', 'capsule', 'wardrobe', 'sarah', 'inspiration'],
        'dateAdded': DateTime(2025, 6, 8),
      },
      {
        'id': 'shopping_1',
        'category': 'shopping',
        'title': 'Designer Silk Scarf',
        'subtitle': 'Wishlist • \$129.99',
        'color': const Color(0xFF4CAF50),
        'icon': Icons.shopping_bag_outlined,
        'stats': '20% off today',
        'statsIcon': Icons.local_offer_rounded,
        'count': '119',
        'tags': ['designer', 'silk', 'scarf', 'wishlist', 'luxury'],
        'dateAdded': DateTime(2025, 6, 13),
      },
    ];
  }

  List<Map<String, dynamic>> _getFilteredItems() {
    var items = _getAllItems();
    
    if (_selectedTab > 0) {
      final category = _categories[_selectedTab].toLowerCase();
      items = items.where((item) => 
        item['category'] == category.replaceAll('-', '').replaceAll('s', '')).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) {
        final query = _searchQuery.toLowerCase();
        return item['title'].toLowerCase().contains(query) ||
               item['subtitle'].toLowerCase().contains(query) ||
               item['category'].toLowerCase().contains(query) ||
               item['tags'].any((tag) => tag.toString().toLowerCase().contains(query));
      }).toList();
    }
    
    switch (_sortBy) {
      case 'name':
        items.sort((a, b) => a['title'].compareTo(b['title']));
        break;
      case 'category':
        items.sort((a, b) => a['category'].compareTo(b['category']));
        break;
      case 'oldest':
        items.sort((a, b) => a['dateAdded'].compareTo(b['dateAdded']));
        break;
      case 'recent':
      default:
        items.sort((a, b) => b['dateAdded'].compareTo(a['dateAdded']));
        break;
    }
    
    return items;
  }

  int _getCategoryCount(int tabIndex) {
    if (tabIndex == 0) return _getAllItems().length;
    final category = _categories[tabIndex].toLowerCase();
    return _getAllItems().where((item) => 
      item['category'] == category.replaceAll('-', '').replaceAll('s', '')).length;
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'name': return 'Name A-Z';
      case 'category': return 'Category';
      case 'oldest': return 'Oldest First';
      case 'recent': return 'Recent First';
      default: return 'Recent First';
    }
  }

  // === ACTION METHODS ===
  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  void _clearAllFilters() {
    setState(() {
      _selectedTab = 0;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _openItemDetail(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FavoriteDetailPage(item: item)),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: softWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: EdgeInsets.all(_paddingS),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              SizedBox(height: _paddingS),
              
              // Title
              Text(
                'Sort Options',
                style: GoogleFonts.poppins(
                  fontSize: _fontSizeL(18),
                  fontWeight: FontWeight.w800,
                  color: darkGray,
                ),
              ),
              
              SizedBox(height: _paddingS),
              
              // Options
              ...[
                ('recent', 'Recent First', Icons.schedule_rounded),
                ('oldest', 'Oldest First', Icons.history_rounded),
                ('name', 'Name A-Z', Icons.sort_by_alpha_rounded),
                ('category', 'Category', Icons.category_rounded),
              ].map((option) => _buildSortOption(option.$1, option.$2, option.$3)),
              
              SizedBox(height: _paddingXS),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(String value, String title, IconData icon) {
    final isSelected = _sortBy == value;
    return GestureDetector(
      onTap: () {
        setState(() => _sortBy = value);
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: _paddingXS, horizontal: _paddingS),
        margin: EdgeInsets.only(bottom: _paddingXS * 0.5),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(buttonBorderRadius),
          border: Border.all(
            color: isSelected ? primaryBlue.withOpacity(0.2) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? primaryBlue : mediumGray.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? softWhite : mediumGray,
                size: _responsiveSize(16),
              ),
            ),
            
            SizedBox(width: _paddingXS),
            
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: _fontSize(14),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? primaryBlue : darkGray,
                ),
              ),
            ),
            
            if (isSelected)
              Icon(
                Icons.check_rounded,
                color: primaryBlue,
                size: _responsiveSize(18),
              ),
          ],
        ),
      ),
    );
  }
}

// === DETAIL PAGE (RESPONSIVE) ===
class FavoriteDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const FavoriteDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final padding = isTablet ? 24.0 : 20.0;
    
    return Scaffold(
      backgroundColor: const Color(0xFFEBF3FF),
      appBar: AppBar(
        title: Text(
          item['title'],
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: isTablet ? 18 : 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            Container(
              width: double.infinity,
              height: isTablet ? 280 : 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    item['color'].withOpacity(0.15),
                    item['color'].withOpacity(0.08),
                    Colors.white.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: item['color'].withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(isTablet ? 24 : 20),
                  decoration: BoxDecoration(
                    color: item['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    item['icon'],
                    size: isTablet ? 80 : 64,
                    color: item['color'],
                  ),
                ),
              ),
            ),
            
            SizedBox(height: padding),
            
            // Title & Subtitle
            Text(
              item['title'],
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 28 : 24,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2C3E50),
                height: 1.2,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              item['subtitle'],
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),
            
            SizedBox(height: padding),
            
            // Details Card
            Container(
              padding: EdgeInsets.all(isTablet ? 24 : 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Details',
                    style: GoogleFonts.poppins(
                      fontSize: isTablet ? 20 : 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  
                  SizedBox(height: isTablet ? 20 : 16),
                  
                  _buildDetailRow('Category', item['category'], isTablet),
                  _buildDetailRow('Stats', item['stats'], isTablet),
                  _buildDetailRow('Count', item['count'], isTablet),
                  _buildDetailRow('Tags', item['tags'].join(', '), isTablet),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isTablet ? 100 : 80,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2C3E50),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
