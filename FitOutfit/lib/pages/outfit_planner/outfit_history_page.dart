import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'outfit_planner_page.dart';

class OutfitHistoryPage extends StatefulWidget {
  final Map<DateTime, List<OutfitEvent>>? outfitEvents;

  const OutfitHistoryPage({super.key, this.outfitEvents});

  @override
  State<OutfitHistoryPage> createState() => _OutfitHistoryPageState();
}

class _OutfitHistoryPageState extends State<OutfitHistoryPage> {
  // FitOutfit brand colors
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color softCream = Color(0xFFFAF9F7);

  List<MapEntry<DateTime, OutfitEvent>> _historyItems = [];

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  void _loadHistoryData() {
    if (widget.outfitEvents != null) {
      final now = DateTime.now();
      final historyEntries = <MapEntry<DateTime, OutfitEvent>>[];

      widget.outfitEvents!.forEach((date, events) {
        for (final event in events) {
          // Only include past events and completed events
          if (date.isBefore(now) ||
              event.status == OutfitEventStatus.completed) {
            historyEntries.add(MapEntry(date, event));
          }
        }
      });

      // Sort by date (most recent first)
      historyEntries.sort((a, b) => b.key.compareTo(a.key));

      setState(() {
        _historyItems = historyEntries;
      });
    }
  }

  Color _getStatusColor(OutfitEventStatus status) {
    switch (status) {
      case OutfitEventStatus.completed:
        return Colors.green;
      case OutfitEventStatus.emailSent:
        return primaryBlue;
      case OutfitEventStatus.planned:
        return accentYellow;
    }
  }

  String _getStatusText(OutfitEventStatus status) {
    switch (status) {
      case OutfitEventStatus.completed:
        return 'Completed';
      case OutfitEventStatus.emailSent:
        return 'Email Sent';
      case OutfitEventStatus.planned:
        return 'Planned';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getCurrentMonthName() {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final now = DateTime.now();
    return months[now.month - 1];
  }

  int _getThisMonthCount() {
    final now = DateTime.now();
    return _historyItems
        .where(
          (entry) => entry.key.year == now.year && entry.key.month == now.month,
        )
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final padding = isSmallScreen ? 16.0 : 20.0;
    
    return Scaffold(
      backgroundColor: softCream,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: Text(
          'Outfit History',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Stats
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryBlue.withValues(alpha: 0.1),
                      accentYellow.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryBlue.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Icon(
                            Icons.checkroom_rounded,
                            color: primaryBlue,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_historyItems.length}',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: primaryBlue,
                            ),
                          ),
                          Text(
                            'Total Outfits',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: mediumGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: mediumGray.withValues(alpha: 0.3),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            color: accentYellow,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getCurrentMonthName(),
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: accentYellow,
                            ),
                          ),
                          Text(
                            '${_getThisMonthCount()} this month',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: mediumGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // History List Title
              Text(
                'Recent History',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: darkGray,
                ),
              ),
              const SizedBox(height: 16),

              // History List
              Expanded(
                child:
                    _historyItems.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                          itemCount: _historyItems.length,
                          itemBuilder: (context, index) {
                            final entry = _historyItems[index];
                            return _buildHistoryCard(entry.key, entry.value);
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryBlue.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(Icons.history_rounded, color: primaryBlue, size: 48),
          ),
          const SizedBox(height: 20),
          Text(
            'No History Yet',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your outfit planning history will appear here once you start creating and completing outfit plans.',
            style: GoogleFonts.poppins(fontSize: 14, color: mediumGray),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Start Planning',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(DateTime date, OutfitEvent event) {
    final statusColor = _getStatusColor(event.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Date Circle
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: darkGray,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusText(event.status),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  event.outfitName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _formatDate(date),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: mediumGray,
                      ),
                    ),
                    if (event.notes != null) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.note_outlined, size: 12, color: mediumGray),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Arrow
          Icon(Icons.arrow_forward_ios_rounded, color: mediumGray, size: 16),
        ],
      ),
    );
  }
}
