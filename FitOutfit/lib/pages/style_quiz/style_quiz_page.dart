import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/user_service.dart';

class StyleQuizPage extends StatefulWidget {
  const StyleQuizPage({super.key});

  @override
  State<StyleQuizPage> createState() => _StyleQuizPageState();
}

class _StyleQuizPageState extends State<StyleQuizPage>
    with TickerProviderStateMixin {
  // Budget Fashion Quiz Brand Colors - Emerald Green + Beige Theme
  static const Color primaryGreen = Color(0xFF10B981); // Emerald Green - savings theme
  static const Color accentBeige = Color(0xFFF5F5DC); // Warm Beige - calm theme
  static const Color accentOrange = Color(0xFFFF6B35); // Budget alert orange
  static const Color accentPurple = Color(0xFF7B68EE); // Smart shopping purple
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color softCream = Color(0xFFFAF9F7);
  static const Color deepGreen = Color(0xFF047857); // Deep emerald
  static const Color lightGreen = Color(0xFFD1FAE5); // Light green tint
  static const Color shadowColor = Color(0x1A000000);
  
  // Budget-specific colors
  static const Color savingsGreen = Color(0xFF10B981); // Smart Saver
  static const Color spendingRed = Color(0xFFEF4444); // Overbudget
  static const Color impulseBlue = Color(0xFF3B82F6); // Impulse Switcher  
  static const Color dealGold = Color(0xFFF59E0B); // Deal Hunter

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
  String? _budgetResult;
  String? _budgetDescription;
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
      _generateAIBudgetQuestions();
    } catch (e) {
      print('Failed to load user data: $e');
      // Fallback to default
      setState(() {
        _currentUser = 'Guest';
        _currentUserId = 'guest_user';
      });
      _generateAIBudgetQuestions();
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

  // AI Budget Question Generation
  Future<void> _generateAIBudgetQuestions() async {
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
                  '''You are FitOutfit's AI budget fashion advisor for user "$_currentUser". Generate exactly 6 unique, personalized budget behavior quiz questions for mobile app. 
              Current context: $dayOfWeek morning ($timeOfDay UTC), late June 2025.
              User: $_currentUser
              
              Make questions fresh, engaging, and different each time. Address the user by name occasionally. 
              
              Generate ALL 6 questions covering:
              1. Budget mindset & spending philosophy
              2. Shopping frequency & habits  
              3. Response to sales & discounts
              4. Value perception & priorities
              5. Brand vs thrift preferences
              6. Financial planning for fashion
              
              Return ONLY valid JSON with exactly 6 questions:
              {
                "questions": [
                  {
                    "id": 1,
                    "category": "Budget Mindset",
                    "question": "When shopping for clothes, what drives your decisions, $_currentUser?",
                    "subtitle": "Your money mindset",
                    "icon": "psychology_outlined",
                    "options": [
                      {"text": "Value for Money", "subtitle": "Quality that lasts", "value": "quality_investment", "icon": "star_outline", "color": "primaryGreen"},
                      {"text": "Latest Trends", "subtitle": "Must-have styles", "value": "latest_trends", "icon": "trending_up_outlined", "color": "accentOrange"},
                      {"text": "Great Deals", "subtitle": "Sales & discounts", "value": "sales_only", "icon": "local_offer_outlined", "color": "dealGold"},
                      {"text": "Mood & Feelings", "subtitle": "Depends how I feel", "value": "mood_dependent", "icon": "mood_outlined", "color": "impulseBlue"}
                    ]
                  },
                  {
                    "id": 2,
                    "category": "Color Vibes",
                    "question": "What colors make you feel most confident, $_currentUser?",
                    "subtitle": "Your power palette",
                    "icon": "palette_outlined",
                    "options": [
                      {"text": "Deep & Rich", "subtitle": "Burgundy, navy, emerald", "value": "deep", "icon": "circle_outlined", "color": "deepGreen"},
                      {"text": "Soft & Neutral", "subtitle": "Beige, cream, blush", "value": "neutral", "icon": "circle_outlined", "color": "mediumGray"},
                      {"text": "Bright & Bold", "subtitle": "Coral, electric blue, fuchsia", "value": "bright", "icon": "flash_on_outlined", "color": "accentOrange"},
                      {"text": "Earth & Natural", "subtitle": "Olive, rust, camel", "value": "earth", "icon": "nature_people_outlined", "color": "accentBeige"}
                    ]
                  },
                  {
                    "id": 3,
                    "category": "Lifestyle Match",
                    "question": "What best describes your daily routine?",
                    "subtitle": "Fashion meets function",
                    "icon": "directions_run_outlined",
                    "options": [
                      {"text": "Always On-The-Go", "subtitle": "Active & dynamic", "value": "active", "icon": "directions_run_outlined", "color": "accentOrange"},
                      {"text": "Work-Focused", "subtitle": "Professional first", "value": "professional", "icon": "business_center_outlined", "color": "primaryGreen"},
                      {"text": "Creative & Flexible", "subtitle": "Artistic projects", "value": "creative", "icon": "palette_outlined", "color": "accentPurple"},
                      {"text": "Balanced Living", "subtitle": "Mix of everything", "value": "balanced", "icon": "spa_outlined", "color": "accentBeige"}
                    ]
                  },
                  {
                    "id": 4,
                    "category": "Comfort Zone",
                    "question": "How do you prefer your clothes to fit?",
                    "subtitle": "Your comfort priority",
                    "icon": "checkroom_outlined",
                    "options": [
                      {"text": "Perfectly Tailored", "subtitle": "Sharp & structured", "value": "tailored", "icon": "straighten_outlined", "color": "primaryGreen"},
                      {"text": "Relaxed & Flowy", "subtitle": "Comfortable ease", "value": "relaxed", "icon": "air_outlined", "color": "accentBeige"},
                      {"text": "Figure-Hugging", "subtitle": "Show your silhouette", "value": "fitted", "icon": "fitness_center_outlined", "color": "accentOrange"},
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
                      {"text": "Quality Investment", "subtitle": "Fewer, better pieces", "value": "quality", "icon": "diamond_outlined", "color": "deepGreen"},
                      {"text": "Trendy Updates", "subtitle": "Latest styles regularly", "value": "trendy", "icon": "trending_up_outlined", "color": "accentOrange"},
                      {"text": "Vintage & Unique", "subtitle": "One-of-a-kind finds", "value": "vintage", "icon": "auto_awesome_outlined", "color": "accentPurple"},
                      {"text": "Practical Basics", "subtitle": "Versatile essentials", "value": "practical", "icon": "checkroom_outlined", "color": "primaryGreen"}
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
                      {"text": "Street Style", "subtitle": "Real people, real looks", "value": "street", "icon": "directions_walk_outlined", "color": "primaryGreen"},
                      {"text": "Fashion Icons", "subtitle": "Celebrities & influencers", "value": "icons", "icon": "star_outline", "color": "accentBeige"},
                      {"text": "My Own Creativity", "subtitle": "Original style", "value": "creative", "icon": "psychology_outlined", "color": "accentOrange"}
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
      case 'primaryGreen':
        return primaryGreen;
      case 'accentBeige':
        return accentBeige;
      case 'accentOrange':
        return accentOrange;
      case 'accentPurple':
        return accentPurple;
      case 'deepGreen':
        return deepGreen;
      case 'mediumGray':
        return mediumGray;
      default:
        return primaryGreen;
    }
  }

  Future<void> _generateContextualFallback() async {
    _getCurrentDateTime();
    final prefs = await SharedPreferences.getInstance();
    final previousQuizCount = prefs.getInt('quiz_count') ?? 0;

    List<Map<String, dynamic>> contextualQuestions = [
      _getBudgetMindsetQuestion(),
      _getShoppingHabitsQuestion(), 
      _getSpendingTriggersQuestion(),
      _getValuePerceptionQuestion(),
      _getDealSeekingQuestion(),
      _getBudgetPlanningQuestion(),
    ];

    setState(() {
      _questions = contextualQuestions;
      _isGeneratingQuestions = false;
    });

    await prefs.setInt('quiz_count', previousQuizCount + 1);
    _startQuiz();
  }

  Map<String, dynamic> _getBudgetMindsetQuestion() {
    return {
      'id': 1,
      'category': 'Budget Mindset',
      'question': 'When shopping for clothes, what drives your decisions, $_currentUser?',
      'subtitle': 'Your money mindset',
      'icon': Icons.psychology_outlined,
      'options': [
        {
          'text': 'Value for Money',
          'subtitle': 'Quality that lasts',
          'value': 'quality_investment',
          'icon': Icons.star_outline,
          'color': savingsGreen,
        },
        {
          'text': 'Latest Trends',
          'subtitle': 'Must-have styles',
          'value': 'latest_trends',
          'icon': Icons.trending_up_outlined,
          'color': spendingRed,
        },
        {
          'text': 'Great Deals',
          'subtitle': 'Sales & discounts',
          'value': 'sales_only',
          'icon': Icons.local_offer_outlined,
          'color': dealGold,
        },
        {
          'text': 'Mood & Feelings',
          'subtitle': 'Depends how I feel',
          'value': 'mood_dependent',
          'icon': Icons.mood_outlined,
          'color': impulseBlue,
        },
      ],
    };
  }

  Map<String, dynamic> _getShoppingHabitsQuestion() {
    return {
      'id': 2,
      'category': 'Shopping Habits',
      'question': 'How often do you typically buy new clothes?',
      'subtitle': 'Frequency patterns',
      'icon': Icons.shopping_bag_outlined,
      'options': [
        {
          'text': 'Monthly or Less',
          'subtitle': 'Planned purchases',
          'value': 'plan_purchases',
          'icon': Icons.schedule_outlined,
          'color': savingsGreen,
        },
        {
          'text': 'Weekly Shopping',
          'subtitle': 'Regular updates',
          'value': 'frequent_shopping',
          'icon': Icons.repeat_outlined,
          'color': spendingRed,
        },
        {
          'text': 'Only During Sales',
          'subtitle': 'Strategic timing',
          'value': 'sales_only',
          'icon': Icons.access_time_outlined,
          'color': dealGold,
        },
        {
          'text': 'When I Feel Like It',
          'subtitle': 'Spontaneous buys',
          'value': 'impulse_buyer',
          'icon': Icons.flash_on_outlined,
          'color': impulseBlue,
        },
      ],
    };
  }

  Map<String, dynamic> _getSpendingTriggersQuestion() {
    return {
      'id': 3,
      'category': 'Spending Triggers',
      'question': 'What usually makes you buy clothes, $_currentUser?',
      'subtitle': 'Your purchase motivators',
      'icon': Icons.psychology_outlined,
      'options': [
        {
          'text': 'Need Something Specific',
          'subtitle': 'Gap in wardrobe',
          'value': 'budget_conscious',
          'icon': Icons.checklist_outlined,
          'color': savingsGreen,
        },
        {
          'text': 'See Something I Love',
          'subtitle': 'Instant attraction',
          'value': 'impulse_buyer',
          'icon': Icons.favorite_outlined,
          'color': spendingRed,
        },
        {
          'text': 'Amazing Deal/Sale',
          'subtitle': 'Can\'t miss opportunity',
          'value': 'discount_finder',
          'icon': Icons.local_offer_outlined,
          'color': dealGold,
        },
        {
          'text': 'Feeling Down/Celebrating',
          'subtitle': 'Emotional purchases',
          'value': 'mood_dependent',
          'icon': Icons.sentiment_satisfied_outlined,
          'color': impulseBlue,
        },
      ],
    };
  }

  Map<String, dynamic> _getValuePerceptionQuestion() {
    return {
      'id': 4,
      'category': 'Value Perception',
      'question': 'What defines \'worth it\' when buying clothes?',
      'subtitle': 'Your value definition',
      'icon': Icons.balance_outlined,
      'options': [
        {
          'text': 'Cost Per Wear',
          'subtitle': 'Price ÷ times worn',
          'value': 'practical',
          'icon': Icons.calculate_outlined,
          'color': savingsGreen,
        },
        {
          'text': 'How It Makes Me Feel',
          'subtitle': 'Confidence boost',
          'value': 'expensive_taste',
          'icon': Icons.favorite_outlined,
          'color': spendingRed,
        },
        {
          'text': 'Percentage Saved',
          'subtitle': 'Original vs sale price',
          'value': 'bargain_lover',
          'icon': Icons.trending_down_outlined,
          'color': dealGold,
        },
        {
          'text': 'Depends on the Item',
          'subtitle': 'Situational value',
          'value': 'mixed_shopping',
          'icon': Icons.shuffle_outlined,
          'color': impulseBlue,
        },
      ],
    };
  }

  Map<String, dynamic> _getDealSeekingQuestion() {
    return {
      'id': 5,
      'category': 'Deal Seeking',
      'question': 'How do you approach sales and discounts?',
      'subtitle': 'Your bargain hunting style',
      'icon': Icons.local_offer_outlined,
      'options': [
        {
          'text': 'Plan Around Sales',
          'subtitle': 'Wait for right timing',
          'value': 'save_money',
          'icon': Icons.event_outlined,
          'color': savingsGreen,
        },
        {
          'text': 'Buy When I Want It',
          'subtitle': 'Price doesn\'t matter',
          'value': 'brand_lover',
          'icon': Icons.shopping_cart_outlined,
          'color': spendingRed,
        },
        {
          'text': 'Never Buy Full Price',
          'subtitle': 'Sale hunter mentality',
          'value': 'coupon_hunter',
          'icon': Icons.search_outlined,
          'color': dealGold,
        },
        {
          'text': 'Sometimes Both',
          'subtitle': 'Depends on the item',
          'value': 'sometimes_splurge',
          'icon': Icons.balance_outlined,
          'color': impulseBlue,
        },
      ],
    };
  }

  Map<String, dynamic> _getBudgetPlanningQuestion() {
    return {
      'id': 6,
      'category': 'Budget Planning',
      'question': 'How do you manage your fashion budget?',
      'subtitle': 'Financial fashion planning',
      'icon': Icons.account_balance_wallet_outlined,
      'options': [
        {
          'text': 'Set Monthly Limit',
          'subtitle': 'Strict budget tracking',
          'value': 'budget_conscious',
          'icon': Icons.timeline_outlined,
          'color': savingsGreen,
        },
        {
          'text': 'No Set Budget',
          'subtitle': 'Buy what I want',
          'value': 'frequent_shopping',
          'icon': Icons.all_inclusive_outlined,
          'color': spendingRed,
        },
        {
          'text': 'Only Buy on Sale',
          'subtitle': 'Discount-driven',
          'value': 'promotional',
          'icon': Icons.percent_outlined,
          'color': dealGold,
        },
        {
          'text': 'Varies Each Month',
          'subtitle': 'Flexible approach',
          'value': 'balanced',
          'icon': Icons.trending_flat_outlined,
          'color': impulseBlue,
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
      final aiResult = await _getAIBudgetAnalysis();

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _budgetResult = aiResult['style'] ?? 'Unique Budget Personality';
        _budgetDescription =
            aiResult['description'] ??
            'Your budget approach is uniquely yours and perfectly reflects your financial style!';
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

  Future<Map<String, dynamic>> _getAIBudgetAnalysis() async {
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
                '''You are FitOutfit's AI budget fashion advisor analyzing $_currentUser's budget behavior quiz results from Sunday morning, June 29, 2025 at $timeOfDay UTC.
            
            Create a personalized budget personality profile for $_currentUser that feels authentic and actionable. Consider:
            - Current economic trends (late 2025)
            - Early Sunday morning context ($timeOfDay)
            - Personal financial wellness for $_currentUser
            - Practical money-saving fashion advice
            
            Return ONLY valid JSON:
            {
              "style": "Personalized Budget Type (like 'Smart Saver' or 'Deal Hunter')",
              "description": "Warm, personal description of $_currentUser's unique budget approach (2-3 sentences that feel genuine)",
              "tips": [
                "Specific, actionable budget tip 1 for $_currentUser",
                "Specific, actionable budget tip 2 for $_currentUser", 
                "Specific, actionable budget tip 3 for $_currentUser",
                "Specific, actionable budget tip 4 for $_currentUser",
                "Specific, actionable budget tip 5 for $_currentUser"
              ]
            }''',
          },
          {
            'role': 'user',
            'content':
                'Analyze $_currentUser\'s Sunday morning budget fashion quiz answers for personalized results: $answersText',
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

    Map<String, int> budgetScores = {
      'smart_saver': 0,      // 🧾 Smart Saver - frugal & thoughtful
      'overbudget': 0,       // 💳 Overbudget Fashionista - stylish but wasteful
      'impulse_switcher': 0, // 🔄 Impulse Switcher - sometimes frugal, sometimes splurging
      'deal_hunter': 0,      // 📦 Deal Hunter - always looking for promotions & discounts
    };

    // Enhanced budget behavior scoring algorithm
    for (String answer in answers) {
      switch (answer) {
        // Budget-conscious answers → Smart Saver
        case 'budget_conscious':
        case 'thrift_shopping':
        case 'plan_purchases':
        case 'quality_investment':
        case 'save_money':
          budgetScores['smart_saver'] = budgetScores['smart_saver']! + 3;
          break;
        // Impulse/mixed behavior → Impulse Switcher  
        case 'sometimes_splurge':
        case 'balanced':
        case 'mood_dependent':
        case 'mixed_shopping':
          budgetScores['impulse_switcher'] = budgetScores['impulse_switcher']! + 3;
          break;
        // Deal-focused answers → Deal Hunter
        case 'sales_only':
        case 'coupon_hunter':
        case 'discount_finder':
        case 'promotional':
        case 'bargain_lover':
          budgetScores['deal_hunter'] = budgetScores['deal_hunter']! + 3;
          break;
        // High spending/trend-focused → Overbudget Fashionista
        case 'latest_trends':
        case 'brand_lover':
        case 'frequent_shopping':
        case 'expensive_taste':
        case 'impulse_buyer':
          budgetScores['overbudget'] = budgetScores['overbudget']! + 3;
          break;
        // Default scoring based on typical answers
        case 'effortless':
        case 'practical':
          budgetScores['smart_saver'] = budgetScores['smart_saver']! + 2;
          break;
        case 'trendy':
        case 'bold':
          budgetScores['overbudget'] = budgetScores['overbudget']! + 2;
          break;
      }
    }

    String topBudgetType =
        budgetScores.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    final profiles = _getBudgetPersonalityProfiles();
    final profile = profiles[topBudgetType] ?? profiles['smart_saver']!;

    return {
      'style': profile['title'],
      'description': profile['description'],
      'tips': profile['tips'],
      'profile': profile,

    return {
      'style': profile['title'],
      'description': profile['description'],
      'tips': profile['tips'],
      'profile': profile,
    };
  }

  Map<String, Map<String, dynamic>> _getBudgetPersonalityProfiles() {
    return {
      'smart_saver': {
        'title': '🧾 Smart Saver',
        'description':
            'You are a thoughtful spender, $_currentUser! You make intentional fashion choices that align with your financial goals. Your approach to style is strategic - you invest in quality pieces that offer long-term value and versatility.',
        'tips': [
          'Build a capsule wardrobe with 20-30 versatile pieces that mix and match',
          'Invest in quality basics that last - better to buy one good piece than three cheap ones',
          'Shop your closet first before buying anything new',
          'Use the cost-per-wear calculation: divide price by expected wears',
          'Set a monthly fashion budget and stick to it using apps or spreadsheets',
        ],
      },
      'overbudget': {
        'title': '💳 Overbudget Fashionista',
        'description':
            'Style is your passion, $_currentUser! You love staying on-trend and looking amazing, but sometimes your fashion desires outpace your budget. Your eye for style is impeccable - now let\'s align it with smarter spending.',
        'tips': [
          'Set up automatic savings for fashion purchases to avoid credit card debt',
          'Use the 24-hour rule: wait a day before buying anything over \$50',
          'Follow fashion bloggers who focus on affordable styling',
          'Rent special occasion pieces instead of buying them',
          'Create outfit photos to remind yourself of what you already own',
        ],
      },
      'impulse_switcher': {
        'title': '🔄 Impulse Switcher',
        'description':
            'Your fashion spending is like the weather, $_currentUser - sometimes sunny savings, sometimes stormy splurges! You have great taste but your spending patterns vary with your mood and circumstances.',
        'tips': [
          'Track your spending patterns to identify your splurge triggers',
          'Create a wish list and review it monthly instead of buying immediately',
          'Shop with a specific list and budget to stay focused',
          'Find alternative outlets for fashion excitement - try styling challenges',
          'Set up automatic transfers to a fashion fund during your saving moods',
        ],
      },
      'deal_hunter': {
        'title': '📦 Deal Hunter',
        'description':
            'You are the master of finding fashion bargains, $_currentUser! Your skills at sniffing out sales, coupons, and discounts are legendary. You know that looking great doesn\'t require breaking the bank.',
        'tips': [
          'Use price tracking apps to monitor when items go on sale',
          'Follow your favorite brands on social media for flash sale notifications',
          'Shop end-of-season clearances for next year\'s wardrobe',
          'Join loyalty programs and cashback apps for extra savings',
          'But remember: it\'s only a deal if you actually need and will wear it!',
        ],
      },
    };
  }

  List<String> _generateFallbackTips() {
    return [
      'Focus on cost-per-wear - well-bought clothes offer better value long-term',
      'Build around budget-friendly pieces that make you feel confident',
      'Use accessories to change up your looks without buying new clothes',
      'Invest in quality basics during sales that work with multiple outfits',
      'Don\'t be afraid to express your personality through budget-conscious choices',
    ];
  }

  Future<void> _saveQuizResult(Map<String, dynamic> result) async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = DateTime.now().toIso8601String();

    await prefs.setString(
      'last_budget_result',
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
        backgroundColor: primaryGreen,
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
                'Creating $_budgetResult outfits for $_currentUser...',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: primaryGreen,
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
            colors: [softCream, lightGreen.withOpacity(0.2), softCream],
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
                          primaryGreen.withOpacity(0.2),
                          accentPurple.withOpacity(0.2),
                          accentBeige.withOpacity(0.2),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryGreen.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.psychology_outlined,
                      color: primaryGreen,
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
                      colors: [primaryGreen, accentBeige, primaryGreen],
                      stops: [
                        _shimmerAnimation.value - 0.3,
                        _shimmerAnimation.value,
                        _shimmerAnimation.value + 0.3,
                      ],
                    ).createShader(bounds);
                  },
                  child: Text(
                    'AI is Crafting Your Budget Quiz...',
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
              'Creating personalized budget questions just for $_currentUser',
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
                          color: primaryGreen,
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
                          colors: [primaryGreen, accentPurple],
                        ).createShader(bounds),
                    child: Row(
                      children: [
                        Text(
                          'AI Budget Fashion Quiz',
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 16 : 20,
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
                                colors: [accentBeige, accentOrange],
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
                              ? [accentBeige, accentOrange]
                              : [primaryGreen, accentPurple],
                    ),
                    borderRadius: BorderRadius.circular(
                      isSmallScreen ? 14 : 16,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryGreen.withOpacity(0.3),
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
                        color: primaryGreen,
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
                  gradient: LinearGradient(colors: [primaryGreen, accentPurple]),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryGreen.withOpacity(0.3),
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
                    valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
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
                            primaryGreen.withOpacity(0.1),
                            accentBeige.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          isSmallScreen ? 14 : 16,
                        ),
                        border: Border.all(
                          color: primaryGreen.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        question['icon'],
                        size: isSmallScreen ? 20 : 24,
                        color: primaryGreen,
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
                                  color: primaryGreen,
                                ),
                              ),
                              SizedBox(width: 6),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: accentBeige.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'AI',
                                  style: GoogleFonts.poppins(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    color: accentBeige,
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
                    foregroundColor: primaryGreen,
                    side: BorderSide(color: primaryGreen, width: 1.5),
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
                        ? LinearGradient(colors: [primaryGreen, accentPurple])
                        : null,
                color: hasAnswer ? null : mediumGray.withOpacity(0.3),
                boxShadow:
                    hasAnswer
                        ? [
                          BoxShadow(
                            color: primaryGreen.withOpacity(0.3),
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
                  color: primaryGreen.withOpacity(0.3),
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
                    colors: [primaryGreen, accentPurple],
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
                      _budgetResult ?? 'Sunday Style Icon',
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
                        _budgetDescription ??
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
                        accentBeige.withOpacity(0.2),
                        accentBeige.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                      isSmallScreen ? 10 : 12,
                    ),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline_rounded,
                    color: accentBeige,
                    size: isSmallScreen ? 20 : 24,
                  ),
                ),
                SizedBox(width: screenSize.width * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Budget Tips',
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
              gradient: LinearGradient(colors: [primaryGreen, accentPurple]),
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
                color: lightGreen.withOpacity(0.3),
                borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
                border: Border.all(
                  color: primaryGreen.withOpacity(0.1),
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
            gradient: LinearGradient(colors: [primaryGreen, accentPurple]),
            borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 22),
            boxShadow: [
              BoxShadow(
                color: primaryGreen.withOpacity(0.4),
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
                    foregroundColor: primaryGreen,
                    side: BorderSide(color: primaryGreen, width: 1.5),
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
                'Sharing $_currentUser\'s $_budgetResult profile...',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: accentBeige,
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
      _budgetResult = null;
      _budgetDescription = null;
      _personalizedTips.clear();
      _isGeneratingQuestions = true;
    });

    _generateUniqueSession();
    _generateAIBudgetQuestions();

    _slideController.reset();
    _scaleController.reset();
  }
}
