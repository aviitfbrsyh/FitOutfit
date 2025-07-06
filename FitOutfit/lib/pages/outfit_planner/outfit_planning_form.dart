import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'outfit_planner_page.dart';
import '../../models/wardrobe_item.dart';

class OutfitPlanningForm extends StatefulWidget {
  final DateTime selectedDate;
  final OutfitEvent? editingEvent;

  const OutfitPlanningForm({
    super.key,
    required this.selectedDate,
    this.editingEvent,
  });

  @override
  State<OutfitPlanningForm> createState() => _OutfitPlanningFormState();
}

class _OutfitPlanningFormState extends State<OutfitPlanningForm> {
  // FitOutfit brand colors
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color softCream = Color(0xFFFAF9F7);

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _outfitNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedOccasion = '';
  String _selectedWeather = '';
  List<String> _selectedClothingItems = [];
  List<WardrobeItem> _selectedWardrobeItems = [];

  final List<String> _occasions = [
    'Work Meeting',
    'Date Night',
    'Casual Outing',
    'Party',
    'Wedding',
    'Exercise',
    'Travel',
    'Other',
  ];

  final List<String> _weatherOptions = [
    'Sunny',
    'Rainy',
    'Cloudy',
    'Cold',
    'Hot',
    'Windy',
  ];

  final List<String> _clothingItems = [
    'Blouse',
    'T-Shirt',
    'Jeans',
    'Dress',
    'Jacket',
    'Shoes',
    'Accessories',
    'Bag',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editingEvent != null) {
      _titleController.text = widget.editingEvent!.title;
      _outfitNameController.text = widget.editingEvent!.outfitName;
      _emailController.text = widget.editingEvent!.reminderEmail;
      _notesController.text = widget.editingEvent!.notes ?? '';
      
      // Initialize selected wardrobe items if editing
      if (widget.editingEvent!.wardrobeItems != null) {
        _selectedWardrobeItems = List.from(widget.editingEvent!.wardrobeItems!);
        // Also populate clothing items for the UI
        _selectedClothingItems = _selectedWardrobeItems
            .map((item) => item.name)
            .where((name) => _clothingItems.contains(name))
            .toList();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _outfitNameController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softCream,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: Text(
          widget.editingEvent != null ? 'Edit Outfit Plan' : 'Plan New Outfit',
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
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryBlue.withValues(alpha: 0.1),
                        accentYellow.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primaryBlue.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, color: primaryBlue),
                      const SizedBox(width: 12),
                      Text(
                        'Planning for ${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Event Title
                _buildTextField(
                  controller: _titleController,
                  label: 'Event Title',
                  hint: 'e.g., Work Meeting, Date Night',
                  icon: Icons.event_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an event title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Outfit Name
                _buildTextField(
                  controller: _outfitNameController,
                  label: 'Outfit Name',
                  hint: 'e.g., Professional Chic, Casual Cool',
                  icon: Icons.checkroom_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an outfit name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Occasion Selection
                _buildSectionTitle('Occasion'),
                const SizedBox(height: 8),
                _buildChipSelection(
                  items: _occasions,
                  selectedItem: _selectedOccasion,
                  onSelected: (value) => setState(() => _selectedOccasion = value),
                  color: primaryBlue,
                ),
                const SizedBox(height: 16),

                // Weather Selection
                _buildSectionTitle('Weather'),
                const SizedBox(height: 8),
                _buildChipSelection(
                  items: _weatherOptions,
                  selectedItem: _selectedWeather,
                  onSelected: (value) => setState(() => _selectedWeather = value),
                  color: accentYellow,
                ),
                const SizedBox(height: 16),

                // Clothing Items
                _buildSectionTitle('Clothing Items'),
                const SizedBox(height: 8),
                _buildMultiChipSelection(
                  items: _clothingItems,
                  selectedItems: _selectedClothingItems,
                  onSelectionChanged: (items) => setState(() => _selectedClothingItems = items),
                  color: accentRed,
                ),
                const SizedBox(height: 16),

                // Email Reminder
                _buildTextField(
                  controller: _emailController,
                  label: 'Reminder Email',
                  hint: 'your@email.com',
                  icon: Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email address';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Notes
                _buildTextField(
                  controller: _notesController,
                  label: 'Notes (Optional)',
                  hint: 'Additional notes about this outfit...',
                  icon: Icons.note_rounded,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveOutfit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.editingEvent != null
                          ? 'Update Outfit'
                          : 'Save Outfit Plan',
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
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryBlue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: mediumGray.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryBlue, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: darkGray,
      ),
    );
  }

  Widget _buildChipSelection({
    required List<String> items,
    required String selectedItem,
    required Function(String) onSelected,
    required Color color,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = selectedItem == item;
        return GestureDetector(
          onTap: () => onSelected(item),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color : color.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              item,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultiChipSelection({
    required List<String> items,
    required List<String> selectedItems,
    required Function(List<String>) onSelectionChanged,
    required Color color,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = selectedItems.contains(item);
        return GestureDetector(
          onTap: () {
            List<String> newSelection = List.from(selectedItems);
            if (isSelected) {
              newSelection.remove(item);
            } else {
              newSelection.add(item);
            }
            onSelectionChanged(newSelection);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color : color.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              item,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _saveOutfit() {
    if (_formKey.currentState!.validate()) {
      // Convert selected clothing categories to WardrobeItem objects if _selectedWardrobeItems is empty
      List<WardrobeItem>? finalWardrobeItems;
      if (_selectedWardrobeItems.isNotEmpty) {
        finalWardrobeItems = _selectedWardrobeItems;
      } else if (_selectedClothingItems.isNotEmpty) {
        finalWardrobeItems = _convertClothingItemsToWardrobeItems(_selectedClothingItems);
      }
      
      final outfitEvent = OutfitEvent(
        id: widget.editingEvent?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        outfitName: _outfitNameController.text,
        reminderEmail: _emailController.text,
        status: OutfitEventStatus.planned,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        wardrobeItems: finalWardrobeItems,
      );
      
      // Return the outfit event to the previous screen
      Navigator.pop(context, outfitEvent);
    }
  }

  List<WardrobeItem> _convertClothingItemsToWardrobeItems(List<String> clothingItems) {
    return clothingItems.map((item) {
      return WardrobeItem(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}_${item.toLowerCase().replaceAll(' ', '_')}',
        name: item,
        category: _getCategoryForClothingItem(item),
        color: 'Various',
        description: 'Selected $item for outfit',
        tags: [item.toLowerCase()],
        userId: '', // Will be set when properly integrated with user system
        createdAt: DateTime.now(),
      );
    }).toList();
  }

  String _getCategoryForClothingItem(String item) {
    switch (item.toLowerCase()) {
      case 'blouse':
      case 't-shirt':
        return 'Tops';
      case 'jeans':
        return 'Bottoms';
      case 'dress':
        return 'Dresses';
      case 'jacket':
        return 'Outerwear';
      case 'shoes':
        return 'Shoes';
      case 'accessories':
        return 'Accessories';
      case 'bag':
        return 'Accessories';
      default:
        return 'Other';
    }
  }
}
