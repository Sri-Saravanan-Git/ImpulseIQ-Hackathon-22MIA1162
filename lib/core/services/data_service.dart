import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';

class DataService {
  static final _uuid = Uuid();
  static final _random = Random(42);

  static const _categories = [
    'Food & Dining',
    'Fashion',
    'Gaming',
    'Entertainment',
    'Electronics',
    'Grocery',
    'Travel',
    'Health',
    'Alcohol',
    'Subscriptions'
  ];

  static const _archetypes = [
    'night_owl',
    'eom_spender',
    'freq_binger',
    'controlled'
  ];

  // Generate a demo user with realistic transactions
  static UserProfile generateDemoUser() {
    final archetype = _archetypes[_random.nextInt(_archetypes.length)];
    final avgSpend = 500 + _random.nextDouble() * 1500;
    final transactions = <Transaction>[];
    final now = DateTime.now();

    for (int i = 0; i < 30; i++) {
      final daysAgo = _random.nextInt(30);
      final hour = _pickHour(archetype);
      final day = _pickDay(archetype);

      final ts = DateTime(
        now.year,
        now.month,
        day.clamp(1, 28),
        hour,
        _random.nextInt(60),
      ).subtract(Duration(days: daysAgo));

      final category = _categories[_random.nextInt(_categories.length)];
      final isImpulseCategory = [
        'Fashion',
        'Gaming',
        'Entertainment',
        'Alcohol',
        'Electronics'
      ].contains(category);

      final amount = isImpulseCategory
          ? avgSpend * (0.5 + _random.nextDouble() * 3)
          : avgSpend * (0.1 + _random.nextDouble() * 1.2);

      final impulseScore = _computeImpulseScore(
        hour: hour,
        day: day,
        category: category,
        amount: amount,
        avgSpend: avgSpend,
        archetype: archetype,
      );

      transactions.add(Transaction(
        id: _uuid.v4(),
        userId: 'U0001',
        timestamp: ts,
        category: category,
        amount: double.parse(amount.toStringAsFixed(2)),
        impulseScore: impulseScore,
        isImpulse: impulseScore > 0.5,
        archetype: archetype,
      ));
    }

    transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final overallRisk = transactions
            .take(10)
            .map((t) => t.impulseScore)
            .reduce((a, b) => a + b) /
        10;

    return UserProfile(
      userId: 'U0001',
      archetype: archetype,
      avgSpend: avgSpend,
      transactions: transactions,
      overallRiskScore: overallRisk,
    );
  }

  static int _pickHour(String archetype) {
    if (archetype == 'night_owl' && _random.nextDouble() < 0.6) {
      return [23, 0, 1, 2][_random.nextInt(4)];
    }
    return 8 + _random.nextInt(14);
  }

  static int _pickDay(String archetype) {
    if (archetype == 'eom_spender' && _random.nextDouble() < 0.6) {
      return 26 + _random.nextInt(5);
    }
    return 1 + _random.nextInt(25);
  }

  static double _computeImpulseScore({
    required int hour,
    required int day,
    required String category,
    required double amount,
    required double avgSpend,
    required String archetype,
  }) {
    double score = 0;
    final isLateNight = hour >= 23 || hour <= 3;
    final isEOM = day >= 26;
    final isImpulseCat = [
      'Fashion',
      'Gaming',
      'Entertainment',
      'Alcohol',
      'Electronics'
    ].contains(category);

    if (isLateNight) score += 0.25;
    if (isEOM) score += 0.15;
    if (isImpulseCat) score += 0.25;
    if (amount > avgSpend * 2) score += 0.20;
    if (archetype == 'night_owl' && isLateNight) score += 0.10;
    if (archetype == 'eom_spender' && isEOM) score += 0.10;
    if (archetype == 'freq_binger') score += 0.08;

    score += (_random.nextDouble() - 0.5) * 0.1;
    return score.clamp(0.0, 1.0);
  }

  // Generate simulation transaction
  static Transaction simulateTransaction({
    required String category,
    required double amount,
    required double avgSpend,
    required String archetype,
    int? hour,
  }) {
    final now = DateTime.now();
    final h = hour ?? now.hour;
    final impulseScore = _computeImpulseScore(
      hour: h,
      day: now.day,
      category: category,
      amount: amount,
      avgSpend: avgSpend,
      archetype: archetype,
    );
    return Transaction(
      id: _uuid.v4(),
      userId: 'U0001',
      timestamp: now,
      category: category,
      amount: amount,
      impulseScore: impulseScore,
      isImpulse: impulseScore > 0.5,
      archetype: archetype,
    );
  }
}
