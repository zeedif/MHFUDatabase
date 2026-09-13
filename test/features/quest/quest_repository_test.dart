import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhfudatabase/core/database/app_database.dart' show AppDatabase;
import 'package:mhfudatabase/core/database/localized_collation.dart';
import 'package:mhfudatabase/features/quest/data/quest_repository.dart';
import 'package:mhfudatabase/features/quest/domain/quest_filter.dart';

void main() {
  late AppDatabase database;
  late QuestRepository repository;

  setUpAll(() {
    database = AppDatabase(
      NativeDatabase(
        File('assets/database/data.db'),
        setup: (db) {
          db.createCollation(name: 'LOCALIZED', function: compareLocalized);
        },
      ),
    );
    repository = QuestRepository(database);
  });

  tearDownAll(() => database.close());

  test('getQuest returns location, monsters, rewards, and supplies', () async {
    final quest = await repository.getQuest(441, 'en');

    expect(quest.id, 441);
    expect(quest.name, isNotEmpty);
    expect(quest.location, isNotNull);
    expect(quest.monsters, isNotEmpty);
    expect(quest.rewards, isNotEmpty);
  });

  test('getQuest returns the supply box', () async {
    final quest = await repository.getQuest(397, 'en');
    expect(quest.supplies, isNotEmpty);
  });

  test('getQuest returns daytime when set', () async {
    final quest = await repository.getQuest(1, 'en');
    expect(quest.daytime, isNotNull);
  });

  test('getQuestList returns quests without a filter', () async {
    final quests = await repository.getQuestList('en');
    expect(quests, isNotEmpty);
  });

  test('QuestFilter.matches filters by name', () async {
    final all = await repository.getQuestList('en');
    final target = all.first;

    final filtered = all.where(QuestFilter(name: target.name).matches);

    expect(filtered, isNotEmpty);
    expect(filtered.map((quest) => quest.id), contains(target.id));
  });

  test('QuestFilter.matches filters by stars', () async {
    final all = await repository.getQuestList('en');
    final stars = all.first.stars;

    final filtered = all.where(QuestFilter(stars: [stars]).matches);

    expect(filtered, isNotEmpty);
    expect(filtered.every((quest) => quest.stars == stars), isTrue);
  });
}
