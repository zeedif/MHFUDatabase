import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';

class const FilterSheetBody({required final List<Widget> children, super.key})
    extends StatelessWidget {
  // Material 3's default bottom sheet max width.
  static const _maxWidth = 640.0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final width =
        (screenWidth < _maxWidth ? screenWidth : _maxWidth) - AppPadding.large;

    return SafeArea(
      child: SizedBox(
        width: width,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppPadding.large),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}
