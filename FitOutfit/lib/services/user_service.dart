import '../models/user_personalization.dart';

class UserService {
  // Simulate fetching from a database
  Future<UserPersonalization> fetchUserPersonalization(String userId) async {
    // Simulated delay
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock data
    return UserPersonalization(
      bodyShape: 'Hourglass',
      skinTone: 'Medium',
      hairColor: 'Brown',
      personalColor: 'Spring',
    );
  }
}