import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/state/language_fetch_mixin.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/entity_icon.dart';
import '../../../../core/widgets/filterable_list_body.dart';
import '../../../../core/widgets/list_item_layout.dart';
import '../../../../core/widgets/pill_list_item.dart';
import '../../../../core/widgets/search_filter_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/veggie_repository.dart';
import '../../domain/veggie_filter.dart';
import '../../domain/veggie.dart';

String _areaLabel(AppLocalizations l10n, int area) =>
    area == 0 ? l10n.locationBaseCamp : l10n.locationArea(area);

class const VeggieListView({
  required final VoidCallback openDrawer,
  required final VoidCallback openSearch,
  super.key,
}) extends StatefulWidget {
  @override
  State<VeggieListView> createState() => _VeggieListViewState();
}

class _VeggieListViewState extends State<VeggieListView>
    with LanguageFetchMixin<VeggieLocation, VeggieListView> {
  VeggieFilter _filter = const VeggieFilter();

  @override
  Future<List<VeggieLocation>> fetchItems(String language) =>
      VeggieRepository().getVeggieLocationList(language);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: SearchFilterAppBar(
        title: l10n.screenVeggieList,
        navigation: AppTopBarNavigation.menu,
        onNavigationTap: widget.openDrawer,
        onQueryChanged: (name) => setState(
          () => _filter = VeggieFilter(name: name.isEmpty ? null : name),
        ),
        onGlobalSearch: widget.openSearch,
      ),
      body: FilterableListBody<VeggieLocation>(
        items: items,
        filter: _filter.matches,
        itemBuilder: (context, veggieLocation) => PillListItem(
          child: ListItemLayout(
            leading: EntityIcon(
              asset: locationIconAsset(veggieLocation.location.id),
            ),
            headline: Text(
              veggieLocation.location.name,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            supporting: Text(
              _areaLabel(l10n, veggieLocation.locationArea),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onTap: () =>
                context.push(AppRoutes.veggieDetail(veggieLocation.id)),
          ),
        ),
      ),
    );
  }
}
