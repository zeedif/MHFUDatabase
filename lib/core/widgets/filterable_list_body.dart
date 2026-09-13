import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import '../theme/screen_padding.dart';
import 'app_h_divider.dart';

/// Body for a list+filter screen that renders as a flat, separated list:
/// a loading spinner while `items` is `null`, otherwise `items` filtered
/// with `filter` and rendered through `itemBuilder`. A screen with custom
/// rendering (grouping, sections) should build its own body against
/// `items` directly instead — see `quest_list_view.dart`.
class FilterableListBody<T> extends StatelessWidget {
  const FilterableListBody({
    required this.items,
    required this.filter,
    required this.itemBuilder,
    super.key,
  });

  final List<T>? items;
  final bool Function(T item) filter;
  final Widget Function(BuildContext context, T item) itemBuilder;

  @override
  Widget build(BuildContext context) {
    final items = this.items;
    if (items == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = items.where(filter).toList();
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
      itemBuilder: (context, index) => itemBuilder(context, filtered[index]),
    );
  }
}
