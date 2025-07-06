import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'outfit_planner_page.dart';
import '../../models/wardrobe_item.dart';

class OutfitPreviewPage extends StatefulWidget {
  final OutfitEvent outfitEvent;
  final DateTime date;

  const OutfitPreviewPage({
    super.key,
    required this.outfitEvent,
    required this.date,
  });

  @override
  State<OutfitPreviewPage> createState() => _OutfitPreviewPageState();
}

class _OutfitPreviewPageState extends State<OutfitPreviewPage>
    with TickerProviderStateMixin {
  // FitOutfit brand colors
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color softCream = Color(0xFFFAF9F7);

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  double _getScreenWidth() => MediaQuery.of(context).size.width;
  bool _isSmallScreen() => _getScreenWidth() < 360;
  double _getHorizontalPadding() => _isSmallScreen() ? 16 : 20;
  double _getResponsiveHeight(double baseHeight) =>
      _isSmallScreen() ? baseHeight * 0.9 : baseHeight;
  double _getResponsiveFontSize(double baseSize) =>
      _isSmallScreen() ? baseSize * 0.9 : baseSize;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softCream,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(_getHorizontalPadding()),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOutfitHeader(),
                        SizedBox(height: _getResponsiveHeight(24)),
                        _buildOutfitVisualization(),
                        SizedBox(height: _getResponsiveHeight(24)),
                        _buildOutfitDetails(),
                        SizedBox(height: _getResponsiveHeight(24)),
                        _buildClothingItems(),
                        SizedBox(height: _getResponsiveHeight(24)),
                        _buildActionButtons(),
                        SizedBox(height: _getResponsiveHeight(100)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: _getResponsiveHeight(120),
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.arrow_back_ios_rounded, color: primaryBlue),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: _isFavorite ? accentRed : primaryBlue,
            ),
          ),
          onPressed: () {
            setState(() {
              _isFavorite = !_isFavorite;
            });
            HapticFeedback.lightImpact();
          },
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.share_rounded, color: primaryBlue),
          ),
          onPressed: () => _shareOutfit(),
        ),
        SizedBox(width: _getHorizontalPadding()),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryBlue.withValues(alpha: 0.9),
                accentYellow.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(_getResponsiveHeight(30)),
              bottomRight: Radius.circular(_getResponsiveHeight(30)),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(_getHorizontalPadding()),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Outfit Preview',
                    style: GoogleFonts.poppins(
                      fontSize: _getResponsiveFontSize(28),
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'How you\'ll look amazing',
                    style: GoogleFonts.poppins(
                      fontSize: _getResponsiveFontSize(14),
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: _getResponsiveHeight(10)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutfitHeader() {
    Color statusColor = _getStatusColor();

    return Container(
      padding: EdgeInsets.all(_getHorizontalPadding()),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.1),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.outfitEvent.outfitName,
                      style: GoogleFonts.poppins(
                        fontSize: _getResponsiveFontSize(22),
                        fontWeight: FontWeight.w800,
                        color: darkGray,
                      ),
                    ),
                    SizedBox(height: _getResponsiveHeight(4)),
                    Text(
                      widget.outfitEvent.title,
                      style: GoogleFonts.poppins(
                        fontSize: _getResponsiveFontSize(16),
                        color: primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(),
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(12),
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: _getResponsiveHeight(16)),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, color: mediumGray, size: 16),
              const SizedBox(width: 8),
              Text(
                '${widget.date.day}/${widget.date.month}/${widget.date.year}',
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(14),
                  color: mediumGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time_rounded, color: mediumGray, size: 16),
              const SizedBox(width: 8),
              Text(
                'All Day',
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(14),
                  color: mediumGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitVisualization() {
    return Container(
      width: double.infinity,
      height: _getResponsiveHeight(300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Placeholder for outfit visualization
          Container(
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
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.checkroom_rounded,
                    color: primaryBlue,
                    size: 64,
                  ),
                ),
                SizedBox(height: _getResponsiveHeight(16)),
                Text(
                  'Outfit Visualization',
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(18),
                    fontWeight: FontWeight.w700,
                    color: darkGray,
                  ),
                ),
                SizedBox(height: _getResponsiveHeight(8)),
                Text(
                  'AI-generated outfit preview',
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(12),
                    color: mediumGray,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: accentYellow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'PREVIEW',
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(10),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitDetails() {
    return Container(
      padding: EdgeInsets.all(_getHorizontalPadding()),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Outfit Details',
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(18),
              fontWeight: FontWeight.w700,
              color: darkGray,
            ),
          ),
          SizedBox(height: _getResponsiveHeight(16)),
          _buildDetailRow(
            'Event',
            widget.outfitEvent.title,
            Icons.event_rounded,
          ),
          SizedBox(height: _getResponsiveHeight(12)),
          _buildDetailRow(
            'Style',
            widget.outfitEvent.outfitName,
            Icons.style_rounded,
          ),
          SizedBox(height: _getResponsiveHeight(12)),
          _buildDetailRow(
            'Reminder',
            widget.outfitEvent.reminderEmail,
            Icons.email_rounded,
          ),
          if (widget.outfitEvent.notes != null &&
              widget.outfitEvent.notes!.isNotEmpty) ...[
            SizedBox(height: _getResponsiveHeight(12)),
            _buildDetailRow(
              'Notes',
              widget.outfitEvent.notes!,
              Icons.note_rounded,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryBlue, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(12),
                  fontWeight: FontWeight.w600,
                  color: mediumGray,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(14),
                  color: darkGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClothingItems() {
    final wardrobeItems = widget.outfitEvent.wardrobeItems ?? [];
    
    // Create default items if no wardrobe items are selected
    final displayItems = wardrobeItems.isNotEmpty 
        ? wardrobeItems
        : _getDefaultWardrobeItems();

    return Container(
      padding: EdgeInsets.all(_getHorizontalPadding()),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Clothing Items (${displayItems.length})',
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(18),
              fontWeight: FontWeight.w700,
              color: darkGray,
            ),
          ),
          SizedBox(height: _getResponsiveHeight(16)),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: displayItems.map((item) => _buildClothingChip(item.name)).toList(),
          ),
        ],
      ),
    );
  }

  List<WardrobeItem> _getDefaultWardrobeItems() {
    return [
      WardrobeItem(
        id: 'default_1',
        name: 'Blazer',
        category: 'Outerwear',
        color: 'Navy',
        description: 'Classic navy blazer',
        tags: [],
        userId: '',
        createdAt: DateTime.now(),
      ),
      WardrobeItem(
        id: 'default_2', 
        name: 'White Shirt',
        category: 'Tops',
        color: 'White',
        description: 'Crisp white dress shirt',
        tags: [],
        userId: '',
        createdAt: DateTime.now(),
      ),
      WardrobeItem(
        id: 'default_3',
        name: 'Dark Jeans',
        category: 'Bottoms', 
        color: 'Dark Blue',
        description: 'Dark wash denim jeans',
        tags: [],
        userId: '',
        createdAt: DateTime.now(),
      ),
      WardrobeItem(
        id: 'default_4',
        name: 'Leather Shoes',
        category: 'Shoes',
        color: 'Brown',
        description: 'Classic brown leather shoes',
        tags: [],
        userId: '',
        createdAt: DateTime.now(),
      ),
      WardrobeItem(
        id: 'default_5',
        name: 'Watch',
        category: 'Accessories',
        color: 'Silver',
        description: 'Silver wristwatch',
        tags: [],
        userId: '',
        createdAt: DateTime.now(),
      ),
    ];
  }

  Widget _buildClothingChip(String item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryBlue.withValues(alpha: 0.2)),
      ),
      child: Text(
        item,
        style: GoogleFonts.poppins(
          fontSize: _getResponsiveFontSize(12),
          fontWeight: FontWeight.w600,
          color: primaryBlue,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _tryOnOutfit(),
                icon: Icon(Icons.camera_alt_rounded),
                label: Text('Try On'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: _getResponsiveHeight(16),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(width: _getHorizontalPadding()),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _editOutfit(),
                icon: Icon(Icons.edit_rounded),
                label: Text('Edit'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryBlue,
                  side: BorderSide(color: primaryBlue),
                  padding: EdgeInsets.symmetric(
                    vertical: _getResponsiveHeight(16),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: _getResponsiveHeight(12)),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _markAsWorn(),
            icon: Icon(Icons.check_circle_rounded),
            label: Text('Mark as Worn'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: _getResponsiveHeight(16)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (widget.outfitEvent.status) {
      case OutfitEventStatus.planned:
        return accentYellow;
      case OutfitEventStatus.emailSent:
        return Colors.green;
      case OutfitEventStatus.completed:
        return primaryBlue;
    }
  }

  String _getStatusText() {
    switch (widget.outfitEvent.status) {
      case OutfitEventStatus.planned:
        return 'Planned';
      case OutfitEventStatus.emailSent:
        return 'Reminder Sent';
      case OutfitEventStatus.completed:
        return 'Completed';
    }
  }

  void _shareOutfit() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Outfit shared successfully!',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _tryOnOutfit() {
    // Navigate to virtual try-on
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Opening Virtual Try-On...',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: accentYellow,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _editOutfit() {
    Navigator.pop(context);
  }

  void _markAsWorn() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Outfit marked as worn!', style: GoogleFonts.poppins()),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.pop(context);
  }
}
