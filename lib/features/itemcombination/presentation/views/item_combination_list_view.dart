import 'package:flutter/material.dart';

import '../../../../core/domain/enums.dart';
import '../../../../core/state/language_fetch_mixin.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/filter_sheet_body.dart';
import '../../../../core/widgets/filterable_list_body.dart';
import '../../../../core/widgets/pill_list_item.dart';
import '../../../../core/widgets/selection_pill.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/item_combination_repository.dart';
import '../../domain/item_combination.dart';
import '../widgets/combination_row.dart';

class const ItemCombinationListView({
  required final VoidCallback openDrawer,
  required final VoidCallback openSearch,
  super.key,
}) extends StatefulWidget {
  @override
  State<ItemCombinationListView> createState() =>
      _ItemCombinationListViewState();
}

class _ItemCombinationListViewState extends State<ItemCombinationListView>
    with LanguageFetchMixin<ItemCombination, ItemCombinationListView> {
  ItemCombinationType? _type;

  @override
  Future<List<ItemCombination>> fetchItems(String language) =>
      ItemCombinationRepository().getItemCombinationList(language);

  Future<void> _openFilterSheet() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CombinationFilterSheet(
        type: _type,
        onFilterChange: (type) => setState(() => _type = type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppTopBar(
        title: l10n.screenItemCombinationList,
        navigation: AppTopBarNavigation.menu,
        onNavigationTap: widget.openDrawer,
        onSearchTap: widget.openSearch,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      body: FilterableListBody<ItemCombination>(
        items: items,
        filter: (c) => _type == null || c.type == _type,
        itemBuilder: (context, combination) =>
            PillListItem(child: CombinationRow(combination: combination)),
      ),
    );
  }
}

class const _CombinationFilterSheet({
  required final ItemCombinationType? type,
  required final ValueChanged<ItemCombinationType?> onFilterChange,
}) extends StatefulWidget {
  @override
  State<_CombinationFilterSheet> createState() =>
      _CombinationFilterSheetState();
}

class _CombinationFilterSheetState extends State<_CombinationFilterSheet> {
  late ItemCombinationType? _type = widget.type;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    String labelFor(ItemCombinationType? type) => switch (type) {
      ItemCombinationType.normal => l10n.combinationFilterTypeNormal,
      ItemCombinationType.treasure => l10n.combinationFilterTypeTreasure,
      ItemCombinationType.alchemy => l10n.combinationFilterTypeAlchemy,
      null => l10n.combinationFilterTypeAll,
    };

    return FilterSheetBody(
      children: [
        Text(
          l10n.combinationFilterType,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.medium),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            for (final type in [null, ...ItemCombinationType.values])
              SelectionPill(
                selected: _type == type,
                onTap: () {
                  setState(() => _type = type);
                  widget.onFilterChange(type);
                },
                compact: true,
                child: Text(labelFor(type)),
              ),
          ],
        ),
      ],
    );
  }
}
