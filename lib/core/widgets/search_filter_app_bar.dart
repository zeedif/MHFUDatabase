import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'app_search_field.dart';
import 'app_top_bar.dart';

class const SearchFilterAppBar({
  required final String title,
  required final AppTopBarNavigation navigation,
  required final VoidCallback onNavigationTap,
  required final ValueChanged<String> onQueryChanged,
  required final VoidCallback onGlobalSearch,
  final VoidCallback? onFilterTap,
  super.key,
}) extends StatefulWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<SearchFilterAppBar> createState() => _SearchFilterAppBarState();
}

class _SearchFilterAppBarState extends State<SearchFilterAppBar> {
  final _controller = TextEditingController();
  bool _searching = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openSearch() => setState(() => _searching = true);

  void _closeSearch() {
    _controller.clear();
    widget.onQueryChanged('');
    setState(() => _searching = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      scrolledUnderElevation: 0,
      titleSpacing: _searching ? 0 : null,
      automaticallyImplyLeading: false,
      leading: _searching
          ? null
          : IconButton(
              icon: Icon(
                widget.navigation == AppTopBarNavigation.menu
                    ? Icons.menu
                    : Icons.arrow_back,
              ),
              onPressed: widget.onNavigationTap,
            ),
      title: _searching
          ? AppSearchField(
              controller: _controller,
              autofocus: true,
              hintText: l10n.searchHint,
              onBack: _closeSearch,
              onChanged: widget.onQueryChanged,
              trailing: [
                if (widget.onFilterTap != null)
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: widget.onFilterTap,
                  ),
                IconButton(
                  icon: const Icon(Icons.travel_explore),
                  onPressed: widget.onGlobalSearch,
                ),
              ],
            )
          : Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      actions: _searching
          ? const []
          : [
              if (widget.onFilterTap != null)
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: widget.onFilterTap,
                ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: _openSearch,
              ),
            ],
    );
  }
}
