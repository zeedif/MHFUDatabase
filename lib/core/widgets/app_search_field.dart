import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';

class const AppSearchField({
  required final TextEditingController controller,
  required final ValueChanged<String> onChanged,
  required final String hintText,
  required final VoidCallback onBack,
  final FocusNode? focusNode,
  final bool autofocus = false,
  final List<Widget> trailing = const [],
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isCompact = Theme.of(context).visualDensity.horizontal < 0;
    final barPadding = isCompact ? AppPadding.medium : AppPadding.small;

    return Padding(
      padding: EdgeInsets.all(barPadding),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        style: Theme.of(context).textTheme.titleLarge,
        decoration: InputDecoration(
          filled: true,
          fillColor: colors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.medium,
          ),
          prefixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
              ),
              const SizedBox(width: AppSpacing.large),
            ],
          ),
          prefixIconConstraints: const BoxConstraints(),
          hint: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.search, size: AppSize.extraSmall),
              const SizedBox(width: AppSpacing.medium),
              Text(hintText, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder(
                valueListenable: controller,
                builder: (context, value, _) => value.text.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          controller.clear();
                          onChanged('');
                        },
                      ),
              ),
              ...trailing,
            ],
          ),
        ),
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
      ),
    );
  }
}
