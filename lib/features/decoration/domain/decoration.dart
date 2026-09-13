import '../../../core/domain/enums.dart';
import '../../../core/domain/shared.dart';

class const Decoration({
  required final int id,
  required final String name,
  final String? fullName,
  required final String description,
  required final int rarity,
  required final int buyPrice,
  required final int sellPrice,
  required final int requiredSlots,
  required final ItemIconColor color,
  final List<SkillPoint>? skills,
  final List<ItemQuantity>? recipeA,
  final List<ItemQuantity>? recipeB,
});
