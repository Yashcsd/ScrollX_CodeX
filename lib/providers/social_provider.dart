import 'package:flutter/foundation.dart';

class SocialProvider extends ChangeNotifier {
  String _leaderboardPeriod = 'all_time';

  String get leaderboardPeriod => _leaderboardPeriod;

  void setLeaderboardPeriod(String value) {
    if (_leaderboardPeriod == value) return;
    _leaderboardPeriod = value;
    notifyListeners();
  }
}
