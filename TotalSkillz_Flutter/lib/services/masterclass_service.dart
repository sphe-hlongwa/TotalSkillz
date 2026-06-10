import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/masterclass_model.dart';

class MasterclassService extends ChangeNotifier {
  Map<String, List<MasterclassItem>> _allData = {};
  bool _isLoading = false;

  Map<String, List<MasterclassItem>> get data => _allData;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    if (_allData.isNotEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      final String response = await rootBundle.loadString('assets/masterclass_data.json');
      final Map<String, dynamic> decoded = json.decode(response);
      
      _allData = decoded.map((key, value) {
        return MapEntry(
          key,
          (value as List).map((i) => MasterclassItem.fromJson(i)).toList(),
        );
      });
    } catch (e) {
      debugPrint('Error loading masterclass data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<String> get topics => _allData.keys.toList();
}
