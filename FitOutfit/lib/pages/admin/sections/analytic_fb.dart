import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsFeedbackSection {
  // FitOutfit Brand Colors
  static const Color primaryLavender = Color(0xFFE8E4F3);
  static const Color softBlue = Color(0xFFE8F4FD);
  static const Color darkPurple = Color(0xFF6B46C1);
  static const Color lightPurple = Color(0xFFAD8EE6);

  static Widget buildAnalyticsAndFeedback(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final verticalPadding =
        isMobile
            ? 12.0
            : (MediaQuery.of(context).size.width >= 768 &&
                    MediaQuery.of(context).size.width < 1024
                ? 16.0
                : 20.0);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(
            context,
            'Analytics & Feedback',
            'Monitor app performance and user feedback insights',
            Icons.analytics_rounded,
          ),
          SizedBox(height: verticalPadding * 1.5),
          _buildAnalyticsOverviewCards(context),
          SizedBox(height: verticalPadding),
          if (isMobile) ...[
            _buildPerformanceChart(context),
            SizedBox(height: verticalPadding),
            _buildUserFeedbackSection(context),
            SizedBox(height: verticalPadding),
            _buildAIInsights(context),
            SizedBox(height: verticalPadding),
            _buildTopFeatures(context),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildPerformanceChart(context),
                      SizedBox(height: verticalPadding),
                      _buildUserEngagementChart(context),
                    ],
                  ),
                ),
                SizedBox(width: verticalPadding),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildUserFeedbackSection(context),
                      SizedBox(height: verticalPadding),
                      _buildAIInsights(context),
                      SizedBox(height: verticalPadding),
                      _buildTopFeatures(context),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  static Widget _buildPageHeader(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final isTablet =
        MediaQuery.of(context).size.width >= 768 &&
        MediaQuery.of(context).size.width < 1024;
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

  static Widget _buildAnalyticsOverviewCards(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final horizontalPadding =
        isMobile
            ? 16.0
            : (MediaQuery.of(context).size.width >= 768 &&
                    MediaQuery.of(context).size.width < 1024
                ? 20.0
                : 24.0);
    final verticalPadding =
        isMobile
            ? 12.0
            : (MediaQuery.of(context).size.width >= 768 &&
                    MediaQuery.of(context).size.width < 1024
                ? 16.0
                : 20.0);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isMobile ? 2 : 4,
      crossAxisSpacing: horizontalPadding,
      mainAxisSpacing: verticalPadding,
      childAspectRatio: isMobile ? 1.2 : 1.3,
      children: [
        _buildAnalyticsCard(
          context,
          'Monthly Active Users',
          '24.8K',
          '+18.7% from last month',
          Icons.people_rounded,
          const Color(0xFF6B46C1),
          '↗️ Growing',
        ),
        _buildAnalyticsCard(
          context,
          'AI Recommendations',
          '156.2K',
          'total generated',
          Icons.psychology_rounded,
          const Color(0xFF0EA5E9),
          '94% accuracy',
        ),
        _buildAnalyticsCard(
          context,
          'User Satisfaction',
          '4.8/5',
          'average rating',
          Icons.star_rounded,
          const Color(0xFF10B981),
          '+0.3 this month',
        ),
        _buildAnalyticsCard(
          context,
          'Session Duration',
          '12.4min',
          'average time',
          Icons.schedule_rounded,
          const Color(0xFFF59E0B),
          '+2.1min increase',
        ),
      ],
    );
  }

  static Widget _buildAnalyticsCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    String trend,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final cardPadding =
        isMobile
            ? 16.0
            : (MediaQuery.of(context).size.width >= 768 &&
                    MediaQuery.of(context).size.width < 1024
                ? 20.0
                : 24.0);
    final borderRadius =
        isMobile
            ? 12.0
            : (MediaQuery.of(context).size.width >= 768 &&
                    MediaQuery.of(context).size.width < 1024
                ? 16.0
                : 20.0);

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
              fontSize: isMobile ? 18 : 22,
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

  static Widget _buildPerformanceChart(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final cardPadding =
        isMobile
            ? 16.0
            : (MediaQuery.of(context).size.width >= 768 &&
                    MediaQuery.of(context).size.width < 1024
                ? 20.0
                : 24.0);
    final borderRadius =
        isMobile
            ? 12.0
            : (MediaQuery.of(context).size.width >= 768 &&
                    MediaQuery.of(context).size.width < 1024
                ? 16.0
                : 20.0);
    final verticalPadding =
        isMobile
            ? 12.0
            : (MediaQuery.of(context).size.width >= 768 &&
                    MediaQuery.of(context).size.width < 1024
                ? 16.0
                : 20.0);

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
            children: [
              Text(
                'Performance Analytics',
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 16 : 20,
                  fontWeight: FontWeight.w600,
                  color: darkPurple,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: const Color(0xFF10B981),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Healthy',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: verticalPadding),
          SizedBox(
            height: isMobile ? 200 : 300,
            child: _buildPerformanceLineChart(),
          ),
          SizedBox(height: verticalPadding),
          Row(
            children: [
              Expanded(
                child: _buildPerformanceMetric(
                  'App Crashes',
                  '0.02%',
                  const Color(0xFF10B981),
                ),
              ),
              Expanded(
                child: _buildPerformanceMetric(
                  'Load Time',
                  '1.8s',
                  const Color(0xFF0EA5E9),
                ),
              ),
              Expanded(
                child: _buildPerformanceMetric(
                  'Success Rate',
                  '99.7%',
                  const Color(0xFF6B46C1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildPerformanceLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey[200]!, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                );
                Widget text;
                switch (value.toInt()) {
                  case 1:
                    text = const Text('Jan', style: style);
                    break;
                  case 2:
                    text = const Text('Feb', style: style);
                    break;
                  case 3:
                    text = const Text('Mar', style: style);
                    break;
                  case 4:
                    text = const Text('Apr', style: style);
                    break;
                  case 5:
                    text = const Text('May', style: style);
                    break;
                  case 6:
                    text = const Text('Jun', style: style);
                    break;
                  default:
                    text = const Text('', style: style);
                    break;
                }
                return text;
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                );
                return Text('${value.toInt()}K', style: style);
              },
              reservedSize: 32,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[200]!),
        ),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 6,
        lineBarsData: [
          // Active Users Line
          LineChartBarData(
            spots: const [
              FlSpot(0, 2),
              FlSpot(1, 2.8),
              FlSpot(2, 3.2),
              FlSpot(3, 4.1),
              FlSpot(4, 4.6),
              FlSpot(5, 5.2),
              FlSpot(6, 5.8),
            ],
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6B46C1).withValues(alpha: 0.8),
                const Color(0xFF6B46C1).withValues(alpha: 0.3),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF6B46C1).withValues(alpha: 0.1),
                  const Color(0xFF6B46C1).withValues(alpha: 0.05),
                ],
              ),
            ),
          ),
          // AI Usage Line
          LineChartBarData(
            spots: const [
              FlSpot(0, 1.5),
              FlSpot(1, 2.2),
              FlSpot(2, 2.7),
              FlSpot(3, 3.5),
              FlSpot(4, 4.2),
              FlSpot(5, 4.8),
              FlSpot(6, 5.3),
            ],
            isCurved: true,
            color: const Color(0xFF0EA5E9),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  static Widget _buildPerformanceMetric(
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  static Widget _buildUserEngagementChart(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final cardPadding =
        isMobile
            ? 16.0
            : (MediaQuery.of(context).size.width >= 768 &&
                    MediaQuery.of(context).size.width < 1024
                ? 20.0
                : 24.0);
    final borderRadius =
        isMobile
            ? 12.0
            : (MediaQuery.of(context).size.width >= 768 &&
                    MediaQuery.of(context).size.width < 1024
                ? 16.0
                : 20.0);
    final verticalPadding =
        isMobile
            ? 12.0
            : (MediaQuery.of(context).size.width >= 768 &&
                    MediaQuery.of(context).size.width < 1024
                ? 16.0
                : 20.0);

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
            'User Engagement Breakdown',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: darkPurple,
            ),
          ),
          SizedBox(height: verticalPadding),
          SizedBox(
            height: isMobile ? 200 : 250,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(enabled: false),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: const Color(0xFF6B46C1),
                          value: 35,
                          title: '35%',
                          radius: 60,
                          titleStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: const Color(0xFF0EA5E9),
                          value: 25,
                          title: '25%',
                          radius: 60,
                          titleStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: const Color(0xFF10B981),
                          value: 20,
                          title: '20%',
                          radius: 60,
                          titleStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: const Color(0xFFF59E0B),
                          value: 20,
                          title: '20%',
                          radius: 60,
                          titleStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildEngagementLegend(
                        'AI Styling',
                        '35%',
                        const Color(0xFF6B46C1),
                      ),
                      const SizedBox(height: 12),
                      _buildEngagementLegend(
                        'Virtual Try-On',
                        '25%',
                        const Color(0xFF0EA5E9),
                      ),
                      const SizedBox(height: 12),
                      _buildEngagementLegend(
                        'Community',
                        '20%',
                        const Color(0xFF10B981),
                      ),
                      const SizedBox(height: 12),
                      _buildEngagementLegend(
                        'Fashion News',
                        '20%',
                        const Color(0xFFF59E0B),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildEngagementLegend(
    String label,
    String percentage,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
          ),
        ),
        Text(
          percentage,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  static Widget _buildUserFeedbackSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final cardPadding =
        isMobile
            ? 16.0
            : (MediaQuery.of(context).size.width >= 768 &&
                    MediaQuery.of(context).size.width < 1024
                ? 20.0
                : 24.0);
    final borderRadius =
        isMobile
            ? 12.0
            : (MediaQuery.of(context).size.width >= 768 &&
                    MediaQuery.of(context).size.width < 1024
                ? 16.0
                : 20.0);

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
            children: [
              Text(
                'Recent Feedback',
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: darkPurple,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: const Color(0xFF10B981),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '4.8',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          ...List.generate(4, (index) => _buildFeedbackItem(context, index)),
          SizedBox(height: isMobile ? 12 : 16),
          Center(
            child: TextButton(
              onPressed: () => _showAllFeedback(context),
              child: Text(
                'View All Feedback',
                style: GoogleFonts.poppins(
                  color: darkPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildFeedbackItem(BuildContext context, int index) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    final feedbacks = [
      {
        'user': 'Maya Johnson',
        'rating': '5',
        'comment': 'Amazing AI recommendations! Found my perfect style.',
        'time': '2 hours ago',
        'feature': 'AI Styling',
      },
      {
        'user': 'Alex Chen',
        'rating': '4',
        'comment': 'Virtual try-on is fantastic, very realistic results.',
        'time': '5 hours ago',
        'feature': 'Virtual Try-On',
      },
      {
        'user': 'Sarah Williams',
        'rating': '5',
        'comment': 'Love the community features and outfit sharing!',
        'time': '1 day ago',
        'feature': 'Community',
      },
      {
        'user': 'David Brown',
        'rating': '4',
        'comment': 'App is great but could use more color options.',
        'time': '2 days ago',
        'feature': 'UI/UX',
      },
    ];

    final feedback = feedbacks[index];

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: isMobile ? 16 : 20,
                backgroundColor: darkPurple.withValues(alpha: 0.1),
                child: Text(
                  feedback['user']![0],
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: darkPurple,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          feedback['user']!,
                          style: GoogleFonts.poppins(
                            fontSize: isMobile ? 12 : 14,
                            fontWeight: FontWeight.w600,
                            color: darkPurple,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ...List.generate(
                          int.parse(feedback['rating']!),
                          (index) => Icon(
                            Icons.star_rounded,
                            color: const Color(0xFFF59E0B),
                            size: isMobile ? 12 : 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getFeatureColor(
                              feedback['feature']!,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            feedback['feature']!,
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 8 : 10,
                              fontWeight: FontWeight.w600,
                              color: _getFeatureColor(feedback['feature']!),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          feedback['time']!,
                          style: GoogleFonts.poppins(
                            fontSize: isMobile ? 8 : 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            feedback['comment']!,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 11 : 13,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildAIInsights(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final cardPadding =
        isMobile
            ? 16.0
            : (MediaQuery.of(context).size.width >= 768 &&
                    MediaQuery.of(context).size.width < 1024
                ? 20.0
                : 24.0);
    final borderRadius =
        isMobile
            ? 12.0
            : (MediaQuery.of(context).size.width >= 768 &&
                    MediaQuery.of(context).size.width < 1024
                ? 16.0
                : 20.0);

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
            children: [
              Icon(Icons.psychology_rounded, color: darkPurple, size: 20),
              const SizedBox(width: 8),
              Text(
                'AI Insights',
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: darkPurple,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildInsightItem(
            '🎯 Recommendation Accuracy',
            '94.2% of users accept AI outfit suggestions',
            const Color(0xFF10B981),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildInsightItem(
            '📈 Usage Growth',
            'Virtual try-on feature usage increased by 67%',
            const Color(0xFF0EA5E9),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildInsightItem(
            '👗 Popular Styles',
            'Minimalist and casual styles are trending',
            const Color(0xFF6B46C1),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildInsightItem(
            '⏰ Peak Hours',
            'Most active between 7-9 PM weekdays',
            const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  static Widget _buildInsightItem(
    String title,
    String description,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey[700],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildTopFeatures(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final cardPadding =
        isMobile
            ? 16.0
            : (MediaQuery.of(context).size.width >= 768 &&
                    MediaQuery.of(context).size.width < 1024
                ? 20.0
                : 24.0);
    final borderRadius =
        isMobile
            ? 12.0
            : (MediaQuery.of(context).size.width >= 768 &&
                    MediaQuery.of(context).size.width < 1024
                ? 16.0
                : 20.0);

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
            'Top Features',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: darkPurple,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildFeatureItem(
            'AI Style Recommendations',
            '94%',
            const Color(0xFF6B46C1),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildFeatureItem('Virtual Try-On', '87%', const Color(0xFF0EA5E9)),
          SizedBox(height: isMobile ? 12 : 16),
          _buildFeatureItem('Color Matching', '82%', const Color(0xFF10B981)),
          SizedBox(height: isMobile ? 12 : 16),
          _buildFeatureItem(
            'Body Type Analysis',
            '78%',
            const Color(0xFFF59E0B),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildFeatureItem(
            'Community Sharing',
            '73%',
            const Color(0xFFEC4899),
          ),
        ],
      ),
    );
  }

  static Widget _buildFeatureItem(
    String feature,
    String satisfaction,
    Color color,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor:
                      double.parse(satisfaction.replaceAll('%', '')) / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          satisfaction,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  // Helper Methods
  static Color _getFeatureColor(String feature) {
    switch (feature) {
      case 'AI Styling':
        return const Color(0xFF6B46C1);
      case 'Virtual Try-On':
        return const Color(0xFF0EA5E9);
      case 'Community':
        return const Color(0xFF10B981);
      case 'UI/UX':
        return const Color(0xFFF59E0B);
      default:
        return Colors.grey;
    }
  }

  static void _showAllFeedback(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.feedback_rounded, color: darkPurple, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'All User Feedback',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: darkPurple,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 10,
                      itemBuilder:
                          (context, index) =>
                              _buildFeedbackItem(context, index % 4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Feedback exported successfully! 📊',
                                ),
                                backgroundColor: darkPurple,
                              ),
                            );
                          },
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: const Text('Export Report'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
