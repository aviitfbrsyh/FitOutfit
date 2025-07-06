import '../models/user_personalization.dart';
import '../models/outfit_suggestion.dart';

class OutfitService {
  OutfitSuggestion suggestOutfit(UserPersonalization user, String destination) {
    // Logic for outfit suggestion based on user preferences and destination
    if (destination.toLowerCase().contains('beach')) {
      return OutfitSuggestion(
        top: 'Light Linen Shirt',
        bottom: 'Shorts',
        shoes: 'Sandals',
        accessory: 'Sunglasses',
        imageAsset: null, // Remove hardcoded asset paths
      );
    }
    if (user.bodyShape == 'Hourglass' && user.personalColor == 'Spring') {
      return OutfitSuggestion(
        top: 'Fitted Floral Blouse',
        bottom: 'High-waisted Jeans',
        shoes: 'Ballet Flats',
        accessory: 'Pastel Scarf',
        imageAsset: null, // Remove hardcoded asset paths
      );
    }
    // Default suggestion - no hardcoded assets
    return OutfitSuggestion(
      top: 'Basic Tee',
      bottom: 'Jeans',
      shoes: 'Sneakers',
      accessory: 'Watch',
      imageAsset: null, // Remove hardcoded asset paths
    );
  }
}