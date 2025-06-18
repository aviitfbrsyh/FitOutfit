import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class CommunityModerationSection {
  // FitOutfit Brand Colors
  static const Color primaryLavender = Color(0xFFE8E4F3);
  static const Color softBlue = Color(0xFFE8F4FD);
  static const Color darkPurple = Color(0xFF6B46C1);
  static const Color lightPurple = Color(0xFFAD8EE6);

  static Widget buildCommunityModeration(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final verticalPadding = isMobile ? 12.0 : (MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1024 ? 16.0 : 20.0);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(
            context,
            'Community Moderation', 
            'Monitor and manage user interactions and community content',
            Icons.forum_rounded,
          ),
          SizedBox(height: verticalPadding * 1.5),
          _buildModerationOverviewCards(context),
          SizedBox(height: verticalPadding),
          if (isMobile) ...[
            _buildRecentReports(context),
            SizedBox(height: verticalPadding),
            _buildQuickActions(context),
            SizedBox(height: verticalPadding),
            _buildCommunityStats(context),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildRecentReports(context),
                      SizedBox(height: verticalPadding),
                      _buildActivityChart(context),
                    ],
                  ),
                ),
                SizedBox(width: verticalPadding),
                Expanded(
                  child: Column(
                    children: [
                      _buildQuickActions(context),
                      SizedBox(height: verticalPadding),
                      _buildCommunityStats(context),
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

  static Widget _buildModerationOverviewCards(BuildContext context) {
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
        _buildModerationCard(
          context,
          'Pending Reports',
          '12',
          'reports awaiting review',
          Icons.flag_rounded,
          const Color(0xFFEF4444),
          'Urgent attention needed',
        ),
        _buildModerationCard(
          context,
          'Active Users',
          '2,847',
          'users online today',
          Icons.people_rounded,
          const Color(0xFF10B981),
          '+5.2% from yesterday',
        ),
        _buildModerationCard(
          context,
          'Community Posts',
          '428',
          'posts today',
          Icons.forum_rounded,
          const Color(0xFF0EA5E9),
          '+12 posts this hour',
        ),
        _buildModerationCard(
          context,
          'Content Removed',
          '8',
          'violations this week',
          Icons.remove_circle_rounded,
          const Color(0xFFF59E0B),
          '-3 from last week',
        ),
      ],
    );
  }

  static Widget _buildModerationCard(BuildContext context, String title, String value, String subtitle, IconData icon, Color color, String trend) {
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

  static Widget _buildRecentReports(BuildContext context) {
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
                'Recent Reports',
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
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '12 Pending',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          ...List.generate(5, (index) => _buildReportItem(context, index)),
        ],
      ),
    );
  }

  static Widget _buildReportItem(BuildContext context, int index) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    final reports = [
      {
        'user': '@fashionista_maya',
        'type': 'Inappropriate Content',
        'content': 'Posted revealing outfit photo',
        'time': '2 hours ago',
        'severity': 'High',
        'status': 'Pending',
      },
      {
        'user': '@style_guru_alex',
        'type': 'Spam',
        'content': 'Excessive promotional posts',
        'time': '4 hours ago',
        'severity': 'Medium',
        'status': 'Under Review',
      },
      {
        'user': '@trendy_sarah',
        'type': 'Harassment',
        'content': 'Bullying other users in comments',
        'time': '6 hours ago',
        'severity': 'High',
        'status': 'Pending',
      },
      {
        'user': '@casual_david',
        'type': 'Copyright',
        'content': 'Using copyrighted fashion images',
        'time': '8 hours ago',
        'severity': 'Medium',
        'status': 'Resolved',
      },
      {
        'user': '@elegant_emma',
        'type': 'Fake Profile',
        'content': 'Impersonating fashion influencer',
        'time': '1 day ago',
        'severity': 'High',
        'status': 'Pending',
      },
    ];

    final report = reports[index];
    
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
                backgroundColor: _getSeverityColor(report['severity']!).withValues(alpha: 0.1),
                child: Icon(
                  Icons.person_rounded,
                  color: _getSeverityColor(report['severity']!),
                  size: isMobile ? 16 : 20,
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
                          report['user']!,
                          style: GoogleFonts.poppins(
                            fontSize: isMobile ? 12 : 14,
                            fontWeight: FontWeight.w600,
                            color: darkPurple,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getReportTypeColor(report['type']!).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            report['type']!,
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 8 : 10,
                              fontWeight: FontWeight.w600,
                              color: _getReportTypeColor(report['type']!),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      report['content']!,
                      style: GoogleFonts.poppins(
                        fontSize: isMobile ? 10 : 12,
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
          SizedBox(height: isMobile ? 8 : 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getSeverityColor(report['severity']!).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${report['severity']} Priority',
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 8 : 10,
                    fontWeight: FontWeight.w600,
                    color: _getSeverityColor(report['severity']!),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                report['time']!,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 8 : 10,
                  color: Colors.grey[500],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _reviewReport(context, report),
                    icon: Icon(Icons.visibility_rounded, size: isMobile ? 16 : 18),
                    style: IconButton.styleFrom(
                      backgroundColor: softBlue,
                      foregroundColor: const Color(0xFF0EA5E9),
                      minimumSize: Size(isMobile ? 28 : 32, isMobile ? 28 : 32),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () => _takeAction(context, report),
                    icon: Icon(Icons.gavel_rounded, size: isMobile ? 16 : 18),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFFEF3C7),
                      foregroundColor: const Color(0xFFF59E0B),
                      minimumSize: Size(isMobile ? 28 : 32, isMobile ? 28 : 32),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildQuickActions(BuildContext context) {
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
            'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: darkPurple,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildActionButton(
            context,
            'Ban User',
            'Permanently ban a user account',
            Icons.block_rounded,
            const Color(0xFFEF4444),
            () => _showBanUserDialog(context),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildActionButton(
            context,
            'Remove Content',
            'Delete inappropriate posts or comments',
            Icons.delete_rounded,
            const Color(0xFFF59E0B),
            () => _showRemoveContentDialog(context),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildActionButton(
            context,
            'Send Warning',
            'Issue warning to community members',
            Icons.warning_rounded,
            const Color(0xFF6B46C1),
            () => _showWarningDialog(context),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildActionButton(
            context,
            'Community Guidelines',
            'Update and manage community rules',
            Icons.rule_rounded,
            const Color(0xFF0EA5E9),
            () => _showGuidelinesDialog(context),
          ),
        ],
      ),
    );
  }

  static Widget _buildActionButton(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onPressed) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 8 : 10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: isMobile ? 16 : 20),
            ),
            SizedBox(width: isMobile ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 10 : 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color,
              size: isMobile ? 14 : 16,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildCommunityStats(BuildContext context) {
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
            'Community Health',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: darkPurple,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildStatItem('Report Resolution Rate', '94%', const Color(0xFF10B981)),
          SizedBox(height: isMobile ? 12 : 16),
          _buildStatItem('Average Response Time', '2.3h', const Color(0xFF0EA5E9)),
          SizedBox(height: isMobile ? 12 : 16),
          _buildStatItem('Community Satisfaction', '87%', const Color(0xFFF59E0B)),
          SizedBox(height: isMobile ? 12 : 16),
          _buildStatItem('Active Moderators', '6', const Color(0xFF6B46C1)),
          SizedBox(height: isMobile ? 16 : 20),
          
          // Violation Types Breakdown
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryLavender.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Violation Types This Week',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 8),
                _buildViolationItem('Spam', '45%', const Color(0xFFEF4444)),
                _buildViolationItem('Inappropriate Content', '30%', const Color(0xFFF59E0B)),
                _buildViolationItem('Harassment', '15%', const Color(0xFF6B46C1)),
                _buildViolationItem('Copyright', '10%', const Color(0xFF0EA5E9)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildStatItem(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  static Widget _buildViolationItem(String type, String percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              type,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            percentage,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildActivityChart(BuildContext context) {
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
            'Moderation Activity',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 14 : 18,
              fontWeight: FontWeight.w600,
              color: darkPurple,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          SizedBox(
            height: isMobile ? 150 : 200,
            child: _buildModerationChart(),
          ),
        ],
      ),
    );
  }

  static Widget _buildModerationChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 20,
        barTouchData: BarTouchData(enabled: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: const Color(0xFFEF4444))]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 12, color: const Color(0xFFF59E0B))]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 6, color: const Color(0xFF10B981))]),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 15, color: const Color(0xFF6B46C1))]),
          BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 9, color: const Color(0xFF0EA5E9))]),
          BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 11, color: const Color(0xFFEF4444))]),
          BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 7, color: const Color(0xFF10B981))]),
        ],
        gridData: const FlGridData(show: false),
      ),
    );
  }

  // Helper Methods
  static Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'High':
        return const Color(0xFFEF4444);
      case 'Medium':
        return const Color(0xFFF59E0B);
      case 'Low':
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  static Color _getReportTypeColor(String type) {
    switch (type) {
      case 'Inappropriate Content':
        return const Color(0xFFEF4444);
      case 'Spam':
        return const Color(0xFFF59E0B);
      case 'Harassment':
        return const Color(0xFF6B46C1);
      case 'Copyright':
        return const Color(0xFF0EA5E9);
      case 'Fake Profile':
        return const Color(0xFFEC4899);
      default:
        return Colors.grey;
    }
  }

  static void _reviewReport(BuildContext context, Map<String, String> report) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.visibility_rounded, color: darkPurple, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Review Report',
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
              Text(
                'Report Details:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: darkPurple,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'User: ${report['user']}\nType: ${report['type']}\nContent: ${report['content']}\nTime: ${report['time']}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Report reviewed: ${report['user']}'),
                            backgroundColor: darkPurple,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Mark as Reviewed'),
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

  static void _takeAction(BuildContext context, Map<String, String> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Take Action',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('What action would you like to take for ${report['user']}?'),
            const SizedBox(height: 16),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showWarningDialog(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
                    child: const Text('Send Warning'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showBanUserDialog(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                    child: const Text('Ban User'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  static void _showBanUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Ban User',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Username or Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Reason for Ban',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User has been banned successfully'),
                  backgroundColor: Color(0xFFEF4444),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Ban User'),
          ),
        ],
      ),
    );
  }

  static void _showRemoveContentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Remove Content',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Content ID or URL',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Reason for Removal',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Content has been removed successfully'),
                  backgroundColor: Color(0xFFF59E0B),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
            child: const Text('Remove Content'),
          ),
        ],
      ),
    );
  }

  static void _showWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Send Warning',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Username or Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Warning Message',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Warning sent successfully'),
                  backgroundColor: darkPurple,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: darkPurple),
            child: const Text('Send Warning'),
          ),
        ],
      ),
    );
  }

  static void _showGuidelinesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Community Guidelines',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('1. Be respectful to all community members'),
              SizedBox(height: 8),
              Text('2. No inappropriate or revealing content'),
              SizedBox(height: 8),
              Text('3. No spam or excessive promotional posts'),
              SizedBox(height: 8),
              Text('4. Respect copyright and intellectual property'),
              SizedBox(height: 8),
              Text('5. No harassment or bullying'),
              SizedBox(height: 16),
              Text('Guidelines can be updated through the admin panel.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Guidelines updated successfully'),
                  backgroundColor: darkPurple,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: darkPurple),
            child: const Text('Update Guidelines'),
          ),
        ],
      ),
    );
  }
}
