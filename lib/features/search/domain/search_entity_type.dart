/// One value per result list in `SearchResults` / private `_searchX` method
/// in `SearchRepository`, so a deactivated type can skip its SQL query
/// entirely instead of just being filtered out of the results in memory.
enum SearchEntityType {
  location,
  monster,
  skillTree,
  skill,
  quest,
  item,
  decoration,
  armor,
  weapon,
}
