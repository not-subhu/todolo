import 'package:uuid/uuid.dart';

enum RewardCategory { entertainment, food, selfCare, social, custom }

class Reward {
  final String id;
  String name;
  String description;
  int cost;
  String emoji;
  RewardCategory category;
  bool isPurchased;
  DateTime? purchasedAt;
  bool isDefault;
  DateTime createdAt;

  Reward({
    String? id,
    required this.name,
    this.description = '',
    required this.cost,
    this.emoji = '🎁',
    this.category = RewardCategory.custom,
    this.isPurchased = false,
    this.purchasedAt,
    this.isDefault = false,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'cost': cost,
        'emoji': emoji,
        'category': category.index,
        'isPurchased': isPurchased,
        'purchasedAt': purchasedAt?.toIso8601String(),
        'isDefault': isDefault,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Reward.fromJson(Map<String, dynamic> json) => Reward(
        id: json['id'],
        name: json['name'],
        description: json['description'] ?? '',
        cost: json['cost'],
        emoji: json['emoji'] ?? '🎁',
        category: RewardCategory.values[json['category'] ?? 4],
        isPurchased: json['isPurchased'] ?? false,
        purchasedAt: json['purchasedAt'] != null
            ? DateTime.parse(json['purchasedAt'])
            : null,
        isDefault: json['isDefault'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
      );

  static List<Reward> get defaultRewards => [
        Reward(
          name: 'Watch an episode',
          description: 'One guilt-free episode of your fave anime uwu',
          cost: 50,
          emoji: '📺',
          category: RewardCategory.entertainment,
          isDefault: true,
        ),
        Reward(
          name: 'Boba tea time!',
          description: 'You deserve that sweet boba~ (◕‿◕✿)',
          cost: 80,
          emoji: '🧋',
          category: RewardCategory.food,
          isDefault: true,
        ),
        Reward(
          name: '30min gaming session',
          description: 'Earned it! Game on, champion! ٩(◕‿◕)۶',
          cost: 60,
          emoji: '🎮',
          category: RewardCategory.entertainment,
          isDefault: true,
        ),
        Reward(
          name: 'Skincare ritual',
          description: 'Glow up time! You\'ve been working hard (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧',
          cost: 40,
          emoji: '✨',
          category: RewardCategory.selfCare,
          isDefault: true,
        ),
        Reward(
          name: 'Nap time!',
          description: '30 min power nap — recharge like a main character!',
          cost: 70,
          emoji: '😴',
          category: RewardCategory.selfCare,
          isDefault: true,
        ),
        Reward(
          name: 'Social media break',
          description: '15 min guilt-free scroll. You\'ve earned it~ (^▽^)',
          cost: 30,
          emoji: '📱',
          category: RewardCategory.entertainment,
          isDefault: true,
        ),
        Reward(
          name: 'Treat yourself to snacks',
          description: 'Your favourite snack. Go wild, bestie! (ﾉ>ω<)ﾉ',
          cost: 100,
          emoji: '🍫',
          category: RewardCategory.food,
          isDefault: true,
        ),
        Reward(
          name: 'Friend hangout',
          description: 'Text your bestie — you\'ve finished enough today!',
          cost: 120,
          emoji: '👯',
          category: RewardCategory.social,
          isDefault: true,
        ),
      ];
}
