import 'package:flutter/material.dart';

import '../../../../core/domain/enums.dart';
import '../../../../core/state/language_fetch_mixin.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/filter_sheet_body.dart';
import '../../../../core/widgets/filterable_list_body.dart';
import '../../../../core/widgets/list_item_layout.dart';
import '../../../../core/widgets/pill_list_item.dart';
import '../../../../core/widgets/selection_pill.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../skill/data/skill_repository.dart';
import '../../../skill/domain/skill_tree_filter.dart';
import '../../../skill/domain/skill.dart';
import '../widgets/selection_search_bar.dart';

class const SkillSelectionView({super.key}) extends StatefulWidget {
  @override
  State<SkillSelectionView> createState() => _SkillSelectionViewState();
}

class _SkillSelectionViewState extends State<SkillSelectionView>
    with LanguageFetchMixin<SkillTree, SkillSelectionView> {
  SkillTreeFilter _filter = const SkillTreeFilter();

  @override
  Future<List<SkillTree>> fetchItems(String language) =>
      SkillRepository().getSkillTreeList(language);

  Future<void> _openFilterSheet() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _SkillCategorySheet(
        selected: _filter.category,
        onCategoryChange: (category) => setState(
          () => _filter = SkillTreeFilter(
            name: _filter.name,
            category: category,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SelectionSearchBar(
        onQueryChange: (name) => setState(
          () => _filter = SkillTreeFilter(
            name: name.isEmpty ? null : name,
            category: _filter.category,
          ),
        ),
        onFilterTap: _openFilterSheet,
      ),
      body: FilterableListBody<SkillTree>(
        items: items,
        filter: _filter.matches,
        itemBuilder: (context, skillTree) => PillListItem(
          child: ListItemLayout(
            headline: Text(skillTree.name),
            onTap: () => Navigator.of(context).pop(skillTree),
          ),
        ),
      ),
    );
  }
}

class const _SkillCategorySheet({
  required final SkillCategory? selected,
  required final ValueChanged<SkillCategory?> onCategoryChange,
}) extends StatefulWidget {
  @override
  State<_SkillCategorySheet> createState() => _SkillCategorySheetState();
}

class _SkillCategorySheetState extends State<_SkillCategorySheet> {
  late SkillCategory? _selected = widget.selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    String labelFor(SkillCategory category) => switch (category) {
      SkillCategory.blade => l10n.userSetFilterSkillBlade,
      SkillCategory.combat => l10n.userSetFilterSkillCombat,
      SkillCategory.felyne => l10n.userSetFilterSkillFelyne,
      SkillCategory.gather => l10n.userSetFilterSkillGather,
      SkillCategory.gunner => l10n.userSetFilterSkillGunner,
      SkillCategory.item => l10n.userSetFilterSkillItem,
      SkillCategory.resistance => l10n.userSetFilterSkillResistance,
      SkillCategory.status => l10n.userSetFilterSkillStatus,
    };

    return FilterSheetBody(
      children: [
        Text(
          l10n.userSetFilterSkillCategory,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.medium),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            for (final category in SkillCategory.values)
              SelectionPill(
                selected: category == _selected,
                onTap: () {
                  final updated = category == _selected ? null : category;
                  setState(() => _selected = updated);
                  widget.onCategoryChange(updated);
                },
                child: Text(labelFor(category)),
              ),
          ],
        ),
      ],
    );
  }
}
