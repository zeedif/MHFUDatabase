import '../../../core/database/localized_collation.dart';
import '../../../core/domain/enums.dart';
import 'weapon.dart';

class const WeaponFilter({
  final String? name,
  final List<WeaponType>? weaponType,
  final HunterType? hunterType,
  final List<int>? numberOfSlots,
  final List<int>? rarity,
  final List<WeaponElement>? elementType,
}) {
  bool matches(Weapon weapon) {
    final name = this.name;
    if (name != null) {
      final query = normalizeForSearch(name);
      final matchesName =
          normalizeForSearch(weapon.name).contains(query) ||
          normalizeForSearch(weapon.fullName ?? weapon.name).contains(query);
      if (!matchesName) return false;
    }
    final weaponType = this.weaponType;
    if (weaponType != null && weaponType.isNotEmpty) {
      if (!weaponType.contains(weapon.type)) return false;
    } else if (hunterType != null) {
      if (!WeaponType.forHunterType(hunterType!).contains(weapon.type)) {
        return false;
      }
    }
    if (numberOfSlots != null &&
        !numberOfSlots!.contains(weapon.numberOfSlots)) {
      return false;
    }
    if (rarity != null && !rarity!.contains(weapon.rarity)) return false;
    final elementType = this.elementType;
    if (elementType != null && elementType.isNotEmpty) {
      final matchesElement =
          elementType.contains(weapon.element1) ||
          elementType.contains(weapon.element2);
      if (!matchesElement) return false;
    }
    return true;
  }

  WeaponFilter withName(String? name) => WeaponFilter(
    name: name,
    weaponType: weaponType,
    hunterType: hunterType,
    numberOfSlots: numberOfSlots,
    rarity: rarity,
    elementType: elementType,
  );

  WeaponFilter copyWith({
    List<WeaponType>? weaponType,
    List<WeaponElement>? elementType,
    List<int>? rarity,
    List<int>? numberOfSlots,
  }) {
    return WeaponFilter(
      name: name,
      hunterType: hunterType,
      weaponType: (weaponType ?? this.weaponType)?.isEmpty ?? true
          ? null
          : weaponType ?? this.weaponType,
      elementType: (elementType ?? this.elementType)?.isEmpty ?? true
          ? null
          : elementType ?? this.elementType,
      rarity: (rarity ?? this.rarity)?.isEmpty ?? true
          ? null
          : rarity ?? this.rarity,
      numberOfSlots: (numberOfSlots ?? this.numberOfSlots)?.isEmpty ?? true
          ? null
          : numberOfSlots ?? this.numberOfSlots,
    );
  }
}
