import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/personalization_data.dart';

class Step2PhotoUpload extends StatefulWidget {
  final PersonalizationData data;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final VoidCallback onChanged;

  const Step2PhotoUpload({
    super.key,
    required this.data,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.onChanged,
  });

  @override
  State<Step2PhotoUpload> createState() => _Step2PhotoUploadState();
}

class _Step2PhotoUploadState extends State<Step2PhotoUpload>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color softGray = Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.fadeAnimation,
      child: SlideTransition(
        position: widget.slideAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 200,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Enhanced Header
                  _buildPremiumHeader(),

                  const SizedBox(height: 32),

                  // Main Photo Upload Section
                  _buildPhotoUploadSection(),

                  const SizedBox(height: 32),

                  // Upload Options (when no photo)
                  if (widget.data.uploadedPhoto == null) _buildUploadOptions(),

                  const SizedBox(height: 32),

                  // Benefits Section
                  _buildBenefitsSection(),

                  const SizedBox(height: 24),

                  // Privacy Section
                  _buildPrivacySection(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            primaryBlue.withValues(alpha: 0.03),
            accentYellow.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          // Animated camera icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryBlue, accentYellow],
                      stops: [0.3, 0.9],
                    ),
                    borderRadius: BorderRadius.circular(45),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withValues(alpha: 0.4),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Enhanced title with gradient
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [primaryBlue, accentYellow],
            ).createShader(bounds),
            child: Text(
              'Upload Your Photo',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.8,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Enhance your personalized experience with AI-powered style analysis',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: darkGray.withValues(alpha: 0.8),
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUploadSection() {
    bool hasPhoto = widget.data.uploadedPhoto != null;

    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hasPhoto
              ? [accentYellow.withValues(alpha: 0.08), Colors.white]
              : [
                  primaryBlue.withValues(alpha: 0.05),
                  accentYellow.withValues(alpha: 0.02),
                ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: hasPhoto
              ? accentYellow.withValues(alpha: 0.3)
              : primaryBlue.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (hasPhoto ? accentYellow : primaryBlue).withValues(
              alpha: 0.15,
            ),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: hasPhoto
                    ? [
                        accentYellow.withValues(alpha: 0.15),
                        accentYellow.withValues(alpha: 0.05),
                      ]
                    : [
                        primaryBlue.withValues(alpha: 0.15),
                        primaryBlue.withValues(alpha: 0.05),
                      ],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: (hasPhoto ? accentYellow : primaryBlue).withValues(
                  alpha: 0.3,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasPhoto
                      ? Icons.check_circle_rounded
                      : Icons.camera_alt_rounded,
                  color: hasPhoto ? accentYellow : primaryBlue,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  hasPhoto ? 'Photo Added' : 'Photo',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: hasPhoto ? accentYellow : primaryBlue,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Main upload area
          GestureDetector(
            onTap: () => _showPhotoOptions(context),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: hasPhoto ? Colors.transparent : Colors.white,
                borderRadius: BorderRadius.circular(110),
                border: Border.all(
                  color: hasPhoto ? accentYellow : primaryBlue,
                  width: hasPhoto ? 4 : 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (hasPhoto ? accentYellow : primaryBlue).withValues(
                      alpha: 0.3,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                image: hasPhoto
                    ? DecorationImage(
                        image: FileImage(widget.data.uploadedPhoto!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: !hasPhoto
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        // Shimmer effect
                        AnimatedBuilder(
                          animation: _shimmerAnimation,
                          builder: (context, child) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(110),
                                gradient: LinearGradient(
                                  begin: Alignment(
                                    -1.0 + _shimmerAnimation.value,
                                    0.0,
                                  ),
                                  end: Alignment(
                                    1.0 + _shimmerAnimation.value,
                                    0.0,
                                  ),
                                  colors: [
                                    Colors.transparent,
                                    primaryBlue.withValues(alpha: 0.1),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                              ),
                            );
                          },
                        ),
                        // Content
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryBlue.withValues(alpha: 0.1),
                                    accentYellow.withValues(alpha: 0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Icon(
                                Icons.add_a_photo_rounded,
                                size: 40,
                                color: primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tap to Upload',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Optional but recommended',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : null,
            ),
          ),

          if (hasPhoto) ...[
            const SizedBox(height: 32),
            // Centered and symmetrical action buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionChip(
                      'Change Photo',
                      Icons.refresh_rounded,
                      primaryBlue,
                      () => _showPhotoOptions(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionChip(
                      'Remove',
                      Icons.delete_outline_rounded,
                      accentRed,
                      () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          widget.data.uploadedPhoto = null;
                        });
                        widget.onChanged();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionChip(
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryBlue, accentYellow],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Learn About Body Shapes',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: darkGray,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Explore different body types to understand what works best for ${widget.data.selectedGender?.toLowerCase() ?? 'your'} physique',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),

        // Body Shape Information Grid
        _buildBodyShapeGrid(),
      ],
    );
  }

  Widget _buildBodyShapeGrid() {
    final bodyShapes = _getBodyShapesForGender();

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildBodyShapeCard(bodyShapes[0])),
            const SizedBox(width: 12),
            Expanded(child: _buildBodyShapeCard(bodyShapes[1])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildBodyShapeCard(bodyShapes[2])),
            const SizedBox(width: 12),
            Expanded(child: _buildBodyShapeCard(bodyShapes[3])),
          ],
        ),
        // Show fifth option for male (Trapezoid)
        if (bodyShapes.length > 4) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(flex: 1, child: const SizedBox()),
              Expanded(flex: 2, child: _buildBodyShapeCard(bodyShapes[4])),
              Expanded(flex: 1, child: const SizedBox()),
            ],
          ),
        ],

        // Info text about this being just for information
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: accentYellow.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accentYellow.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: accentYellow,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'These are just for reference. You\'ll choose your actual body shape in the next step.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: darkGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getBodyShapesForGender() {
    if (widget.data.selectedGender == 'Male') {
      return [
        {
          'name': 'Rectangle',
          'icon': Icons.crop_square,
          'description': 'Athletic build',
          'emoji': '📏',
        },
        {
          'name': 'Triangle',
          'icon': Icons.change_history,
          'description': 'Broad shoulders',
          'emoji': '🔺',
        },
        {
          'name': 'Inverted Triangle',
          'icon': Icons.change_history,
          'description': 'V-shaped',
          'emoji': '🔻',
        },
        {
          'name': 'Oval',
          'icon': Icons.circle,
          'description': 'Fuller midsection',
          'emoji': '⭕',
        },
        {
          'name': 'Trapezoid',
          'icon': Icons.hexagon_outlined,
          'description': 'Broad & strong',
          'emoji': '⬟',
        },
      ];
    } else {
      // Female body shapes
      return [
        {
          'name': 'Apple',
          'icon': Icons.circle,
          'description': 'Fuller midsection',
          'emoji': '🍎',
        },
        {
          'name': 'Pear',
          'icon': Icons.lightbulb_outline,
          'description': 'Wider hips',
          'emoji': '🍐',
        },
        {
          'name': 'Hourglass',
          'icon': Icons.hourglass_empty,
          'description': 'Balanced curves',
          'emoji': '⏳',
        },
        {
          'name': 'Rectangle',
          'icon': Icons.crop_square,
          'description': 'Straight silhouette',
          'emoji': '📏',
        },
      ];
    }
  }

  Widget _buildBodyShapeCard(Map<String, dynamic> bodyShape) {
    return GestureDetector(
      onTap: () => _showBodyShapeDetails(bodyShape['name'] as String),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              softGray.withValues(alpha: 0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji
            Text(
              bodyShape['emoji'] as String,
              style: const TextStyle(fontSize: 28),
            ),

            const SizedBox(height: 12),

            // Shape name
            Text(
              bodyShape['name'] as String,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: darkGray,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 4),

            // Description
            Text(
              bodyShape['description'] as String,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // Tap to learn more indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Tap to learn more',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBodyShapeDetails(String bodyShape) {
    final details = _getBodyShapeDetails(bodyShape);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Text(
                            details['emoji'] as String,
                            style: const TextStyle(fontSize: 40),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$bodyShape Body Shape',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: darkGray,
                                  ),
                                ),
                                Text(
                                  '${widget.data.selectedGender ?? 'Person'} Body Type',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Description
                      Text(
                        'Characteristics',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        details['description'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Style recommendations
                      Text(
                        'Style Recommendations',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 12),

                      ...(details['recommendations'] as List<String>).map((rec) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(top: 8, right: 12),
                                decoration: BoxDecoration(
                                  color: accentYellow,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  rec,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 24),

                      // Best fits
                      Text(
                        'Best Fits For You',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (details['bestFits'] as List<String>).map((fit) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: primaryBlue.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              fit,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: primaryBlue,
                              ),
                            ),
                          );
                        }).toList(),
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

  Map<String, dynamic> _getBodyShapeDetails(String bodyShape) {
    if (widget.data.selectedGender == 'Male') {
      switch (bodyShape) {
        case 'Rectangle':
          return {
            'emoji': '📏',
            'description':
                'Athletic rectangular build with balanced proportions. Shoulders, chest, and waist are relatively similar in width, creating a straight, masculine silhouette.',
            'recommendations': [
              'Fitted t-shirts and polos to show your athletic build',
              'Layered looks with jackets and cardigans',
              'Structured blazers for formal occasions',
              'Well-fitted jeans and chinos',
              'V-neck sweaters to create visual interest',
            ],
            'bestFits': [
              'Fitted Shirts',
              'Structured Blazers',
              'Layered Looks',
              'Classic Jeans',
              'Athletic Wear',
            ],
          };
        case 'Triangle':
          return {
            'emoji': '🔺',
            'description':
                'Strong, broad shoulders with a narrower waist. This classic masculine V-shape is considered the ideal male physique, perfect for showcasing upper body strength.',
            'recommendations': [
              'Fitted shirts that highlight your shoulder-to-waist ratio',
              'V-neck and crew neck tops',
              'Slim-fit or tailored pants',
              'Avoid oversized tops that hide your shape',
              'Emphasize your strong upper body',
            ],
            'bestFits': [
              'Fitted Shirts',
              'V-Necks',
              'Tailored Fit',
              'Slim Pants',
              'Athletic Cuts',
            ],
          };
        case 'Inverted Triangle':
          return {
            'emoji': '🔻',
            'description':
                'Very broad shoulders and chest with narrow hips. This powerful, athletic build is common among swimmers and bodybuilders.',
            'recommendations': [
              'Balance proportions with straight-leg or wider pants',
              'Avoid shoulder padding or emphasis',
              'Choose softer, unstructured tops',
              'Add visual weight to your lower body',
              'Horizontal stripes on the bottom half',
            ],
            'bestFits': [
              'Straight Pants',
              'Unstructured Tops',
              'Wide Leg Pants',
              'Soft Fabrics',
              'Minimal Shoulders',
            ],
          };
        case 'Oval':
          return {
            'emoji': '⭕',
            'description':
                'Fuller midsection with broader chest and waist. Focus on creating vertical lines and drawing attention to your strong arms and legs.',
            'recommendations': [
              'Vertical stripes and patterns',
              'Open cardigans and jackets',
              'Well-fitted shoulders that skim the body',
              'Dark colors for a slimming effect',
              'Quality fabrics that drape well',
            ],
            'bestFits': [
              'Vertical Lines',
              'Open Layers',
              'Dark Colors',
              'Quality Fabrics',
              'Structured Shoulders',
            ],
          };
        case 'Trapezoid':
          return {
            'emoji': '⬟',
            'description':
                'Broad shoulders with a fuller waist and strong build. This powerful physique suggests strength and masculinity.',
            'recommendations': [
              'Structured jackets that define your silhouette',
              'Straight-leg pants to balance proportions',
              'Quality fabrics in classic cuts',
              'Avoid tight-fitting clothes around the middle',
              'Emphasize your strong shoulder line',
            ],
            'bestFits': [
              'Structured Jackets',
              'Classic Cuts',
              'Straight Pants',
              'Quality Fabrics',
              'Strong Shoulders',
            ],
          };
        default:
          return {
            'emoji': '👨',
            'description': 'Every masculine body is unique and powerful.',
            'recommendations': ['Wear what makes you feel confident and strong'],
            'bestFits': ['Confidence'],
          };
      }
    } else {
      // Female body shapes
      switch (bodyShape) {
        case 'Apple':
          return {
            'emoji': '🍎',
            'description':
                'Apple body shapes typically have broader shoulders and chest, with weight carried around the midsection. The waist is less defined, and hips tend to be narrower than the upper body.',
            'recommendations': [
              'Empire waist dresses and tops to create a defined waistline',
              'V-necks and scoop necks to elongate the torso',
              'A-line skirts and dresses to balance proportions',
              'Layering with open cardigans or blazers',
              'High-waisted bottoms to create curves',
            ],
            'bestFits': [
              'Empire Waist',
              'A-Line',
              'V-Neck',
              'High-Waisted',
              'Flowing Tops',
            ],
          };
        case 'Pear':
          return {
            'emoji': '🍐',
            'description':
                'Pear body shapes have narrower shoulders and bust compared to hips and thighs. The waist is typically well-defined, and weight is primarily carried in the lower body.',
            'recommendations': [
              'Boat necks and off-shoulder tops to broaden shoulders',
              'Bright colors and patterns on top, darker on bottom',
              'Straight-leg or bootcut jeans to balance proportions',
              'Structured blazers to add volume to upper body',
              'A-line skirts that skim over hips',
            ],
            'bestFits': [
              'Boat Neck',
              'A-Line Skirts',
              'Bootcut',
              'Structured Tops',
              'Empire Waist',
            ],
          };
        case 'Hourglass':
          return {
            'emoji': '⏳',
            'description':
                'Hourglass body shapes have balanced shoulders and hips with a well-defined waist. This is considered the most proportionate body type with natural curves.',
            'recommendations': [
              'Fitted clothing that follows your natural silhouette',
              'Wrap dresses and tops to emphasize the waist',
              'High-waisted bottoms to maintain proportions',
              'Belted outfits to highlight the waistline',
              'Avoid baggy clothing that hides your shape',
            ],
            'bestFits': [
              'Wrap Style',
              'Fitted',
              'High-Waisted',
              'Belted',
              'Body-Con',
            ],
          };
        case 'Rectangle':
          return {
            'emoji': '📏',
            'description':
                'Rectangle body shapes have similar measurements for bust, waist, and hips. The goal is to create the illusion of curves and define the waistline.',
            'recommendations': [
              'Peplum tops and dresses to create hip curves',
              'Layering to add dimension and shape',
              'Belts to create a defined waistline',
              'Ruffles and textures to add volume',
              'Crop tops with high-waisted bottoms',
            ],
            'bestFits': ['Peplum', 'Layered', 'Belted', 'Textured', 'Crop Tops'],
          };
        default:
          return {
            'emoji': '👩',
            'description': 'Every feminine body is unique and beautiful.',
            'recommendations': ['Wear what makes you feel confident'],
            'bestFits': ['Confidence'],
          };
      }
    }
  }

  void _showPhotoOptions(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.camera_alt_rounded,
                      size: 48,
                      color: primaryBlue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Choose Photo Source',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: darkGray,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Camera option
                    _buildModalOption(
                      'Camera',
                      Icons.camera_alt_rounded,
                      'Take a new photo',
                      primaryBlue,
                      () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Gallery option
                    _buildModalOption(
                      'Photo Library',
                      Icons.photo_library_rounded,
                      'Choose from your photos',
                      accentYellow,
                      () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalOption(
    String title,
    IconData icon,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withValues(alpha: 0.08), Colors.white],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: darkGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        HapticFeedback.lightImpact();
        setState(() {
          widget.data.uploadedPhoto = File(image.path);
        });
        widget.onChanged();
      }
    } catch (e) {
      // Handle error gracefully with mounted check
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to access photo. Please try again.',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: accentRed,
          ),
        );
      }
    }
  }

  Widget _buildBenefitsSection() {
    final benefits = [
      {
        'icon': Icons.palette_rounded,
        'title': 'Color Analysis',
        'desc': 'AI analyzes your skin tone',
      },
      {
        'icon': Icons.face_rounded,
        'title': 'Face Shape',
        'desc': 'Detect face features',
      },
      {
        'icon': Icons.style_rounded,
        'title': 'Style Match',
        'desc': 'Perfect outfit suggestions',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: softGray.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: accentYellow, size: 24),
              const SizedBox(width: 12),
              Text(
                'Why Upload Your Photo?',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: darkGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: benefits.map((benefit) {
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(
                        benefit['icon'] as IconData,
                        color: primaryBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      benefit['title'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: darkGray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      benefit['desc'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentYellow.withValues(alpha: 0.08), Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentYellow.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.security_rounded, color: accentYellow, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Privacy is Protected',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: darkGray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Photos are processed securely and never shared',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}