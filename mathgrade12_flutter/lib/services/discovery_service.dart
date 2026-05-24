import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiscoveryStep {
  final String title;
  final String body;
  final GlobalKey targetKey;
  final IconData icon;

  DiscoveryStep({
    required this.title,
    required this.body,
    required this.targetKey,
    required this.icon,
  });
}

class DiscoveryService extends ChangeNotifier {
  bool _isTourActive = false;
  int _currentStepIndex = 0;
  List<DiscoveryStep> _steps = [];
  bool _isCompleted = false;

  bool get isTourActive => _isTourActive;
  int get currentStepIndex => _currentStepIndex;
  List<DiscoveryStep> get steps => _steps;
  bool get isCompleted => _isCompleted;
  
  DiscoveryStep? get currentStep => 
      (_isTourActive && _currentStepIndex < _steps.length) ? _steps[_currentStepIndex] : null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isCompleted = prefs.getBool('discovery_tour_completed') ?? false;
    notifyListeners();
  }

  void startTour(List<DiscoveryStep> steps) {
    if (_isCompleted) return;
    _steps = steps;
    _isTourActive = true;
    _currentStepIndex = 0;
    notifyListeners();
  }

  void next() {
    if (_currentStepIndex < _steps.length - 1) {
      _currentStepIndex++;
    } else {
      finish();
    }
    notifyListeners();
  }

  void skip() {
    finish();
  }

  Future<void> finish() async {
    _isTourActive = false;
    _isCompleted = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('discovery_tour_completed', true);
    notifyListeners();
  }
}
