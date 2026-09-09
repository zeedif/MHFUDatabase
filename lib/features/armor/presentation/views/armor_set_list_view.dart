import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/enums.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/settings/app_settings_controller.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/screen_padding.dart';
import '../../../../core/widgets/app_h_divider.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/entity_icon.dart';
import '../../../../core/widgets/filter_sheet_body.dart';
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

class _ArmorSetListViewState extends State<ArmorSetListView> {
  ArmorSetFilter _filter = const ArmorSetFilter();

  void _setFilter(ArmorSetFilter filter) => setState(() => _filter = filter);

  Future<void> _openFilterSheet() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          _ArmorSetFilterSheet(filter: _filter, onFilterChange: _setFilter),
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
      body: FutureBuilder<List<ArmorSet>>(
        future: ArmorRepository().getArmorSetList(
          AppSettingsController.instance.locale.languageCode,
          filter: _filter,
        ),
        builder: (context, snapshot) {
          final armorSets = snapshot.data;
          if (armorSets == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.separated(
            padding: context.scrollPadding(
              const EdgeInsets.fromLTRB(
                AppPadding.medium,
                0,
                AppPadding.medium,
                AppPadding.small,
              ),
            ),
            itemCount: armorSets.length,
            separatorBuilder: (context, index) => const AppHDivider(),
            itemBuilder: (context, index) {
              final armorSet = armorSets[index];
              return PillListItem(
                child: ListItemLayout(
                  leading: EntityIcon(
                    asset: 'ic_armor_set',
                    tint: rarityColor(armorSet.rarity),
                  ),
                  headline: Text(
                    armorSet.name,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  onTap: () =>
                      context.push(AppRoutes.armorSetDetail(armorSet.id)),
                ),
              );
            },
          );
        },
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
