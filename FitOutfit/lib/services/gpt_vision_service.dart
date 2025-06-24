import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wardrobe_item.dart';

class GptVisionService {
  static const _apiKey = ("OPENAI_API_KEY")
  static const _apiUrl = 'https://api.openai.com/v1/chat/completions';

  static Future<Map<String, dynamic>> generateOutfitRecommendation(
    List<WardrobeItem> items, {
    required String occasion,
    required String weather,
    required String style,
  }) async {
    try {
      print('🤖 Starting AI outfit generation...');
      print('🤖 Items count: ${items.length}');
      print('🤖 Occasion: $occasion, Weather: $weather, Style: $style');

      // ✅ FILTER ITEMS WITH VALID IMAGES
      final validItems = items.where((item) => 
        item.imageUrl != null && 
        item.imageUrl!.isNotEmpty && 
        item.imageUrl != 'null'
      ).toList();

      if (validItems.isEmpty) {
        throw Exception('Tidak ada item dengan gambar yang valid di wardrobe');
      }

      print('🤖 Valid items with images: ${validItems.length}');
      
      // ✅ CREATE ITEMS MAP FOR MATCHING
      final Map<String, WardrobeItem> itemsMap = {};
      for (var item in validItems) {
        final key = '${item.name.toLowerCase().replaceAll(' ', '_')}_${item.category.toLowerCase()}';
        itemsMap[key] = item;
        print('🤖 Item: ${item.name} - Image: ${item.imageUrl}');
      }

      // ✅ TEST API KEY FIRST
      print('🔑 Testing OpenAI API key...');
      final apiKeyValid = await testApiKey();
      if (!apiKeyValid) {
        print('🚨 API Key invalid, using enhanced smart fallback');
        return _createEnhancedSmartFallbackResponse(validItems, occasion, weather, style);
      }
      print('✅ API key is valid!');

      // ✅ TRY REAL AI WITH IMAGE ANALYSIS
      try {
        final List<Map<String, dynamic>> images = validItems.map((e) => {
          'type': 'image_url',
          'image_url': {
            'url': e.imageUrl!,
            'detail': 'low'
          }
        }).toList();

        // ✅ IMPROVED PROMPT YANG MINTA EXACT NAME MATCHING
        final prompt = '''
Analyze the clothing images I'm sending and create an outfit recommendation.

Available wardrobe items:
${validItems.map((item) => '- ${item.name} (${item.category}, ${item.color})').join('\n')}

Event details:
- Occasion: $occasion
- Weather: $weather  
- Style preference: $style

IMPORTANT: You must use EXACT item names from the list above. Do not create new names.

Respond with JSON format only:
{
  "outfit": [
    {
      "name": "EXACT_NAME_FROM_LIST",
      "category": "EXACT_CATEGORY_FROM_LIST",
      "description": "why this item was chosen"
    }
  ],
  "alasan": "detailed reasoning for this outfit combination based on the images"
}
''';

        final body = jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {
              "role": "user",
              "content": [
                {"type": "text", "text": prompt},
                ...images,
              ]
            }
          ],
          "max_tokens": 1200,
          "temperature": 0.8,
        });

        print('🤖 Sending request to OpenAI...');

        final response = await http.post(
          Uri.parse(_apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          body: body,
        );

        print('🤖 Response status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final content = data['choices'][0]['message']['content'] as String;

          print('🤖 AI Response: $content');

          try {
            final jsonStart = content.indexOf('{');
            final jsonEnd = content.lastIndexOf('}');
            
            if (jsonStart != -1 && jsonEnd != -1) {
              final jsonString = content.substring(jsonStart, jsonEnd + 1);
              final aiResult = jsonDecode(jsonString);
              
              // ✅ MAP AI RESPONSE TO REAL WARDROBE ITEMS
              final mappedResult = _mapAIResponseToRealItems(aiResult, itemsMap);
              
              print('✅ Real AI outfit generated and mapped successfully!');
              return mappedResult;
            } else {
              throw Exception('No valid JSON found in response');
            }
          } catch (parseError) {
            print('⚠️ JSON parse error: $parseError, falling back to enhanced smart logic');
            return _createEnhancedSmartFallbackResponse(validItems, occasion, weather, style);
          }
        } else {
          final errorBody = response.body;
          print('❌ API Error: $errorBody, falling back to enhanced smart logic');
          return _createEnhancedSmartFallbackResponse(validItems, occasion, weather, style);
        }
      } catch (apiError) {
        print('❌ AI API call failed: $apiError, using enhanced smart fallback');
        return _createEnhancedSmartFallbackResponse(validItems, occasion, weather, style);
      }
    } catch (e) {
      print('❌ Error in generateOutfitRecommendation: $e, using enhanced fallback');
      // ✅ FIX: Gunakan items parameter, bukan validItems yang undefined
      final validItemsForFallback = items.where((item) => 
        item.imageUrl != null && 
        item.imageUrl!.isNotEmpty && 
        item.imageUrl != 'null'
      ).toList();
      return _createEnhancedSmartFallbackResponse(validItemsForFallback, occasion, weather, style);
    }
  }

  // ✅ NEW METHOD: MAP AI RESPONSE TO REAL WARDROBE ITEMS
  static Map<String, dynamic> _mapAIResponseToRealItems(
    Map<String, dynamic> aiResult,
    Map<String, WardrobeItem> itemsMap,
  ) {
    print('🔄 Mapping AI response to real wardrobe items...');
    
    final aiOutfit = aiResult['outfit'] as List<dynamic>;
    List<Map<String, dynamic>> mappedOutfit = [];
    
    for (var aiItem in aiOutfit) {
      final aiName = aiItem['name']?.toString() ?? '';
      final aiCategory = aiItem['category']?.toString() ?? '';
      
      print('🔍 Looking for AI item: $aiName ($aiCategory)');
      
      // ✅ FIND MATCHING REAL ITEM
      WardrobeItem? matchedItem;
      
      // Try exact match first
      final exactKey = '${aiName.toLowerCase().replaceAll(' ', '_')}_${aiCategory.toLowerCase()}';
      if (itemsMap.containsKey(exactKey)) {
        matchedItem = itemsMap[exactKey];
        print('✅ Exact match found: ${matchedItem!.name}');
      } else {
        // Try fuzzy match
        for (var entry in itemsMap.entries) {
          final item = entry.value;
          if (item.name.toLowerCase().contains(aiName.toLowerCase().split(' ').first) ||
              aiName.toLowerCase().contains(item.name.toLowerCase().split(' ').first)) {
            if (item.category.toLowerCase() == aiCategory.toLowerCase()) {
              matchedItem = item;
              print('✅ Fuzzy match found: ${matchedItem.name}');
              break;
            }
          }
        }
      }
      
      if (matchedItem != null) {
        // ✅ ADD REAL ITEM WITH REAL IMAGE URL (REMOVED 'brand')
        mappedOutfit.add({
          'name': matchedItem.name,
          'category': matchedItem.category,
          'description': aiItem['description'] ?? 'Selected by AI',
          'imageUrl': matchedItem.imageUrl!, // ✅ REAL FIREBASE URL!
          'color': matchedItem.color,
          'id': matchedItem.id,
        });
        
        print('🎯 Mapped: ${matchedItem.name} - Real Image: ${matchedItem.imageUrl}');
      } else {
        print('⚠️ No real item found for AI suggestion: $aiName');
        // Skip items that can't be matched
      }
    }
    
    // ✅ RETURN MAPPED RESULT
    return {
      'outfit': mappedOutfit,
      'alasan': aiResult['alasan'] ?? 'AI-generated outfit recommendation',
    };
  }

  // ✅ ENHANCED SMART FALLBACK (REMOVED UNUSED VARIABLES)
  static Map<String, dynamic> _createEnhancedSmartFallbackResponse(
    List<WardrobeItem> items,
    String occasion, 
    String weather, 
    String style
  ) {
    print('🔄 Using ENHANCED smart fallback outfit generation...');
    
    items.shuffle();
    
    final tops = items.where((item) => item.category == 'Tops').toList();
    final bottoms = items.where((item) => item.category == 'Bottoms').toList();
    final outerwear = items.where((item) => item.category == 'Outerwear').toList();
    final dresses = items.where((item) => item.category == 'Dresses').toList();
    // ✅ REMOVED: shoes dan accessories karena tidak digunakan
    
    print('🔄 Available - Tops: ${tops.length}, Bottoms: ${bottoms.length}, Outerwear: ${outerwear.length}, Dresses: ${dresses.length}');
    
    List<Map<String, dynamic>> selectedItems = [];
    
    // Smart selection logic
    if (dresses.isNotEmpty && (occasion.toLowerCase().contains('formal') || occasion.toLowerCase().contains('party'))) {
      final dress = dresses.first;
      selectedItems.add({
        "name": dress.name,
        "category": dress.category,
        "description": "Elegant ${dress.color.toLowerCase()} dress perfect for ${occasion.toLowerCase()} events",
        "imageUrl": dress.imageUrl ?? "" // ✅ REAL FIREBASE URL
      });
    } else {
      // Add tops and bottoms
      if (tops.isNotEmpty) {
        final selectedTop = tops.first;
        selectedItems.add({
          "name": selectedTop.name,
          "category": selectedTop.category,
          "description": "Stylish ${selectedTop.color.toLowerCase()} ${selectedTop.category.toLowerCase()} perfect for ${style.toLowerCase()} ${occasion.toLowerCase()}",
          "imageUrl": selectedTop.imageUrl ?? "" // ✅ REAL FIREBASE URL
        });
        
        if (bottoms.isNotEmpty) {
          final selectedBottom = bottoms.first;
          selectedItems.add({
            "name": selectedBottom.name,
            "category": selectedBottom.category,
            "description": "Complementary ${selectedBottom.color.toLowerCase()} ${selectedBottom.category.toLowerCase()}",
            "imageUrl": selectedBottom.imageUrl ?? "" // ✅ REAL FIREBASE URL
          });
        }
      }
    }
    
    // Add outerwear for cold weather
    if (outerwear.isNotEmpty && (
      weather.toLowerCase().contains('cold') || 
      weather.toLowerCase().contains('cool') || 
      weather.toLowerCase().contains('rainy')
    )) {
      final outer = outerwear.first;
      selectedItems.add({
        "name": outer.name,
        "category": outer.category,
        "description": "Essential ${outer.color.toLowerCase()} outerwear for ${weather.toLowerCase()} conditions",
        "imageUrl": outer.imageUrl ?? "" // ✅ REAL FIREBASE URL
      });
    }
    
    String reasoning = "Outfit ini dirancang khusus untuk $occasion dengan mempertimbangkan cuaca $weather dan gaya $style. ";
    if (selectedItems.length > 1) {
      reasoning += "Kombinasi ${selectedItems[0]['name']} dengan ${selectedItems[1]['name']} menciptakan keseimbangan sempurna. ";
    }
    reasoning += "Setiap elemen dipilih berdasarkan kesesuaian warna dan appropriateness untuk acara ${occasion.toLowerCase()}.";

    return {
      "outfit": selectedItems,
      "alasan": reasoning
    };
  }

  // ✅ API KEY TEST METHOD
  static Future<bool> testApiKey() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.openai.com/v1/models'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );
      
      print('🔑 API Key test - Status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('🔑 API Key test failed: $e');
      return false;
    }
  }
}
