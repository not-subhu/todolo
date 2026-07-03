import 'package:flutter/material.dart';
import '../models/reward.dart';
import '../services/database_service.dart';

class RewardsProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  List<Reward> _rewards = [];
  bool _isLoading = true;

  List<Reward> get rewards => _rewards;
  bool get isLoading => _isLoading;

  List<Reward> get available => _rewards.where((r) => !r.isPurchased).toList();
  List<Reward> get purchased => _rewards.where((r) => r.isPurchased).toList();

  Future<void> load() async {
    _rewards = await _db.getRewards();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addReward(Reward reward) async {
    await _db.saveReward(reward);
    _rewards.add(reward);
    notifyListeners();
  }

  Future<bool> purchaseReward(String id) async {
    final idx = _rewards.indexWhere((r) => r.id == id);
    if (idx < 0) return false;
    final r = _rewards[idx];
    r.isPurchased = true;
    r.purchasedAt = DateTime.now();
    await _db.saveReward(r);
    notifyListeners();
    return true;
  }

  Future<void> deleteReward(String id) async {
    await _db.deleteReward(id);
    _rewards.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}
