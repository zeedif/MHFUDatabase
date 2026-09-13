import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/enums.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/settings/list_filter_preferences.dart';
import '../../../../core/state/language_fetch_mixin.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/entity_icon.dart';
import '../../../../core/widgets/filter_sheet_body.dart';
import '../../../../core/widgets/filterable_list_body.dart';
import '../../../../core/widgets/list_item_layout.dart';
import '../../../../core/widgets/mhfu_colors.dart';
import '../../../../core/widgets/pill_list_item.dart';
import '../../../../core/widgets/search_filter_app_bar.dart';
import '../../../../core/widgets/selection_pill.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/armor_repository.dart';
import '../../domain/armor_filter.dart';
import '../../domain/armor.dart';

const _armorSetRarities = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

class const ArmorSetListView({
  required final VoidCallback openDrawer,
  required final VoidCallback openSearch,
  super.key,
}) extends StatefulWidget {
  @override
  State<ArmorSetListView> createState() => _ArmorSetListViewState();
}

class _ArmorSetListViewState extends State<ArmorSetListView>
    with LanguageFetchMixin<ArmorSet, ArmorSetListView> {
  ArmorSetFilter _filter = ArmorSetFilter(
    rarity: ListFilterPreferences.instance.armorSetRarity,
    hunterType: ListFilterPreferences.instance.armorSetHunterType,
    gender: ListFilterPreferences.instance.armorSetGender,
  );

  @override
  Future<List<ArmorSet>> fetchItems(String language) =>
      ArmorRepository().getArmorSetList(language);

  void _setFilter(ArmorSetFilter filter) => setState(() => _filter = filter);

  Future<void> _openFilterSheet() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ArmorSetFilterSheet(
        filter: _filter,
        onFilterChange: (filter) {
          _setFilter(filter);
          final prefs = ListFilterPreferences.instance;
          prefs.setArmorSetRarity(filter.rarity);
          prefs.setArmorSetHunterType(filter.hunterType);
          prefs.setArmorSetGender(filter.gender);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: SearchFilterAppBar(
        title: l10n.screenArmorSetList,
        navigation: AppTopBarNavigation.menu,
        onNavigationTap: widget.openDrawer,
        onQueryChanged: (name) => _setFilter(
          ArmorSetFilter(
            name: name.isEmpty ? null : name,
            rarity: _filter.rarity,
            hunterType: _filter.hunterType,
            gender: _filter.gender,
          ),
        ),
        onGlobalSearch: widget.openSearch,
        onFilterTap: _openFilterSheet,
      ),
      body: FilterableListBody<ArmorSet>(
        items: items,
        filter: _filter.matches,
        itemBuilder: (context, armorSet) => PillListItem(
          child: ListItemLayout(
            leading: EntityIcon(
              asset: 'ic_armor_set',
              tint: rarityColor(armorSet.rarity),
            ),
            headline: Text(
              armorSet.name,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            onTap: () => context.push(AppRoutes.armorSetDetail(armorSet.id)),
          ),
        ),
      ),
    );
  }
}

class const _ArmorSetFilterSheet({
  required final ArmorSetFilter filter,
  required final ValueChanged<ArmorSetFilter> onFilterChange,
}) extends StatefulWidget {
  @override
  State<_ArmorSetFilterSheet> createState() => _ArmorSetFilterSheetState();
}

class _ArmorSetFilterSheetState extends State<_ArmorSetFilterSheet> {
  late ArmorSetFilter _filter = widget.filter;

  void _update(ArmorSetFilter filter) {
    setState(() => _filter = filter);
    widget.onFilterChange(filter);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rarities = _filter.rarity ?? const <int>[];

    String labelForHunter(HunterType? hunterType) => switch (hunterType) {
      HunterType.blade => l10n.armorSetFilterHunterBlade,
      HunterType.gunner => l10n.armorSetFilterHunterGunner,
      HunterType.both || null => l10n.armorSetFilterHunterAll,
    };

    String labelForGender(Gender? gender) => switch (gender) {
      Gender.male => l10n.armorSetFilterGenderMale,
      Gender.female => l10n.armorSetFilterGenderFemale,
      Gender.both || null => l10n.armorSetFilterGenderAll,
    };

    return FilterSheetBody(
      children: [
        Text(
          l10n.armorSetFilterHunter,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.medium),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            for (final hunterType in const [
              null,
              HunterType.blade,
              HunterType.gunner,
            ])
              SelectionPill(
                selected: _filter.hunterType == hunterType,
                onTap: () => _update(
                  ArmorSetFilter(
                    name: _filter.name,
                    rarity: _filter.rarity,
                    hunterType: hunterType,
                    gender: _filter.gender,
                  ),
                ),
                compact: true,
                child: Text(labelForHunter(hunterType)),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.large),
        Text(
          l10n.armorSetFilterGender,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.medium),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            for (final gender in const [null, Gender.male, Gender.female])
              SelectionPill(
                selected: _filter.gender == gender,
                onTap: () => _update(
                  ArmorSetFilter(
                    name: _filter.name,
                    rarity: _filter.rarity,
                    hunterType: _filter.hunterType,
                    gender: gender,
                  ),
                ),
                compact: true,
                child: Text(labelForGender(gender)),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.large),
        Text(
          l10n.armorSetFilterRarity,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.medium),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            for (final rarity in _armorSetRarities)
              SelectionPill(
                selected: rarities.contains(rarity),
                onTap: () {
                  final updated = rarities.contains(rarity)
                      ? (rarities.toList()..remove(rarity))
                      : (rarities.toList()..add(rarity));
                  _update(
                    ArmorSetFilter(
                      name: _filter.name,
                      hunterType: _filter.hunterType,
                      gender: _filter.gender,
                      rarity: updated.isEmpty ? null : updated,
                    ),
                  );
                },
                child: Text(rarity.toString()),
              ),
          ],
        ),
      ],
    );
  }
}
