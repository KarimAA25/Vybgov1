import 'dart:convert';

import 'package:customer/constant_widgets/osm_place_picker/osm_selected_location_model.dart';
import 'package:customer/constant_widgets/place_picker/selected_location_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentSearchLocation {
  static const String _googleKey = 'recent_searches_google';
  static const String _osmKey = 'recent_searches_osm';

  /// Add a single CategoryHistoryModel to the existing list
  static Future<void> addLocationInHistory(SelectedLocationModel newItem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Load existing list
    List<String> jsonList = prefs.getStringList(_googleKey) ?? [];
    // Convert to models
    List<SelectedLocationModel> rawList = jsonList.map((jsonStr) {
      Map<String, dynamic> jsonMap = jsonDecode(jsonStr);
      return SelectedLocationModel.fromJson(jsonMap);
    }).toList();
    // Remove any existing item with the same slug
    rawList.removeWhere((item) => item.getFullAddress() == newItem.getFullAddress());
    // Add new item
    rawList.add(newItem);
    // Convert back to string list
    List<String> updatedJsonList = rawList.map((item) => jsonEncode(item.toJson())).toList();
    // Save
    await prefs.setStringList(_googleKey, updatedJsonList);
  }

  /// Get the full list
  static Future<List<SelectedLocationModel>> getLocationFromHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList(_googleKey);
    if (jsonList == null) return [];
    // Parse list
    List<SelectedLocationModel> rawList = jsonList.map((jsonStr) {
      Map<String, dynamic> jsonMap = jsonDecode(jsonStr);
      return SelectedLocationModel.fromJson(jsonMap);
    }).toList();
    // Remove duplicates by category ID
    final Map<String, SelectedLocationModel> uniqueMap = {};
    for (var item in rawList) {
      final categoryId = item.getFullAddress();
      // You can use name instead
      if (categoryId.isNotEmpty) {
        uniqueMap[categoryId] = item;
        // overwrite to keep the latest
      }
    }
    return uniqueMap.values.toList();
  }

  /// Optional: Clear the stored list
  static Future<void> clearLocationHistoryList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_googleKey);
  }

  ///OSM Map
  static Future<void> addOSMLocationInHistory(OsmSelectedLocationModel newItem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Load existing list
    List<String> jsonList = prefs.getStringList(_osmKey) ?? [];
    // Convert to models
    List<OsmSelectedLocationModel> rawList = jsonList.map((jsonStr) {
      Map<String, dynamic> jsonMap = jsonDecode(jsonStr);
      return OsmSelectedLocationModel.fromJson(jsonMap);
    }).toList();
    // Remove any existing item with the same slug
    rawList.removeWhere((item) => item.getFullAddress() == newItem.getFullAddress());
    // Add new item
    rawList.add(newItem);
    // Convert back to string list
    List<String> updatedJsonList = rawList.map((item) => jsonEncode(item.toJson())).toList();
    // Save
    await prefs.setStringList(_osmKey, updatedJsonList);
  }

  static Future<List<OsmSelectedLocationModel>> getOSMLocationFromHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList(_osmKey);
    if (jsonList == null) return [];
    // Parse list
    List<OsmSelectedLocationModel> rawList = jsonList.map((jsonStr) {
      Map<String, dynamic> jsonMap = jsonDecode(jsonStr);
      return OsmSelectedLocationModel.fromJson(jsonMap);
    }).toList();
    // Remove duplicates by category ID
    final Map<String, OsmSelectedLocationModel> uniqueMap = {};
    for (var item in rawList) {
      final categoryId = item.getFullAddress();
      // You can use name instead
      if (categoryId.isNotEmpty) {
        uniqueMap[categoryId] = item;
        // overwrite to keep the latest
      }
    }
    return uniqueMap.values.toList();
  }

  static Future<void> clearOSMLocationHistoryList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_osmKey);
  }
}
