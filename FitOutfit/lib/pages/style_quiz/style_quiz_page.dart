import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/user_service.dart';

class StyleQuizPage extends StatefulWidget {
  const StyleQuizPage({super.key});

  @override
  State<StyleQuizPage> createState() => _StyleQuizPageState();
}

class _StyleQuizPageState extends State<StyleQuizPage>
    with TickerProviderStateMixin {
  // FitOutfit Brand Colors
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

  // API Configuration - GANTI API KEY MU DI SINI!
  static const String OPENAI_API_KEY = ("OPENAI_API_KEY");

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _progressController;
  late AnimationController _shimmerController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _breathingAnimation;
  late Animation<double> _shimmerAnimation;

  // State Variables
  int _currentQuestion = 0;
  final Map<int, String> _answers = {};
  bool _isLoading = false;
  bool _isGeneratingQuestions = true;
  bool _showResult = false;
  String? _styleResult;
  String? _styleDescription;
  List<String> _personalizedTips = [];
  String _quizSessionId = '';

  // User Data
  String _currentUser = 'User';
  String _currentUserId = 'user_001';

  // AI-Generated Questions
  List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();
    _generateUniqueSession();
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
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_rotationController);

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    final breathingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _breathingAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: breathingController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  // Load current user data
  Future<void> _loadUserData() async {
    try {
      // Sinkronkan dulu dengan Firebase Auth
      await UserService.syncUserFromAuth();

      final username = await UserService.getCurrentUser();
      final userId = await UserService.getCurrentUserId();

      setState(() {
        _currentUser = username;
        _currentUserId = userId;
      });

      // Generate questions after loading user data
      _generateAIQuestions();
    } catch (e) {
      print('Failed to load user data: $e');
      // Fallback to default
      setState(() {
        _currentUser = 'Guest';
        _currentUserId = 'guest_user';
      });
      _generateAIQuestions();
    }
  }

  DateTime _getCurrentDateTime() {
    try {
      return DateTime.parse('2025-06-29 06:35:56');
    } catch (e) {
      return DateTime.now(); // Fallback to system time
    }
  }

  void _generateUniqueSession() {
    final now = _getCurrentDateTime();
    _quizSessionId =
        'quiz_${now.millisecondsSinceEpoch}_${_currentUser}_${math.Random().nextInt(10000)}';
  }

  // AI Question Generation
  Future<void> _generateAIQuestions() async {
    setState(() => _isGeneratingQuestions = true);

    try {
      // Try OpenAI first
      final aiQuestions = await _tryOpenAI();
      if (aiQuestions != null) {
        setState(() {
          _questions = aiQuestions;
          _isGeneratingQuestions = false;
        });
        _startQuiz();
        return;
      }

      // Fallback to contextual questions
      await _generateContextualFallback();
    } catch (e) {
      print('AI Generation failed: $e');
      await _generateContextualFallback();
    }
  }

  Future<List<Map<String, dynamic>>?> _tryOpenAI() async {
    if (OPENAI_API_KEY == 'sk-your-openai-api-key-here') return null;

    try {
      final currentDateTime = _getCurrentDateTime();
      final dayOfWeek =
          [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
            'Sunday',
          ][currentDateTime.weekday - 1];
      final timeOfDay =
          '${currentDateTime.hour.toString().padLeft(2, '0')}:${currentDateTime.minute.toString().padLeft(2, '0')}';

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $OPENAI_API_KEY',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content':
                  '''You are Fitur's AI fashion stylist for user "$_currentUser". Generate exactly 6 unique, personalized style quiz questions for mobile app. 
              Current context: $dayOfWeek morning ($timeOfDay UTC), late June 2025.
              User: $_currentUser
              
              Make questions fresh, engaging, and different each time. Address the user by name occasionally. 
              
              Generate ALL 6 questions covering:
              1. Personal style aesthetic 
              2. Color/pattern preferences
              3. Lifestyle/occasion needs
              4. Comfort & fit preferences  
              5. Shopping/budget habits
              6. Style inspiration sources
              
              Return ONLY valid JSON with exactly 6 questions:
              {
                "questions": [
                  {
                    "id": 1,
                    "category": "Morning Style",
                    "question": "How do you want to feel in your clothes this $dayOfWeek, $_currentUser?",
                    "subtitle": "Weekend energy check",
                    "icon": "wb_sunny_outlined",
                    "options": [
                      {"text": "Effortlessly Chic", "subtitle": "Put-together ease", "value": "effortless", "icon": "star_outline", "color": "primaryBlue"},
                      {"text": "Cozy Comfort", "subtitle": "Relaxed vibes", "value": "cozy", "icon": "home_outlined", "color": "accentYellow"},
                      {"text": "Bold Statement", "subtitle": "Make an impact", "value": "bold", "icon": "flash_on_outlined", "color": "accentRed"},
                      {"text": "Classic Grace", "subtitle": "Timeless elegance", "value": "classic", "icon": "diamond_outlined", "color": "deepBlue"}
                    ]
                  },
                  {
                    "id": 2,
                    "category": "Color Vibes",
                    "question": "What colors make you feel most confident, $_currentUser?",
                    "subtitle": "Your power palette",
                    "icon": "palette_outlined",
                    "options": [
                      {"text": "Deep & Rich", "subtitle": "Burgundy, navy, emerald", "value": "deep", "icon": "circle_outlined", "color": "deepBlue"},
                      {"text": "Soft & Neutral", "subtitle": "Beige, cream, blush", "value": "neutral", "icon": "circle_outlined", "color": "mediumGray"},
                      {"text": "Bright & Bold", "subtitle": "Coral, electric blue, fuchsia", "value": "bright", "icon": "flash_on_outlined", "color": "accentRed"},
                      {"text": "Earth & Natural", "subtitle": "Olive, rust, camel", "value": "earth", "icon": "nature_people_outlined", "color": "accentYellow"}
                    ]
                  },
                  {
                    "id": 3,
                    "category": "Lifestyle Match",
                    "question": "What best describes your daily routine?",
                    "subtitle": "Fashion meets function",
                    "icon": "directions_run_outlined",
                    "options": [
                      {"text": "Always On-The-Go", "subtitle": "Active & dynamic", "value": "active", "icon": "directions_run_outlined", "color": "accentRed"},
                      {"text": "Work-Focused", "subtitle": "Professional first", "value": "professional", "icon": "business_center_outlined", "color": "primaryBlue"},
                      {"text": "Creative & Flexible", "subtitle": "Artistic projects", "value": "creative", "icon": "palette_outlined", "color": "accentPurple"},
                      {"text": "Balanced Living", "subtitle": "Mix of everything", "value": "balanced", "icon": "spa_outlined", "color": "accentYellow"}
                    ]
                  },
                  {
                    "id": 4,
                    "category": "Comfort Zone",
                    "question": "How do you prefer your clothes to fit?",
                    "subtitle": "Your comfort priority",
                    "icon": "checkroom_outlined",
                    "options": [
                      {"text": "Perfectly Tailored", "subtitle": "Sharp & structured", "value": "tailored", "icon": "straighten_outlined", "color": "primaryBlue"},
                      {"text": "Relaxed & Flowy", "subtitle": "Comfortable ease", "value": "relaxed", "icon": "air_outlined", "color": "accentYellow"},
                      {"text": "Figure-Hugging", "subtitle": "Show your silhouette", "value": "fitted", "icon": "fitness_center_outlined", "color": "accentRed"},
                      {"text": "Mix of Both", "subtitle": "Balanced approach", "value": "mixed", "icon": "balance_outlined", "color": "accentPurple"}
                    ]
                  },
                  {
                    "id": 5,
                    "category": "Shopping Style",
                    "question": "How do you prefer to build your wardrobe?",
                    "subtitle": "Your shopping philosophy",
                    "icon": "shopping_bag_outlined",
                    "options": [
                      {"text": "Quality Investment", "subtitle": "Fewer, better pieces", "value": "quality", "icon": "diamond_outlined", "color": "deepBlue"},
                      {"text": "Trendy Updates", "subtitle": "Latest styles regularly", "value": "trendy", "icon": "trending_up_outlined", "color": "accentRed"},
                      {"text": "Vintage & Unique", "subtitle": "One-of-a-kind finds", "value": "vintage", "icon": "auto_awesome_outlined", "color": "accentPurple"},
                      {"text": "Practical Basics", "subtitle": "Versatile essentials", "value": "practical", "icon": "checkroom_outlined", "color": "primaryBlue"}
                    ]
                  },
                  {
                    "id": 6,
                    "category": "Style Inspiration",
                    "question": "Where do you find your fashion inspiration?",
                    "subtitle": "Your creative source",
                    "icon": "lightbulb_outline_rounded",
                    "options": [
                      {"text": "Social Media", "subtitle": "Instagram & TikTok", "value": "social", "icon": "photo_camera_outlined", "color": "accentPurple"},
                      {"text": "Street Style", "subtitle": "Real people, real looks", "value": "street", "icon": "directions_walk_outlined", "color": "primaryBlue"},
                      {"text": "Fashion Icons", "subtitle": "Celebrities & influencers", "value": "icons", "icon": "star_outline", "color": "accentYellow"},
                      {"text": "My Own Creativity", "subtitle": "Original style", "value": "creative", "icon": "psychology_outlined", "color": "accentRed"}
                    ]
                  }
                ]
              }''',
            },
            {
              'role': 'user',
              'content':
                  'Generate fresh $dayOfWeek morning style quiz for $_currentUser at $timeOfDay. Session: $_quizSessionId. Make it feel personal and current.',
            },
          ],
          'max_tokens': 2500,
          'temperature': 0.8,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final cleanContent =
            content.replaceAll('```json', '').replaceAll('```', '').trim();
        final parsed = jsonDecode(cleanContent);
        return _parseAIQuestions(parsed['questions']);
      }
    } catch (e) {
      print('OpenAI error: $e');
    }
    return null;
  }

  List<Map<String, dynamic>> _parseAIQuestions(List<dynamic> aiQuestions) {
    return aiQuestions.map<Map<String, dynamic>>((q) {
      return {
        'id': q['id'],
        'category': q['category'],
        'question': q['question'],
        'subtitle': q['subtitle'],
        'icon': _parseIcon(q['icon']),
        'options':
            (q['options'] as List)
                .map(
                  (opt) => {
                    'text': opt['text'],
                    'subtitle': opt['subtitle'],
                    'value': opt['value'],
                    'icon': _parseIcon(opt['icon']),
                    'color': _parseColor(opt['color']),
                  },
                )
                .toList(),
      };
    }).toList();
  }

  IconData _parseIcon(String iconName) {
    switch (iconName) {
      case 'wb_sunny_outlined':
        return Icons.wb_sunny_outlined;
      case 'palette_outlined':
        return Icons.palette_outlined;
      case 'color_lens_outlined':
        return Icons.color_lens_outlined;
      case 'weekend_outlined':
        return Icons.weekend_outlined;
      case 'checkroom_outlined':
        return Icons.checkroom_outlined;
      case 'watch_outlined':
        return Icons.watch_outlined;
      case 'star_outline':
        return Icons.star_outline;
      case 'home_outlined':
        return Icons.home_outlined;
      case 'flash_on_outlined':
        return Icons.flash_on_outlined;
      case 'diamond_outlined':
        return Icons.diamond_outlined;
      case 'nature_people_outlined':
        return Icons.nature_people_outlined;
      case 'trending_up_outlined':
        return Icons.trending_up_outlined;
      case 'favorite_border_outlined':
        return Icons.favorite_border_outlined;
      case 'shopping_bag_outlined':
        return Icons.shopping_bag_outlined;
      case 'camera_alt_outlined':
        return Icons.camera_alt_outlined;
      case 'waves_outlined':
        return Icons.waves_outlined;
      case 'circle_outlined':
        return Icons.circle_outlined;
      case 'local_fire_department_outlined':
        return Icons.local_fire_department_outlined;
      case 'architecture_outlined':
        return Icons.architecture_outlined;
      case 'psychology_outlined':
        return Icons.psychology_outlined;
      case 'straighten_outlined':
        return Icons.straighten_outlined;
      case 'air_outlined':
        return Icons.air_outlined;
      case 'balance_outlined':
        return Icons.balance_outlined;
      case 'fitness_center_outlined':
        return Icons.fitness_center_outlined;
      case 'photo_camera_outlined':
        return Icons.photo_camera_outlined;
      case 'directions_walk_outlined':
        return Icons.directions_walk_outlined;
      case 'auto_awesome_outlined':
        return Icons.auto_awesome_outlined;
      case 'directions_run_outlined':
        return Icons.directions_run_outlined;
      case 'business_center_outlined':
        return Icons.business_center_outlined;
      case 'celebration_outlined':
        return Icons.celebration_outlined;
      case 'spa_outlined':
        return Icons.spa_outlined;
      default:
        return Icons.style_outlined;
    }
  }

  Color _parseColor(String colorName) {
    switch (colorName) {
      case 'primaryBlue':
        return primaryBlue;
      case 'accentYellow':
        return accentYellow;
      case 'accentRed':
        return accentRed;
      case 'accentPurple':
        return accentPurple;
      case 'deepBlue':
        return deepBlue;
      case 'mediumGray':
        return mediumGray;
      default:
        return primaryBlue;
    }
  }

  Future<void> _generateContextualFallback() async {
    _getCurrentDateTime();
    final prefs = await SharedPreferences.getInstance();
    final previousQuizCount = prefs.getInt('quiz_count') ?? 0;

    List<Map<String, dynamic>> contextualQuestions = [
      _getSundayMorningQuestion(),
      _getSummerVibesQuestion(),
      _getPersonalityQuestion(),
      _getComfortQuestion(),
      _getInspirationQuestion(),
      _getLifestyleQuestion(),
    ];

    setState(() {
      _questions = contextualQuestions;
      _isGeneratingQuestions = false;
    });

    await prefs.setInt('quiz_count', previousQuizCount + 1);
    _startQuiz();
  }

  Map<String, dynamic> _getSundayMorningQuestion() {
    return {
      'id': 1,
      'category': 'Sunday Vibes',
      'question': 'How do you want to feel this Sunday morning, $_currentUser?',
      'subtitle': 'Weekend energy check',
      'icon': Icons.wb_sunny_outlined,
      'options': [
        {
          'text': 'Effortlessly Chic',
          'subtitle': 'Put-together ease',
          'value': 'effortless',
          'icon': Icons.star_outline,
          'color': primaryBlue,
        },
        {
          'text': 'Cozy & Relaxed',
          'subtitle': 'Comfort first',
          'value': 'cozy',
          'icon': Icons.home_outlined,
          'color': accentYellow,
        },
        {
          'text': 'Bold & Confident',
          'subtitle': 'Make a statement',
          'value': 'bold',
          'icon': Icons.flash_on_outlined,
          'color': accentRed,
        },
        {
          'text': 'Classic & Timeless',
          'subtitle': 'Elegant simplicity',
          'value': 'classic',
          'icon': Icons.diamond_outlined,
          'color': deepBlue,
        },
      ],
    };
  }

  Map<String, dynamic> _getSummerVibesQuestion() {
    return {
      'id': 2,
      'category': 'Summer Colors',
      'question': 'What summer palette speaks to your soul?',
      'subtitle': 'Late June inspiration',
      'icon': Icons.color_lens_outlined,
      'options': [
        {
          'text': 'Ocean Blues',
          'subtitle': 'Cool & calming',
          'value': 'blues',
          'icon': Icons.waves_outlined,
          'color': primaryBlue,
        },
        {
          'text': 'Sunset Warmth',
          'subtitle': 'Golden & vibrant',
          'value': 'warmth',
          'icon': Icons.wb_sunny_outlined,
          'color': accentYellow,
        },
        {
          'text': 'Fresh Neutrals',
          'subtitle': 'Clean & crisp',
          'value': 'neutrals',
          'icon': Icons.circle_outlined,
          'color': mediumGray,
        },
        {
          'text': 'Bold Brights',
          'subtitle': 'Eye-catching pop',
          'value': 'brights',
          'icon': Icons.local_fire_department_outlined,
          'color': accentRed,
        },
      ],
    };
  }

  Map<String, dynamic> _getPersonalityQuestion() {
    return {
      'id': 3,
      'category': 'Style Identity',
      'question': 'Which style personality resonates with you, $_currentUser?',
      'subtitle': 'Your fashion essence',
      'icon': Icons.psychology_outlined,
      'options': [
        {
          'text': 'Minimalist Maven',
          'subtitle': 'Less is more',
          'value': 'minimalist',
          'icon': Icons.architecture_outlined,
          'color': primaryBlue,
        },
        {
          'text': 'Bohemian Spirit',
          'subtitle': 'Free & artistic',
          'value': 'bohemian',
          'icon': Icons.nature_people_outlined,
          'color': accentYellow,
        },
        {
          'text': 'Trendy Innovator',
          'subtitle': 'Always ahead',
          'value': 'trendy',
          'icon': Icons.trending_up_outlined,
          'color': accentRed,
        },
        {
          'text': 'Classic Icon',
          'subtitle': 'Timeless elegance',
          'value': 'classic',
          'icon': Icons.diamond_outlined,
          'color': deepBlue,
        },
      ],
    };
  }

  Map<String, dynamic> _getComfortQuestion() {
    return {
      'id': 4,
      'category': 'Comfort Zone',
      'question': 'How do you prefer your clothes to fit?',
      'subtitle': 'Your comfort priority',
      'icon': Icons.checkroom_outlined,
      'options': [
        {
          'text': 'Perfectly Tailored',
          'subtitle': 'Sharp & structured',
          'value': 'tailored',
          'icon': Icons.straighten_outlined,
          'color': primaryBlue,
        },
        {
          'text': 'Relaxed & Flowy',
          'subtitle': 'Comfortable ease',
          'value': 'relaxed',
          'icon': Icons.air_outlined,
          'color': accentYellow,
        },
        {
          'text': 'Mix of Both',
          'subtitle': 'Balanced approach',
          'value': 'mixed',
          'icon': Icons.balance_outlined,
          'color': accentPurple,
        },
        {
          'text': 'Figure-Hugging',
          'subtitle': 'Show your silhouette',
          'value': 'fitted',
          'icon': Icons.fitness_center_outlined,
          'color': accentRed,
        },
      ],
    };
  }

  Map<String, dynamic> _getInspirationQuestion() {
    return {
      'id': 5,
      'category': 'Style Inspiration',
      'question': 'Where do you find your fashion inspiration?',
      'subtitle': 'Your creative source',
      'icon': Icons.lightbulb_outline_rounded,
      'options': [
        {
          'text': 'Social Media',
          'subtitle': 'Instagram & TikTok',
          'value': 'social',
          'icon': Icons.photo_camera_outlined,
          'color': accentPurple,
        },
        {
          'text': 'Street Style',
          'subtitle': 'Real people, real looks',
          'value': 'street',
          'icon': Icons.directions_walk_outlined,
          'color': primaryBlue,
        },
        {
          'text': 'Magazines & Runway',
          'subtitle': 'High fashion influence',
          'value': 'runway',
          'icon': Icons.auto_awesome_outlined,
          'color': accentRed,
        },
        {
          'text': 'My Own Creativity',
          'subtitle': 'Original style',
          'value': 'creative',
          'icon': Icons.palette_outlined,
          'color': accentYellow,
        },
      ],
    };
  }

  Map<String, dynamic> _getLifestyleQuestion() {
    return {
      'id': 6,
      'category': 'Lifestyle Match',
      'question': 'What best describes your lifestyle?',
      'subtitle': 'Fashion meets function',
      'icon': Icons.line_style_outlined,
      'options': [
        {
          'text': 'Always On-The-Go',
          'subtitle': 'Active & dynamic',
          'value': 'active',
          'icon': Icons.directions_run_outlined,
          'color': accentRed,
        },
        {
          'text': 'Work-Focused',
          'subtitle': 'Professional first',
          'value': 'professional',
          'icon': Icons.business_center_outlined,
          'color': primaryBlue,
        },
        {
          'text': 'Social Butterfly',
          'subtitle': 'Events & gatherings',
          'value': 'social',
          'icon': Icons.celebration_outlined,
          'color': accentYellow,
        },
        {
          'text': 'Balanced Living',
          'subtitle': 'Mix of everything',
          'value': 'balanced',
          'icon': Icons.spa_outlined,
          'color': accentPurple,
        },
      ],
    };
  }

  void _startQuiz() {
    _slideController.forward();
    _scaleController.forward();
    _progressController.forward();
  }

  Future<void> _submitAnswers() async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      // Send answers to AI for personalized analysis
      final aiResult = await _getAIStyleAnalysis();

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _styleResult = aiResult['style'] ?? 'Unique Style Personality';
        _styleDescription =
            aiResult['description'] ??
            'Your style is uniquely yours and perfectly reflects your personality!';
        _personalizedTips = List<String>.from(
          aiResult['tips'] ?? _generateFallbackTips(),
        );
        _showResult = true;
        _isLoading = false;
      });

      _scaleController.reset();
      _scaleController.forward();
      HapticFeedback.lightImpact();

      // Save result for future personalization
      await _saveQuizResult(aiResult);
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar(
        'AI analysis complete! Using smart analysis for your results.',
      );
    }
  }

  Future<Map<String, dynamic>> _getAIStyleAnalysis() async {
    try {
      if (OPENAI_API_KEY != 'sk-your-openai-api-key-here') {
        return await _getOpenAIAnalysis();
      }
    } catch (e) {
      print('AI Analysis error: $e');
    }

    return _generateEnhancedResult();
  }

  Future<Map<String, dynamic>> _getOpenAIAnalysis() async {
    final answersText = _answers.entries
        .map((e) => 'Q${e.key}: ${e.value}')
        .join(', ');

    final currentDateTime = _getCurrentDateTime();
    final timeOfDay =
        '${currentDateTime.hour.toString().padLeft(2, '0')}:${currentDateTime.minute.toString().padLeft(2, '0')}';

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $OPENAI_API_KEY',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content':
                '''You are FitYr's AI fashion stylist analyzing $_currentUser's style quiz results from Sunday morning, June 29, 2025 at $timeOfDay UTC.
            
            Create a personalized style profile for $_currentUser that feels authentic and actionable. Consider:
            - Current trends (late 2025)
            - Early Sunday morning context ($timeOfDay)
            - Personal expression needs for $_currentUser
            - Practical styling advice
            
            Return ONLY valid JSON:
            {
              "style": "Personalized Style Name (like 'Sunday Minimalist' or 'Morning Trendsetter')",
              "description": "Warm, personal description of $_currentUser's unique style (2-3 sentences that feel genuine)",
              "tips": [
                "Specific, actionable tip 1 for $_currentUser",
                "Specific, actionable tip 2 for $_currentUser", 
                "Specific, actionable tip 3 for $_currentUser",
                "Specific, actionable tip 4 for $_currentUser",
                "Specific, actionable tip 5 for $_currentUser"
              ]
            }''',
          },
          {
            'role': 'user',
            'content':
                'Analyze $_currentUser\'s Sunday morning style quiz answers for personalized results: $answersText',
          },
        ],
        'max_tokens': 1000,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      final cleanContent =
          content.replaceAll('```json', '').replaceAll('```', '').trim();
      return jsonDecode(cleanContent);
    }

    throw Exception('OpenAI API failed');
  }

  Map<String, dynamic> _generateEnhancedResult() {
    final answers = _answers.values.toList();

    Map<String, int> styleScores = {
      'minimalist': 0,
      'bohemian': 0,
      'classic': 0,
      'trendy': 0,
      'casual': 0,
      'professional': 0,
    };

    // Enhanced scoring algorithm
    for (String answer in answers) {
      switch (answer) {
        case 'effortless':
        case 'minimalist':
        case 'neutrals':
        case 'tailored':
          styleScores['minimalist'] = styleScores['minimalist']! + 3;
          styleScores['classic'] = styleScores['classic']! + 1;
          break;
        case 'cozy':
        case 'relaxed':
        case 'creative':
        case 'balanced':
          styleScores['casual'] = styleScores['casual']! + 3;
          styleScores['bohemian'] = styleScores['bohemian']! + 2;
          break;
        case 'bohemian':
        case 'warmth':
        case 'street':
        case 'social':
          styleScores['bohemian'] = styleScores['bohemian']! + 3;
          styleScores['trendy'] = styleScores['trendy']! + 1;
          break;
        case 'classic':
        case 'blues':
        case 'professional':
          styleScores['classic'] = styleScores['classic']! + 3;
          styleScores['professional'] = styleScores['professional']! + 2;
          break;
        case 'bold':
        case 'trendy':
        case 'brights':
        case 'runway':
        case 'active':
          styleScores['trendy'] = styleScores['trendy']! + 3;
          styleScores['professional'] = styleScores['professional']! + 1;
          break;
      }
    }

    String topStyle =
        styleScores.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    final profiles = _getEnhancedStyleProfiles();
    final profile = profiles[topStyle] ?? profiles['minimalist']!;

    return {
      'style': profile['title'],
      'description': profile['description'],
      'tips': profile['tips'],
      'profile': profile,
    };
  }

  Map<String, Map<String, dynamic>> _getEnhancedStyleProfiles() {
    return {
      'minimalist': {
        'title': 'Sunday Minimalist',
        'description':
            'You believe in the power of simplicity, $_currentUser. Your style is intentional and effortless, focusing on quality pieces that make you feel confident without trying too hard.',
        'tips': [
          'Invest in premium basics in neutral colors that mix and match effortlessly',
          'Choose one statement piece per outfit to add personality',
          'Focus on perfect fit - well-tailored pieces always look expensive',
          'Build around a curated color palette of 3-5 colors max',
          'Quality over quantity - fewer pieces, better materials',
        ],
      },
      'bohemian': {
        'title': 'Free Spirit Dreamer',
        'description':
            'Your style tells stories, $_currentUser. You mix textures, patterns, and eras to create looks that are uniquely yours and inspire others to embrace their creativity.',
        'tips': [
          'Layer different textures like denim, silk, and knits for depth',
          'Mix patterns confidently - start with one bold, one subtle',
          'Embrace earthy tones and natural fabrics like cotton and linen',
          'Use accessories to express your artistic side - scarves, jewelry, bags',
          'Vintage pieces add character - mix them with modern basics',
        ],
      },
      'classic': {
        'title': 'Timeless Icon',
        'description':
            'Your style embodies elegance and sophistication, $_currentUser. You understand that true style transcends trends, choosing pieces that will look as good today as they will in decades.',
        'tips': [
          'Invest in classic pieces like blazers, white shirts, and well-fitted jeans',
          'Master the art of tailoring - fit makes all the difference',
          'Choose refined color combinations like navy & white, black & cream',
          'Add subtle luxury through quality fabrics and craftsmanship',
          'Maintain your pieces properly to keep them looking fresh',
        ],
      },
      'trendy': {
        'title': 'Style Innovator',
        'description':
            'You\'re fearlessly ahead of the curve, $_currentUser. Your style is dynamic and confident, constantly evolving while staying true to your bold personality.',
        'tips': [
          'Stay updated with fashion weeks and emerging designers',
          'Mix high-street with designer pieces for balance',
          'Experiment with bold colors and unexpected combinations',
          'Use accessories to update classic pieces with current trends',
          'Take calculated fashion risks - not every trend needs to work for you',
        ],
      },
      'casual': {
        'title': 'Effortless Cool',
        'description':
            'Comfort meets style in your wardrobe, $_currentUser. You\'ve mastered the art of looking put-together while feeling relaxed and authentic.',
        'tips': [
          'Invest in elevated basics like soft knits and comfortable denim',
          'Layer pieces for depth and visual interest',
          'Choose comfortable shoes that still look stylish',
          'Mix casual pieces with one polished element',
          'Focus on fabrics that move with you throughout the day',
        ],
      },
      'professional': {
        'title': 'Power Player',
        'description':
            'Your style commands respect and confidence, $_currentUser. You understand the power of dressing for the role you want, creating looks that are both professional and personal.',
        'tips': [
          'Build a foundation of quality work staples in versatile colors',
          'Master the blazer - it instantly elevates any outfit',
          'Choose pieces that transition from day to evening',
          'Pay attention to details like fit, grooming, and accessories',
          'Express personality through color, texture, or subtle statement pieces',
        ],
      },
    };
  }

  List<String> _generateFallbackTips() {
    return [
      'Focus on fit - well-fitted clothes always look more expensive',
      'Build around pieces that make you feel confident and comfortable',
      'Use accessories to change up your looks without buying new clothes',
      'Invest in quality basics that work with multiple outfits',
      'Don\'t be afraid to express your personality through your style choices',
    ];
  }

  Future<void> _saveQuizResult(Map<String, dynamic> result) async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = DateTime.now().toIso8601String();

    await prefs.setString(
      'last_style_result',
      jsonEncode({
        'result': result,
        'answers': _answers,
        'user': _currentUser,
        'userId': _currentUserId,
        'timestamp': timestamp,
        'session_id': _quizSessionId,
      }),
    );
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
            Icon(Icons.smart_toy_outlined, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'AI Analysis Complete!',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(message, style: GoogleFonts.poppins(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        duration: const Duration(seconds: 3),
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
                'Creating $_styleResult outfits for $_currentUser...',
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
    _shimmerController.dispose();
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
            colors: [softCream, lightBlue.withOpacity(0.2), softCream],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildMobileAppBar(screenSize),
              Expanded(
                child:
                    _isGeneratingQuestions
                        ? _buildAILoadingScreen(screenSize)
                        : _showResult
                        ? _buildMobileResultView(screenSize)
                        : _buildMobileQuizView(screenSize),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAILoadingScreen(Size screenSize) {
    final isSmallScreen = screenSize.width < 360;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AI Brain Animation
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 2 * math.pi,
                  child: Container(
                    padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryBlue.withOpacity(0.2),
                          accentPurple.withOpacity(0.2),
                          accentYellow.withOpacity(0.2),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.psychology_outlined,
                      color: primaryBlue,
                      size: isSmallScreen ? 48 : 64,
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: screenSize.height * 0.04),

            // Shimmer Text Effect
            AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      colors: [primaryBlue, accentYellow, primaryBlue],
                      stops: [
                        _shimmerAnimation.value - 0.3,
                        _shimmerAnimation.value,
                        _shimmerAnimation.value + 0.3,
                      ],
                    ).createShader(bounds);
                  },
                  child: Text(
                    'AI is Crafting Your Quiz...',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),

            SizedBox(height: screenSize.height * 0.02),

            Text(
              'Creating personalized questions just for $_currentUser',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 14 : 16,
                color: mediumGray,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: screenSize.height * 0.04),

            // Animated Progress Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    final delay = index * 0.3;
                    final animValue = (_rotationAnimation.value + delay) % 1.0;
                    final scale =
                        0.8 + (math.sin(animValue * 2 * math.pi) * 0.3);

                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isSmallScreen ? 8 : 10,
                        height: isSmallScreen ? 8 : 10,
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
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
          // Back Button
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
                    Navigator.of(context).pop();
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

          // Title
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback:
                        (bounds) => LinearGradient(
                          colors: [primaryBlue, accentPurple],
                        ).createShader(bounds),
                    child: Row(
                      children: [
                        Text(
                          'AI Style Quiz',
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 18 : 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (!_isGeneratingQuestions && !isSmallScreen) ...[
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [accentYellow, accentRed],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'SMART',
                              style: GoogleFonts.poppins(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!_showResult &&
                      !isSmallScreen &&
                      !_isGeneratingQuestions) ...[
                    Text(
                      'Personalized for $_currentUser',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: mediumGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // AI Indicator
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
                      colors:
                          _isGeneratingQuestions
                              ? [accentYellow, accentRed]
                              : [primaryBlue, accentPurple],
                    ),
                    borderRadius: BorderRadius.circular(
                      isSmallScreen ? 14 : 16,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isGeneratingQuestions
                        ? Icons.psychology_outlined
                        : Icons.auto_awesome_rounded,
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
          // Progress Stats
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
                    borderRadius: BorderRadius.circular(
                      isSmallScreen ? 14 : 16,
                    ),
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
                  gradient: LinearGradient(colors: [primaryBlue, accentPurple]),
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

          // Progress Bar
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
                // Question Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryBlue.withOpacity(0.1),
                            accentYellow.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          isSmallScreen ? 14 : 16,
                        ),
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
                          Row(
                            children: [
                              Text(
                                'Question ${_currentQuestion + 1}',
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 11 : 12,
                                  fontWeight: FontWeight.w600,
                                  color: primaryBlue,
                                ),
                              ),
                              SizedBox(width: 6),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: accentYellow.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'AI',
                                  style: GoogleFonts.poppins(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    color: accentYellow,
                                  ),
                                ),
                              ),
                            ],
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

                // Question Text
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

                // Options
                ...question['options']
                    .map<Widget>(
                      (option) => _buildMobileOptionCard(option, screenSize),
                    )
                    .toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileOptionCard(Map<String, dynamic> option, Size screenSize) {
    bool isSelected =
        _answers[_questions[_currentQuestion]['id']] == option['value'];
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
              color:
                  isSelected
                      ? option['color'].withOpacity(0.1)
                      : lightGray.withOpacity(0.5),
              borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
              border: Border.all(
                color: isSelected ? option['color'] : Colors.transparent,
                width: 1.5,
              ),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: option['color'].withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                      : [],
            ),
            child: Row(
              children: [
                // Radio Button
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
                  child:
                      isSelected
                          ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: isSmallScreen ? 12 : 14,
                          )
                          : null,
                ),

                SizedBox(width: screenSize.width * 0.03),

                // Option Icon
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                  decoration: BoxDecoration(
                    color:
                        isSelected
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

                // Option Text
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
                          color:
                              isSelected
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
          // Previous Button
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
                      borderRadius: BorderRadius.circular(
                        isSmallScreen ? 18 : 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: screenSize.width * 0.03),
          ],

          // Next/Submit Button
          Expanded(
            flex: _currentQuestion == 0 ? 1 : 1,
            child: Container(
              height: isSmallScreen ? 44 : 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 20),
                gradient:
                    hasAnswer
                        ? LinearGradient(colors: [primaryBlue, accentPurple])
                        : null,
                color: hasAnswer ? null : mediumGray.withOpacity(0.3),
                boxShadow:
                    hasAnswer
                        ? [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : [],
              ),
              child: ElevatedButton.icon(
                onPressed: hasAnswer ? _nextQuestion : null,
                icon:
                    _isLoading
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
                      ? 'Analyzing...'
                      : _currentQuestion == _questions.length - 1
                      ? 'Get My Style'
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
                    borderRadius: BorderRadius.circular(
                      isSmallScreen ? 18 : 20,
                    ),
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
                    // AI Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.psychology_outlined,
                            color: Colors.white,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'AI Analyzed for $_currentUser',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenSize.height * 0.02),

                    // Result Icon
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
                      '🎉 Your AI Style Profile',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),

                    SizedBox(height: screenSize.height * 0.01),

                    // Style Title
                    Text(
                      _styleResult ?? 'Sunday Style Icon',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 22 : 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: screenSize.height * 0.015),

                    // Description
                    Container(
                      padding: EdgeInsets.all(screenSize.width * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(
                          isSmallScreen ? 14 : 16,
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _styleDescription ??
                            'Your unique style perfectly balances comfort and sophistication, $_currentUser. You have an innate ability to look effortlessly put-together.',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 12 : 13,
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
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accentYellow.withOpacity(0.2),
                        accentYellow.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                      isSmallScreen ? 10 : 12,
                    ),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline_rounded,
                    color: accentYellow,
                    size: isSmallScreen ? 20 : 24,
                  ),
                ),
                SizedBox(width: screenSize.width * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Style Tips',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.w700,
                          color: darkGray,
                        ),
                      ),
                      Text(
                        'Personalized for $_currentUser',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: mediumGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: screenSize.height * 0.02),

            // Tips
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
          // Number Badge
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

          // Tip Content
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
            icon: Icon(Icons.checkroom_rounded, size: isSmallScreen ? 18 : 20),
            label: Text(
              'Create AI Outfits',
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
                  onPressed: () => _shareResult(),
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
                      borderRadius: BorderRadius.circular(
                        isSmallScreen ? 18 : 20,
                      ),
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
                  onPressed: () => _retakeQuiz(),
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
                      borderRadius: BorderRadius.circular(
                        isSmallScreen ? 18 : 20,
                      ),
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

  void _shareResult() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.share, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Sharing $_currentUser\'s $_styleResult profile...',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: accentYellow,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      ),
    );
  }

  void _retakeQuiz() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentQuestion = 0;
      _answers.clear();
      _showResult = false;
      _styleResult = null;
      _styleDescription = null;
      _personalizedTips.clear();
      _isGeneratingQuestions = true;
    });

    _generateUniqueSession();
    _generateAIQuestions();

    _slideController.reset();
    _scaleController.reset();
  }
}
