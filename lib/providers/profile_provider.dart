import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../services/hive_service.dart';

class ProfileProvider with ChangeNotifier {
  final HiveService _hiveService = HiveService();
  
  Profile? _profile;
  Profile? get profile => _profile;
  
  bool get hasProfile => _profile != null;

  Future<void> loadProfile() async {
    _profile = _hiveService.getProfile();
    notifyListeners();
  }

  Future<void> createProfile(String nickname) async {
    _profile = await _hiveService.createInitialProfile(nickname);
    notifyListeners();
  }

  Future<void> updateXP(int amount) async {
    if (_profile == null) return;
    _profile = _profile!.copyWith(xp: _profile!.xp + amount);
    await _hiveService.saveProfile(_profile!);
    notifyListeners();
  }

  Future<void> addCoins(int amount) async {
    if (_profile == null) return;
    _profile = _profile!.copyWith(coins: _profile!.coins + amount);
    await _hiveService.saveProfile(_profile!);
    notifyListeners();
  }

  Future<bool> spendCoins(int amount) async {
    if (_profile == null || _profile!.coins < amount) return false;
    _profile = _profile!.copyWith(coins: _profile!.coins - amount);
    await _hiveService.saveProfile(_profile!);
    notifyListeners();
    return true;
  }

  Future<void> updateStreak() async {
    if (_profile == null) return;

    final now = DateTime.now();
    final lastActive = _profile!.lastActiveDate;
    
    // Calculate difference in days (disregarding hours)
    final lastActiveDay = DateTime(lastActive.year, lastActive.month, lastActive.day);
    final today = DateTime(now.year, now.month, now.day);
    final difference = today.difference(lastActiveDay).inDays;

    int newStreak = _profile!.streakCount;

    if (difference == 1) {
      // Practiced consecutive day
      newStreak += 1;
    } else if (difference > 1) {
      // Streak broken
      newStreak = 1; // Reset to 1 for today's practice
    } else if (difference == 0 && newStreak == 0) {
      newStreak = 1;
    }

    _profile = _profile!.copyWith(
      streakCount: newStreak,
      lastActiveDate: now,
    );
    
    await _hiveService.saveProfile(_profile!);
    notifyListeners();
  }

  Future<void> resetProfile() async {
    await _hiveService.clearAllData();
    _profile = null;
    notifyListeners();
  }
}
