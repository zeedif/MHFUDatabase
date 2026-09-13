import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/state/language_fetch_mixin.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/filterable_list_body.dart';
import '../../../../core/widgets/list_item_layout.dart';
import '../../../../core/widgets/pill_list_item.dart';
import '../../../../core/widgets/search_filter_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/skill_repository.dart';
import '../../domain/skill_tree_filter.dart';
import '../../domain/skill.dart';

class const SkillTreeListView({
  required final VoidCallback openDrawer,
  required final VoidCallback openSearch,
  super.key,
}) extends StatefulWidget {
  @override
  State<SkillTreeListView> createState() => _SkillTreeListViewState();
}

class _SkillTreeListViewState extends State<SkillTreeListView>
    with LanguageFetchMixin<SkillTree, SkillTreeListView> {
  SkillTreeFilter _filter = const SkillTreeFilter();

  @override
  Future<List<SkillTree>> fetchItems(String language) =>
      SkillRepository().getSkillTreeList(language);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: SearchFilterAppBar(
        title: l10n.screenSkillTreeList,
        navigation: AppTopBarNavigation.menu,
        onNavigationTap: widget.openDrawer,
        onQueryChanged: (name) => setState(
          () => _filter = SkillTreeFilter(name: name.isEmpty ? null : name),
        ),
        onGlobalSearch: widget.openSearch,
      ),
      body: FilterableListBody<SkillTree>(
        items: items,
        filter: _filter.matches,
        itemBuilder: (context, skillTree) => PillListItem(
          child: ListItemLayout(
            headline: Text(skillTree.name),
            onTap: () => context.push(AppRoutes.skillTreeDetail(skillTree.id)),
          ),
        ),
      ),
    );
  }
}
