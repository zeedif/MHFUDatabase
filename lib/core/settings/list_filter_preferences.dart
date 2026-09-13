import 'package:shared_preferences/shared_preferences.dart';

import '../domain/enums.dart';

/// Persists the bottom-sheet filter criteria for the list/filter screens that
/// have one (monsters, items, quests, armor sets, item combinations, weapon
/// trees), so they survive navigating away and app restarts. The free-text
/// search box is never persisted here — only structured criteria are.
/// `WeaponTypeListView` doesn't persist its filter at all.
class ListFilterPreferences {
  ListFilterPreferences._();

  static final instance = ListFilterPreferences._();

  static const _monsterTypeKey = 'filter_monster_type';
  static const _itemRarityKey = 'filter_item_rarity';
  static const _itemIconsKey = 'filter_item_icons';
  static const _itemIconColorsKey = 'filter_item_icon_colors';
  static const _questHubKey = 'filter_quest_hub';
  static const _questTypeKey = 'filter_quest_type';
  static const _armorSetRarityKey = 'filter_armor_set_rarity';
  static const _armorSetHunterTypeKey = 'filter_armor_set_hunter_type';
  static const _armorSetGenderKey = 'filter_armor_set_gender';
  static const _itemCombinationTypeKey = 'filter_item_combination_type';
  static const _armorSetNumberOfSlotsKey = 'filter_armor_set_number_of_slots';
  static const _weaponTreeElementTypeKey = 'filter_weapon_tree_element_type';
  static const _weaponTreeRarityKey = 'filter_weapon_tree_rarity';
  static const _weaponTreeNumberOfSlotsKey =
      'filter_weapon_tree_number_of_slots';

  late SharedPreferences _prefs;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
  }

  MonsterType? get monsterType {
    final raw = _prefs.getString(_monsterTypeKey);
    return raw == null ? null : MonsterType.fromDb(raw);
  }

  Future<void> setMonsterType(MonsterType? type) => type == null
      ? _prefs.remove(_monsterTypeKey)
      : _prefs.setString(_monsterTypeKey, type.dbValue);

  List<int>? get itemRarity => _getIntList(_itemRarityKey);

  Future<void> setItemRarity(List<int>? rarity) =>
      _setIntList(_itemRarityKey, rarity);

  List<ItemIconType>? get itemIcons =>
      _getEnumList(_itemIconsKey, ItemIconType.fromDb);

  Future<void> setItemIcons(List<ItemIconType>? icons) =>
      _setEnumList(_itemIconsKey, icons, (icon) => icon.dbValue);

  List<ItemIconColor>? get itemIconColors =>
      _getEnumList(_itemIconColorsKey, ItemIconColor.fromDb);

  Future<void> setItemIconColors(List<ItemIconColor>? colors) =>
      _setEnumList(_itemIconColorsKey, colors, (color) => color.dbValue);

  HubType? get questHub {
    final raw = _prefs.getString(_questHubKey);
    return raw == null ? null : HubType.fromDb(raw);
  }

  Future<void> setQuestHub(HubType? hub) => hub == null
      ? _prefs.remove(_questHubKey)
      : _prefs.setString(_questHubKey, hub.dbValue);

  List<QuestType>? get questType =>
      _getEnumList(_questTypeKey, QuestType.fromDb);

  Future<void> setQuestType(List<QuestType>? type) =>
      _setEnumList(_questTypeKey, type, (type) => type.dbValue);

  List<int>? get armorSetRarity => _getIntList(_armorSetRarityKey);

  Future<void> setArmorSetRarity(List<int>? rarity) =>
      _setIntList(_armorSetRarityKey, rarity);

  HunterType? get armorSetHunterType {
    final raw = _prefs.getString(_armorSetHunterTypeKey);
    return raw == null ? null : HunterType.fromDb(raw);
  }

  Future<void> setArmorSetHunterType(HunterType? hunterType) =>
      hunterType == null
      ? _prefs.remove(_armorSetHunterTypeKey)
      : _prefs.setString(_armorSetHunterTypeKey, hunterType.dbValue);

  Gender? get armorSetGender {
    final raw = _prefs.getString(_armorSetGenderKey);
    return raw == null ? null : Gender.fromDb(raw);
  }

  Future<void> setArmorSetGender(Gender? gender) => gender == null
      ? _prefs.remove(_armorSetGenderKey)
      : _prefs.setString(_armorSetGenderKey, gender.dbValue);

  List<int>? get armorSetNumberOfSlots =>
      _getIntList(_armorSetNumberOfSlotsKey);

  Future<void> setArmorSetNumberOfSlots(List<int>? numberOfSlots) =>
      _setIntList(_armorSetNumberOfSlotsKey, numberOfSlots);

  ItemCombinationType? get itemCombinationType {
    final raw = _prefs.getString(_itemCombinationTypeKey);
    return raw == null ? null : ItemCombinationType.fromDb(raw);
  }

  Future<void> setItemCombinationType(ItemCombinationType? type) =>
      type == null
      ? _prefs.remove(_itemCombinationTypeKey)
      : _prefs.setString(_itemCombinationTypeKey, type.dbValue);

  List<WeaponElement>? get weaponTreeElementType =>
      _getEnumList(_weaponTreeElementTypeKey, WeaponElement.fromDb);

  Future<void> setWeaponTreeElementType(List<WeaponElement>? elementType) =>
      _setEnumList(
        _weaponTreeElementTypeKey,
        elementType,
        (elementType) => elementType.dbValue,
      );

  List<int>? get weaponTreeRarity => _getIntList(_weaponTreeRarityKey);

  Future<void> setWeaponTreeRarity(List<int>? rarity) =>
      _setIntList(_weaponTreeRarityKey, rarity);

  List<int>? get weaponTreeNumberOfSlots =>
      _getIntList(_weaponTreeNumberOfSlotsKey);

  Future<void> setWeaponTreeNumberOfSlots(List<int>? numberOfSlots) =>
      _setIntList(_weaponTreeNumberOfSlotsKey, numberOfSlots);

  List<int>? _getIntList(String key) {
    final raw = _prefs.getStringList(key);
    if (raw == null || raw.isEmpty) return null;
    return raw.map(int.parse).toList();
  }

  Future<void> _setIntList(String key, List<int>? value) =>
      value == null || value.isEmpty
      ? _prefs.remove(key)
      : _prefs.setStringList(key, value.map((v) => v.toString()).toList());

  List<T>? _getEnumList<T>(String key, T Function(String) fromDb) {
    final raw = _prefs.getStringList(key);
    if (raw == null || raw.isEmpty) return null;
    return raw.map(fromDb).toList();
  }

  Future<void> _setEnumList<T>(
    String key,
    List<T>? value,
    String Function(T) toDb,
  ) => value == null || value.isEmpty
      ? _prefs.remove(key)
      : _prefs.setStringList(key, value.map(toDb).toList());
}
