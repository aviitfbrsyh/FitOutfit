import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/login_page.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color softCream = Color(0xFFFAF9F7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softCream,
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomAppBar(context),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        childAspectRatio: 1.15,
                        children: [
                          _AdminMenuCard(
                            icon: Icons.people_alt_rounded,
                            label: 'Manajemen User',
                            color: primaryBlue,
                            onTap: () {},
                          ),
                          _AdminMenuCard(
                            icon: Icons.shopping_bag_rounded,
                            label: 'Manajemen Produk',
                            color: accentYellow,
                            onTap: () {},
                          ),
                          _AdminMenuCard(
                            icon: Icons.bar_chart_rounded,
                            label: 'Laporan & Statistik',
                            color: accentRed,
                            onTap: () {},
                          ),
                          _AdminMenuCard(
                            icon: Icons.settings_rounded,
                            label: 'Pengaturan',
                            color: mediumGray,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryBlue.withOpacity(0.95),
            primaryBlue.withOpacity(0.85),
            accentYellow.withOpacity(0.1),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.only(left: 20, right: 8, top: 18, bottom: 18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Admin FitOutfit',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1.2,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: accentYellow, size: 26),
            onPressed: () {
              // Logout logic: kembali ke LoginPage
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryBlue.withOpacity(0.09),
            accentYellow.withOpacity(0.07),
            accentRed.withOpacity(0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ganti CircleAvatar dengan logo dari assets
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.transparent,
            child: ClipOval(
              child: Image.asset(
                'assets/logo.png',
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang, Admin!',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: darkGray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kelola FitOutfit dengan mudah dan profesional.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: primaryBlue,
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

class _AdminMenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AdminMenuCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        splashColor: color.withOpacity(0.13),
        highlightColor: color.withOpacity(0.09),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.18),
                      color.withOpacity(0.09),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(16),
                child: Icon(icon, color: color, size: 36),
              ),
              const SizedBox(height: 18),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: color,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}