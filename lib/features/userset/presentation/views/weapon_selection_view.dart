import 'package:flutter/material.dart';

import '../../../../core/domain/enums.dart';
import '../../../../core/state/language_fetch_mixin.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/entity_icon.dart';
import '../../../../core/widgets/filterable_list_body.dart';
import '../../../../core/widgets/list_item_layout.dart';
import '../../../../core/widgets/pill_list_item.dart';
import '../../../weapon/data/weapon_repository.dart';
import '../../../weapon/domain/weapon_filter.dart';
import '../../../weapon/domain/weapon.dart';
import '../../../weapon/presentation/widgets/weapon_filter_sheet.dart';
import '../widgets/selection_search_bar.dart';

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

  Future<void> _openFilterSheet() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => WeaponFilterSheet(
        filter: _filter,
        onFilterChange: (filter) => setState(() => _filter = filter),
        weaponTypeOptions: WeaponType.forHunterType(widget.hunterType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SelectionSearchBar(
        onQueryChange: (name) => setState(
          () => _filter = _filter.withName(name.isEmpty ? null : name),
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
