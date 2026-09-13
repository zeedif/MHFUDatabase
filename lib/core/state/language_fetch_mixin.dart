import 'package:flutter/widgets.dart';

import '../settings/app_settings_controller.dart';

/// Fetches `items` once for the current app language, re-fetching only when
/// the language actually changes. Mix this into a `State` and implement
/// [fetchItems]; `items` stays `null` until the first fetch resolves.
mixin LanguageFetchMixin<T, W extends StatefulWidget> on State<W> {
  List<T>? items;
  String? _language;

  Future<List<T>> fetchItems(String language);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = AppSettingsController.instance.locale.languageCode;
    if (_language != language) {
      _language = language;
      _load();
    }
  }

  Future<void> _load() async {
    final result = await fetchItems(_language!);
    if (mounted) setState(() => items = result);
  }
}
