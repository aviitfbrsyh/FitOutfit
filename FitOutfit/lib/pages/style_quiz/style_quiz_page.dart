import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../home/home_page.dart';

class StyleQuizPage extends StatefulWidget {
  const StyleQuizPage({super.key});

  @override
  State<StyleQuizPage> createState() => _StyleQuizPageState();
}

class _StyleQuizPageState extends State<StyleQuizPage>
    with TickerProviderStateMixin {
  // FitOutfit Brand Colors - Mobile Optimized
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color accentPurple = Color(0xFF7B68EE);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color softCream = Color(0xFFFAF9F7);
  static const Color deepBlue = Color(0xFF1A2B4A);
  static const Color lightBlue = Color(0xFFE6F0FF);
  static const Color shadowColor = Color(0x1A000000);

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _progressController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _breathingAnimation;

  // State Variables
  int _currentQuestion = 0;
  final Map<int, String> _answers = {};
  bool _isLoading = false;
  bool _showResult = false;
  String? _styleResult;
  String? _styleDescription;
  List<String> _personalizedTips = [];

  // Enhanced Questions - Mobile Optimized
  final List<Map<String, dynamic>> _questions = [
    {
      'id': 1,
      'category': 'Style',
      'question': 'What aesthetic defines you?',
      'subtitle': 'Your style personality',
      'icon': Icons.palette_outlined,
      'options': [
        {
          'text': 'Minimalist',
          'subtitle': 'Clean & Simple',
          'value': 'minimalist',
          'icon': Icons.architecture_outlined,
          'color': primaryBlue,
        },
        {
          'text': 'Bohemian',
          'subtitle': 'Free & Artistic',
          'value': 'bohemian',
          'icon': Icons.nature_people_outlined,
          'color': accentYellow,
        },
        {
          'text': 'Classic',
          'subtitle': 'Timeless & Elegant',
          'value': 'classic',
          'icon': Icons.diamond_outlined,
          'color': deepBlue,
        },
        {
          'text': 'Trendy',
          'subtitle': 'Bold & Modern',
          'value': 'trendy',
          'icon': Icons.trending_up_outlined,
          'color': accentRed,
        },
      ]
    },
    {
      'id': 2,
      'category': 'Colors',
      'question': 'Which palette speaks to you?',
      'subtitle': 'Your color preference',
      'icon': Icons.color_lens_outlined,
      'options': [
        {
          'text': 'Neutrals',
          'subtitle': 'Black, White, Beige',
          'value': 'neutral',
          'icon': Icons.circle_outlined,
          'color': darkGray,
        },
        {
          'text': 'Earth Tones',
          'subtitle': 'Brown, Green, Terra',
          'value': 'earth',
          'icon': Icons.eco_outlined,
          'color': Color(0xFF8B4513),
        },
        {
          'text': 'Bold Colors',
          'subtitle': 'Red, Blue, Yellow',
          'value': 'bold',
          'icon': Icons.flash_on_outlined,
          'color': accentRed,
        },
        {
          'text': 'Pastels',
          'subtitle': 'Pink, Lavender, Mint',
          'value': 'pastel',
          'icon': Icons.favorite_border_outlined,
          'color': accentPurple,
        },
      ]
    },
    {
      'id': 3,
      'category': 'Lifestyle',
      'question': 'Your weekend vibe?',
      'subtitle': 'Comfort zone style',
      'icon': Icons.weekend_outlined,
      'options': [
        {
          'text': 'Cozy Casual',
          'subtitle': 'Jeans & Sweater',
          'value': 'casual',
          'icon': Icons.home_outlined,
          'color': mediumGray,
        },
        {
          'text': 'Romantic',
          'subtitle': 'Flowy & Feminine',
          'value': 'romantic',
          'icon': Icons.local_florist_outlined,
          'color': accentPurple,
        },
        {
          'text': 'Polished',
          'subtitle': 'Tailored & Crisp',
          'value': 'polished',
          'icon': Icons.business_center_outlined,
          'color': primaryBlue,
        },
        {
          'text': 'Edgy',
          'subtitle': 'Bold & Statement',
          'value': 'edgy',
          'icon': Icons.star_outline,
          'color': accentRed,
        },
      ]
    },
    {
      'id': 4,
      'category': 'Fit',
      'question': 'How do clothes fit you?',
      'subtitle': 'Your preferred silhouette',
      'icon': Icons.checkroom_outlined,
      'options': [
        {
          'text': 'Relaxed',
          'subtitle': 'Comfortable & Easy',
          'value': 'relaxed',
          'icon': Icons.air_outlined,
          'color': lightBlue,
        },
        {
          'text': 'Fitted',
          'subtitle': 'Tailored & Sharp',
          'value': 'fitted',
          'icon': Icons.straighten_outlined,
          'color': primaryBlue,
        },
        {
          'text': 'Flowy',
          'subtitle': 'Loose & Graceful',
          'value': 'flowy',
          'icon': Icons.waves_outlined,
          'color': accentYellow,
        },
        {
          'text': 'Mixed',
          'subtitle': 'Fitted + Loose Balance',
          'value': 'mixed',
          'icon': Icons.balance_outlined,
          'color': deepBlue,
        },
      ]
    },
    {
      'id': 5,
      'category': 'Accessories',
      'question': 'Your accessory philosophy?',
      'subtitle': 'How you complete looks',
      'icon': Icons.watch_outlined,
      'options': [
        {
          'text': 'Minimal',
          'subtitle': 'Less is More',
          'value': 'minimal',
          'icon': Icons.minimize_outlined,
          'color': darkGray,
        },
        {
          'text': 'Statement',
          'subtitle': 'Bold Pieces',
          'value': 'statement',
          'icon': Icons.campaign_outlined,
          'color': accentRed,
        },
        {
          'text': 'Layered',
          'subtitle': 'Creative Mix',
          'value': 'layered',
          'icon': Icons.layers_outlined,
          'color': accentYellow,
        },
        {
          'text': 'Classic',
          'subtitle': 'Timeless Pieces',
          'value': 'classic_acc',
          'icon': Icons.history_outlined,
          'color': primaryBlue,
        },
      ]
    }
  ];

  // Mobile-Optimized Style Profiles
  final Map<String, Map<String, dynamic>> _styleProfiles = {
    'minimalist': {
      'title': 'Minimalist Chic',
      'subtitle': 'Less is More',
      'description': 'You appreciate clean lines, quality fabrics, and timeless pieces. Your style is sophisticated in its simplicity.',
      'icon': Icons.architecture_outlined,
      'color': primaryBlue,
      'tips': [
        'Focus on quality basics in neutral colors',
        'Choose pieces with perfect fit',
        'One statement piece per outfit',
        'Build a versatile capsule wardrobe',
        'Invest in premium fabrics'
      ]
    },
    'bohemian': {
      'title': 'Bohemian Spirit',
      'subtitle': 'Free & Creative',
      'description': 'You express creativity through fashion, mixing textures and patterns. Your style tells unique stories.',
      'icon': Icons.nature_people_outlined,
      'color': accentYellow,
      'tips': [
        'Mix patterns with confidence',
        'Layer textures creatively',
        'Choose flowing silhouettes',
        'Embrace earthy colors',
        'Add vintage pieces'
      ]
    },
    'classic': {
      'title': 'Timeless Classic',
      'subtitle': 'Elegant & Refined',
      'description': 'Your style is refined and never goes out of fashion. You appreciate traditional craftsmanship and heritage.',
      'icon': Icons.diamond_outlined,
      'color': deepBlue,
      'tips': [
        'Invest in quality over quantity',
        'Choose classic silhouettes',
        'Stick to refined color palette',
        'Add elegant accessories',
        'Maintain pieces properly'
      ]
    },
    'trendy': {
      'title': 'Modern Trendsetter',
      'subtitle': 'Bold & Current',
      'description': 'You\'re ahead of trends, experimenting with latest styles. Your fashion is dynamic and confident.',
      'icon': Icons.trending_up_outlined,
      'color': accentRed,
      'tips': [
        'Stay updated with trends',
        'Experiment with bold colors',
        'Mix high-street with designer',
        'Use accessories to update looks',
        'Take calculated fashion risks'
      ]
    }
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadQuestions();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.2, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      _rotationController,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    final breathingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _breathingAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: breathingController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
    _progressController.forward();
  }

  Future<void> _loadQuestions() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _submitAnswers() async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      await Future.delayed(const Duration(seconds: 2));
      final result = _generateEnhancedResult();
      
      setState(() {
        _styleResult = result['style'];
        _styleDescription = result['description'];
        _personalizedTips = result['tips'];
        _showResult = true;
        _isLoading = false;
      });
      
      _scaleController.reset();
      _scaleController.forward();
      HapticFeedback.lightImpact();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Analysis failed. Please try again.');
    }
  }

  Map<String, dynamic> _generateEnhancedResult() {
    final answers = _answers.values.toList();
    
    Map<String, int> styleScores = {
      'minimalist': 0,
      'bohemian': 0,
      'classic': 0,
      'trendy': 0,
    };

    for (String answer in answers) {
      switch (answer) {
        case 'minimalist':
        case 'neutral':
        case 'fitted':
        case 'minimal':
          styleScores['minimalist'] = styleScores['minimalist']! + 2;
          styleScores['classic'] = styleScores['classic']! + 1;
          break;
        case 'bohemian':
        case 'earth':
        case 'flowy':
        case 'layered':
          styleScores['bohemian'] = styleScores['bohemian']! + 2;
          styleScores['trendy'] = styleScores['trendy']! + 1;
          break;
        case 'classic':
        case 'polished':
        case 'classic_acc':
          styleScores['classic'] = styleScores['classic']! + 2;
          styleScores['minimalist'] = styleScores['minimalist']! + 1;
          break;
        case 'trendy':
        case 'bold':
        case 'edgy':
        case 'statement':
          styleScores['trendy'] = styleScores['trendy']! + 2;
          styleScores['bohemian'] = styleScores['bohemian']! + 1;
          break;
      }
    }

    String topStyle = styleScores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    final profile = _styleProfiles[topStyle]!;
    
    return {
      'style': profile['title'],
      'description': profile['description'],
      'tips': profile['tips'],
      'profile': profile,
    };
  }

  void _nextQuestion() {
    HapticFeedback.selectionClick();
    if (_currentQuestion < _questions.length - 1) {
      setState(() => _currentQuestion++);
      _slideController.reset();
      _slideController.forward();
      _scaleController.reset();
      _scaleController.forward();
    } else {
      _submitAnswers();
    }
  }

  void _previousQuestion() {
    HapticFeedback.selectionClick();
    if (_currentQuestion > 0) {
      setState(() => _currentQuestion--);
      _slideController.reset();
      _slideController.forward();
      _scaleController.reset();
      _scaleController.forward();
    }
  }

  void _selectAnswer(String value) {
    HapticFeedback.lightImpact();
    setState(() {
      _answers[_questions[_currentQuestion]['id']] = value;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: accentRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      ),
    );
  }

  void _navigateToOutfitPlanner() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.checkroom, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Creating $_styleResult outfits...',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: softCream,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              softCream,
              lightBlue.withOpacity(0.2),
              softCream,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildMobileAppBar(screenSize),
              Expanded(
                child: _showResult ? _buildMobileResultView(screenSize) : _buildMobileQuizView(screenSize),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileAppBar(Size screenSize) {
    final isSmallScreen = screenSize.width < 360;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.05,
        vertical: screenSize.height * 0.015,
      ),
      child: Row(
        children: [
          // Compact Back Button
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: isSmallScreen ? 40 : 44,
              height: isSmallScreen ? 40 : 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 18),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 18),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: darkGray,
                    size: isSmallScreen ? 18 : 20,
                  ),
                ),
              ),
            ),
          ),
          
          SizedBox(width: screenSize.width * 0.04),
          
          // Compact Title
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [primaryBlue, accentPurple],
                    ).createShader(bounds),
                    child: Text(
                      'Style Quiz',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  if (!_showResult && !isSmallScreen) ...[
                    Text(
                      'Discover your style',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: mediumGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Compact Animated Icon
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * 2 * math.pi,
                child: Container(
                  width: isSmallScreen ? 36 : 40,
                  height: isSmallScreen ? 36 : 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryBlue, accentYellow],
                    ),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: isSmallScreen ? 18 : 20,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileQuizView(Size screenSize) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildMobileProgressBar(screenSize),
          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _buildMobileQuestionCard(screenSize),
              ),
            ),
          ),
          _buildMobileNavigationButtons(screenSize),
        ],
      ),
    );
  }

  Widget _buildMobileProgressBar(Size screenSize) {
    double progress = (_currentQuestion + 1) / _questions.length;
    final question = _questions[_currentQuestion];
    final isSmallScreen = screenSize.width < 360;
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.05,
        vertical: screenSize.height * 0.01,
      ),
      child: Column(
        children: [
          // Compact Progress Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 10 : 12,
                    vertical: isSmallScreen ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        question['icon'],
                        color: primaryBlue,
                        size: isSmallScreen ? 14 : 16,
                      ),
                      SizedBox(width: isSmallScreen ? 4 : 6),
                      Flexible(
                        child: Text(
                          question['category'],
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 11 : 12,
                            fontWeight: FontWeight.w600,
                            color: darkGray,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 10 : 12,
                  vertical: isSmallScreen ? 6 : 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryBlue, accentPurple],
                  ),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${_currentQuestion + 1}/${_questions.length}',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 11 : 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: screenSize.height * 0.015),
          
          // Compact Progress Bar
          Container(
            height: isSmallScreen ? 6 : 8,
            decoration: BoxDecoration(
              color: lightGray,
              borderRadius: BorderRadius.circular(isSmallScreen ? 3 : 4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isSmallScreen ? 3 : 4),
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: progress * _progressAnimation.value,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                  );
                },
              ),
            ),
          ),
          
          SizedBox(height: screenSize.height * 0.005),
          
          // Progress Percentage
          Text(
            '${(progress * 100).round()}% Complete',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: mediumGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileQuestionCard(Size screenSize) {
    final question = _questions[_currentQuestion];
    final isSmallScreen = screenSize.width < 360;
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.04,
        vertical: screenSize.height * 0.01,
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
        ),
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: isSmallScreen ? 15 : 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(screenSize.width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Compact Question Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryBlue.withOpacity(0.1),
                            accentYellow.withOpacity(0.1)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
                        border: Border.all(
                          color: primaryBlue.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        question['icon'],
                        size: isSmallScreen ? 20 : 24,
                        color: primaryBlue,
                      ),
                    ),
                    
                    SizedBox(width: screenSize.width * 0.04),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question ${_currentQuestion + 1}',
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 11 : 12,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                          Text(
                            question['category'],
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 10 : 11,
                              fontWeight: FontWeight.w500,
                              color: mediumGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: screenSize.height * 0.02),
                
                // Compact Question Text
                Text(
                  question['question'],
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.w700,
                    color: darkGray,
                    height: 1.3,
                  ),
                ),
                
                SizedBox(height: screenSize.height * 0.008),
                
                Text(
                  question['subtitle'],
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 13 : 14,
                    color: mediumGray,
                    height: 1.4,
                  ),
                ),
                
                SizedBox(height: screenSize.height * 0.025),
                
                // Compact Options
                ...question['options'].map<Widget>((option) => 
                  _buildMobileOptionCard(option, screenSize)).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileOptionCard(Map<String, dynamic> option, Size screenSize) {
    bool isSelected = _answers[_questions[_currentQuestion]['id']] == option['value'];
    final isSmallScreen = screenSize.width < 360;
    
    return Container(
      margin: EdgeInsets.only(bottom: screenSize.height * 0.012),
      child: Material(
        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectAnswer(option['value']),
          borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.all(screenSize.width * 0.04),
            decoration: BoxDecoration(
              color: isSelected 
                  ? option['color'].withOpacity(0.1) 
                  : lightGray.withOpacity(0.5),
              borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
              border: Border.all(
                color: isSelected ? option['color'] : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: option['color'].withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ] : [],
            ),
            child: Row(
              children: [
                // Compact Radio Button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: isSmallScreen ? 20 : 22,
                  height: isSmallScreen ? 20 : 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? option['color'] : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? option['color'] : mediumGray,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: Colors.white,
                          size: isSmallScreen ? 12 : 14,
                        )
                      : null,
                ),
                
                SizedBox(width: screenSize.width * 0.03),
                
                // Compact Option Icon
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? option['color'].withOpacity(0.2)
                        : mediumGray.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                  ),
                  child: Icon(
                    option['icon'],
                    color: isSelected ? option['color'] : mediumGray,
                    size: isSmallScreen ? 16 : 18,
                  ),
                ),
                
                SizedBox(width: screenSize.width * 0.03),
                
                // Compact Option Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option['text'],
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? option['color'] : darkGray,
                        ),
                      ),
                      Text(
                        option['subtitle'],
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 11 : 12,
                          color: isSelected 
                              ? option['color'].withOpacity(0.8)
                              : mediumGray,
                          height: 1.2,
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

  Widget _buildMobileNavigationButtons(Size screenSize) {
    bool hasAnswer = _answers.containsKey(_questions[_currentQuestion]['id']);
    final isSmallScreen = screenSize.width < 360;
    
    return Container(
      padding: EdgeInsets.all(screenSize.width * 0.05),
      child: Row(
        children: [
          // Compact Previous Button
          if (_currentQuestion > 0) ...[
            Expanded(
              child: Container(
                height: isSmallScreen ? 44 : 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 20),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: OutlinedButton.icon(
                  onPressed: _previousQuestion,
                  icon: Icon(
                    Icons.arrow_back_ios_rounded, 
                    size: isSmallScreen ? 14 : 16,
                  ),
                  label: Text(
                    'Back',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 13 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryBlue,
                    side: BorderSide(color: primaryBlue, width: 1.5),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 20),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: screenSize.width * 0.03),
          ],
          
          // Compact Next/Submit Button
          Expanded(
            flex: _currentQuestion == 0 ? 1 : 1,
            child: Container(
              height: isSmallScreen ? 44 : 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 20),
                gradient: hasAnswer
                    ? LinearGradient(
                        colors: [primaryBlue, accentPurple],
                      )
                    : null,
                color: hasAnswer ? null : mediumGray.withOpacity(0.3),
                boxShadow: hasAnswer ? [
                  BoxShadow(
                    color: primaryBlue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ] : [],
              ),
              child: ElevatedButton.icon(
                onPressed: hasAnswer ? _nextQuestion : null,
                icon: _isLoading
                    ? SizedBox(
                        width: isSmallScreen ? 16 : 18,
                        height: isSmallScreen ? 16 : 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 1.5,
                        ),
                      )
                    : Icon(
                        _currentQuestion == _questions.length - 1
                            ? Icons.auto_awesome_rounded
                            : Icons.arrow_forward_ios_rounded,
                        size: isSmallScreen ? 14 : 16,
                      ),
                label: Text(
                  _isLoading
                      ? 'Wait...'
                      : _currentQuestion == _questions.length - 1
                          ? 'Get Style'
                          : 'Next',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileResultView(Size screenSize) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(screenSize.width * 0.04),
        child: Column(
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: _buildMobileResultCard(screenSize),
            ),
            SizedBox(height: screenSize.height * 0.025),
            _buildMobileTips(screenSize),
            SizedBox(height: screenSize.height * 0.025),
            _buildMobileActionButtons(screenSize),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileResultCard(Size screenSize) {
    final isSmallScreen = screenSize.width < 360;
    
    return AnimatedBuilder(
      animation: _breathingAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _breathingAnimation.value,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isSmallScreen ? 24 : 28),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 24 : 28),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryBlue, accentPurple],
                  ),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 24 : 28),
                ),
                padding: EdgeInsets.all(screenSize.width * 0.08),
                child: Column(
                  children: [
                    // Compact Result Icon
                    AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Container(
                          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Transform.rotate(
                            angle: _rotationAnimation.value * 0.3 * math.pi,
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              size: isSmallScreen ? 36 : 42,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    SizedBox(height: screenSize.height * 0.02),
                    
                    Text(
                      '🎉 Your Style',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    
                    SizedBox(height: screenSize.height * 0.01),
                    
                    // Compact Style Title
                    Text(
                      _styleResult ?? 'Modern Trendsetter',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 24 : 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: screenSize.height * 0.015),
                    
                    // Compact Description
                    Container(
                      padding: EdgeInsets.all(screenSize.width * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _styleDescription ?? 
                        'Your unique style combines modern trends with personal flair.',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 13 : 14,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileTips(Size screenSize) {
    final isSmallScreen = screenSize.width < 360;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 20),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 20),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: EdgeInsets.all(screenSize.width * 0.06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentYellow.withOpacity(0.2), accentYellow.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline_rounded,
                    color: accentYellow,
                    size: isSmallScreen ? 20 : 24,
                  ),
                ),
                SizedBox(width: screenSize.width * 0.03),
                Expanded(
                  child: Text(
                    'Style Tips for You',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w700,
                      color: darkGray,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: screenSize.height * 0.02),
            
            // Compact Tips
            ..._personalizedTips.asMap().entries.map((entry) {
              int index = entry.key;
              String tip = entry.value;
              return _buildMobileTipItem(tip, index, screenSize);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileTipItem(String tip, int index, Size screenSize) {
    final isSmallScreen = screenSize.width < 360;
    
    return Container(
      margin: EdgeInsets.only(bottom: screenSize.height * 0.015),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact Number Badge
          Container(
            width: isSmallScreen ? 24 : 28,
            height: isSmallScreen ? 24 : 28,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primaryBlue, accentPurple]),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 11 : 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          SizedBox(width: screenSize.width * 0.03),
          
          // Compact Tip Content
          Expanded(
            child: Container(
              padding: EdgeInsets.all(screenSize.width * 0.04),
              decoration: BoxDecoration(
                color: lightBlue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
                border: Border.all(
                  color: primaryBlue.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Text(
                tip,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 12 : 13,
                  color: darkGray,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileActionButtons(Size screenSize) {
    final isSmallScreen = screenSize.width < 360;
    
    return Column(
      children: [
        // Primary Action
        Container(
          width: double.infinity,
          height: isSmallScreen ? 48 : 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primaryBlue, accentPurple]),
            borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 22),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: _navigateToOutfitPlanner,
            icon: Icon(
              Icons.checkroom_rounded, 
              size: isSmallScreen ? 18 : 20,
            ),
            label: Text(
              'Create Style Board',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 22),
              ),
            ),
          ),
        ),
        
        SizedBox(height: screenSize.height * 0.015),
        
        // Secondary Actions Row
        Row(
          children: [
            Expanded(
              child: Container(
                height: isSmallScreen ? 44 : 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sharing $_styleResult profile...'),
                        backgroundColor: accentYellow,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: EdgeInsets.all(screenSize.width * 0.04),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.share_outlined,
                    size: isSmallScreen ? 16 : 18,
                  ),
                  label: Text(
                    'Share',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryBlue,
                    side: BorderSide(color: primaryBlue, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 20),
                    ),
                  ),
                ),
              ),
            ),
            
            SizedBox(width: screenSize.width * 0.03),
            
            Expanded(
              child: Container(
                height: isSmallScreen ? 44 : 48,
                child: TextButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _currentQuestion = 0;
                      _answers.clear();
                      _showResult = false;
                      _styleResult = null;
                      _styleDescription = null;
                      _personalizedTips.clear();
                    });
                    _slideController.reset();
                    _slideController.forward();
                    _scaleController.reset();
                    _scaleController.forward();
                  },
                  icon: Icon(
                    Icons.refresh_rounded,
                    size: isSmallScreen ? 16 : 18,
                  ),
                  label: Text(
                    'Retake',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: mediumGray,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 20),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
