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
import '../../../../core/widgets/pill_list_item.dart';
import '../../../../core/widgets/search_filter_app_bar.dart';
import '../../../../core/widgets/selection_pill.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/monster_repository.dart';
import '../../domain/monster_filter.dart';
import '../../domain/monster.dart';

class const MonsterListView({
  required final VoidCallback openDrawer,
  required final VoidCallback openSearch,
  super.key,
}) extends StatefulWidget {
  @override
  State<MonsterListView> createState() => _MonsterListViewState();
}

class _MonsterListViewState extends State<MonsterListView> {
  MonsterFilter _filter = const MonsterFilter();

  void _setFilter(MonsterFilter filter) => setState(() => _filter = filter);

  Future<void> _openFilterSheet() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          _MonsterFilterSheet(filter: _filter, onFilterChange: _setFilter),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: SearchFilterAppBar(
        title: l10n.screenMonsterList,
        navigation: AppTopBarNavigation.menu,
        onNavigationTap: widget.openDrawer,
        onQueryChanged: (name) => _setFilter(
          MonsterFilter(name: name.isEmpty ? null : name, type: _filter.type),
        ),
        onGlobalSearch: widget.openSearch,
        onFilterTap: _openFilterSheet,
      ),
      body: FutureBuilder<List<Monster>>(
        future: MonsterRepository().getMonsterList(
          AppSettingsController.instance.locale.languageCode,
          filter: _filter,
        ),
        builder: (context, snapshot) {
          final monsters = snapshot.data;
          if (monsters == null) {
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
            itemCount: monsters.length,
            separatorBuilder: (context, index) => const AppHDivider(),
            itemBuilder: (context, index) {
              final monster = monsters[index];
              return PillListItem(
                child: ListItemLayout(
                  leading: EntityIcon(asset: monsterIconAsset(monster.id)),
                  headline: Text(monster.name),
                  supporting: Text(monster.ecology),
                  onTap: () =>
                      context.push(AppRoutes.monsterDetail(monster.id)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class const _MonsterFilterSheet({
  required final MonsterFilter filter,
  required final ValueChanged<MonsterFilter> onFilterChange,
}) extends StatefulWidget {
  @override
  State<_MonsterFilterSheet> createState() => _MonsterFilterSheetState();
}

class _MonsterFilterSheetState extends State<_MonsterFilterSheet> {
  late MonsterFilter _filter = widget.filter;

  void _update(MonsterFilter filter) {
    setState(() => _filter = filter);
    widget.onFilterChange(filter);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    String labelFor(MonsterType? type) => switch (type) {
      MonsterType.small => l10n.monsterFilterSizeSmall,
      MonsterType.large => l10n.monsterFilterSizeLarge,
      null => l10n.monsterFilterSizeAll,
    };

    return FilterSheetBody(
      children: [
        Text(
          l10n.monsterFilterSize,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.medium),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            for (final type in [null, ...MonsterType.values])
              SelectionPill(
                selected: _filter.type == type,
                onTap: () =>
                    _update(MonsterFilter(name: _filter.name, type: type)),
                compact: true,
                child: Text(labelFor(type)),
              ),
          ],
        ),
      ],
    );
  }
}
