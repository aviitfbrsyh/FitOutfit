import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

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
            SizedBox(height: verticalPadding),
            _buildMobileNewsList(context),
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
          '127',
          'articles published',
          Icons.article_rounded,
          const Color(0xFF6B46C1),
          '+12 this week',
        ),
        _buildNewsOverviewCard(
          context,
          'Weekly Views',
          '24.5K',
          'total views',
          Icons.visibility_rounded,
          const Color(0xFF0EA5E9),
          '+8.3% from last week',
        ),
        _buildNewsOverviewCard(
          context,
          'Engagement',
          '87%',
          'avg engagement rate',
          Icons.thumb_up_rounded,
          const Color(0xFF10B981),
          'Excellent performance',
        ),
        _buildNewsOverviewCard(
          context,
          'Trending',
          '5',
          'trending articles',
          Icons.trending_up_rounded,
          const Color(0xFFF59E0B),
          'Hot topics this week',
        ),
      ],
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

  static Widget _buildMobileNewsList(BuildContext context) {
    return Column(
      children: List.generate(3, (index) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fashion Article ${index + 1}',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Article preview content here...',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      )),
    );
  }

  static Widget _buildAddNewsForm(BuildContext context) {
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
              color: darkPurple,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Article Title',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
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
              onPressed: () => _publishNews(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Publish'),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildNewsStats(BuildContext context) {
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
            'News Performance',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: darkPurple,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow('Total Articles', '127'),
          _buildStatRow('Total Views', '156.2K'),
          _buildStatRow('Engagement Rate', '87%'),
        ],
      ),
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
