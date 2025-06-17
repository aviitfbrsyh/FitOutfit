import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/home_page.dart';

class OutfitPlannerPage extends StatefulWidget {
  final String? userStyle;
  
  const OutfitPlannerPage({super.key, this.userStyle});

  @override
  State<OutfitPlannerPage> createState() => _OutfitPlannerPageState();
}

class _OutfitPlannerPageState extends State<OutfitPlannerPage>
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

  // Event categories with icons and colors
  final List<Map<String, dynamic>> _eventCategories = [
    {
      'name': 'Work & Professional',
      'icon': Icons.work_outline_rounded,
      'color': primaryBlue,
      'events': ['Interview', 'Meeting', 'Conference', 'Presentation']
    },
    {
      'name': 'Social & Party',
      'icon': Icons.celebration_outlined,
      'color': accentRed,
      'events': ['Birthday Party', 'Wedding', 'Cocktail Party', 'Dinner Date']
    },
    {
      'name': 'Casual & Daily',
      'icon': Icons.weekend_outlined,
      'color': accentYellow,
      'events': ['Shopping', 'Coffee Date', 'Movie Night', 'Casual Hangout']
    },
    {
      'name': 'Active & Sports',
      'icon': Icons.fitness_center_outlined,
      'color': accentPurple,
      'events': ['Gym', 'Yoga', 'Running', 'Sports Event']
    },
  ];

  String _selectedCategory = '';
  String _selectedEvent = '';
  String _selectedWeather = '';
  DateTime? _selectedDate;
  bool _isLoading = false;
  List<Map<String, dynamic>> _outfitSuggestions = [];

  final List<String> _weatherOptions = [
    'Sunny & Warm',
    'Rainy & Cool', 
    'Cold & Windy',
    'Hot & Humid',
    'Mild & Pleasant',
  ];

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
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _generateOutfitPlan() async {
    if (_selectedCategory.isEmpty || _selectedEvent.isEmpty || _selectedWeather.isEmpty) {
      _showErrorSnackBar('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Replace with actual API call
      // final response = await http.post(
      //   Uri.parse('YOUR_API_ENDPOINT/generate-outfit-plan'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode({
      //     'category': _selectedCategory,
      //     'event': _selectedEvent,
      //     'weather': _selectedWeather,
      //     'date': _selectedDate?.toIso8601String(),
      //     'userStyle': widget.userStyle,
      //   }),
      // );

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock outfit suggestions
      List<Map<String, dynamic>> suggestions = _generateMockOutfits();
      
      setState(() {
        _outfitSuggestions = suggestions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to generate outfit plan. Please try again.');
    }
  }

  List<Map<String, dynamic>> _generateMockOutfits() {
    return [
      {
        'id': 1,
        'name': 'Professional Power Look',
        'description': 'Perfect for making a strong impression',
        'items': ['Navy Blazer', 'White Shirt', 'Dark Jeans', 'Oxford Shoes'],
        'confidence': 95,
        'weather_suitable': true,
        'style_match': widget.userStyle ?? 'Classic',
      },
      {
        'id': 2,
        'name': 'Smart Casual Comfort',
        'description': 'Comfortable yet polished appearance',
        'items': ['Knit Sweater', 'Chino Pants', 'Loafers', 'Watch'],
        'confidence': 88,
        'weather_suitable': true,
        'style_match': widget.userStyle ?? 'Modern',
      },
      {
        'id': 3,
        'name': 'Contemporary Edge',
        'description': 'Modern and trendy outfit choice',
        'items': ['Graphic Tee', 'Bomber Jacket', 'Slim Jeans', 'Sneakers'],
        'confidence': 82,
        'weather_suitable': false,
        'style_match': widget.userStyle ?? 'Trendy',
      },
    ];
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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _outfitSuggestions.isEmpty 
              ? _buildPlannerForm() 
              : _buildOutfitResults(),
        ),
      ),
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
        'Outfit Planner',
        style: GoogleFonts.poppins(
          color: darkGray,
          fontWeight: FontWeight.w800,
          fontSize: 22,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: true,
      actions: [
        if (_outfitSuggestions.isNotEmpty)
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: primaryBlue),
            onPressed: () {
              setState(() {
                _outfitSuggestions.clear();
                _selectedCategory = '';
                _selectedEvent = '';
                _selectedWeather = '';
                _selectedDate = null;
              });
            },
          ),
      ],
    );
  }

  Widget _buildPlannerForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: 32),
          _buildEventCategorySection(),
          const SizedBox(height: 24),
          _buildEventSelector(),
          const SizedBox(height: 24),
          _buildWeatherSelector(),
          const SizedBox(height: 24),
          _buildDateSelector(),
          const SizedBox(height: 40),
          _buildGenerateButton(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryBlue, accentPurple],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.3),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plan Your Perfect Outfit',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'AI-powered styling for any occasion',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.userStyle != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: accentYellow,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Your Style: ${widget.userStyle}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Widget _buildEventCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Event Category',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: darkGray,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: _eventCategories.length,
          itemBuilder: (context, index) {
            final category = _eventCategories[index];
            bool isSelected = _selectedCategory == category['name'];
            
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = category['name'];
                  _selectedEvent = ''; // Reset event selection
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [category['color'], category['color'].withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? category['color'] : lightGray,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: category['color'].withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category['icon'],
                      size: 32,
                      color: isSelected ? Colors.white : category['color'],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      category['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : darkGray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEventSelector() {
    if (_selectedCategory.isEmpty) return const SizedBox.shrink();
    
    final selectedCategoryData = _eventCategories.firstWhere(
      (cat) => cat['name'] == _selectedCategory,
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Specific Event',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: darkGray,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selectedCategoryData['events'].map<Widget>((event) {
            bool isSelected = _selectedEvent == event;
            
            return InkWell(
              onTap: () => setState(() => _selectedEvent = event),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? selectedCategoryData['color'] : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selectedCategoryData['color'],
                    width: 1,
                  ),
                ),
                child: Text(
                  event,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : selectedCategoryData['color'],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWeatherSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expected Weather',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: darkGray,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: lightGray),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedWeather.isEmpty ? null : _selectedWeather,
              hint: Text(
                'Select weather condition',
                style: GoogleFonts.poppins(
                  color: mediumGray,
                  fontSize: 16,
                ),
              ),
              icon: Icon(Icons.keyboard_arrow_down, color: primaryBlue),
              items: _weatherOptions.map((weather) {
                return DropdownMenuItem(
                  value: weather,
                  child: Row(
                    children: [
                      Icon(
                        _getWeatherIcon(weather),
                        color: primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        weather,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: darkGray,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedWeather = value ?? '');
              },
            ),
          ),
        ),
      ],
    );
  }

  IconData _getWeatherIcon(String weather) {
    switch (weather) {
      case 'Sunny & Warm':
        return Icons.wb_sunny_outlined;
      case 'Rainy & Cool':
        return Icons.cloud_outlined;
      case 'Cold & Windy':
        return Icons.ac_unit_outlined;
      case 'Hot & Humid':
        return Icons.whatshot_outlined;
      default:
        return Icons.wb_cloudy_outlined;
    }
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Date (Optional)',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: darkGray,
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: primaryBlue,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              setState(() => _selectedDate = date);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: lightGray),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: primaryBlue),
                const SizedBox(width: 12),
                Text(
                  _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'Select date',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: _selectedDate != null ? darkGray : mediumGray,
                  ),
                ),
                const Spacer(),
                Icon(Icons.keyboard_arrow_down, color: mediumGray),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    bool canGenerate = _selectedCategory.isNotEmpty && 
                      _selectedEvent.isNotEmpty && 
                      _selectedWeather.isNotEmpty;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canGenerate ? _generateOutfitPlan : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canGenerate ? primaryBlue : mediumGray,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: canGenerate ? 4 : 0,
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
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Generate Outfit Plan',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildOutfitResults() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResultsHeader(),
          const SizedBox(height: 24),
          ..._outfitSuggestions.map((outfit) => _buildOutfitCard(outfit)).toList(),
          const SizedBox(height: 32),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentYellow, accentYellow.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                'Outfit Plan Ready!',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Event: $_selectedEvent • Weather: $_selectedWeather',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitCard(Map<String, dynamic> outfit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                          outfit['name'],
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: darkGray,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          outfit['description'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${outfit['confidence']}% Match',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Outfit Items:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: darkGray,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: outfit['items'].map<Widget>((item) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: lightGray,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      item,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: mediumGray,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    outfit['weather_suitable'] ? Icons.check_circle : Icons.info,
                    color: outfit['weather_suitable'] ? Colors.green : accentYellow,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    outfit['weather_suitable'] 
                        ? 'Perfect for selected weather'
                        : 'Consider weather adjustments',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: mediumGray,
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Save outfit plan or navigate to wardrobe
              _showSuccessSnackBar('Outfit plan saved to your wardrobe!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bookmark_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Save Outfit Plan',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _outfitSuggestions.clear();
                _selectedCategory = '';
                _selectedEvent = '';
                _selectedWeather = '';
                _selectedDate = null;
              });
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: mediumGray),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Plan Another Outfit',
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
