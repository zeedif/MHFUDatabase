import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/enums.dart';
import '../../../../core/router/app_routes.dart';
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
import '../../data/item_repository.dart';
import '../../domain/item_filter.dart';
import '../../domain/item.dart';

const _itemRarities = [1, 2, 3, 4, 5, 6, 7, 8];

class const ItemListView({
  required final VoidCallback openDrawer,
  required final VoidCallback openSearch,
  super.key,
}) extends StatefulWidget {
  @override
  State<ItemListView> createState() => _ItemListViewState();
}

class _ItemListViewState extends State<ItemListView>
    with LanguageFetchMixin<Item, ItemListView> {
  ItemFilter _filter = const ItemFilter();

  @override
  Future<List<Item>> fetchItems(String language) =>
      ItemRepository().getItemList(language);

  void _setFilter(ItemFilter filter) => setState(() => _filter = filter);

  Future<void> _openFilterSheet() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          _ItemFilterSheet(filter: _filter, onFilterChange: _setFilter),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: SearchFilterAppBar(
        title: l10n.screenItemList,
        navigation: AppTopBarNavigation.menu,
        onNavigationTap: widget.openDrawer,
        onQueryChanged: (name) => _setFilter(_filter.copyWith(name: name)),
        onGlobalSearch: widget.openSearch,
        onFilterTap: _openFilterSheet,
      ),
      body: FilterableListBody<Item>(
        items: items,
        filter: _filter.matches,
        itemBuilder: (context, item) =>
            PillListItem(child: _ItemRow(item: item)),
      ),
    );
  }
}

class const _ItemFilterSheet({
  required final ItemFilter filter,
  required final ValueChanged<ItemFilter> onFilterChange,
}) extends StatefulWidget {
  @override
  State<_ItemFilterSheet> createState() => _ItemFilterSheetState();
}

class _ItemFilterSheetState extends State<_ItemFilterSheet> {
  late ItemFilter _filter = widget.filter;

  void _update(ItemFilter filter) {
    setState(() => _filter = filter);
    widget.onFilterChange(filter);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rarities = _filter.rarity ?? const <int>[];
    final icons = _filter.icons ?? const <ItemIconType>[];
    final colors = _filter.iconColors ?? const <ItemIconColor>[];

    return FilterSheetBody(
      children: [
        Text(
          l10n.itemFilterRarity,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.medium),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            for (final rarity in _itemRarities)
              SelectionPill(
                selected: rarities.contains(rarity),
                onTap: () => _update(
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
          l10n.itemFilterIcon,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.medium),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            for (final icon in ItemIconType.values)
              SelectionPill(
                selected: icons.contains(icon),
                onTap: () => _update(
                  _filter.copyWith(
                    icons: icons.contains(icon)
                        ? (icons.toList()..remove(icon))
                        : (icons.toList()..add(icon)),
                  ),
                ),
                child: Image.asset(
                  'assets/images/${itemIconAsset(icon)}.webp',
                  width: AppSize.extraSmall,
                  height: AppSize.extraSmall,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.large),
        Text(
          l10n.itemFilterColor,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.medium),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            for (final color in ItemIconColor.values)
              SelectionPill(
                selected: colors.contains(color),
                onTap: () => _update(
                  _filter.copyWith(
                    iconColors: colors.contains(color)
                        ? (colors.toList()..remove(color))
                        : (colors.toList()..add(color)),
                  ),
                ),
                child: Container(
                  width: AppSize.extraSmall,
                  height: AppSize.extraSmall,
                  decoration: BoxDecoration(
                    color: itemIconColorValue(color),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class const _ItemRow({required final Item item}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListItemLayout(
      leading: ItemEntityIcon(
        type: item.iconType,
        color: item.iconColor,
        size: AppSize.medium,
      ),
      headline: Text(
        item.name,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      onTap: () => context.push(AppRoutes.itemDetail(item.id)),
    );
  }
}

extension on ItemFilter {
  ItemFilter copyWith({
    String? name,
    List<int>? rarity,
    List<ItemIconType>? icons,
    List<ItemIconColor>? iconColors,
  }) {
    return ItemFilter(
      name: (name ?? this.name)?.isEmpty ?? true ? null : name ?? this.name,
      rarity: (rarity ?? this.rarity)?.isEmpty ?? true
          ? null
          : rarity ?? this.rarity,
      icons: (icons ?? this.icons)?.isEmpty ?? true
          ? null
          : icons ?? this.icons,
      iconColors: (iconColors ?? this.iconColors)?.isEmpty ?? true
          ? null
          : iconColors ?? this.iconColors,
    );
  }
}
