import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/models.dart';

class SnapshotLoader {
  static const String _assetPath = 'assets/data/exchange_rates_2025-10-04T14-00+03.json';

  /// Load the bundled exchange rates snapshot
  static Future<FxSnapshot> loadSnapshot() async {
    try {
      final String jsonString = await rootBundle.loadString(_assetPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return FxSnapshot.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load exchange rates snapshot: $e');
    }
  }

  /// Get the asset path for reference
  static String get assetPath => _assetPath;
}
