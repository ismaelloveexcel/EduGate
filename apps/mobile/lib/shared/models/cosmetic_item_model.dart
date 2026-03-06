// lib/shared/models/cosmetic_item_model.dart
import 'package:equatable/equatable.dart';

class CosmeticItemModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final int coinCost;
  final String assetPath;
  final String category; // 'avatar', 'badge', 'theme'

  const CosmeticItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.coinCost,
    required this.assetPath,
    required this.category,
  });

  @override
  List<Object?> get props =>
      [id, name, description, coinCost, assetPath, category];
}

/// Built-in cosmetics catalogue
const List<CosmeticItemModel> kCosmeticsShop = [
  CosmeticItemModel(
    id: 'avatar_rocket',
    name: 'Rocket Avatar',
    description: 'Zoom through questions!',
    coinCost: 50,
    assetPath: 'assets/images/avatar_rocket.png',
    category: 'avatar',
  ),
  CosmeticItemModel(
    id: 'avatar_owl',
    name: 'Wise Owl',
    description: 'Knowledge is power.',
    coinCost: 80,
    assetPath: 'assets/images/avatar_owl.png',
    category: 'avatar',
  ),
  CosmeticItemModel(
    id: 'badge_star',
    name: 'Star Badge',
    description: 'Show off your streak!',
    coinCost: 30,
    assetPath: 'assets/images/badge_star.png',
    category: 'badge',
  ),
  CosmeticItemModel(
    id: 'badge_lightning',
    name: 'Lightning Badge',
    description: 'Speed and accuracy.',
    coinCost: 60,
    assetPath: 'assets/images/badge_lightning.png',
    category: 'badge',
  ),
  CosmeticItemModel(
    id: 'theme_ocean',
    name: 'Ocean Theme',
    description: 'A calming ocean palette.',
    coinCost: 100,
    assetPath: 'assets/images/theme_ocean.png',
    category: 'theme',
  ),
];
