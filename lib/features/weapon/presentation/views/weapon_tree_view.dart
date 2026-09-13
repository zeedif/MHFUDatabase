import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/localized_collation.dart';
import '../../../../core/domain/enums.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/state/language_fetch_mixin.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/screen_padding.dart';
import '../../../../core/widgets/app_h_divider.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/entity_icon.dart';
import '../../../../core/widgets/search_filter_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/weapon_repository.dart';
import '../../domain/weapon.dart';
import 'weapon_type_list_view.dart' show weaponTypeLabel;

class const WeaponTreeView({
  required final String weaponType,
  required final VoidCallback navigateBack,
  required final VoidCallback openSearch,
  super.key,
}) extends StatefulWidget {
  @override
  State<WeaponTreeView> createState() => _WeaponTreeViewState();
}

class _WeaponTreeViewState extends State<WeaponTreeView>
    with LanguageFetchMixin<FlattenedWeaponNode, WeaponTreeView> {
  String _query = '';

  @override
  Future<List<FlattenedWeaponNode>> fetchItems(String language) =>
      WeaponRepository().getWeaponTree(
        WeaponType.fromDb(widget.weaponType),
        language,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final type = WeaponType.fromDb(widget.weaponType);
    final title = weaponTypeLabel(l10n, type);
    final nodes = items;

    return Scaffold(
      appBar: SearchFilterAppBar(
        title: title,
        navigation: AppTopBarNavigation.back,
        onNavigationTap: widget.navigateBack,
        onQueryChanged: (query) => setState(() => _query = query),
        onGlobalSearch: widget.openSearch,
      ),
      body: nodes == null
          ? const Center(child: CircularProgressIndicator())
          : Builder(
              builder: (context) {
                final query = normalizeForSearch(_query);

                if (query.isNotEmpty) {
                  final filtered = nodes
                      .where(
                        (node) => normalizeForSearch(
                          node.weapon.name,
                        ).contains(query),
                      )
                      .toList();

                  return ListView.separated(
                    padding: context.scrollPadding(
                      const EdgeInsets.fromLTRB(
                        AppPadding.medium,
                        0,
                        AppPadding.medium,
                        AppPadding.small,
                      ),
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const AppHDivider(),
                    itemBuilder: (context, index) {
                      final node = filtered[index];
                      return _WeaponTreeTile(
                        weapon: node.weapon,
                        isLeaf: !node.hasChildren,
                      );
                    },
                  );
                }

                final maxDepth = nodes.fold<int>(
                  0,
                  (max, node) => math.max(max, node.depth),
                );
                final treeWidth =
                    maxDepth * _TreeGuides.indentWidth + _minTileWidth;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: math.max(constraints.maxWidth, treeWidth),
                        child: ListView.separated(
                          padding: context.scrollPadding(
                            const EdgeInsets.fromLTRB(
                              AppPadding.medium,
                              0,
                              AppPadding.medium,
                              AppPadding.small,
                            ),
                          ),
                          itemCount: nodes.length,
                          separatorBuilder: (context, index) =>
                              const AppHDivider(),
                          itemBuilder: (context, index) {
                            final node = nodes[index];
                            return IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  _TreeGuides(
                                    depth: node.depth,
                                    ancestorContinues: node.ancestorContinues,
                                    isLastInGroup: node.isLastInGroup,
                                  ),
                                  Expanded(
                                    child: _WeaponTreeTile(
                                      weapon: node.weapon,
                                      isLeaf: !node.hasChildren,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

const _minTileWidth = 260.0;

/// Draws the ancestor guide lines and the elbow connecting a tree node to
/// its parent, mimicking a file-explorer style tree instead of raw
/// indentation.
class _TreeGuides extends StatelessWidget {
  const _TreeGuides({
    required this.depth,
    required this.ancestorContinues,
    required this.isLastInGroup,
  });

  final int depth;
  final List<bool> ancestorContinues;
  final bool isLastInGroup;

  static const indentWidth = 20.0;

  @override
  Widget build(BuildContext context) {
    if (depth == 0) return const SizedBox.shrink();

    return SizedBox(
      width: depth * indentWidth,
      child: CustomPaint(
        painter: _TreeGuidePainter(
          ancestorContinues: ancestorContinues,
          isLastInGroup: isLastInGroup,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
    );
  }
}

class _TreeGuidePainter extends CustomPainter {
  _TreeGuidePainter({
    required this.ancestorContinues,
    required this.isLastInGroup,
    required this.color,
  });

  final List<bool> ancestorContinues;
  final bool isLastInGroup;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < ancestorContinues.length; i++) {
      if (!ancestorContinues[i]) continue;
      final x = (i + 0.5) * _TreeGuides.indentWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    final ownColumn = ancestorContinues.length;
    final x = (ownColumn + 0.5) * _TreeGuides.indentWidth;
    final centerY = size.height / 2;

    canvas.drawLine(Offset(x, 0), Offset(x, centerY), paint);
    if (!isLastInGroup) {
      canvas.drawLine(Offset(x, centerY), Offset(x, size.height), paint);
    }
    canvas.drawLine(Offset(x, centerY), Offset(size.width, centerY), paint);
  }

  @override
  bool shouldRepaint(covariant _TreeGuidePainter oldDelegate) {
    if (oldDelegate.isLastInGroup != isLastInGroup ||
        oldDelegate.color != color ||
        oldDelegate.ancestorContinues.length != ancestorContinues.length) {
      return true;
    }
    for (var i = 0; i < ancestorContinues.length; i++) {
      if (oldDelegate.ancestorContinues[i] != ancestorContinues[i]) {
        return true;
      }
    }
    return false;
  }
}

class const _WeaponTreeTile({
  required final Weapon weapon,
  required final bool isLeaf,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.small),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.weaponDetail(weapon.id)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.large,
            vertical: AppPadding.medium,
          ),
          child: Row(
            children: [
              WeaponEntityIcon(type: weapon.type, rarity: weapon.rarity),
              const SizedBox(width: AppSpacing.large),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weapon.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: isLeaf ? FontWeight.bold : null,
                        fontStyle: weapon.buildable
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Row(
                      children: [
                        Text('${weapon.attack}'),
                        if (weapon.element1 != null &&
                            weapon.element1Value != null) ...[
                          const SizedBox(width: AppSpacing.medium),
                          Image.asset(
                            'assets/images/${elementIconAsset(weapon.element1!)}.webp',
                            width: AppSize.tiny,
                            height: AppSize.tiny,
                          ),
                          Text('${weapon.element1Value}'),
                        ],
                        if (weapon.element2 != null &&
                            weapon.element2Value != null) ...[
                          const SizedBox(width: AppSpacing.medium),
                          Image.asset(
                            'assets/images/${elementIconAsset(weapon.element2!)}.webp',
                            width: AppSize.tiny,
                            height: AppSize.tiny,
                          ),
                          Text('${weapon.element2Value}'),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Text(l10n.weaponRarity(weapon.rarity)),
            ],
          ),
        ),
      ),
    );
  }
}
