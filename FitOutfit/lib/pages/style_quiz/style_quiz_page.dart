import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/home_page.dart';

class StyleQuizPage extends StatefulWidget {
  const StyleQuizPage({super.key});

  @override
  State<StyleQuizPage> createState() => _StyleQuizPageState();
}

class _StyleQuizPageState extends State<StyleQuizPage>
    with TickerProviderStateMixin {
  // Colors consistent with your app
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color accentPurple = Color(0xFF7B68EE);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color softCream = Color(0xFFFAF9F7);

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentQuestion = 0;
  final Map<int, String> _answers = {}; // Changed to final
  bool _isLoading = false;
  bool _showResult = false;
  String? _styleResult;

  // API Questions - akan diganti dengan API call
  final List<Map<String, dynamic>> _questions = [
    {
      'id': 1,
      'question': 'What\'s your preferred style aesthetic?',
      'options': [
        {'text': 'Minimalist & Clean', 'value': 'minimalist'},
        {'text': 'Bohemian & Free-spirited', 'value': 'bohemian'},
        {'text': 'Classic & Timeless', 'value': 'classic'},
        {'text': 'Trendy & Fashion-forward', 'value': 'trendy'},
      ]
    },
    {
      'id': 2,
      'question': 'Which colors do you gravitate towards?',
      'options': [
        {'text': 'Neutral tones (Black, White, Beige)', 'value': 'neutral'},
        {'text': 'Earth tones (Brown, Green, Orange)', 'value': 'earth'},
        {'text': 'Bold colors (Red, Blue, Yellow)', 'value': 'bold'},
        {'text': 'Pastels (Pink, Lavender, Mint)', 'value': 'pastel'},
      ]
    },
    {
      'id': 3,
      'question': 'What\'s your ideal weekend outfit?',
      'options': [
        {'text': 'Comfy jeans & oversized sweater', 'value': 'casual'},
        {'text': 'Flowy dress & denim jacket', 'value': 'romantic'},
        {'text': 'Tailored pants & crisp shirt', 'value': 'polished'},
        {'text': 'Statement pieces & bold accessories', 'value': 'edgy'},
      ]
    },
    {
      'id': 4,
      'question': 'How do you prefer your clothes to fit?',
      'options': [
        {'text': 'Relaxed & comfortable', 'value': 'relaxed'},
        {'text': 'Fitted & structured', 'value': 'fitted'},
        {'text': 'Flowy & loose', 'value': 'flowy'},
        {'text': 'Mix of fitted & loose pieces', 'value': 'mixed'},
      ]
    },
    {
      'id': 5,
      'question': 'What\'s your approach to accessories?',
      'options': [
        {'text': 'Less is more - minimal jewelry', 'value': 'minimal'},
        {'text': 'Statement pieces that stand out', 'value': 'statement'},
        {'text': 'Layered & eclectic mix', 'value': 'layered'},
        {'text': 'Classic pieces like watches & pearls', 'value': 'classic_acc'},
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadQuestions(); // Future API integration
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _loadQuestions() async {
    // TODO: Replace with actual API call
    // try {
    //   final response = await http.get(
    //     Uri.parse('YOUR_API_ENDPOINT/style-quiz-questions'),
    //     headers: {'Content-Type': 'application/json'},
    //   );
    //   if (response.statusCode == 200) {
    //     final data = json.decode(response.body);
    //     setState(() {
    //       _questions = data['questions'];
    //     });
    //   }
    // } catch (e) {
    //   print('Error loading questions: $e');
    // }
  }

  Future<void> _submitAnswers() async {
    setState(() => _isLoading = true);

    // TODO: Replace with actual API call
    try {
      // final response = await http.post(
      //   Uri.parse('YOUR_API_ENDPOINT/analyze-style'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode({'answers': _answers}),
      // );
      
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock result based on answers
      String result = _generateMockResult();
      
      setState(() {
        _styleResult = result;
        _showResult = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to analyze your style. Please try again.');
    }
  }

  String _generateMockResult() {
    // Simple logic to generate result based on answers
    final answers = _answers.values.toList();
    if (answers.contains('minimalist') || answers.contains('neutral')) {
      return 'Minimalist Chic';
    } else if (answers.contains('bohemian') || answers.contains('earth')) {
      return 'Bohemian Spirit';
    } else if (answers.contains('classic') || answers.contains('classic_acc')) {
      return 'Timeless Classic';
    } else {
      return 'Modern Trendsetter';
    }
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() => _currentQuestion++);
      _slideController.reset();
      _slideController.forward();
    } else {
      _submitAnswers();
    }
  }

  void _previousQuestion() {
    if (_currentQuestion > 0) {
      setState(() => _currentQuestion--);
      _slideController.reset();
      _slideController.forward();
    }
  }

  void _selectAnswer(String value) {
    setState(() {
      _answers[_questions[_currentQuestion]['id']] = value;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: accentRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _navigateToOutfitPlanner() {
    // Navigasi ke halaman yang sudah ada di app kamu atau placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigate to Outfit Planner with style: $_styleResult'),
        backgroundColor: primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softCream,
      appBar: _buildAppBar(),
      body: _showResult ? _buildResultView() : _buildQuizView(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        child: Material(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.black,
              size: 20,
            ),
          ),
        ),
      ),
      title: Text(
        'Style Quiz',
        style: GoogleFonts.poppins(
          color: darkGray,
          fontWeight: FontWeight.w800,
          fontSize: 22,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildQuizView() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildProgressBar(),
          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildQuestionCard(),
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    double progress = (_currentQuestion + 1) / _questions.length;
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestion + 1}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: mediumGray,
                ),
              ),
              Text(
                '${_currentQuestion + 1}/${_questions.length}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: lightGray,
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    final question = _questions[_currentQuestion];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryBlue.withOpacity(0.1), accentYellow.withOpacity(0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.psychology_rounded,
                  size: 32,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                question['question'],
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: darkGray,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              ...question['options'].map<Widget>((option) => _buildOptionCard(option)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(Map<String, dynamic> option) {
    bool isSelected = _answers[_questions[_currentQuestion]['id']] == option['value'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _selectAnswer(option['value']),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? primaryBlue.withOpacity(0.1) : lightGray,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? primaryBlue : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? primaryBlue : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? primaryBlue : mediumGray,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option['text'],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? primaryBlue : darkGray,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    bool hasAnswer = _answers.containsKey(_questions[_currentQuestion]['id']);
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentQuestion > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _previousQuestion,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primaryBlue),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Previous',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: primaryBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: _currentQuestion == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: hasAnswer ? _nextQuestion : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: hasAnswer ? primaryBlue : mediumGray,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: hasAnswer ? 4 : 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _currentQuestion == _questions.length - 1 ? 'Get My Style' : 'Next',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildResultCard(),
            const SizedBox(height: 24),
            _buildStyleTips(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryBlue, accentPurple],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Your Style Is',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _styleResult ?? 'Modern Trendsetter',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Based on your preferences, we\'ve curated the perfect style profile for you.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyleTips() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentYellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline_rounded,
                    color: accentYellow,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Style Tips for You',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: darkGray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTipItem('Focus on quality basics in neutral colors'),
            _buildTipItem('Add personality with statement accessories'),
            _buildTipItem('Experiment with textures and layering'),
            _buildTipItem('Invest in versatile pieces that mix and match'),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: primaryBlue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: mediumGray,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _navigateToOutfitPlanner,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: Text(
              'Plan My Outfits',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _currentQuestion = 0;
                _answers.clear();
                _showResult = false;
                _styleResult = null;
              });
              _slideController.reset();
              _slideController.forward();
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: mediumGray),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Retake Quiz',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: mediumGray,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
