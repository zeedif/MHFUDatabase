import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/localized_collation.dart';
import '../../../../core/domain/enums.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/state/language_fetch_mixin.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/screen_padding.dart';
import '../../../../core/widgets/app_h_divider.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/entity_icon.dart';
import '../../../../core/widgets/filterable_list_body.dart';
import '../../../../core/widgets/list_item_layout.dart';
import '../../../../core/widgets/pill_list_item.dart';
import '../../../../core/widgets/search_filter_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/weapon_repository.dart';
import '../../domain/weapon_filter.dart';
import '../../domain/weapon.dart';
import '../widgets/weapon_filter_sheet.dart';

String weaponTypeLabel(AppLocalizations l10n, WeaponType type) =>
    switch (type) {
      WeaponType.greatSword => l10n.screenWeaponGreatSword,
      WeaponType.longSword => l10n.screenWeaponLongSword,
      WeaponType.swordAndShield => l10n.screenWeaponSwordAndShield,
      WeaponType.dualBlades => l10n.screenWeaponDualBlades,
      WeaponType.hammer => l10n.screenWeaponHammer,
      WeaponType.huntingHorn => l10n.screenWeaponHuntingHorn,
      WeaponType.lance => l10n.screenWeaponLance,
      WeaponType.gunlance => l10n.screenWeaponGunlance,
      WeaponType.lightBowgun => l10n.screenWeaponLightBowgun,
      WeaponType.heavyBowgun => l10n.screenWeaponHeavyBowgun,
      WeaponType.bow => l10n.screenWeaponBow,
    };

class const WeaponTypeListView({
  required final VoidCallback openDrawer,
  required final VoidCallback openSearch,
  super.key,
}) extends StatefulWidget {
  @override
  State<WeaponTypeListView> createState() => _WeaponTypeListViewState();
}

class _WeaponTypeListViewState extends State<WeaponTypeListView>
    with LanguageFetchMixin<Weapon, WeaponTypeListView> {
  // Not persisted: this screen always starts on the type-tile view.
  WeaponFilter _filter = const WeaponFilter();

  @override
  Future<List<Weapon>> fetchItems(String language) =>
      WeaponRepository().getWeaponList(language);

  void _setFilter(WeaponFilter filter) => setState(() => _filter = filter);

  Future<void> _openFilterSheet() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => WeaponFilterSheet(
        filter: _filter,
        onFilterChange: _setFilter,
      ),
    );
  }

  // The text query alone filters the type tiles; only a structured
  // criterion switches to the flat weapon list.
  bool get _hasStructuredFilter =>
      _filter.weaponType != null ||
      _filter.elementType != null ||
      _filter.rarity != null ||
      _filter.numberOfSlots != null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: SearchFilterAppBar(
        title: l10n.screenWeaponTypeList,
        navigation: AppTopBarNavigation.menu,
        onNavigationTap: widget.openDrawer,
        onQueryChanged: (query) =>
            _setFilter(_filter.withName(query.isEmpty ? null : query)),
        onGlobalSearch: widget.openSearch,
        onFilterTap: _openFilterSheet,
      ),
      body: _hasStructuredFilter
          ? FilterableListBody<Weapon>(
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
                  onTap: () => context.push(AppRoutes.weaponDetail(weapon.id)),
                ),
              ),
            )
          : _buildTypeList(l10n),
    );
  }

  Widget _buildTypeList(AppLocalizations l10n) {
    final query = normalizeForSearch(_filter.name ?? '');
    final types = query.isEmpty
        ? WeaponType.values
        : WeaponType.values
              .where(
                (type) =>
                    normalizeForSearch(weaponTypeLabel(l10n, type))
                        .contains(query),
              )
              .toList();

    return ListView.separated(
      padding: context.scrollPadding(
        const EdgeInsets.fromLTRB(
          AppPadding.medium,
          0,
          AppPadding.medium,
          AppPadding.small,
        ),
      ),
      itemCount: types.length,
      separatorBuilder: (context, index) => const AppHDivider(),
      itemBuilder: (context, index) {
        final type = types[index];
        return PillListItem(
          child: ListItemLayout(
            leading: WeaponEntityIcon(
              type: type,
              rarity: 1,
              size: AppSize.extraLarge,
            ),
            headline: Text(weaponTypeLabel(l10n, type)),
            onTap: () => context.push(AppRoutes.weaponTree(type.dbValue)),
          ),
        );
      },
    );
  }
}
