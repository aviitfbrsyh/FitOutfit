import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VirtualTryOnPage extends StatefulWidget {
  const VirtualTryOnPage({super.key});

  @override
  State<VirtualTryOnPage> createState() => _VirtualTryOnPageState();
}

class _VirtualTryOnPageState extends State<VirtualTryOnPage> {
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color softCream = Color(0xFFFAF9F7);

  final List<String> _destinations = [
    'Pantai',
    'Undangan Pernikahan',
    'Main',
    'Kampus',
    'Hangout',
    'Interview Kerja',
    'Formal Meeting',
    'Travel',
  ];

  String _selectedDestination = '';
  bool _loading = false;
  String? _outfitResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: Material(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: darkGray, size: 20),
            ),
          ),
        ),
        title: Text(
          'Virtual Try-On',
          style: GoogleFonts.poppins(
            color: darkGray,
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 28),
            _buildDestinationSelector(),
            const SizedBox(height: 36),
            _buildGenerateButton(),
            if (_loading) ...[
              const SizedBox(height: 36),
              Center(child: CircularProgressIndicator(color: primaryBlue)),
            ],
            if (_outfitResult != null && !_loading) ...[
              const SizedBox(height: 36),
              _buildOutfitResult(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryBlue.withOpacity(0.18),
            accentYellow.withOpacity(0.12),
            accentRed.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.10),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: accentYellow.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: primaryBlue.withOpacity(0.10),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar/Logo/Effect
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [primaryBlue, accentYellow],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accentYellow.withOpacity(0.10),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Color(0xFF4A90E2),
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [primaryBlue, accentYellow, accentRed],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Text(
                    'Virtual Try-On',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white, // Warna ini akan di-mask oleh gradient
                      letterSpacing: -1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Simulasikan outfit terbaikmu sesuai destinasi pilihan. Stylish, mudah, dan personal!',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: darkGray.withOpacity(0.85),
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationSelector() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryBlue.withOpacity(0.08),
            accentYellow.withOpacity(0.05),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: primaryBlue.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.05),
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
                  gradient: LinearGradient(
                    colors: [
                      primaryBlue.withOpacity(0.15),
                      primaryBlue.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryBlue.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(Icons.place_rounded, color: primaryBlue, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Pilih Destinasi',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: darkGray,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _destinations.map((dest) {
              final isSelected = _selectedDestination == dest;
              return Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => setState(() => _selectedDestination = dest),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [primaryBlue, accentYellow],
                            )
                          : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : lightGray,
                        width: isSelected ? 0 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? primaryBlue.withOpacity(0.2)
                              : darkGray.withOpacity(0.04),
                          blurRadius: isSelected ? 16 : 8,
                          offset: Offset(0, isSelected ? 6 : 2),
                        ),
                      ],
                    ),
                    child: Text(
                      dest,
                      style: GoogleFonts.poppins(
                        color: isSelected ? Colors.white : darkGray,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    final canGenerate = _selectedDestination.isNotEmpty;
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        gradient: canGenerate
            ? LinearGradient(
                colors: [accentRed, accentRed.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: canGenerate ? null : mediumGray.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: canGenerate
            ? [
                BoxShadow(
                  color: accentRed.withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: accentRed.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: accentRed.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: darkGray.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : [
                BoxShadow(
                  color: darkGray.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ElevatedButton.icon(
        onPressed: canGenerate ? _generateOutfit : null,
        icon: const Icon(Icons.auto_awesome_rounded, size: 24),
        label: Text(
          'Generate Outfit',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: -0.2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildOutfitResult() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: darkGray.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rekomendasi Outfit',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _outfitResult ?? '',
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: mediumGray,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // INTEGRASI API CHATGPT
  // =========================
  Future<void> _generateOutfit() async {
    setState(() {
      _loading = true;
      _outfitResult = null;
    });

    // --- GANTI DENGAN LOGIKA PEMANGGILAN API CHATGPT ---
    // Contoh: panggil API kamu di sini, misal pakai http package
    // Prompt bisa kamu custom sesuai kebutuhan
    final prompt = "Buatkan rekomendasi outfit untuk pergi ke $_selectedDestination. "
        "Tampilkan detail item (atasan, bawahan, sepatu, aksesoris) dan alasan pemilihannya, "
        "gunakan bahasa Indonesia yang ramah dan singkat.";

    final apiKey = 'YOUR_OPENAI_API_KEY'; // Simpan di env/config
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "system", "content": "Kamu adalah asisten fashion."},
          {"role": "user", "content": prompt},
        ],
        "max_tokens": 200,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final result = data['choices'][0]['message']['content'];
      setState(() {
        _loading = false;
        _outfitResult = result;
      });
    } else {
      setState(() {
        _loading = false;
        _outfitResult = "Gagal mendapatkan rekomendasi outfit.";
      });
    }
  }
}