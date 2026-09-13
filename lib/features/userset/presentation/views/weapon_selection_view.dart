import 'package:flutter/material.dart';

import '../../../../core/domain/enums.dart';
import '../../../../core/state/language_fetch_mixin.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/entity_icon.dart';
import '../../../../core/widgets/filter_sheet_body.dart';
import '../../../../core/widgets/filterable_list_body.dart';
import '../../../../core/widgets/list_item_layout.dart';
import '../../../../core/widgets/pill_list_item.dart';
import '../../../../core/widgets/selection_pill.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../weapon/data/weapon_repository.dart';
import '../../../weapon/domain/weapon_filter.dart';
import '../../../weapon/domain/weapon.dart';
import '../widgets/selection_search_bar.dart';

const _rarities = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
const _slotOptions = [0, 1, 2, 3];

class const WeaponSelectionView({
  required final HunterType hunterType,
  super.key,
}) extends StatefulWidget {
  @override
  State<WeaponSelectionView> createState() => _WeaponSelectionViewState();
}

class _WeaponSelectionViewState extends State<WeaponSelectionView>
    with LanguageFetchMixin<Weapon, WeaponSelectionView> {
  late WeaponFilter _filter = WeaponFilter(hunterType: widget.hunterType);

  @override
  Future<List<Weapon>> fetchItems(String language) =>
      WeaponRepository().getWeaponList(language);

  Future<void> _openFilterSheet() async {
    final updated = await showModalBottomSheet<WeaponFilter>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _WeaponFilterSheet(filter: _filter),
    );
    if (!mounted || updated == null) return;
    setState(() => _filter = updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SelectionSearchBar(
        onQueryChange: (name) => setState(
          () => _filter = WeaponFilter(
            name: name.isEmpty ? null : name,
            hunterType: _filter.hunterType,
            weaponType: _filter.weaponType,
            elementType: _filter.elementType,
            rarity: _filter.rarity,
            numberOfSlots: _filter.numberOfSlots,
          ),
        ),
        onFilterTap: _openFilterSheet,
      ),
      body: FilterableListBody<Weapon>(
        items: items,
        filter: _filter.matches,
        itemBuilder: (context, weapon) => PillListItem(
          child: ListItemLayout(
            leading: WeaponEntityIcon(
              type: weapon.type,
              rarity: weapon.rarity,
              size: AppSize.medium,
            ),
            headline: Text(weapon.name),
            supporting: Text('${weapon.attack}'),
            onTap: () => Navigator.of(context).pop(weapon),
          ),
        ),
      ),
    );
  }
}

class const _WeaponFilterSheet({required final WeaponFilter filter})
    extends StatefulWidget {
  @override
  State<_WeaponFilterSheet> createState() => _WeaponFilterSheetState();
}

class _WeaponFilterSheetState extends State<_WeaponFilterSheet> {
  late WeaponFilter _filter = widget.filter;

  void _apply(WeaponFilter filter) {
    setState(() => _filter = filter);
    Navigator.of(context).pop(filter);
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
        Text(
          l10n.userSetFilterWeaponType,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.medium),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            for (final type in WeaponType.forHunterType(
              _filter.hunterType ?? HunterType.both,
            ))
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

extension on WeaponFilter {
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
