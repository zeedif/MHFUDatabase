import '../../../core/database/localized_collation.dart';
import '../../skill/domain/skill.dart';
import 'decoration.dart';

class const DecorationFilter({
  final String? name,
  final int? maxAvailableSlots,
  final List<int>? numberOfSlots,
  final List<SkillTree>? skills,
}) {
  bool matches(Decoration decoration) {
    final name = this.name;
    if (name != null) {
      final query = normalizeForSearch(name);
      final matchesName =
          normalizeForSearch(decoration.name).contains(query) ||
          normalizeForSearch(
            decoration.fullName ?? decoration.name,
          ).contains(query);
      if (!matchesName) return false;
    }
    final maxAvailableSlots = this.maxAvailableSlots;
    if (maxAvailableSlots != null &&
        decoration.requiredSlots > maxAvailableSlots) {
      return false;
    }
    if (numberOfSlots != null &&
        !numberOfSlots!.contains(decoration.requiredSlots)) {
      return false;
    }
    final skills = this.skills;
    if (skills != null) {
      final skillIds = skills.map((skill) => skill.id).toSet();
      final matchesSkill = (decoration.skills ?? const []).any(
        (point) => skillIds.contains(point.skillTree.id),
      );
      if (!matchesSkill) return false;
    }
    return true;
  }
}
