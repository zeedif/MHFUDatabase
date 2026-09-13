import '../../../core/database/localized_collation.dart';
import 'location.dart';

class const LocationFilter({final String? name}) {
  bool matches(Location location) {
    final name = this.name;
    if (name != null &&
        !normalizeForSearch(
          location.name,
        ).contains(normalizeForSearch(name))) {
      return false;
    }
    return true;
  }
}
