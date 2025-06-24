import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../splash_screen_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color softCream = Color(0xFFFAF9F7);

  String displayName = '';
  String email = '';
  String? bio;
  String? photoUrl;
  File? photoFile;
  String? userUid;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    userUid = user?.uid;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    setState(() {
      displayName = doc.data()?['name'] ?? user.displayName ?? '';
      email = doc.data()?['email'] ?? user.email ?? '';
      bio = doc.data()?['bio'] ?? '';
      photoUrl = doc.data()?['photoUrl'] ?? user.photoURL;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            color: darkGray,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: primaryBlue),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF4A90E2), // primaryBlue
                        Color(0xFFF5A623), // accentYellow
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 38,
                        backgroundColor: Colors.white,
                        backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
                            ? NetworkImage(photoUrl!)
                            : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => EditProfilePage(
                                      initialName: displayName,
                                      initialBio: bio ?? '',
                                      initialPhotoUrl: photoUrl,
                                    ),
                                  ),
                                );
                                if (result == true && mounted) {
                                  await _loadUserData();
                                  setState(() {
                                    photoFile = null; // always reload from url
                                  });
                                }
                              },
                              icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                              label: Text(
                                'Edit Profile',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentYellow,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Statistik
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatItem(label: 'Wardrobe', value: '127'),
                    _StatItem(label: 'Favorites', value: '247'),
                    _StatItem(label: 'Posts', value: '12'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Bio
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.07),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    bio ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: darkGray,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              // Grid Navigasi
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.25,
                  ),
                  children: [
                    _NavButton(
                      icon: Icons.checkroom_rounded,
                      color: accentYellow,
                      label: 'My Wardrobe',
                      onTap: () {
                        // TODO: Navigate to wardrobe
                      },
                    ),
                    _NavButton(
                      icon: Icons.favorite_rounded,
                      color: accentRed,
                      label: 'Favorites',
                      onTap: () {
                        // TODO: Navigate to favorites
                      },
                    ),
                    _NavButton(
                      icon: Icons.psychology_rounded,
                      color: primaryBlue,
                      label: 'Style Quiz',
                      onTap: () {
                        // TODO: Navigate to style quiz
                      },
                    ),
                    _NavButton(
                      icon: Icons.calendar_today_rounded,
                      color: accentYellow,
                      label: 'Outfit Planner',
                      onTap: () {
                        // TODO: Navigate to planner
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Settings & Logout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                child: Column(
                  children: [
                    ListTile(
                      onTap: () {
                        // TODO: Navigate to settings
                      },
                      leading: const Icon(Icons.settings_rounded, color: primaryBlue),
                      title: Text(
                        'Settings',
                        style: GoogleFonts.poppins(
                          color: darkGray,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: mediumGray),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => SplashScreenPage()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
                      label: Text(
                        'Logout',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size.fromHeight(48),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24), // pengganti Spacer()
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  const _NavButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
