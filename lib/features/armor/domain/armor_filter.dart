import '../../../core/database/localized_collation.dart';
import '../../../core/domain/enums.dart';
import '../../skill/domain/skill.dart';
import 'armor.dart';

class const ArmorFilter({
  final String? name,
  final EquipmentType? type,
  final List<int>? numberOfSlots,
  final List<int>? rarity,
  final Gender? gender,
  final HunterType? hunterType,
  final List<SkillTree>? skills,
}) {
  bool matches(Armor armor) {
    final name = this.name;
    if (name != null) {
      final query = normalizeForSearch(name);
      final matchesName =
          normalizeForSearch(armor.name).contains(query) ||
          normalizeForSearch(armor.fullName ?? armor.name).contains(query);
      if (!matchesName) return false;
    }
    if (type != null && armor.type != type) return false;
    if (numberOfSlots != null &&
        !numberOfSlots!.contains(armor.numberOfSlots)) {
      return false;
    }
    if (rarity != null && !rarity!.contains(armor.rarity)) return false;
    if (gender != null &&
        armor.gender != gender &&
        armor.gender != Gender.both) {
      return false;
    }
    if (hunterType != null &&
        armor.hunterType != hunterType &&
        armor.hunterType != HunterType.both) {
      return false;
    }
    final skills = this.skills;
    if (skills != null) {
      final skillIds = skills.map((skill) => skill.id).toSet();
      final matchesSkill = (armor.skills ?? const []).any(
        (point) => skillIds.contains(point.skillTree.id),
      );
      if (!matchesSkill) return false;
    }
    return true;
  }
}

class const ArmorSetFilter({
  final String? name,
  final List<int>? rarity,
  final Rank? rank,
  final HunterType? hunterType,
  final Gender? gender,
  final List<SkillTree>? skills,
}) {
  bool matches(ArmorSet armorSet) {
    final name = this.name;
    if (name != null &&
        !normalizeForSearch(
          armorSet.name,
        ).contains(normalizeForSearch(name))) {
      return false;
    }
    if (rarity != null && !rarity!.contains(armorSet.rarity)) return false;
    if (rank != null && armorSet.rank != rank) return false;
    if (hunterType != null &&
        armorSet.hunterType != hunterType &&
        armorSet.hunterType != HunterType.both) {
      return false;
    }
    if (gender != null && armorSet.gender != gender) return false;
    final skills = this.skills;
    if (skills != null) {
      final skillIds = skills.map((skill) => skill.id).toSet();
      final matchesSkill = (armorSet.armors ?? const []).any(
        (armor) => (armor.skills ?? const []).any(
          (point) => skillIds.contains(point.skillTree.id),
        ),
      );
      if (!matchesSkill) return false;
    }
    return true;
  }
}
