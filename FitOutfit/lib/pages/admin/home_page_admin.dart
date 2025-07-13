import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;
// ✅ PDF imports (removed unused imports)
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// Import section files
import 'sections/fashion_news_section.dart';
import 'sections/community_moderation_section.dart';
import 'sections/analytic_fb.dart';
import 'sections/user_management_section.dart';
import 'debug_firebase_page.dart';
import '../../services/admin_data_service.dart';
import 'sections/budget_personality_section.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AdminDataService _dataService = AdminDataService();

  // FitOutfit Brand Colors - Pastel Tones
  static const Color primaryLavender = Color(0xFFE8E4F3);
  static const Color softBlue = Color(0xFFE8F4FD);
  static const Color darkPurple = Color(0xFF6B46C1);
  static const Color lightPurple = Color(0xFFAD8EE6);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _updateAnalytics();
    _initializeUserTracking();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Update analytics on page load
  void _updateAnalytics() async {
    try {
      await _dataService.updateDailyAnalytics();
    } catch (e) {
      // Silent fail, analytics update is not critical for UI
    }
  }

  // ✅ Initialize user tracking on app start
  void _initializeUserTracking() async {
    try {
      await _dataService.initializeUserTracking();
    } catch (e) {
      developer.log('Failed to initialize user tracking: $e');
    }
  }

  // Responsive breakpoints
  bool get isMobile => MediaQuery.of(context).size.width < 768;
  bool get isTablet =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1024;
  bool get isDesktop => MediaQuery.of(context).size.width >= 1024;

  // Responsive values
  double get horizontalPadding => isMobile ? 16 : (isTablet ? 20 : 24);
  double get verticalPadding => isMobile ? 12 : (isTablet ? 16 : 20);
  double get cardPadding => isMobile ? 16 : (isTablet ? 20 : 24);
  double get borderRadius => isMobile ? 12 : (isTablet ? 16 : 20);
  int get gridCrossAxisCount => isMobile ? 2 : (isTablet ? 3 : 4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFBFAFF),
      appBar: _buildAppBar(),
      drawer: isMobile ? _buildMobileDrawer() : null,
      body: Row(
        children: [
          if (!isMobile) _buildSideNavigation(),
          Expanded(
            child: Container(
              margin: EdgeInsets.all(horizontalPadding),
              child: _buildMainContent(),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      leading:
          isMobile
              ? IconButton(
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                icon: const Icon(Icons.menu_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: primaryLavender,
                  foregroundColor: darkPurple,
                ),
              )
              : null,
      automaticallyImplyLeading: isMobile,
      title: _buildAppBarTitle(),
      actions: _buildAppBarActions(),
    );
  }

  Widget _buildAppBarTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 8 : 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [darkPurple, lightPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            boxShadow: [
              BoxShadow(
                color: lightPurple.withValues(alpha: 0.3),
                blurRadius: isMobile ? 8 : 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.checkroom_rounded,
            color: Colors.white,
            size: isMobile ? 20 : 28,
          ),
        ),
        if (!isMobile) ...[
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'FitOutfit Admin',
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 18 : 20,
                  fontWeight: FontWeight.w700,
                  color: darkPurple,
                ),
              ),
              Text(
                'Fashion AI Assistant Dashboard',
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 10 : 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      // Desktop/Tablet Actions
      if (!isMobile) ...[
        _buildHeaderAction(Icons.bug_report_rounded, 'Debug Firebase', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DebugFirebasePage()),
          );
        }),
        const SizedBox(width: 8),
        _buildHeaderAction(Icons.refresh_rounded, 'Refresh Data', () {
          _handleRefreshData();
        }),
        const SizedBox(width: 8),
        _buildHeaderAction(
          Icons.notifications_none_rounded,
          'Notifications',
          _showNotifications,
        ),
        const SizedBox(width: 8),
        _buildHeaderAction(Icons.download_rounded, 'Export', () {
          _exportAllDataToPDF();
        }),
        const SizedBox(width: 16),
      ],

      // Mobile Actions - All buttons visible
      if (isMobile) ...[
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DebugFirebasePage(),
              ),
            );
          },
          icon: const Icon(Icons.bug_report_rounded, size: 18),
          tooltip: 'Debug Firebase',
          style: IconButton.styleFrom(
            backgroundColor: primaryLavender,
            foregroundColor: darkPurple,
            padding: const EdgeInsets.all(6),
            minimumSize: const Size(32, 32),
          ),
        ),
        IconButton(
          onPressed: () => _handleRefreshData(),
          icon: const Icon(Icons.refresh_rounded, size: 18),
          tooltip: 'Refresh Data',
          style: IconButton.styleFrom(
            backgroundColor: primaryLavender,
            foregroundColor: darkPurple,
            padding: const EdgeInsets.all(6),
            minimumSize: const Size(32, 32),
          ),
        ),
        IconButton(
          onPressed: _showNotifications,
          icon: const Icon(Icons.notifications_none_rounded, size: 18),
          tooltip: 'Notifications',
          style: IconButton.styleFrom(
            backgroundColor: primaryLavender,
            foregroundColor: darkPurple,
            padding: const EdgeInsets.all(6),
            minimumSize: const Size(32, 32),
          ),
        ),
        IconButton(
          onPressed: () => _exportAllDataToPDF(),
          icon: const Icon(Icons.download_rounded, size: 18),
          tooltip: 'Export PDF',
          style: IconButton.styleFrom(
            backgroundColor: primaryLavender,
            foregroundColor: darkPurple,
            padding: const EdgeInsets.all(6),
            minimumSize: const Size(32, 32),
          ),
        ),
        const SizedBox(width: 4),
      ],

      // Logout Button (Always visible)
      Container(
        height: isMobile ? 36 : 42,
        margin: EdgeInsets.symmetric(vertical: isMobile ? 6 : 4),
        child: ElevatedButton.icon(
          onPressed: _logout,
          icon: Icon(Icons.logout_rounded, size: isMobile ? 16 : 18),
          label:
              isMobile
                  ? const SizedBox.shrink()
                  : Text(
                    'Logout',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFB3BA),
            foregroundColor: const Color(0xFF8B0000),
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      SizedBox(width: horizontalPadding),
    ];
  }

  void _handleRefreshData() async {
    try {
      _updateAnalytics();
      await _dataService.updateUserCount();

      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '📊 Data refreshed successfully! User count updated.',
            ),
            backgroundColor: darkPurple,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Refresh failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Widget _buildHeaderAction(
    IconData icon,
    String tooltip,
    VoidCallback onPressed,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: primaryLavender,
          foregroundColor: darkPurple,
          padding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: _buildNavigationContent(),
    );
  }

  Widget _buildSideNavigation() {
    return Container(
      width: isTablet ? 250 : 300,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: _buildNavigationContent(),
    );
  }

  Widget _buildNavigationContent() {
    final navItems = [
      {'icon': Icons.dashboard_rounded, 'title': 'Dashboard', 'index': 0},
      {
        'icon': Icons.people_outline_rounded,
        'title': 'User Management',
        'index': 1,
      },
      {'icon': Icons.newspaper_rounded, 'title': 'Fashion News', 'index': 2},
      {
        'icon': Icons.forum_rounded,
        'title': 'Community Moderation',
        'index': 3,
      },
      {
        'icon': Icons.analytics_rounded,
        'title': 'Analytics & Feedback',
        'index': 4,
      },
        {
    'icon': Icons.pie_chart_rounded,
    'title': 'Budget Personality',
    'index': 5,
  },
    ];

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 24 : 32),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [darkPurple, lightPurple],
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.checkroom_rounded,
                  color: Colors.white,
                  size: isMobile ? 24 : 32,
                ),
              ),
              SizedBox(height: isMobile ? 12 : 16),
              Text(
                'FitOutfit Admin',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: isMobile ? 16 : 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Fashion AI Assistant Management',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: isMobile ? 10 : 12,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: verticalPadding),
            child: ListView.builder(
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isSelected = _selectedIndex == item['index'];

                return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: isMobile ? 4 : 6,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: InkWell(
                      onTap: () {
                        setState(() => _selectedIndex = item['index'] as int);
                        if (isMobile) Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(borderRadius),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: verticalPadding,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? primaryLavender : Colors.transparent,
                          borderRadius: BorderRadius.circular(borderRadius),
                          border: Border.all(
                            color:
                                isSelected
                                    ? darkPurple.withValues(alpha: 0.3)
                                    : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(isMobile ? 8 : 10),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? darkPurple.withValues(alpha: 0.15)
                                        : Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  isMobile ? 8 : 12,
                                ),
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color:
                                    isSelected ? darkPurple : Colors.grey[600],
                                size: isMobile ? 18 : 22,
                              ),
                            ),
                            SizedBox(width: isMobile ? 12 : 16),
                            Expanded(
                              child: Text(
                                item['title'] as String,
                                style: GoogleFonts.poppins(
                                  color:
                                      isSelected
                                          ? darkPurple
                                          : Colors.grey[700],
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                  fontSize: isMobile ? 12 : 14,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: isMobile ? 6 : 8,
                                height: isMobile ? 6 : 8,
                                decoration: const BoxDecoration(
                                  color: darkPurple,
                                  shape: BoxShape.circle,
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
        ),
        Container(
          padding: EdgeInsets.all(horizontalPadding),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: primaryLavender,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: lightPurple.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 6 : 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
                  ),
                  child: Icon(
                    Icons.circle,
                    color: Colors.green,
                    size: isMobile ? 10 : 14,
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'System Status',
                        style: GoogleFonts.poppins(
                          fontSize: isMobile ? 10 : 12,
                          fontWeight: FontWeight.w600,
                          color: darkPurple,
                        ),
                      ),
                      Text(
                        'All systems operational',
                        style: GoogleFonts.poppins(
                          fontSize: isMobile ? 8 : 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return const EnhancedUserManagement();
      case 2:
        return FashionNewsSection.buildFashionNewsManagement(context);
      case 3:
        return CommunityModerationSection.buildCommunityModeration(context);
      case 4:
        return AnalyticsFeedbackSection.buildAnalyticsAndFeedback(context);
    case 5:
      return const BudgetPersonalitySection();
    default:
      return _buildDashboard();
  }
}

  Widget _buildDashboard() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(
            'Dashboard Overview',
            'Welcome to FitOutfit Admin - Monitor your fashion AI assistant performance\nLogged in as: aviitfbrsyh | ${DateTime.now().toString().substring(0, 19)} UTC',
            Icons.dashboard_rounded,
          ),
          SizedBox(height: verticalPadding * 1.5),
          _buildOverviewCards(),
          SizedBox(height: verticalPadding * 1.5),
          if (isMobile) ...[
            _buildTrendingStyles(),
            SizedBox(height: verticalPadding),
            _buildCommunityHighlights(),
            SizedBox(height: verticalPadding),
            _buildQuickStats(),
            SizedBox(height: verticalPadding),
            _buildChart('Weekly Activity Overview', _buildActivityChart()),
          ] else
            _buildDashboardGrid(),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: isTablet ? 6 : 7,
          child: Column(
            children: [
              _buildTrendingStyles(),
              SizedBox(height: verticalPadding),
              _buildChart('Weekly Activity Overview', _buildActivityChart()),
            ],
          ),
        ),
        SizedBox(width: verticalPadding),
        Expanded(
          flex: isTablet ? 4 : 3,
          child: Column(
            children: [
              _buildCommunityHighlights(),
              SizedBox(height: verticalPadding),
              _buildQuickStats(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPageHeader(String title, String subtitle, IconData icon) {
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
      child:
          isMobile
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

  Widget _buildOverviewCards() {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _dataService.getDashboardStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {};

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: gridCrossAxisCount,
          crossAxisSpacing: horizontalPadding,
          mainAxisSpacing: verticalPadding,
          childAspectRatio: isMobile ? 1.2 : 1.1,
          children: [
            StreamBuilder<int>(
              stream: _dataService.getTotalUsersCountRealtime(),
              builder: (context, userSnapshot) {
                final userCount = userSnapshot.data ?? 0;
                return _buildOverviewCard(
                  'Total Registered Users',
                  userCount.toString(),
                  Icons.people_rounded,
                  const Color(0xFFE8E4F3),
                  '+${stats['userGrowth']?.toStringAsFixed(1) ?? '0.0'}%',
                  const Color(0xFF6B46C1),
                );
              },
            ),

            FutureBuilder<int>(
              future: _dataService.getWeeklyOutfitsCount(),
              builder: (context, outfitSnapshot) {
                return _buildOverviewCard(
                  'Outfits Uploaded This Week',
                  outfitSnapshot.data?.toString() ?? '0',
                  Icons.checkroom_rounded,
                  const Color(0xFFE8F4FD),
                  '+${stats['outfitGrowth']?.toStringAsFixed(1) ?? '0.0'}%',
                  const Color(0xFF0EA5E9),
                );
              },
            ),

            StreamBuilder<int>(
              stream: _dataService.getCommunityPostsCount(),
              builder: (context, postSnapshot) {
                return _buildOverviewCard(
                  'Community Posts',
                  postSnapshot.data?.toString() ?? '0',
                  Icons.forum_rounded,
                  const Color(0xFFF0FDF4),
                  '+${stats['postGrowth']?.toStringAsFixed(1) ?? '0.0'}%',
                  const Color(0xFF10B981),
                );
              },
            ),

            FutureBuilder<Map<String, dynamic>>(
              future: _dataService.getFashionNewsStats(),
              builder: (context, newsSnapshot) {
                final newsData = newsSnapshot.data ?? {};
                return _buildOverviewCard(
                  'Weekly Fashion News Reads',
                  newsData['weeklyReads']?.toString() ?? '0',
                  Icons.newspaper_rounded,
                  const Color(0xFFFEF3C7),
                  '+${stats['newsGrowth']?.toStringAsFixed(1) ?? '0.0'}%',
                  const Color(0xFFF59E0B),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildOverviewCard(
    String title,
    String value,
    IconData icon,
    Color bgColor,
    String growth,
    Color iconColor,
  ) {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 10 : 14),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(isMobile ? 10 : 14),
                ),
                child: Icon(icon, color: iconColor, size: isMobile ? 20 : 26),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 6 : 10,
                  vertical: isMobile ? 3 : 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: Colors.green,
                      size: isMobile ? 10 : 14,
                    ),
                    SizedBox(width: isMobile ? 2 : 4),
                    Text(
                      growth,
                      style: GoogleFonts.poppins(
                        color: Colors.green,
                        fontSize: isMobile ? 8 : 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 18 : 26,
                  fontWeight: FontWeight.w700,
                  color: darkPurple,
                ),
              ),
              SizedBox(height: isMobile ? 3 : 6),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 9 : 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingStyles() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _dataService.getTrendingStyles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard('Trending Outfit Styles');
        }

        final trendingStyles = snapshot.data ?? [];

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trending Outfit Styles',
                          style: GoogleFonts.poppins(
                            fontSize: isMobile ? 16 : 20,
                            fontWeight: FontWeight.w600,
                            color: darkPurple,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Based on real user data',
                          style: GoogleFonts.poppins(
                            fontSize: isMobile ? 10 : 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(isMobile ? 8 : 10),
                    decoration: BoxDecoration(
                      color: primaryLavender,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.trending_up_rounded,
                      color: darkPurple,
                      size: isMobile ? 16 : 20,
                    ),
                  ),
                ],
              ),
              SizedBox(height: verticalPadding),

              if (trendingStyles.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'No style data available yet',
                      style: GoogleFonts.poppins(color: Colors.grey[500]),
                    ),
                  ),
                )
              else
                ...trendingStyles
                    .take(4)
                    .map(
                      (style) => Container(
                        margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
                        child: Row(
                          children: [
                            Container(
                              width: isMobile ? 8 : 12,
                              height: isMobile ? 8 : 12,
                              decoration: BoxDecoration(
                                color: _getStyleColor(style['style']),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: isMobile ? 8 : 12),
                            Expanded(
                              child: Text(
                                style['style'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: isMobile ? 12 : 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 8 : 12,
                                vertical: isMobile ? 2 : 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStyleColor(
                                  style['style'],
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                style['percentage'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: isMobile ? 10 : 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getStyleColor(style['style']),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingCard(String title) {
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
            title,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 16 : 20,
              fontWeight: FontWeight.w600,
              color: darkPurple,
            ),
          ),
          SizedBox(height: verticalPadding),
          const Center(
            child: CircularProgressIndicator(color: Color(0xFF6B46C1)),
          ),
        ],
      ),
    );
  }

  Color _getStyleColor(String style) {
    final colors = [
      const Color(0xFF6B46C1),
      const Color(0xFF0EA5E9),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
    ];
    return colors[style.hashCode % colors.length];
  }

  Widget _buildCommunityHighlights() {
    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Community Highlights',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: darkPurple,
            ),
          ),
          SizedBox(height: verticalPadding),
          _buildHighlightItem(
            'Featured Post',
            'Summer Collection Styling by @fashionista_maya',
            Icons.star_rounded,
            const Color(0xFFF59E0B),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildHighlightItem(
            'Reports Today',
            '3 community reports pending review',
            Icons.flag_rounded,
            const Color(0xFFEF4444),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildHighlightItem(
            'New Members',
            '47 new users joined this week',
            Icons.person_add_rounded,
            const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 6 : 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: isMobile ? 14 : 18),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 10 : 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 9 : 11,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Stats',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: darkPurple,
            ),
          ),
          SizedBox(height: verticalPadding),
          _buildStatItem(
            'Virtual Try-On Usage',
            '89%',
            const Color(0xFF6B46C1),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildStatItem('AI Recommendations', '76%', const Color(0xFF0EA5E9)),
          SizedBox(height: isMobile ? 12 : 16),
          _buildStatItem('User Satisfaction', '94%', const Color(0xFF10B981)),
          SizedBox(height: isMobile ? 12 : 16),
          _buildStatItem('Weekly Engagement', '82%', const Color(0xFFF59E0B)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 10 : 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isMobile ? 12 : 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildChart(String title, Widget chart) {
    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 14 : 18,
              fontWeight: FontWeight.w600,
              color: darkPurple,
            ),
          ),
          SizedBox(height: verticalPadding),
          SizedBox(height: isMobile ? 200 : 300, child: chart),
        ],
      ),
    );
  }

  Widget _buildActivityChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 3),
              FlSpot(1, 4),
              FlSpot(2, 3.5),
              FlSpot(3, 5),
              FlSpot(4, 4),
              FlSpot(5, 6),
              FlSpot(6, 5.5),
            ],
            isCurved: true,
            color: darkPurple,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: darkPurple.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Notifications',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.warning_rounded, color: Colors.orange),
                  title: Text('3 reports pending review'),
                  subtitle: Text('Community moderation needed'),
                ),
                ListTile(
                  leading: Icon(Icons.info_rounded, color: Colors.blue),
                  title: Text('System update available'),
                  subtitle: Text('Version 2.1.0 is ready'),
                ),
                ListTile(
                  leading: Icon(Icons.analytics_rounded, color: Colors.green),
                  title: Text('Weekly report ready'),
                  subtitle: Text('Performance analytics compiled'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _exportAllDataToPDF() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(color: darkPurple),
                const SizedBox(width: 16),
                Text('Generating PDF report...', style: GoogleFonts.poppins()),
              ],
            ),
          ),
    );

    try {
      final totalUsers = await _dataService.getTotalUsersCount().first;
      final weeklyOutfits = await _dataService.getWeeklyOutfitsCount();
      final communityPosts = await _dataService.getCommunityPostsCount().first;
      final fashionNewsStats = await _dataService.getFashionNewsStats();
      final trendingStyles = await _dataService.getTrendingStyles();
      final userStats = await _dataService.getUserStats();

      final pdf = await _generatePDFReport(
        totalUsers: totalUsers,
        weeklyOutfits: weeklyOutfits,
        communityPosts: communityPosts,
        fashionNewsStats: fashionNewsStats,
        trendingStyles: trendingStyles,
        userStats: userStats,
      );

      if (mounted) {
        Navigator.pop(context);

        // ✅ Open PDF in new tab instead of system dialog
        await Printing.sharePdf(
          bytes: await pdf.save(),
          filename:
              'FitOutfit_Admin_Report_${DateTime.now().toString().substring(0, 10)}.pdf',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('📊 PDF report opened in new tab!'),
            backgroundColor: darkPurple,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            action: SnackBarAction(
              label: 'OPEN AGAIN',
              textColor: Colors.white,
              onPressed: () async {
                await Printing.sharePdf(
                  bytes: await pdf.save(),
                  filename: 'FitOutfit_Admin_Report.pdf',
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ PDF generation failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  // ✅ FIXED: Replaced withAlpha with standard alpha value
  Future<pw.Document> _generatePDFReport({
    required int totalUsers,
    required int weeklyOutfits,
    required int communityPosts,
    required Map<String, dynamic> fashionNewsStats,
    required List<Map<String, dynamic>> trendingStyles,
    required Map<String, int> userStats,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#6B46C1'),
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'FitOutfit Admin Report',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Fashion AI Assistant Dashboard Analytics',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromInt(
                        0x33FFFFFF,
                      ), // 0x33 = 20% opacity, FFFFFF = white
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Icon(
                      pw.IconData(0xe7fd),
                      color: PdfColors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Report Info
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F3F4F6'),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Report Generated: ${now.toString().substring(0, 19)} UTC',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Admin User: aviitfbrsyh',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.Text(
                    'Report Type: Complete Dashboard Analytics',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 30),

            // Overview Statistics
            pw.Text(
              'DASHBOARD OVERVIEW',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#6B46C1'),
              ),
            ),
            pw.SizedBox(height: 15),

            pw.Table.fromTextArray(
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#6B46C1'),
              ),
              cellPadding: const pw.EdgeInsets.all(12),
              border: pw.TableBorder.all(color: PdfColor.fromHex('#E5E7EB')),
              headers: ['Metric', 'Current Value', 'Status'],
              data: [
                ['Total Registered Users', totalUsers.toString(), '📈 Active'],
                [
                  'Weekly Outfits Uploaded',
                  weeklyOutfits.toString(),
                  '📈 Growing',
                ],
                ['Community Posts', communityPosts.toString(), '💬 Engaged'],
                [
                  'Fashion News Reads',
                  fashionNewsStats['weeklyReads']?.toString() ?? '0',
                  '📰 Popular',
                ],
              ],
            ),

            pw.SizedBox(height: 30),

            // User Management Statistics
            pw.Text(
              'USER MANAGEMENT STATISTICS',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#6B46C1'),
              ),
            ),
            pw.SizedBox(height: 15),

            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#DBEAFE'),
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: PdfColor.fromHex('#3B82F6')),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          userStats['total'].toString(),
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#1D4ED8'),
                          ),
                        ),
                        pw.Text(
                          'Total Users',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#D1FAE5'),
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: PdfColor.fromHex('#10B981')),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          userStats['active'].toString(),
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#059669'),
                          ),
                        ),
                        pw.Text(
                          'Active Users',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#FEE2E2'),
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: PdfColor.fromHex('#EF4444')),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          userStats['inactive'].toString(),
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#DC2626'),
                          ),
                        ),
                        pw.Text(
                          'Inactive Users',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 30),

            // Trending Styles
            pw.Text(
              'TRENDING OUTFIT STYLES',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#6B46C1'),
              ),
            ),
            pw.SizedBox(height: 15),

            pw.Table.fromTextArray(
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#6B46C1'),
              ),
              cellPadding: const pw.EdgeInsets.all(12),
              border: pw.TableBorder.all(color: PdfColor.fromHex('#E5E7EB')),
              headers: ['Rank', 'Style Category', 'Popularity', 'Trend'],
              data:
                  trendingStyles.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final style = entry.value;
                    return [
                      '#$index',
                      style['style'] as String,
                      style['percentage'] as String,
                      index <= 2 ? '📈 Rising' : '📊 Stable',
                    ];
                  }).toList(),
            ),

            pw.SizedBox(height: 30),

            // System Performance
            pw.Text(
              'SYSTEM PERFORMANCE METRICS',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#6B46C1'),
              ),
            ),
            pw.SizedBox(height: 15),

            pw.Table.fromTextArray(
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#6B46C1'),
              ),
              cellPadding: const pw.EdgeInsets.all(12),
              border: pw.TableBorder.all(color: PdfColor.fromHex('#E5E7EB')),
              headers: ['Feature', 'Usage Rate', 'Performance', 'Status'],
              data: [
                ['Virtual Try-On', '89%', 'Excellent', '✅ Optimal'],
                ['AI Recommendations', '76%', 'Good', '✅ Stable'],
                ['User Satisfaction', '94%', 'Excellent', '✅ Outstanding'],
                ['Weekly Engagement', '82%', 'Very Good', '✅ Strong'],
              ],
            ),

            pw.SizedBox(height: 30),

            // Footer
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F9FAFB'),
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColor.fromHex('#E5E7EB')),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'DATA SOURCE & NOTES',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#6B46C1'),
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    '• Real-time data from Firebase Firestore',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                  pw.Text(
                    '• Data refreshed every 5 minutes automatically',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                  pw.Text(
                    '• FitOutfit Admin Panel v2.1.0',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                  pw.Text(
                    '• Report generated for administrative review',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'This report contains confidential information. Handle according to company data policy.',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontStyle: pw.FontStyle.italic,
                      color: PdfColor.fromHex('#6B7280'),
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Logout failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}
