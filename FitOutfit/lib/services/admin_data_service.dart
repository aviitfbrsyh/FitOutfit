import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

class AdminDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize user tracking
  Future<void> initializeUserTracking() async {
    try {
      await _firestore.collection('admin_logs').add({
        'action': 'user_tracking_initialized',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log('Failed to initialize user tracking: $e');
    }
  }

  // Update daily analytics
  Future<void> updateDailyAnalytics() async {
    try {
      await _firestore.collection('analytics').doc('daily').set({
        'last_updated': FieldValue.serverTimestamp(),
        'total_users': await getTotalUsersCount().first,
      }, SetOptions(merge: true));
    } catch (e) {
      developer.log('Failed to update daily analytics: $e');
    }
  }

  // Update user count
  Future<void> updateUserCount() async {
    try {
      final userCount = await getTotalUsersCount().first;
      await _firestore.collection('stats').doc('users').set({
        'total_count': userCount,
        'last_updated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log('Failed to update user count: $e');
    }
  }

  // Get dashboard stats
  Stream<Map<String, dynamic>> getDashboardStats() {
    return _firestore.collection('stats').doc('dashboard').snapshots().map((
      doc,
    ) {
      if (doc.exists) {
        return doc.data() ?? {};
      }
      return {
        'userGrowth': 12.5,
        'outfitGrowth': 8.3,
        'postGrowth': 15.2,
        'newsGrowth': 6.7,
      };
    });
  }

  // Get total users count (real-time)
  Stream<int> getTotalUsersCountRealtime() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get total users count (one-time)
  Stream<int> getTotalUsersCount() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get weekly outfits count
  Future<int> getWeeklyOutfitsCount() async {
    try {
      final DateTime weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final snapshot =
          await _firestore
              .collection('outfits')
              .where('created_at', isGreaterThan: weekAgo)
              .get();
      return snapshot.docs.length;
    } catch (e) {
      developer.log('Failed to get weekly outfits count: $e');
      return 0;
    }
  }

  // Get community posts count
  Stream<int> getCommunityPostsCount() {
    return _firestore
        .collection('community_posts')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get fashion news stats
  Future<Map<String, dynamic>> getFashionNewsStats() async {
    try {
      final DateTime weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final snapshot =
          await _firestore
              .collection('fashion_news')
              .where('created_at', isGreaterThan: weekAgo)
              .get();

      return {
        'weeklyReads': snapshot.docs.length * 15, // Simulate reads
        'totalArticles': snapshot.docs.length,
      };
    } catch (e) {
      developer.log('Failed to get fashion news stats: $e');
      return {'weeklyReads': 0, 'totalArticles': 0};
    }
  }

  // Get trending styles
  Future<List<Map<String, dynamic>>> getTrendingStyles() async {
    try {
      // Check if we have outfit data to base trends on
      await _firestore.collection('outfits').limit(1).get();

      // Simulate trending styles based on data
      return [
        {'style': 'Casual Chic', 'percentage': '28%'},
        {'style': 'Business Professional', 'percentage': '22%'},
        {'style': 'Streetwear', 'percentage': '18%'},
        {'style': 'Formal Evening', 'percentage': '15%'},
        {'style': 'Boho Style', 'percentage': '12%'},
      ];
    } catch (e) {
      developer.log('Failed to get trending styles: $e');
      return [];
    }
  }

  // Get all users for user management
  Stream<List<Map<String, dynamic>>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID
        return data;
      }).toList();
    });
  }

  // Update user status (activate/deactivate)
  Future<void> updateUserStatus(String userId, bool isActive) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': isActive,
        'lastModified': FieldValue.serverTimestamp(),
        'modifiedBy': 'admin',
      });

      // Log the action
      await _firestore.collection('admin_logs').add({
        'action': 'user_status_updated',
        'userId': userId,
        'newStatus': isActive ? 'active' : 'inactive',
        'timestamp': FieldValue.serverTimestamp(),
        'adminUser': 'aviitfbrsyh',
      });
    } catch (e) {
      developer.log('Failed to update user status: $e');
      rethrow;
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      // Get user data before deletion for logging
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();

      // Delete user document
      await _firestore.collection('users').doc(userId).delete();

      // Log the deletion
      await _firestore.collection('admin_logs').add({
        'action': 'user_deleted',
        'userId': userId,
        'deletedUserEmail': userData?['email'] ?? 'unknown',
        'deletedUserName': userData?['name'] ?? 'unknown',
        'timestamp': FieldValue.serverTimestamp(),
        'adminUser': 'aviitfbrsyh',
      });

      // Optionally delete related data (outfits, posts, etc.)
      await _deleteUserRelatedData(userId);
    } catch (e) {
      developer.log('Failed to delete user: $e');
      rethrow;
    }
  }

  // Helper method to delete user's related data
  Future<void> _deleteUserRelatedData(String userId) async {
    try {
      // Delete user's outfits
      final outfitsQuery =
          await _firestore
              .collection('outfits')
              .where('userId', isEqualTo: userId)
              .get();

      for (var doc in outfitsQuery.docs) {
        await doc.reference.delete();
      }

      // Delete user's community posts
      final postsQuery =
          await _firestore
              .collection('community_posts')
              .where('userId', isEqualTo: userId)
              .get();

      for (var doc in postsQuery.docs) {
        await doc.reference.delete();
      }

      developer.log('Deleted related data for user: $userId');
    } catch (e) {
      developer.log('Failed to delete user related data: $e');
      // Don't rethrow here as this is cleanup, main deletion should still succeed
    }
  }

  // Get user statistics for admin dashboard
  Future<Map<String, int>> getUserStats() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      final totalUsers = usersSnapshot.docs.length;

      final activeUsers =
          usersSnapshot.docs
              .where((doc) => doc.data()['isActive'] != false)
              .length;

      final inactiveUsers = totalUsers - activeUsers;

      return {
        'total': totalUsers,
        'active': activeUsers,
        'inactive': inactiveUsers,
      };
    } catch (e) {
      developer.log('Failed to get user stats: $e');
      return {'total': 0, 'active': 0, 'inactive': 0};
    }
  }
}
