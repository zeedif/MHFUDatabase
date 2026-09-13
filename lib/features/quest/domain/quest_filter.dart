import '../../../core/database/localized_collation.dart';
import '../../../core/domain/enums.dart';
import 'quest.dart';

class const QuestFilter({
  final String? name,
  final HubType? hub,
  final List<int>? stars,
  final List<QuestType>? type,
  final QuestGoal? goal,
  final List<int>? locations,
}) {
  bool matches(Quest quest) {
    final name = this.name;
    if (name != null &&
        !normalizeForSearch(quest.name).contains(normalizeForSearch(name))) {
      return false;
    }
    if (hub != null && quest.hubType != hub) return false;
    if (stars != null && !stars!.contains(quest.stars)) return false;
    if (type != null && !type!.contains(quest.questType)) return false;
    if (goal != null && quest.goalType != goal) return false;
    if (locations != null && !locations!.contains(quest.locationId)) {
      return false;
    }
    return true;
  }
}
