import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'dart:math' as math;
import '../auth/login_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage>
    with TickerProviderStateMixin {
  // Colors matching FitOutfit branding
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF8B9DC3);
  static const Color lightGray = Color(0xFFF8F9FA);

  // Animation controllers
  late AnimationController _counterAnimationController;
  late AnimationController _chartAnimationController;
  late Animation<double> _counterAnimation;
  late Animation<double> _chartAnimation;

  // Real-time data simulation
  Timer? _dataUpdateTimer;
  int _selectedTimeRange = 0; // 0: Today, 1: Week, 2: Month
  int _selectedDashboardTab = 0; // 0: Overview, 1: Users, 2: AI, 3: Community

  // Live metrics data - make fields final where appropriate
  final int _totalUsers = 12847;
  int _activeUsers = 8923;
  int _newUsers = 284;
  final double _aiSuccessRate = 94.7;
  final double _avgResponseTime = 1.2;
  int _aiRequests = 18492;
  final int _communityPosts = 2341;
  int _communityLikes = 15632;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startRealTimeUpdates();
  }

  void _initializeAnimations() {
    _counterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _counterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _counterAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _chartAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _counterAnimationController.forward();
    _chartAnimationController.forward();
  }

  void _startRealTimeUpdates() {
    _dataUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          // Simulate real-time data updates
          _activeUsers += math.Random().nextInt(10) - 5;
          _newUsers += math.Random().nextInt(3);
          _communityLikes += math.Random().nextInt(20);
          _aiRequests += math.Random().nextInt(50);
        });
      }
    });
  }

  @override
  void dispose() {
    _counterAnimationController.dispose();
    _chartAnimationController.dispose();
    _dataUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return Scaffold(
      backgroundColor: lightGray,
      body: SafeArea(
        child: Column(
          children: [
            _buildModernAppBar(context),
            _buildDashboardTabs(),
            Expanded(child: _buildDashboardContent(isTablet)),
          ],
        ),
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryBlue,
            primaryBlue.withValues(alpha: 0.9),
            accentYellow.withValues(alpha: 0.1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FitOutfit Analytics',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Command Center',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildTimeRangeSelector(),
          const SizedBox(width: 16),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTimeRangeTab('Today', 0),
          _buildTimeRangeTab('Week', 1),
          _buildTimeRangeTab('Month', 2),
        ],
      ),
    );
  }

  Widget _buildTimeRangeTab(String label, int index) {
    final isSelected = _selectedTimeRange == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTimeRange = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? primaryBlue : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: accentRed.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 22),
        onPressed: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        },
        tooltip: 'Logout',
      ),
    );
  }

  Widget _buildDashboardTabs() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildDashboardTab('📊 Overview', 0),
          _buildDashboardTab('👥 Users', 1),
          _buildDashboardTab('🤖 AI Performance', 2),
          _buildDashboardTab('🌍 Community', 3),
        ],
      ),
    );
  }

  Widget _buildDashboardTab(String label, int index) {
    final isSelected = _selectedDashboardTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDashboardTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : mediumGray,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(bool isTablet) {
    switch (_selectedDashboardTab) {
      case 0:
        return _buildOverviewDashboard(isTablet);
      case 1:
        return _buildUserAnalytics(isTablet);
      case 2:
        return _buildAIPerformanceDashboard(isTablet);
      case 3:
        return _buildCommunityDashboard(isTablet);
      default:
        return _buildOverviewDashboard(isTablet);
    }
  }

  Widget _buildOverviewDashboard(bool isTablet) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Live Metrics Command Center
          _buildLiveMetricsGrid(isTablet),
          const SizedBox(height: 24),

          // User Growth Trends Chart
          _buildUserGrowthChart(),
          const SizedBox(height: 24),

          // AI Performance & Community Activity Row
          Row(
            children: [
              Expanded(child: _buildAIPerformanceCard()),
              const SizedBox(width: 16),
              Expanded(child: _buildCommunityActivityCard()),
            ],
          ),
          const SizedBox(height: 24),

          // Fashion Trends Analytics
          _buildFashionTrendsAnalytics(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLiveMetricsGrid(bool isTablet) {
    return AnimatedBuilder(
      animation: _counterAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryBlue.withValues(alpha: 0.05),
                accentYellow.withValues(alpha: 0.03),
                accentRed.withValues(alpha: 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryBlue.withValues(alpha: 0.1)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'FITOUTFIT ANALYTICS COMMAND CENTER',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: darkGray,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricSection('🔴 LIVE METRICS', [
                      _buildAnimatedMetric(
                        'Users',
                        _totalUsers,
                        '+12.5%',
                        true,
                      ),
                      _buildAnimatedMetric(
                        'New Today',
                        _newUsers,
                        '+15.3%',
                        true,
                      ),
                    ]),
                  ),
                  Expanded(
                    child: _buildMetricSection('👥 USER ACTIVITY', [
                      _buildAnimatedMetric(
                        'Active',
                        _activeUsers,
                        '+8.2%',
                        true,
                      ),
                      _buildAnimatedMetric(
                        'Posts',
                        _communityPosts,
                        '+23.1%',
                        true,
                      ),
                      _buildAnimatedMetric(
                        'Likes',
                        _communityLikes,
                        '+34.7%',
                        true,
                      ),
                    ]),
                  ),
                  Expanded(
                    child: _buildMetricSection('🤖 AI PERFORMANCE', [
                      _buildAnimatedMetric(
                        'Success Rate',
                        _aiSuccessRate,
                        '+2.3%',
                        true,
                        isPercentage: true,
                      ),
                      _buildAnimatedMetric(
                        'Avg Response',
                        _avgResponseTime,
                        '-0.1s',
                        false,
                        isTime: true,
                      ),
                      _buildAnimatedMetric(
                        'Recommendations',
                        _aiRequests,
                        '+18.9%',
                        true,
                      ),
                    ]),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricSection(String title, List<Widget> metrics) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryBlue.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: darkGray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ...metrics,
        ],
      ),
    );
  }

  Widget _buildAnimatedMetric(
    String label,
    dynamic value,
    String change,
    bool isPositive, {
    bool isPercentage = false,
    bool isTime = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Text(
            isPercentage
                ? '${(value * _counterAnimation.value).toStringAsFixed(1)}%'
                : isTime
                ? '${(value * _counterAnimation.value).toStringAsFixed(1)}s'
                : (_counterAnimation.value * value).toInt().toString(),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: primaryBlue,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? Colors.green : accentRed,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? Colors.green : accentRed,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 10, color: mediumGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserGrowthChart() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '📈 USER GROWTH TRENDS (30 Days)',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: darkGray,
                ),
              ),
              const Spacer(),
              _buildChartLegend(),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) {
                return LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: 30,
                    minY: 0,
                    maxY: 15000,
                    lineBarsData: [
                      // New Registrations
                      LineChartBarData(
                        spots: _generateUserGrowthData(0),
                        isCurved: true,
                        color: primaryBlue,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: primaryBlue.withValues(alpha: 0.1),
                        ),
                      ),
                      // Active Users
                      LineChartBarData(
                        spots: _generateUserGrowthData(1),
                        isCurved: true,
                        color: accentYellow,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                      ),
                      // Churn Rate
                      LineChartBarData(
                        spots: _generateUserGrowthData(2),
                        isCurved: true,
                        color: accentRed,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 3000,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withValues(alpha: 0.2),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 3000,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${(value / 1000).toInt()}k',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: mediumGray,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 7,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              'Day ${value.toInt()}',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: mediumGray,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend() {
    return Row(
      children: [
        _buildLegendItem(primaryBlue, 'New Registrations'),
        const SizedBox(width: 16),
        _buildLegendItem(accentYellow, 'Active Users'),
        const SizedBox(width: 16),
        _buildLegendItem(accentRed, 'Churn Rate'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: mediumGray),
        ),
      ],
    );
  }

  List<FlSpot> _generateUserGrowthData(int lineIndex) {
    List<FlSpot> spots = [];
    for (int i = 0; i <= 30; i++) {
      double value;
      switch (lineIndex) {
        case 0: // New Registrations
          value =
              8000 +
              math.sin(i * 0.2) * 2000 +
              math.Random().nextDouble() * 1000;
          break;
        case 1: // Active Users
          value =
              6000 +
              math.cos(i * 0.15) * 1500 +
              math.Random().nextDouble() * 800;
          break;
        case 2: // Churn Rate
          value =
              1000 + math.sin(i * 0.1) * 500 + math.Random().nextDouble() * 300;
          break;
        default:
          value = 0;
      }
      spots.add(FlSpot(i.toDouble(), value * _chartAnimation.value));
    }
    return spots;
  }

  Widget _buildAIPerformanceCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryBlue.withValues(alpha: 0.1),
            accentYellow.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryBlue.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '🎯 AI PERFORMANCE',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: darkGray,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Excellent',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) {
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Success Rate',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: mediumGray,
                            ),
                          ),
                          Text(
                            '${(_aiSuccessRate * _chartAnimation.value).toStringAsFixed(1)}%',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Avg Response Time',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: mediumGray,
                            ),
                          ),
                          Text(
                            '${(_avgResponseTime * _chartAnimation.value).toStringAsFixed(2)}s',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: accentYellow,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 100,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: _aiSuccessRate * _chartAnimation.value,
                                color: primaryBlue,
                                radius: 25,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value:
                                    (100 - _aiSuccessRate) *
                                    _chartAnimation.value,
                                color: Colors.grey.withValues(alpha: 0.3),
                                radius: 25,
                                showTitle: false,
                              ),
                            ],
                            centerSpaceRadius: 30,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityActivityCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentRed.withValues(alpha: 0.1),
            primaryBlue.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentRed.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🌍 COMMUNITY ACTIVITY',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) {
                return Column(
                  children: [
                    _buildCommunityMetric(
                      'Latest Posts',
                      _communityPosts,
                      Icons.post_add,
                      accentRed,
                    ),
                    const SizedBox(height: 12),
                    _buildCommunityMetric(
                      'Total Likes',
                      _communityLikes,
                      Icons.favorite,
                      Colors.pink,
                    ),
                    const SizedBox(height: 12),
                    _buildCommunityMetric(
                      'Active Users',
                      _activeUsers,
                      Icons.people,
                      primaryBlue,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityMetric(
    String label,
    int value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 11, color: mediumGray),
              ),
              Text(
                (value * _chartAnimation.value).toInt().toString(),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFashionTrendsAnalytics() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎨 FASHION TREND ANALYTICS',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Popular Styles This Month:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 12),
          _buildStyleTrendBar('Minimalist', 45.2, 5847, primaryBlue),
          _buildStyleTrendBar('Casual', 38.7, 4982, accentYellow),
          _buildStyleTrendBar('Professional', 28.3, 3641, accentRed),
          _buildStyleTrendBar('Bohemian', 21.9, 2817, Colors.purple),
          _buildStyleTrendBar('Trendy', 19.4, 2498, Colors.green),
          _buildStyleTrendBar('Classic', 15.7, 2019, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStyleTrendBar(
    String style,
    double percentage,
    int users,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: AnimatedBuilder(
        animation: _chartAnimation,
        builder: (context, child) {
          return Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      style,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: darkGray,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (percentage / 50) * _chartAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(percentage * _chartAnimation.value).toStringAsFixed(1)}% (${(users * _chartAnimation.value).toInt()} users)',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // Placeholder methods for other dashboard tabs
  Widget _buildUserAnalytics(bool isTablet) {
    return const Center(child: Text('User Analytics Dashboard - Coming Soon'));
  }

  Widget _buildAIPerformanceDashboard(bool isTablet) {
    return const Center(child: Text('AI Performance Dashboard - Coming Soon'));
  }

  Widget _buildCommunityDashboard(bool isTablet) {
    return const Center(child: Text('Community Dashboard - Coming Soon'));
  }
}
