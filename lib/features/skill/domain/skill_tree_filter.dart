import '../../../core/database/localized_collation.dart';
import '../../../core/domain/enums.dart';
import 'skill.dart';

class const SkillTreeFilter({
  final String? name,
  final SkillCategory? category,
}) {
  bool matches(SkillTree skillTree) {
    final name = this.name;
    if (name != null) {
      final query = normalizeForSearch(name);
      final matchesTreeName =
          normalizeForSearch(skillTree.name).contains(query) ||
          normalizeForSearch(
            skillTree.fullName ?? skillTree.name,
          ).contains(query);
      final matchesSkillName = (skillTree.skills ?? const []).any(
        (skill) =>
            normalizeForSearch(skill.name).contains(query) ||
            normalizeForSearch(skill.fullName ?? skill.name).contains(query),
      );
      if (!matchesTreeName && !matchesSkillName) return false;
    }
    if (category != null && skillTree.category != category) return false;
    return true;
  }
}
