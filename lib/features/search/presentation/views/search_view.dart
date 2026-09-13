import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/enums.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/settings/app_settings_controller.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/screen_padding.dart';
import '../../../../core/widgets/app_h_divider.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/entity_icon.dart';
import '../../../../core/widgets/filter_sheet_body.dart';
import '../../../../core/widgets/list_item_layout.dart';
import '../../../../core/widgets/mhfu_colors.dart';
import '../../../../core/widgets/pill_list_item.dart';
import '../../../../core/widgets/selection_pill.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/search_repository.dart';
import '../../domain/search_entity_type.dart';
import '../../domain/search_results.dart';

typedef _TypeEntry = ({SearchEntityType type, bool active});

// Matches the order results appeared in before the type filter existed.
const _defaultTypeOrder = [
  SearchEntityType.location,
  SearchEntityType.monster,
  SearchEntityType.skillTree,
  SearchEntityType.skill,
  SearchEntityType.quest,
  SearchEntityType.item,
  SearchEntityType.decoration,
  SearchEntityType.armor,
  SearchEntityType.weapon,
];

class const SearchView({
  required final VoidCallback navigateBack,
  super.key,
}) extends StatefulWidget {
  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _repository = SearchRepository();
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  SearchResults? _results;

  // Always starts with every type active, in the default order: this screen
  // must guarantee a full search on open, so it never persists this filter.
  List<_TypeEntry> _typeConfig = [
    for (final type in _defaultTypeOrder) (type: type, active: true),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    if (query.isEmpty) {
      setState(() => _results = null);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), _runSearch);
  }

  Future<void> _runSearch() async {
    final query = _controller.text;
    if (query.isEmpty) {
      setState(() => _results = null);
      return;
    }
    final activeTypes = {
      for (final entry in _typeConfig)
        if (entry.active) entry.type,
    };
    final results = await _repository.search(
      query,
      AppSettingsController.instance.locale.languageCode,
      activeTypes,
    );
    if (mounted) setState(() => _results = results);
  }

  void _onTypeConfigChanged(List<_TypeEntry> config) {
    setState(() => _typeConfig = config);
    _debounce?.cancel();
    _runSearch();
  }

  Future<void> _openFilterSheet() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => FilterSheetBody(
        children: [
          _EntityTypeChipGrid(
            config: _typeConfig,
            onConfigChanged: _onTypeConfigChanged,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: AppSearchField(
          controller: _controller,
          focusNode: _focusNode,
          hintText: l10n.searchHint,
          onBack: widget.navigateBack,
          onChanged: _onQueryChanged,
          trailing: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _openFilterSheet,
            ),
          ],
        ),
      ),
      body: _buildResults(l10n),
    );
  }

  Widget _buildResults(AppLocalizations l10n) {
    final results = _results;
    if (results == null) return const SizedBox.shrink();
    if (results.isEmpty) return Center(child: Text(l10n.searchEmpty));

    final rows = [
      for (final entry in _typeConfig)
        if (entry.active) ..._rowsFor(entry.type, results, l10n),
    ];

    return ListView.separated(
      padding: context.scrollPadding(
        const EdgeInsets.fromLTRB(
          AppPadding.medium,
          0,
          AppPadding.medium,
          AppPadding.small,
        ),
      ),
      itemCount: rows.length,
      separatorBuilder: (context, index) => const AppHDivider(),
      itemBuilder: (context, index) {
        final row = rows[index];
        return PillListItem(
          child: ListItemLayout(
            leading: row.icon,
            headline: Text(
              row.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              row.trailing,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            onTap: row.onTap,
          ),
        );
      },
    );
  }

  List<_SearchRow> _rowsFor(
    SearchEntityType type,
    SearchResults results,
    AppLocalizations l10n,
  ) => switch (type) {
    SearchEntityType.location => [
      for (final location in results.locations)
        _SearchRow(
          icon: EntityIcon(
            asset: locationIconAsset(location.id),
            size: AppSize.small,
          ),
          name: location.name,
          trailing: l10n.searchLocation,
          onTap: () => context.push(AppRoutes.locationDetail(location.id)),
        ),
    ],
    SearchEntityType.monster => [
      for (final monster in results.monsters)
        _SearchRow(
          icon: EntityIcon(
            asset: monsterIconAsset(monster.id),
            size: AppSize.small,
          ),
          name: monster.name,
          trailing: l10n.searchMonster,
          onTap: () => context.push(AppRoutes.monsterDetail(monster.id)),
        ),
    ],
    SearchEntityType.skillTree => [
      for (final skillTree in results.skillTrees)
        _SearchRow(
          icon: const ItemEntityIcon(
            type: ItemIconType.armorStone,
            color: ItemIconColor.white,
            size: AppSize.small,
          ),
          name: skillTree.name,
          trailing: l10n.searchSkillTree,
          onTap: () => context.push(AppRoutes.skillTreeDetail(skillTree.id)),
        ),
    ],
    SearchEntityType.skill => [
      for (final skill in results.skills)
        _SearchRow(
          icon: const ItemEntityIcon(
            type: ItemIconType.armorStone,
            color: ItemIconColor.white,
            size: AppSize.small,
          ),
          name: skill.name,
          trailing: l10n.searchSkill,
          onTap: () =>
              context.push(AppRoutes.skillTreeDetail(skill.skillTreeId)),
        ),
    ],
    SearchEntityType.quest => [
      for (final quest in results.quests)
        _SearchRow(
          icon: QuestGoalIcon(goal: quest.goalType, size: AppSize.small),
          name: quest.name,
          trailing: _searchQuestLabel(l10n, quest.group),
          onTap: () => context.push(AppRoutes.questDetail(quest.id)),
        ),
    ],
    SearchEntityType.item => [
      for (final item in results.items)
        _SearchRow(
          icon: ItemEntityIcon(
            type: item.iconType,
            color: item.iconColor,
            size: AppSize.small,
          ),
          name: item.name,
          trailing: l10n.searchItem,
          onTap: () => context.push(AppRoutes.itemDetail(item.id)),
        ),
    ],
    SearchEntityType.decoration => [
      for (final decoration in results.decorations)
        _SearchRow(
          icon: EntityIcon(
            asset: 'ic_ui_decoration',
            tint: itemIconColorValue(decoration.color),
            size: AppSize.small,
          ),
          name: decoration.name,
          trailing: l10n.searchDecoration,
          onTap: () => context.push(AppRoutes.decorationDetail(decoration.id)),
        ),
    ],
    SearchEntityType.armor => [
      for (final armor in results.armors)
        _SearchRow(
          icon: EntityIcon(
            asset: equipmentTypeIconAsset(armor.type),
            tint: rarityColor(armor.rarity),
            size: AppSize.small,
          ),
          name: armor.name,
          trailing: switch (armor.hunterType) {
            HunterType.both => l10n.searchArmorBoth,
            HunterType.blade => l10n.searchArmorBlade,
            HunterType.gunner => l10n.searchArmorGunner,
          },
          onTap: () => context.push(AppRoutes.armorDetail(armor.id)),
        ),
    ],
    SearchEntityType.weapon => [
      for (final weapon in results.weapons)
        _SearchRow(
          icon: WeaponEntityIcon(
            type: weapon.type,
            rarity: weapon.rarity,
            size: AppSize.small,
          ),
          name: weapon.name,
          trailing: l10n.searchWeapon,
          onTap: () => context.push(AppRoutes.weaponDetail(weapon.id)),
        ),
    ],
  };
}

String _searchQuestLabel(AppLocalizations l10n, QuestGroup group) =>
    switch (group) {
      QuestGroup.village1 ||
      QuestGroup.village2 ||
      QuestGroup.village3 ||
      QuestGroup.village4 ||
      QuestGroup.village5 ||
      QuestGroup.village6 ||
      QuestGroup.village7 ||
      QuestGroup.village8 ||
      QuestGroup.village9 => l10n.searchQuestVillage,
      QuestGroup.hr1a ||
      QuestGroup.hr1b ||
      QuestGroup.hr1c ||
      QuestGroup.hr2 ||
      QuestGroup.hr3 ||
      QuestGroup.hr4 ||
      QuestGroup.hr5 ||
      QuestGroup.hr6 ||
      QuestGroup.hr7 ||
      QuestGroup.hr8 ||
      QuestGroup.hr9 => l10n.searchQuestGuild,
      QuestGroup.treasure => l10n.searchQuestTreasure,
      QuestGroup.event => l10n.searchQuestEvent,
      QuestGroup.beginnerBasic ||
      QuestGroup.beginnerWeapon ||
      QuestGroup.trainingBattle ||
      QuestGroup.trainingSpecial ||
      QuestGroup.trainingG ||
      QuestGroup.groupPractice => l10n.searchQuestTraining,
      QuestGroup.groupChallenge => l10n.searchQuestChallenge,
    };

String _entityTypeLabel(AppLocalizations l10n, SearchEntityType type) =>
    switch (type) {
      SearchEntityType.location => l10n.searchLocation,
      SearchEntityType.monster => l10n.searchMonster,
      SearchEntityType.skillTree => l10n.searchSkillTree,
      SearchEntityType.skill => l10n.searchSkill,
      SearchEntityType.quest => l10n.searchQuest,
      SearchEntityType.item => l10n.searchItem,
      SearchEntityType.decoration => l10n.searchDecoration,
      SearchEntityType.armor => l10n.searchArmorBoth,
      SearchEntityType.weapon => l10n.searchWeapon,
    };

class const _SearchRow({
  required final Widget icon,
  required final String name,
  required final String trailing,
  required final VoidCallback onTap,
}) {}

// ── Entity-type filter: reorderable, toggleable pill grid ──────────────────
// Ports PlayVault's _StatusChipGrid/_DraggableStatusChip drag-reorder
// mechanism onto this app's SelectionPill instead of a FilterChip.

class const _EntityTypeChipGrid({
  required final List<_TypeEntry> config,
  required final ValueChanged<List<_TypeEntry>> onConfigChanged,
}) extends StatefulWidget {
  @override
  State<_EntityTypeChipGrid> createState() => _EntityTypeChipGridState();
}

class _EntityTypeChipGridState extends State<_EntityTypeChipGrid> {
  late List<_TypeEntry> _preview = List.of(widget.config);
  SearchEntityType? _dragging;

  void _moveTo(SearchEntityType from, SearchEntityType to) {
    final fromIndex = _preview.indexWhere((entry) => entry.type == from);
    final toIndex = _preview.indexWhere((entry) => entry.type == to);
    if (fromIndex < 0 || toIndex < 0 || fromIndex == toIndex) return;
    setState(() {
      final item = _preview.removeAt(fromIndex);
      _preview.insert(toIndex, item);
    });
  }

  void _toggle(SearchEntityType type) {
    setState(() {
      _preview = [
        for (final entry in _preview)
          if (entry.type == type)
            (type: entry.type, active: !entry.active)
          else
            entry,
      ];
    });
    widget.onConfigChanged(_preview);
  }

  void _commitReorder() {
    if (_dragging == null) return;
    widget.onConfigChanged(_preview);
    setState(() => _dragging = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Wrap(
      spacing: AppSpacing.small,
      runSpacing: AppSpacing.small,
      children: [
        for (final entry in _preview)
          _DraggableEntityTypeChip(
            key: ValueKey(entry.type),
            entry: entry,
            label: _entityTypeLabel(l10n, entry.type),
            currentlyDragging: _dragging,
            onTap: () => _toggle(entry.type),
            onDragStarted: () => setState(() => _dragging = entry.type),
            onHover: (from) => _moveTo(from, entry.type),
            onDrop: _commitReorder,
          ),
      ],
    );
  }
}

class const _DraggableEntityTypeChip({
  required super.key,
  required final _TypeEntry entry,
  required final String label,
  required final SearchEntityType? currentlyDragging,
  required final VoidCallback onTap,
  required final VoidCallback onDragStarted,
  required final ValueChanged<SearchEntityType> onHover,
  required final VoidCallback onDrop,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isThisDragging = currentlyDragging == entry.type;
    final chip = _EntityTypeChip(active: entry.active, label: label, onTap: onTap);
    final feedback = Material(
      type: MaterialType.transparency,
      elevation: 4,
      shadowColor: Theme.of(context).colorScheme.shadow,
      child: chip,
    );

    return DragTarget<SearchEntityType>(
      onWillAcceptWithDetails: (details) {
        if (details.data != currentlyDragging || details.data == entry.type) {
          return false;
        }
        onHover(details.data);
        return true;
      },
      onAcceptWithDetails: (_) {},
      builder: (context, candidates, _) {
        final isTarget = candidates.isNotEmpty && !isThisDragging;
        return AnimatedScale(
          scale: isTarget ? 1.06 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
          child: LongPressDraggable<SearchEntityType>(
            data: entry.type,
            delay: const Duration(milliseconds: 250),
            feedback: feedback,
            childWhenDragging: Opacity(opacity: 0.35, child: chip),
            onDragStarted: onDragStarted,
            onDragEnd: (_) => onDrop(),
            child: chip,
          ),
        );
      },
    );
  }
}

class const _EntityTypeChip({
  required final bool active,
  required final String label,
  required final VoidCallback onTap,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SelectionPill(
      selected: active,
      onTap: onTap,
      compact: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: AppSpacing.small),
          Icon(
            Icons.drag_indicator,
            size: AppSize.tiny,
            color: colors.onSurface.withValues(alpha: 0.45),
          ),
        ],
      ),
    );
  }
}
