import '../../../core/domain/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/armor.dart' show Armor;

/// Label distinguishing armor with the same name but a different hunter
/// type or gender. Returns `null` when both are unrestricted ("both").
String? hunterTypeGenderLabel(
  AppLocalizations l10n, {
  required HunterType hunterType,
  required Gender gender,
}) {
  final parts = [
    switch (hunterType) {
      HunterType.blade => l10n.armorSetFilterHunterBlade,
      HunterType.gunner => l10n.armorSetFilterHunterGunner,
      HunterType.both => null,
    },
    switch (gender) {
      Gender.male => l10n.armorSetFilterGenderMale,
      Gender.female => l10n.armorSetFilterGenderFemale,
      Gender.both => null,
    },
  ].whereType<String>();
  return parts.isEmpty ? null : parts.join(' · ');
}

String? armorVariantLabel(AppLocalizations l10n, Armor armor) =>
    hunterTypeGenderLabel(
      l10n,
      hunterType: armor.hunterType,
      gender: armor.gender,
    );
