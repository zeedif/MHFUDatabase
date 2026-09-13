import 'package:flutter/material.dart' hide Decoration;

import '../../../../core/state/language_fetch_mixin.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/entity_icon.dart';
import '../../../../core/widgets/filter_sheet_body.dart';
import '../../../../core/widgets/filterable_list_body.dart';
import '../../../../core/widgets/list_item_layout.dart';
import '../../../../core/widgets/mhfu_colors.dart';
import '../../../../core/widgets/pill_list_item.dart';
import '../../../../core/widgets/selection_pill.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../decoration/data/decoration_repository.dart';
import '../../../decoration/domain/decoration_filter.dart';
import '../../../decoration/domain/decoration.dart';
import '../../../skill/domain/skill.dart';
import '../widgets/selection_search_bar.dart';
import 'skill_selection_view.dart';

class const DecorationSelectionView({
  required final int maxAvailableSlots,
  super.key,
}) extends StatefulWidget {
  @override
  State<DecorationSelectionView> createState() =>
      _DecorationSelectionViewState();
}

class _DecorationSelectionViewState extends State<DecorationSelectionView>
    with LanguageFetchMixin<Decoration, DecorationSelectionView> {
  late DecorationFilter _filter = DecorationFilter(
    maxAvailableSlots: widget.maxAvailableSlots,
  );

  @override
  Future<List<Decoration>> fetchItems(String language) =>
      DecorationRepository().getDecorationList(language);

  Future<void> _openFilterSheet() async {
    final updated = await showModalBottomSheet<DecorationFilter>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _DecorationFilterSheet(filter: _filter),
    );
    if (!mounted || updated == null) return;
    setState(() => _filter = updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SelectionSearchBar(
        onQueryChange: (name) => setState(
          () => _filter = DecorationFilter(
            name: name.isEmpty ? null : name,
            maxAvailableSlots: _filter.maxAvailableSlots,
            numberOfSlots: _filter.numberOfSlots,
            skills: _filter.skills,
          ),
        ),
        onFilterTap: _openFilterSheet,
      ),
      body: FilterableListBody<Decoration>(
        items: items,
        filter: _filter.matches,
        itemBuilder: (context, decoration) => PillListItem(
          child: ListItemLayout(
            leading: EntityIcon(
              asset: 'ic_ui_decoration',
              size: AppSize.medium,
              tint: itemIconColorValue(decoration.color),
            ),
            headline: Text(decoration.name),
            supporting: Text('${decoration.requiredSlots}'),
            onTap: () => Navigator.of(context).pop(decoration),
          ),
        ),
      ),
    );
  }
}

class const _DecorationFilterSheet({required final DecorationFilter filter})
    extends StatefulWidget {
  @override
  State<_DecorationFilterSheet> createState() => _DecorationFilterSheetState();
}

class _DecorationFilterSheetState extends State<_DecorationFilterSheet> {
  late DecorationFilter _filter = widget.filter;

  void _apply(DecorationFilter filter) {
    setState(() => _filter = filter);
    Navigator.of(context).pop(filter);
  }

  Future<void> _addSkillFilter() async {
    final skillTree =
        await Navigator.of(
          context,
        ).push<SkillTree>(
          MaterialPageRoute(builder: (_) => const SkillSelectionView()),
        );
    if (skillTree == null || !mounted) return;
    final skills = _filter.skills ?? const <SkillTree>[];
    if (skills.any((skill) => skill.id == skillTree.id)) return;
    _apply(_filter.copyWith(skills: [...skills, skillTree]));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final skills = _filter.skills ?? const <SkillTree>[];
    final numberOfSlots = _filter.numberOfSlots ?? const <int>[];
    final slotOptions = [
      for (var slot = 1; slot <= _filter.maxAvailableSlots!; slot++) slot,
    ];

    return FilterSheetBody(
      children: [
        Text(
          l10n.userSetFilterSkill,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.medium),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            for (final skill in skills)
              SelectionPill(
                selected: true,
                onTap: () => _apply(
                  _filter.copyWith(
                    skills: skills.where((s) => s.id != skill.id).toList(),
                  ),
                ),
                child: Text(skill.name),
              ),
            SelectionPill(
              selected: false,
              onTap: _addSkillFilter,
              child: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.large),
        Text(
          l10n.userSetFilterNumberOfSlots,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.medium),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            for (final slots in slotOptions)
              SelectionPill(
                selected: numberOfSlots.contains(slots),
                onTap: () => _apply(
                  _filter.copyWith(
                    numberOfSlots: numberOfSlots.contains(slots)
                        ? (numberOfSlots.toList()..remove(slots))
                        : (numberOfSlots.toList()..add(slots)),
                  ),
                ),
                child: Text('$slots'),
              ),
          ],
        ),
      ],
    );
  }
}

extension on DecorationFilter {
  DecorationFilter copyWith({
    List<int>? numberOfSlots,
    List<SkillTree>? skills,
  }) {
    return DecorationFilter(
      name: name,
      maxAvailableSlots: maxAvailableSlots,
      numberOfSlots: (numberOfSlots ?? this.numberOfSlots)?.isEmpty ?? true
          ? null
          : numberOfSlots ?? this.numberOfSlots,
      skills: (skills ?? this.skills)?.isEmpty ?? true
          ? null
          : skills ?? this.skills,
    );
  }
}
