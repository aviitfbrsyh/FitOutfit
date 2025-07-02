import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Add this import
import '../../../services/admin_data_service.dart';

class EnhancedUserManagement extends StatefulWidget {
  const EnhancedUserManagement({super.key});

  @override
  State<EnhancedUserManagement> createState() => _EnhancedUserManagementState();
}

class _EnhancedUserManagementState extends State<EnhancedUserManagement> {
  final AdminDataService _dataService = AdminDataService();
  String _searchQuery = '';

  static const Color darkPurple = Color(0xFF6B46C1);
  static const Color primaryLavender = Color(0xFFE8E4F3);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildUserStats(),
          const SizedBox(height: 20),
          _buildAgeChart(),
          const SizedBox(height: 20),
          _buildSearchBar(),
          const SizedBox(height: 20),
          _buildUsersList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Management',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage registered users and their account status',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryLavender,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.people_outline_rounded,
              color: darkPurple,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStats() {
    return FutureBuilder<Map<String, int>>(
      future: _dataService.getUserStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {'total': 0, 'active': 0, 'inactive': 0};

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Users',
                stats['total'].toString(),
                Icons.people,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Active Users',
                stats['active'].toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Inactive Users',
                stats['inactive'].toString(),
                Icons.block,
                Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: darkPurple,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search users by name or email...',
          prefixIcon: const Icon(Icons.search, color: darkPurple),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: darkPurple),
          ),
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _dataService.getAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: darkPurple),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading users',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.red[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final users = snapshot.data ?? [];
        final filteredUsers = users.where((user) {
          final name = user['name']?.toString().toLowerCase() ?? '';
          final email = user['email']?.toString().toLowerCase() ?? '';
          return name.contains(_searchQuery.toLowerCase()) ||
              email.contains(_searchQuery.toLowerCase());
        }).toList();

        if (filteredUsers.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No users found'
                        : 'No users match your search',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (_searchQuery.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setState(() => _searchQuery = ''),
                      child: Text(
                        'Clear search',
                        style: GoogleFonts.poppins(color: darkPurple),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Users (${filteredUsers.length})',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: darkPurple,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return _buildUserCard(
                    user,
                    index == filteredUsers.length - 1,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAgeChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bar_chart_rounded,
                color: darkPurple,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'User Age Distribution',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: darkPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FutureBuilder<Map<String, int>>(
            future: _dataService.getAgeDistribution(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: darkPurple),
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text(
                      'Unable to load age data',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                );
              }

              final ageData = snapshot.data!;
              return _buildChart(ageData);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChart(Map<String, int> ageData) {
    final maxValue = ageData.values.isNotEmpty 
        ? ageData.values.reduce((a, b) => a > b ? a : b) 
        : 1;

    return SizedBox(
      height: 300,
      child: Row(
        children: [
          // Age ranges and counts
          Expanded(
            flex: 3,
            child: BarChart(
              BarChartData(
                maxY: maxValue.toDouble() + 2,
                barGroups: _createBarGroups(ageData),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final ageRanges = ageData.keys.toList();
                        if (value.toInt() < ageRanges.length) {
                          return Text(
                            ageRanges[value.toInt()],
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200]!,
                      strokeWidth: 1,
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Legend
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Age Groups',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 12),
                ...ageData.entries.map((entry) => _buildLegendItem(
                  entry.key,
                  entry.value,
                  _getColorForAgeGroup(entry.key),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups(Map<String, int> ageData) {
    return ageData.entries.map((entry) {
      final index = ageData.keys.toList().indexOf(entry.key);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: _getColorForAgeGroup(entry.key),
            width: 30,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildLegendItem(String ageGroup, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ageGroup,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  '$count users',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForAgeGroup(String ageGroup) {
    switch (ageGroup) {
      case '13-17':
        return const Color(0xFF10B981); // Green
      case '18-24':
        return const Color(0xFF3B82F6); // Blue
      case '25-34':
        return const Color(0xFF6366F1); // Indigo
      case '35-44':
        return const Color(0xFF8B5CF6); // Purple
      case '45+':
        return const Color(0xFFEF4444); // Red
      default:
        return Colors.grey;
    }
  }

  // ✅ Helper untuk mengambil usia dari field 'tanggal_lahir'
  int _getUserAge(Map<String, dynamic> user) {
    final tanggalLahir = user['tanggal_lahir'];
    if (tanggalLahir != null) {
      DateTime? birthDate;
      
      // Handle different date formats
      if (tanggalLahir is Timestamp) {
        birthDate = tanggalLahir.toDate();
      } else if (tanggalLahir is String) {
        // Try to parse string date
        try {
          if (tanggalLahir.contains('/')) {
            // Format: DD/MM/YYYY
            final parts = tanggalLahir.split('/');
            if (parts.length == 3) {
              birthDate = DateTime(
                int.parse(parts[2]), // year
                int.parse(parts[1]), // month
                int.parse(parts[0]), // day
              );
            }
          } else if (tanggalLahir.contains('-')) {
            // Format: YYYY-MM-DD
            birthDate = DateTime.parse(tanggalLahir);
          }
        } catch (e) {
          print('Error parsing birth date: $tanggalLahir');
          return 0;
        }
      }
      
      if (birthDate != null) {
        return _calculateAge(birthDate);
      }
    }
    return 0;
  }

  // ✅ Method untuk menghitung usia
  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // ✅ NEW: Helper untuk mendapatkan key age range untuk color coding
  String _getAgeRangeKey(int age) {
    if (age >= 13 && age <= 17) return '13-17';
    if (age >= 18 && age <= 24) return '18-24';
    if (age >= 25 && age <= 34) return '25-34';
    if (age >= 35 && age <= 44) return '35-44';
    if (age >= 45) return '45+';
    return '13-17'; // default
  }

  // ✅ Method _getAgeGroup
  String _getAgeGroup(int age) {
    if (age >= 13 && age <= 17) return 'Teen (13-17)';
    if (age >= 18 && age <= 24) return 'Young Adult (18-24)';
    if (age >= 25 && age <= 34) return 'Adult (25-34)';
    if (age >= 35 && age <= 44) return 'Mid Adult (35-44)';
    if (age >= 45) return 'Senior (45+)';
    return 'Unknown';
  }

  // ✅ Method _formatDate
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // ✅ NEW: Helper untuk format tanggal lahir
  String _getBirthDateString(dynamic tanggalLahir) {
    if (tanggalLahir == null) return '';
    
    try {
      if (tanggalLahir is Timestamp) {
        final date = tanggalLahir.toDate();
        return '${date.day}/${date.month}/${date.year}';
      } else if (tanggalLahir is String) {
        // Return as is if it's already a string
        return tanggalLahir;
      }
    } catch (e) {
      print('Error formatting birth date: $e');
    }
    
    return '';
  }

  // ✅ Method _handleUserAction
  void _handleUserAction(String action, Map<String, dynamic> user) async {
    final userId = user['id'];
    if (userId == null) return;

    try {
      switch (action) {
        case 'toggle_status':
          final currentStatus = user['isActive'] ?? true;
          await _dataService.updateUserStatus(userId, !currentStatus);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'User ${!currentStatus ? 'activated' : 'deactivated'} successfully',
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: !currentStatus ? Colors.green : Colors.orange,
              ),
            );
          }
          break;

        case 'delete':
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                'Delete User',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              content: Text(
                'Are you sure you want to delete this user? This action cannot be undone.',
                style: GoogleFonts.poppins(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await _dataService.deleteUser(userId);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'User deleted successfully',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to $action user: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ✅ SINGLE _buildUserCard method (removed duplicate)
  Widget _buildUserCard(Map<String, dynamic> user, bool isLast) {
    final isActive = user['isActive'] ?? true;
    final joinDate = user['createdAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(
            user['createdAt'].millisecondsSinceEpoch,
          )
        : DateTime.now();
    
    final age = _getUserAge(user);
    final ageGroup = _getAgeGroup(age);
    final birthDate = _getBirthDateString(user['tanggal_lahir']);

    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, bottom: isLast ? 16 : 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? Colors.grey[200]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: primaryLavender,
            child: Text(
              (user['name']?.toString().isNotEmpty == true
                  ? user['name'][0].toUpperCase()
                  : 'U'),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: darkPurple,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user['name']?.toString() ?? 'Unknown User',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: isActive ? Colors.black : Colors.grey[600],
                        ),
                      ),
                    ),
                    if (age > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getColorForAgeGroup(_getAgeRangeKey(age)).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$age tahun',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getColorForAgeGroup(_getAgeRangeKey(age)),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user['email']?.toString() ?? 'No email',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green[100] : Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Inactive',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isActive ? Colors.green[800] : Colors.red[800],
                        ),
                      ),
                    ),
                    if (age > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          ageGroup,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Joined ${_formatDate(joinDate)}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (birthDate.isNotEmpty)
                            Text(
                              'Born: $birthDate',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.grey[400],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleUserAction(value, user),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_status',
                child: Row(
                  children: [
                    Icon(
                      isActive ? Icons.block : Icons.check_circle,
                      size: 18,
                      color: isActive ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(isActive ? 'Deactivate' : 'Activate'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            child: const Icon(Icons.more_vert, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
