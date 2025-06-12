import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class OutfitResultPage extends StatefulWidget {
  final Map<String, dynamic> outfitData;
  final String occasion;
  final String weather;
  final String style;

  const OutfitResultPage({
    super.key,
    required this.outfitData,
    required this.occasion,
    required this.weather,
    required this.style,
  });

  @override
  State<OutfitResultPage> createState() => _OutfitResultPageState();
}

class _OutfitResultPageState extends State<OutfitResultPage>
    with TickerProviderStateMixin {
  // Organized Color Palette
  static const Map<String, Color> colors = {
    // Primary Colors
    'primaryBlue': Color(0xFF4A90E2),
    'secondaryBlue': Color(0xFF6BA3F0),
    'electricBlue': Color(0xFF00D4FF),
    'skyBlue': Color(0xFFE3F2FD),

    // Accent Colors
    'accentYellow': Color(0xFFF5A623),
    'sunsetOrange': Color(0xFFFF6B35),
    'vibrantPurple': Color(0xFF9B59B6),
    'hotPink': Color(0xFFE91E63),
    'neonGreen': Color(0xFF2ECC71),
    'deepTeal': Color(0xFF00BCD4),
    'accentRed': Color(0xFFD0021B),

    // Neutral Colors
    'darkGray': Color(0xFF2C3E50),
    'mediumGray': Color(0xFF6B7280),
    'lightGray': Color(0xFFF8F9FA),
    'pureWhite': Color(0xFFFFFFFF),

    // Background Colors
    'lightLavender': Color(0xFFF3E5F5),
    'mintGreen': Color(0xFFE8F5E8),
    'softPeach': Color(0xFFFFF3E0),
    'shadowColor': Color(0x1A000000),
  };

  // Consistent Spacing and Sizing
  static const double spacing = 16.0;

  // Animation Controllers
  late final List<AnimationController> _controllers;
  late final Map<String, Animation<double>> _animations;

  bool _showAIAnalysis = false;
  int _currentSwipeIndex = 0;
  late PageController _pageController;

  final List<Map<String, dynamic>> _alternatives = [
    {
      'name': 'Casual Chic',
      'rating': 4.7,
      'items': ['White Tee', 'Blue Jeans', 'Sneakers'],
      'style': 'Relaxed',
    },
    {
      'name': 'Elegant Edge',
      'rating': 4.8,
      'items': ['Silk Blouse', 'Dress Pants', 'Heels'],
      'style': 'Sophisticated',
    },
    {
      'name': 'Smart Casual',
      'rating': 4.6,
      'items': ['Polo Shirt', 'Chinos', 'Loafers'],
      'style': 'Versatile',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    final controllerConfigs = [
      {'name': 'header', 'duration': 600},
      {'name': 'content', 'duration': 800},
      {'name': 'badge', 'duration': 1000},
      {'name': 'aiPulse', 'duration': 2000},
      {'name': 'sparkle', 'duration': 3000},
      {'name': 'match', 'duration': 1200},
    ];

    _controllers =
        controllerConfigs
            .map(
              (config) => AnimationController(
                duration: Duration(milliseconds: config['duration'] as int),
                vsync: this,
              ),
            )
            .toList();

    _animations = {
      'header': Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controllers[0], curve: Curves.easeOutQuart),
      ),
      'content': Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controllers[1], curve: Curves.easeOutCubic),
      ),
      'badge': Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controllers[2], curve: Curves.elasticOut),
      ),
      'aiPulse': Tween<double>(begin: 0.98, end: 1.02).animate(
        CurvedAnimation(parent: _controllers[3], curve: Curves.easeInOut),
      ),
      'sparkle': Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controllers[4], curve: Curves.linear)),
      'match': Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controllers[5], curve: Curves.easeOutCubic),
      ),
    };
  }

  void _startAnimationSequence() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controllers[0].forward();
        _controllers[3].repeat(reverse: true);
      }
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controllers[1].forward();
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _controllers[2].forward();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _controllers[4].repeat();
        _controllers[5].forward();
        setState(() => _showAIAnalysis = true);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors['lightGray'],
      body: Container(
        decoration: _buildBackgroundDecoration(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors['pureWhite']!,
            colors['lightGray']!.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors['shadowColor']!,
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _animations['badge']!,
        builder:
            (context, child) => Transform.scale(
              scale: _animations['badge']!.value,
              child: Row(
                children: [
                  // Save to Favorites Button
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    Icons.favorite_rounded,
                                    color: colors['pureWhite'],
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Saved!',
                                      style: GoogleFonts.poppins(
                                        color: colors['pureWhite'],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: colors['hotPink'],
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(12),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors['hotPink']!.withValues(
                            alpha: 0.1,
                          ),
                          foregroundColor: colors['hotPink'],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: colors['hotPink']!.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Icon(Icons.favorite_rounded, size: 18),
                      ),
                    ),
                  ),

                  SizedBox(width: 8),

                  // Generate Another Button
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _generateAnother,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors['vibrantPurple'],
                          foregroundColor: colors['pureWhite'],
                          elevation: 6,
                          shadowColor: colors['vibrantPurple']!.withValues(
                            alpha: 0.3,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh_rounded, size: 16),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Generate',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colors['lightGray']!,
          colors['skyBlue']!,
          colors['mintGreen']!,
          colors['softPeach']!,
          colors['lightLavender']!,
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
      collapsedHeight: 70,
      pinned: true,
      floating: false,
      snap: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final top = constraints.biggest.height;
          final isCollapsed = top <= 90;

          return FlexibleSpaceBar(
            background: _buildSimpleAppBarBackground(isCollapsed),
            collapseMode: CollapseMode.pin,
            titlePadding: EdgeInsets.zero,
          );
        },
      ),
    );
  }

  Widget _buildSimpleAppBarBackground(bool isCollapsed) {
    return AnimatedBuilder(
      animation: _animations['header']!,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors['vibrantPurple']!.withValues(alpha: 0.95),
                colors['electricBlue']!.withValues(alpha: 0.9),
                colors['deepTeal']!.withValues(alpha: 0.85),
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(isCollapsed ? 16 : 24),
              bottomRight: Radius.circular(isCollapsed ? 16 : 24),
            ),
            boxShadow: [
              BoxShadow(
                color: colors['vibrantPurple']!.withValues(
                  alpha: isCollapsed ? 0.1 : 0.2,
                ),
                blurRadius: isCollapsed ? 8 : 16,
                offset: Offset(0, isCollapsed ? 3 : 6),
              ),
            ],
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Background pattern (simplified)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.05,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(isCollapsed ? 16 : 24),
                          bottomRight: Radius.circular(isCollapsed ? 16 : 24),
                        ),
                      ),
                    ),
                  ),
                ),

                // Top controls - Fixed positioning
                Positioned(
                  top: 8,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSimpleBackButton(),
                      SizedBox(width: 40), // Placeholder for symmetry
                    ],
                  ),
                ),

                // Main content - Responsive positioning
                Positioned(
                  bottom: isCollapsed ? 8 : 16,
                  left: 20,
                  right: 20,
                  child: Transform.translate(
                    offset: Offset(0, 10 * (1 - _animations['header']!.value)),
                    child: Opacity(
                      opacity: _animations['header']!.value,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Responsive layout based on available width
                          final screenWidth = MediaQuery.of(context).size.width;
                          final isSmallScreen = screenWidth < 360;

                          return Row(
                            children: [
                              // Icon container
                              Container(
                                padding: EdgeInsets.all(
                                  isCollapsed ? 6 : (isSmallScreen ? 8 : 10),
                                ),
                                decoration: BoxDecoration(
                                  color: colors['pureWhite']!.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    isCollapsed ? 10 : 14,
                                  ),
                                  border: Border.all(
                                    color: colors['pureWhite']!.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons
                                      .psychology_rounded, // Changed from auto_awesome_rounded
                                  color: colors['pureWhite'],
                                  size:
                                      isCollapsed
                                          ? 16
                                          : (isSmallScreen ? 18 : 20),
                                ),
                              ),
                              SizedBox(width: isSmallScreen ? 10 : 12),

                              // Text content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Title
                                    Text(
                                      widget.outfitData['name'] ??
                                          'Perfect AI Match',
                                      style: GoogleFonts.poppins(
                                        fontSize:
                                            isCollapsed
                                                ? (isSmallScreen ? 16 : 18)
                                                : (isSmallScreen ? 20 : 24),
                                        fontWeight: FontWeight.w800,
                                        color: colors['pureWhite'],
                                        letterSpacing: -0.5,
                                        height: 1.1,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    // Stats row - only show when not collapsed
                                    if (!isCollapsed) ...[
                                      SizedBox(height: isSmallScreen ? 2 : 4),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            _buildCompactStat(
                                              Icons.star_rounded,
                                              '${widget.outfitData['rating'] ?? 4.9}',
                                              colors['accentYellow']!,
                                              isSmallScreen,
                                            ),
                                            SizedBox(
                                              width: isSmallScreen ? 6 : 8,
                                            ),
                                            AnimatedBuilder(
                                              animation: _animations['match']!,
                                              builder:
                                                  (
                                                    context,
                                                    child,
                                                  ) => _buildCompactStat(
                                                    Icons.verified_rounded,
                                                    '${((widget.outfitData['matchScore'] ?? 95) * _animations['match']!.value).round()}%',
                                                    colors['neonGreen']!,
                                                    isSmallScreen,
                                                  ),
                                            ),
                                            SizedBox(
                                              width: isSmallScreen ? 6 : 8,
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    isSmallScreen ? 6 : 8,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: colors['pureWhite']!
                                                    .withValues(alpha: 0.15),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${widget.occasion} • ${widget.weather}',
                                                style: GoogleFonts.poppins(
                                                  fontSize:
                                                      isSmallScreen ? 8 : 9,
                                                  color: colors['pureWhite']!
                                                      .withValues(alpha: 0.9),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimpleBackButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colors['pureWhite']!.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors['pureWhite']!.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colors['pureWhite'],
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildCompactStat(
    IconData icon,
    String value,
    Color color,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 6 : 8,
        vertical: isSmallScreen ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: colors['pureWhite']!.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: isSmallScreen ? 10 : 12),
          SizedBox(width: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 9 : 10,
              fontWeight: FontWeight.w700,
              color: colors['pureWhite'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return AnimatedBuilder(
      animation: _animations['content']!,
      builder:
          (context, child) => Transform.translate(
            offset: Offset(0, 50 * (1 - _animations['content']!.value)),
            child: Opacity(
              opacity: _animations['content']!.value,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildAIConfidenceSection(),
                  const SizedBox(height: 16),
                  _buildOutfitPreviewSection(),
                  const SizedBox(height: 16),
                  _buildSwipeableSections(),
                  const SizedBox(height: 16),
                  _buildSmartInsightsSection(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildAIConfidenceSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors['pureWhite']!,
            colors['lightGray']!.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors['shadowColor']!,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _animations['match']!,
        builder:
            (context, child) => Transform.scale(
              scale: 0.98 + (0.02 * _animations['match']!.value),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors['electricBlue']!, colors['deepTeal']!],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: colors['electricBlue']!.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons
                          .verified_rounded, // Changed from auto_awesome_rounded
                      color: colors['pureWhite'],
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Confidence',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: colors['darkGray'],
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${((widget.outfitData['matchScore'] ?? 95) * _animations['match']!.value).round()}%',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: colors['vibrantPurple'],
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colors['neonGreen']!,
                                    colors['deepTeal']!,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'EXCELLENT',
                                style: GoogleFonts.poppins(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: colors['pureWhite'],
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildSwipeableSections() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      height: 380,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors['pureWhite']!,
            colors['lightGray']!.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors['shadowColor']!,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildSectionTab('Analysis', Icons.psychology_rounded, 0),
                _buildSectionTab('Tips', Icons.tips_and_updates_rounded, 1),
                _buildSectionTab('More', Icons.grid_view_rounded, 2),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentSwipeIndex = index);
                HapticFeedback.lightImpact();
              },
              children: [
                _buildAIAnalysisContent(),
                _buildStyleTipsContent(),
                _buildAlternativesContent(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) => _buildPageIndicator(index)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTab(String title, IconData icon, int index) {
    final isActive = _currentSwipeIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient:
                isActive
                    ? LinearGradient(
                      colors: [
                        colors['vibrantPurple']!,
                        colors['electricBlue']!,
                      ],
                    )
                    : null,
            color:
                isActive ? null : colors['lightGray']!.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? colors['pureWhite'] : colors['mediumGray'],
                size: 16,
              ),
              SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isActive ? colors['pureWhite'] : colors['mediumGray'],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = _currentSwipeIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        gradient:
            isActive
                ? LinearGradient(
                  colors: [colors['vibrantPurple']!, colors['electricBlue']!],
                )
                : null,
        color: isActive ? null : colors['mediumGray']!.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildAIAnalysisContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology_rounded,
                color: colors['vibrantPurple'],
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'AI Deep Analysis',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: colors['darkGray'],
                ),
              ),
              Spacer(),
              _buildLiveBadge(),
            ],
          ),
          SizedBox(height: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 1000),
            child:
                _showAIAnalysis
                    ? Column(
                      children: [
                        _buildCompactAnalysisItem(
                          'Neural Style Recognition',
                          '98% style coherence detected',
                          Icons.visibility_rounded,
                          98,
                          colors['vibrantPurple']!,
                        ),
                        SizedBox(height: 12),
                        _buildCompactAnalysisItem(
                          'Color Harmony AI',
                          'Perfect balance achieved',
                          Icons.palette_rounded,
                          95,
                          colors['sunsetOrange']!,
                        ),
                        SizedBox(height: 12),
                        _buildCompactAnalysisItem(
                          'Occasion Intelligence',
                          '${widget.occasion.toLowerCase()} suitability',
                          Icons.event_rounded,
                          97,
                          colors['neonGreen']!,
                        ),
                        SizedBox(height: 12),
                        _buildCompactAnalysisItem(
                          'Weather Optimization',
                          '${widget.weather.toLowerCase()} ready',
                          Icons.thermostat_rounded,
                          92,
                          colors['electricBlue']!,
                        ),
                      ],
                    )
                    : _buildLoadingIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleTipsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Professional Style Tips',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colors['darkGray'],
            ),
          ),
          SizedBox(height: 16),
          _buildStyleTip(
            'Color Coordination',
            'Your outfit uses complementary colors that enhance your natural features.',
            Icons.palette_rounded,
            colors['sunsetOrange']!,
          ),
          SizedBox(height: 12),
          _buildStyleTip(
            'Fit & Silhouette',
            'The proportions create a balanced and flattering silhouette.',
            Icons.straighten_rounded,
            colors['electricBlue']!,
          ),
          SizedBox(height: 12),
          _buildStyleTip(
            'Occasion Appropriateness',
            'Perfect for ${widget.occasion.toLowerCase()} events.',
            Icons.event_rounded,
            colors['neonGreen']!,
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativesContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alternative Outfits',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colors['darkGray'],
            ),
          ),
          SizedBox(height: 16),
          ..._alternatives.map((alt) => _buildAlternativeCard(alt)),
        ],
      ),
    );
  }

  Widget _buildAlternativeCard(Map<String, dynamic> alternative) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors['pureWhite'],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors['shadowColor']!,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors['primaryBlue']!, colors['electricBlue']!],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              Icons.checkroom_rounded,
              color: colors['pureWhite'],
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alternative['name'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors['darkGray'],
                  ),
                ),
                Text(
                  alternative['style'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: colors['mediumGray'],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(Icons.star_rounded, color: colors['accentYellow'], size: 16),
              SizedBox(width: 4),
              Text(
                '${alternative['rating']}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors['darkGray'],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactAnalysisItem(
    String title,
    String description,
    IconData icon,
    int percentage,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colors['pureWhite'], size: 16),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors['darkGray'],
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: colors['mediumGray'],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$percentage%',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleTip(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colors['pureWhite'], size: 16),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors['darkGray'],
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: colors['mediumGray'],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors['neonGreen']!, colors['deepTeal']!],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.live_tv_rounded, color: colors['pureWhite'], size: 12),
          SizedBox(width: 4),
          Text(
            'LIVE',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: colors['pureWhite'],
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  colors['vibrantPurple']!,
                ),
                strokeWidth: 4,
              ),
            ),
            SizedBox(height: spacing),
            Text(
              'Analyzing your style...',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: colors['mediumGray'],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartInsightsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildInsightCard(
              'Weather',
              '88%',
              'Good',
              Icons.wb_sunny_rounded,
              Colors.orange,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _buildInsightCard(
              'Occasion',
              '98%',
              'Perfect',
              Icons.event_rounded,
              Colors.green,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _buildInsightCard(
              'Style',
              '95%',
              'Trending',
              Icons.trending_up_rounded,
              colors['primaryBlue']!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
    String title,
    String percentage,
    String status,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors['pureWhite']!,
            colors['lightGray']!.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors['shadowColor']!,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          SizedBox(height: 8),
          Text(
            percentage,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            status,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: colors['darkGray'],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 8,
              color: colors['mediumGray'],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitPreviewSection() {
    final components =
        widget.outfitData['components'] as List<Map<String, dynamic>>? ??
        [
          {
            'name': 'Classic White Blazer',
            'category': 'Outerwear',
            'brand': 'Zara',
            'color': 'White',
            'price': '\$89',
          },
          {
            'name': 'Slim Fit Trousers',
            'category': 'Bottoms',
            'brand': 'H&M',
            'color': 'Navy',
            'price': '\$45',
          },
          {
            'name': 'Leather Ankle Boots',
            'category': 'Shoes',
            'brand': 'Steve Madden',
            'color': 'Black',
            'price': '\$120',
          },
          {
            'name': 'Minimalist Watch',
            'category': 'Accessories',
            'brand': 'Daniel Wellington',
            'color': 'Rose Gold',
            'price': '\$65',
          },
        ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors['pureWhite']!,
            colors['lightGray']!.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors['shadowColor']!,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors['primaryBlue']!,
                      colors['primaryBlue']!.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colors['primaryBlue']!.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons
                      .collections_rounded, // Changed from auto_awesome_rounded
                  color: colors['pureWhite'],
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete Outfit',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: colors['darkGray'],
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Tap items for details',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: colors['mediumGray'],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemCount: components.length,
            itemBuilder: (context, index) {
              if (index < components.length) {
                return _buildOutfitItemCard(components[index]);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitItemCard(Map<String, dynamic> item) {
    if (item.isEmpty) return const SizedBox.shrink();

    final categoryColor = _getCategoryColor(item['category']);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors['pureWhite']!, categoryColor.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: categoryColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withValues(alpha: 0.15),
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
          onTap: () => _showOutfitItemDetails(item),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        categoryColor,
                        categoryColor.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item['category']?.toString() ?? 'Item',
                    style: GoogleFonts.poppins(
                      fontSize: 7,
                      fontWeight: FontWeight.w800,
                      color: colors['pureWhite'],
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: Center(
                    child: Icon(
                      _getCategoryIconData(item['category']),
                      size: 28,
                      color: categoryColor.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  item['name']?.toString() ?? 'Item',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: colors['darkGray'],
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item['price'] != null) ...[
                  SizedBox(height: 2),
                  Text(
                    item['price'].toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: colors['accentRed'],
                    ),
                  ),
                ],
                SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: categoryColor.withValues(alpha: 0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        size: 8,
                        color: categoryColor.withValues(alpha: 0.8),
                      ),
                      SizedBox(width: 2),
                      Text(
                        'Tap for detail',
                        style: GoogleFonts.poppins(
                          fontSize: 7,
                          fontWeight: FontWeight.w600,
                          color: categoryColor.withValues(alpha: 0.8),
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
    );
  }

  void _showOutfitItemDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder:
                (context, scrollController) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors['pureWhite']!,
                        colors['lightGray']!.withValues(alpha: 0.95),
                        colors['skyBlue']!.withValues(alpha: 0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors['shadowColor']!,
                        blurRadius: 25,
                        offset: const Offset(0, -10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag Handle
                        Center(
                          child: Container(
                            width: 60,
                            height: 6,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colors['vibrantPurple']!.withValues(
                                    alpha: 0.6,
                                  ),
                                  colors['electricBlue']!.withValues(
                                    alpha: 0.6,
                                  ),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),

                        SizedBox(height: 24),

                        // Header with Category Badge
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _getCategoryColor(item['category']),
                                    _getCategoryColor(
                                      item['category'],
                                    ).withValues(alpha: 0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getCategoryColor(
                                      item['category'],
                                    ).withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getCategoryIconData(item['category']),
                                    color: colors['pureWhite'],
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    item['category']
                                            ?.toString()
                                            .toUpperCase() ??
                                        'ITEM',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: colors['pureWhite'],
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colors['lightGray']!.withValues(
                                    alpha: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: colors['mediumGray'],
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 24),

                        // Item Image Placeholder with AI Analysis
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _getCategoryColor(
                                  item['category'],
                                ).withValues(alpha: 0.1),
                                _getCategoryColor(
                                  item['category'],
                                ).withValues(alpha: 0.05),
                                colors['pureWhite']!,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: _getCategoryColor(
                                item['category'],
                              ).withValues(alpha: 0.2),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _getCategoryColor(
                                  item['category'],
                                ).withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Main Item Display
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: _getCategoryColor(
                                          item['category'],
                                        ).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Icon(
                                        _getCategoryIconData(item['category']),
                                        size: 64,
                                        color: _getCategoryColor(
                                          item['category'],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'AI Visual Analysis',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: colors['mediumGray'],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // AI Confidence Badge
                              Positioned(
                                top: 16,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        colors['neonGreen']!,
                                        colors['deepTeal']!,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colors['neonGreen']!.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.verified_rounded,
                                        color: colors['pureWhite'],
                                        size: 14,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '${_getItemConfidence(item['category'])}%',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          color: colors['pureWhite'],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24),

                        // Item Details
                        Text(
                          item['name']?.toString() ?? 'Item Details',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: colors['darkGray'],
                            letterSpacing: -0.5,
                          ),
                        ),

                        SizedBox(height: 8),

                        // Brand and Price Row
                        Row(
                          children: [
                            if (item['brand'] != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colors['primaryBlue']!.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colors['primaryBlue']!.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  item['brand'].toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: colors['primaryBlue'],
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                            ],
                            if (item['price'] != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      colors['accentRed']!.withValues(
                                        alpha: 0.1,
                                      ),
                                      colors['sunsetOrange']!.withValues(
                                        alpha: 0.1,
                                      ),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colors['accentRed']!.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  item['price'].toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: colors['accentRed'],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        SizedBox(height: 24),

                        // AI Analysis Section
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colors['vibrantPurple']!.withValues(
                                  alpha: 0.05,
                                ),
                                colors['electricBlue']!.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: colors['vibrantPurple']!.withValues(
                                alpha: 0.2,
                              ),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          colors['vibrantPurple']!,
                                          colors['electricBlue']!,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.psychology_rounded,
                                      color: colors['pureWhite'],
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'AI Selection Reasoning',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: colors['darkGray'],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors['neonGreen']!,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'OPTIMAL',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: colors['pureWhite'],
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 16),

                              Text(
                                _getAIReasoningText(item),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: colors['darkGray'],
                                  height: 1.6,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20),

                        // Analysis Metrics
                        _buildAnalysisMetrics(item),

                        SizedBox(height: 20),

                        // Style Compatibility
                        _buildStyleCompatibility(item),

                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  void _generateAnother() {
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colors['pureWhite']!),
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Generating new outfit...',
              style: GoogleFonts.poppins(
                color: colors['pureWhite'],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: colors['vibrantPurple'],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(spacing),
        duration: const Duration(seconds: 2),
      ),
    );

    // Simulate navigation back to generate new outfit
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  // Helper methods for AI analysis
  String _getAIReasoningText(Map<String, dynamic> item) {
    final category = item['category']?.toString().toLowerCase() ?? '';

    switch (category) {
      case 'outerwear':
        return "This ${item['name']} was selected as the perfect outer layer for ${widget.occasion.toLowerCase()} occasions. The AI analyzed the color harmony with your other pieces, ensuring a sophisticated look that complements the ${widget.weather.toLowerCase()} weather conditions. The structured silhouette adds professional polish while maintaining comfort and style versatility.";

      case 'tops':
        return "The AI chose this ${item['name']} as your foundational piece based on its exceptional versatility and color coordination. It perfectly balances formality for ${widget.occasion.toLowerCase()} settings while ensuring comfort in ${widget.weather.toLowerCase()} conditions. The fabric choice and cut create an ideal base layer that enhances your overall silhouette.";

      case 'bottoms':
        return "These ${item['name']} were selected for their perfect fit profile and occasion appropriateness. The AI considered the proportional balance with your top pieces, ensuring a flattering silhouette. The style seamlessly transitions between professional and casual settings, making them ideal for ${widget.occasion.toLowerCase()} events.";

      case 'shoes':
        return "The AI selected these ${item['name']} based on comprehensive comfort and style analysis. They provide the perfect finishing touch for ${widget.occasion.toLowerCase()} settings while ensuring all-day comfort. The design complements your outfit's color palette and adds the right level of sophistication to your overall look.";

      case 'accessories':
        return "This ${item['name']} was chosen to perfectly complete your ensemble. The AI analyzed how this piece enhances your outfit's visual balance and adds subtle elegance. It serves as the ideal accent piece that ties together your entire look while maintaining appropriateness for ${widget.occasion.toLowerCase()} occasions.";

      default:
        return "The AI selected this item through comprehensive style analysis, considering color harmony, occasion appropriateness, and overall outfit balance. Every element of your outfit works together to create a cohesive and stylish look that's perfect for your needs.";
    }
  }

  int _getItemConfidence(String? category) {
    switch (category?.toLowerCase()) {
      case 'outerwear':
        return 97;
      case 'tops':
        return 95;
      case 'bottoms':
        return 96;
      case 'shoes':
        return 94;
      case 'accessories':
        return 93;
      default:
        return 95;
    }
  }

  Map<String, Map<String, dynamic>> _getItemMetrics(Map<String, dynamic> item) {
    return {
      'Color Harmony': {
        'score': 96,
        'color': colors['vibrantPurple']!,
        'description': 'Perfect color coordination with outfit palette',
      },
      'Occasion Match': {
        'score': 98,
        'color': colors['neonGreen']!,
        'description': 'Ideal for ${widget.occasion.toLowerCase()} settings',
      },
      'Weather Suitability': {
        'score': 92,
        'color': colors['electricBlue']!,
        'description':
            'Optimized for ${widget.weather.toLowerCase()} conditions',
      },
      'Style Coherence': {
        'score': 94,
        'color': colors['sunsetOrange']!,
        'description': 'Maintains consistent style theme throughout outfit',
      },
    };
  }

  List<Map<String, dynamic>> _getStyleCompatibilities(
    Map<String, dynamic> item,
  ) {
    return [
      {
        'label': 'Professional',
        'icon': Icons.business_center_rounded,
        'color': colors['primaryBlue']!,
      },
      {
        'label': 'Versatile',
        'icon': Icons.tune_rounded,
        'color': colors['neonGreen']!,
      },
      {
        'label': 'Seasonal',
        'icon': Icons.wb_sunny_rounded,
        'color': colors['sunsetOrange']!,
      },
      {
        'label': 'Trending',
        'icon': Icons.trending_up_rounded,
        'color': colors['vibrantPurple']!,
      },
    ];
  }

  Widget _buildAnalysisMetrics(Map<String, dynamic> item) {
    final metrics = _getItemMetrics(item);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors['pureWhite'],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors['shadowColor']!,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analysis Metrics',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colors['darkGray'],
            ),
          ),
          SizedBox(height: 16),

          ...metrics.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildMetricRow(
                entry.key,
                entry.value['score'] as int,
                entry.value['color'] as Color,
                entry.value['description'] as String,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    String label,
    int score,
    Color color,
    String description,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors['darkGray'],
              ),
            ),
            Text(
              '$score%',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 6),

        Container(
          height: 6,
          decoration: BoxDecoration(
            color: colors['lightGray'],
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: score / 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),

        SizedBox(height: 4),

        Text(
          description,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: colors['mediumGray'],
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildStyleCompatibility(Map<String, dynamic> item) {
    final compatibilities = _getStyleCompatibilities(item);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors['neonGreen']!.withValues(alpha: 0.15),
            colors['deepTeal']!.withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors['neonGreen']!.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_rounded, color: colors['neonGreen'], size: 20),
              SizedBox(width: 8),
              Text(
                'Style Compatibility',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: colors['darkGray'],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                compatibilities
                    .map(
                      (compatibility) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: compatibility['color'] as Color,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: (compatibility['color'] as Color)
                                  .withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              compatibility['icon'] as IconData,
                              color: colors['pureWhite'],
                              size: 14,
                            ),
                            SizedBox(width: 6),
                            Text(
                              compatibility['label'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: colors['pureWhite'],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'outerwear':
        return colors['vibrantPurple']!;
      case 'tops':
        return colors['electricBlue']!;
      case 'bottoms':
        return colors['sunsetOrange']!;
      case 'shoes':
        return colors['neonGreen']!;
      case 'accessories':
        return colors['hotPink']!;
      case 'bags':
        return colors['deepTeal']!;
      default:
        return colors['primaryBlue']!;
    }
  }

  IconData _getCategoryIconData(String? category) {
    switch (category?.toLowerCase()) {
      case 'outerwear':
        return Icons.dry_cleaning_rounded;
      case 'tops':
        return Icons.checkroom_rounded;
      case 'bottoms':
        return Icons.local_laundry_service_rounded;
      case 'shoes':
        return Icons.sports_handball_rounded;
      case 'accessories':
        return Icons.watch_rounded;
      case 'bags':
        return Icons.shopping_bag_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
