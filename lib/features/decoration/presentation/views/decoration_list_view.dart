import 'package:flutter/material.dart' hide Decoration;
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/state/language_fetch_mixin.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/entity_icon.dart';
import '../../../../core/widgets/filterable_list_body.dart';
import '../../../../core/widgets/list_item_layout.dart';
import '../../../../core/widgets/mhfu_colors.dart';
import '../../../../core/widgets/pill_list_item.dart';
import '../../../../core/widgets/search_filter_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/decoration_repository.dart';
import '../../domain/decoration_filter.dart';
import '../../domain/decoration.dart';

class const DecorationListView({
  required final VoidCallback openDrawer,
  required final VoidCallback openSearch,
  super.key,
}) extends StatefulWidget {
  @override
  State<DecorationListView> createState() => _DecorationListViewState();
}

class _DecorationListViewState extends State<DecorationListView>
    with LanguageFetchMixin<Decoration, DecorationListView> {
  DecorationFilter _filter = const DecorationFilter();

  @override
  Future<List<Decoration>> fetchItems(String language) =>
      DecorationRepository().getDecorationList(language);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: SearchFilterAppBar(
        title: l10n.screenDecorationList,
        navigation: AppTopBarNavigation.menu,
        onNavigationTap: widget.openDrawer,
        onQueryChanged: (name) => setState(
          () => _filter = DecorationFilter(name: name.isEmpty ? null : name),
        ),
        onGlobalSearch: widget.openSearch,
      ),
      body: FilterableListBody<Decoration>(
        items: items,
        filter: _filter.matches,
        itemBuilder: (context, decoration) => PillListItem(
          child: ListItemLayout(
            leading: EntityIcon(
              asset: 'ic_ui_decoration',
              tint: itemIconColorValue(decoration.color),
              size: AppSize.medium,
            ),
            headline: Text(decoration.name),
            onTap: () =>
                context.push(AppRoutes.decorationDetail(decoration.id)),
          ),
        ),
      ),
    );
  }
}
