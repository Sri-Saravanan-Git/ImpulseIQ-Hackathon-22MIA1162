class Transaction {
  final String id;
  final String userId;
  final DateTime timestamp;
  final String category;
  final double amount;
  final double impulseScore;
  final bool isImpulse;
  final String archetype;

  Transaction({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.category,
    required this.amount,
    required this.impulseScore,
    required this.isImpulse,
    required this.archetype,
  });

  bool get isLateNight => timestamp.hour >= 23 || timestamp.hour <= 3;
  bool get isEndOfMonth => timestamp.day >= 26;
  bool get isWeekend => timestamp.weekday >= 6;

  String get categoryEmoji {
    const map = {
      'Food & Dining': '🍔',
      'Fashion': '👗',
      'Gaming': '🎮',
      'Entertainment': '🎬',
      'Electronics': '📱',
      'Grocery': '🛒',
      'Travel': '✈️',
      'Health': '💊',
      'Alcohol': '🍺',
      'Subscriptions': '📺',
    };
    return map[category] ?? '💳';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'timestamp': timestamp.toIso8601String(),
        'category': category,
        'amount': amount,
        'impulseScore': impulseScore,
        'isImpulse': isImpulse,
        'archetype': archetype,
      };
}

class UserProfile {
  final String userId;
  final String archetype;
  final double avgSpend;
  final List<Transaction> transactions;
  final double overallRiskScore;

  UserProfile({
    required this.userId,
    required this.archetype,
    required this.avgSpend,
    required this.transactions,
    required this.overallRiskScore,
  });

  String get archetypeEmoji {
    const map = {
      'night_owl': '🌙',
      'eom_spender': '📅',
      'freq_binger': '⚡',
      'controlled': '🛡️',
    };
    return map[archetype] ?? '👤';
  }

  String get archetypeLabel {
    const map = {
      'night_owl': 'Night Owl',
      'eom_spender': 'End-of-Month Spender',
      'freq_binger': 'Frequency Binger',
      'controlled': 'Controlled Spender',
    };
    return map[archetype] ?? archetype;
  }

  int get impulseCount => transactions.where((t) => t.isImpulse).length;
  double get totalSpend => transactions.fold(0, (s, t) => s + t.amount);
  double get impulseSpend =>
      transactions.where((t) => t.isImpulse).fold(0, (s, t) => s + t.amount);
}
