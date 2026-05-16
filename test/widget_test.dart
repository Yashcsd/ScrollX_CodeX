import 'package:flutter_test/flutter_test.dart';

import 'package:gamereel/core/app_theme.dart';
import 'package:gamereel/models/user_model.dart';

void main() {
  test('level helpers map XP to the expected level band', () {
    expect(AppConstants.levelNumber(0), 1);
    expect(AppConstants.levelTitle(0), 'Newcomer');

    expect(AppConstants.levelNumber(500), 2);
    expect(AppConstants.levelTitle(500), 'Rookie');

    expect(AppConstants.levelNumber(4500), 10);
    expect(AppConstants.levelTitle(4500), 'Puzzle God');
  });

  test('copyWith preserves existing fields and applies updates', () {
    final user = UserModel(
      id: 'u1',
      username: 'Scroll',
      avatarInitials: 'SC',
      totalXp: 120,
      gamesWon: 3,
      gamesPlayed: 5,
      bestScores: const {'slide_puzzle': 250},
      badges: const ['First Game'],
    );

    final updated = user.copyWith(
      username: 'ScrollX',
      totalXp: 200,
    );

    expect(updated.id, 'u1');
    expect(updated.username, 'ScrollX');
    expect(updated.avatarInitials, 'SC');
    expect(updated.totalXp, 200);
    expect(updated.gamesWon, 3);
    expect(updated.gamesPlayed, 5);
    expect(updated.bestScores['slide_puzzle'], 250);
    expect(updated.badges, contains('First Game'));
  });
}
