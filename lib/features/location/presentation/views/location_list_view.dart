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
import '../../data/location_repository.dart';
import '../../domain/location_filter.dart';
import '../../domain/location.dart';

class const LocationListView({
  required final VoidCallback openDrawer,
  required final VoidCallback openSearch,
  super.key,
}) extends StatefulWidget {
  @override
  State<LocationListView> createState() => _LocationListViewState();
}

class _LocationListViewState extends State<LocationListView>
    with LanguageFetchMixin<Location, LocationListView> {
  LocationFilter _filter = const LocationFilter();

  @override
  Future<List<Location>> fetchItems(String language) =>
      LocationRepository().getLocationList(language);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: SearchFilterAppBar(
        title: l10n.screenLocationList,
        navigation: AppTopBarNavigation.menu,
        onNavigationTap: widget.openDrawer,
        onQueryChanged: (name) => setState(
          () => _filter = LocationFilter(name: name.isEmpty ? null : name),
        ),
        onGlobalSearch: widget.openSearch,
      ),
      body: FilterableListBody<Location>(
        items: items,
        filter: _filter.matches,
        itemBuilder: (context, location) => PillListItem(
          child: ListItemLayout(
            leading: EntityIcon(asset: locationIconAsset(location.id)),
            headline: Text(
              location.name,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            onTap: () => context.push(AppRoutes.locationDetail(location.id)),
          ),
        ),
      ),
    );
  }
}
