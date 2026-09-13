import '../../../core/database/localized_collation.dart';
import '../../../core/domain/enums.dart';
import 'monster.dart';

class const MonsterFilter({
  final String? name,
  final String? ecology,
  final MonsterType? type,
}) {
  bool matches(Monster monster) {
    final name = this.name;
    if (name != null &&
        !normalizeForSearch(
          monster.name,
        ).contains(normalizeForSearch(name))) {
      return false;
    }
    if (ecology != null && monster.ecology != ecology) return false;
    if (type != null && monster.type != type) return false;
    return true;
  }
}
