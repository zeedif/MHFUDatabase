import '../../../core/database/localized_collation.dart';
import 'veggie.dart';

class const VeggieFilter({final String? name}) {
  bool matches(VeggieLocation veggieLocation) {
    final name = this.name;
    if (name != null &&
        !normalizeForSearch(
          veggieLocation.location.name,
        ).contains(normalizeForSearch(name))) {
      return false;
    }
    return true;
  }
}
