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
                final filtered = query.isEmpty
                    ? nodes
                    : nodes
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
                    final depth = query.isEmpty ? node.depth : 0;
                    return Padding(
                      padding: EdgeInsets.only(
                        left: AppPadding.small * depth,
                      ),
                      child: _WeaponTreeTile(weapon: node.weapon),
                    );
                  },
                );
              },
            ),
    );
  }
}

class const _WeaponTreeTile({required final Weapon weapon})
    extends StatelessWidget {
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
