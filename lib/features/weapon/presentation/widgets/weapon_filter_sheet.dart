import 'package:flutter/material.dart';

import '../../../../core/domain/enums.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/entity_icon.dart';
import '../../../../core/widgets/filter_sheet_body.dart';
import '../../../../core/widgets/selection_pill.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/weapon_filter.dart';

const _rarities = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
const _slotOptions = [0, 1, 2, 3];

/// Filter sheet for weapon-picking/browsing screens. Reports changes via
/// [onFilterChange] instead of popping, so it stays open while pills are
/// toggled.
class const WeaponFilterSheet({
  required final WeaponFilter filter,
  required final ValueChanged<WeaponFilter> onFilterChange,
  final bool includeWeaponType = true,
  final List<WeaponType> weaponTypeOptions = WeaponType.values,
  super.key,
}) extends StatefulWidget {
  @override
  State<WeaponFilterSheet> createState() => _WeaponFilterSheetState();
}

class _WeaponFilterSheetState extends State<WeaponFilterSheet> {
  late WeaponFilter _filter = widget.filter;

  void _apply(WeaponFilter filter) {
    setState(() => _filter = filter);
    widget.onFilterChange(filter);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final weaponTypes = _filter.weaponType ?? const <WeaponType>[];
    final elementTypes = _filter.elementType ?? const <WeaponElement>[];
    final rarities = _filter.rarity ?? const <int>[];
    final numberOfSlots = _filter.numberOfSlots ?? const <int>[];

    return FilterSheetBody(
      children: [
        if (widget.includeWeaponType) ...[
          Text(
            l10n.userSetFilterWeaponType,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.medium),
          Wrap(
            spacing: AppSpacing.small,
            runSpacing: AppSpacing.small,
            children: [
              for (final type in widget.weaponTypeOptions)
                SelectionPill(
                  selected: weaponTypes.contains(type),
                  onTap: () => _apply(
                    _filter.copyWith(
                      weaponType: weaponTypes.contains(type)
                          ? (weaponTypes.toList()..remove(type))
                          : (weaponTypes.toList()..add(type)),
                    ),
                  ),
                  child: Image.asset(
                    'assets/images/${weaponTypeIconAsset(type)}.webp',
                    width: AppSize.small,
                    height: AppSize.small,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.large),
        ],
        Text(
          l10n.userSetFilterElementType,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.medium),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            for (final element in WeaponElement.values)
              SelectionPill(
                selected: elementTypes.contains(element),
                onTap: () => _apply(
                  _filter.copyWith(
                    elementType: elementTypes.contains(element)
                        ? (elementTypes.toList()..remove(element))
                        : (elementTypes.toList()..add(element)),
                  ),
                ),
                child: Image.asset(
                  'assets/images/${elementIconAsset(element)}.webp',
                  width: AppSize.small,
                  height: AppSize.small,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.large),
        Text(
          l10n.userSetFilterRarity,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.medium),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            for (final rarity in _rarities)
              SelectionPill(
                selected: rarities.contains(rarity),
                onTap: () => _apply(
                  _filter.copyWith(
                    rarity: rarities.contains(rarity)
                        ? (rarities.toList()..remove(rarity))
                        : (rarities.toList()..add(rarity)),
                  ),
                ),
                child: Text('$rarity'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.large),
        Text(
          l10n.userSetFilterNumberOfSlots,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.medium),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            for (final slots in _slotOptions)
              SelectionPill(
                selected: numberOfSlots.contains(slots),
                onTap: () => _apply(
                  _filter.copyWith(
                    numberOfSlots: numberOfSlots.contains(slots)
                        ? (numberOfSlots.toList()..remove(slots))
                        : (numberOfSlots.toList()..add(slots)),
                  ),
                ),
                child: Text('$slots'),
              ),
          ],
        ),
      ],
    );
  }
}
