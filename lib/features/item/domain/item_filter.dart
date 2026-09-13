import '../../../core/database/localized_collation.dart';
import '../../../core/domain/enums.dart';
import 'item.dart';

class const ItemFilter({
  final String? name,
  final List<int>? rarity,
  final List<ItemIconType>? icons,
  final List<ItemIconColor>? iconColors,
}) {
  bool matches(Item item) {
    final name = this.name;
    if (name != null) {
      final query = normalizeForSearch(name);
      final matchesName =
          normalizeForSearch(item.name).contains(query) ||
          normalizeForSearch(item.fullName ?? item.name).contains(query);
      if (!matchesName) return false;
    }
    if (rarity != null && !rarity!.contains(item.rarity)) return false;
    if (icons != null && !icons!.contains(item.iconType)) return false;
    if (iconColors != null && !iconColors!.contains(item.iconColor)) {
      return false;
    }
    return true;
  }
}
