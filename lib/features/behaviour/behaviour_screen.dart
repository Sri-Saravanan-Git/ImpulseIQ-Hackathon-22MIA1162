import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import '../../theme/app_theme.dart';
import '../../core/models/transaction.dart';
import 'package:intl/intl.dart';

class BehaviourScreen extends StatelessWidget {
  final UserProfile profile;
  const BehaviourScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(child: _header()),
              const SizedBox(height: 24),
              FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: _archetypeCard()),
              const SizedBox(height: 16),
              FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: _radarCard()),
              const SizedBox(height: 16),
              FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: _hourHeatmap()),
              const SizedBox(height: 16),
              FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: _categoryBreakdown()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('BEHAVIOUR ANALYSIS',
              style: TextStyle(
                  color: AppTheme.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2)),
          SizedBox(height: 4),
          Text('Your Spending DNA',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700)),
        ],
      );

  Widget _archetypeCard() {
    final descriptions = {
      'night_owl':
          'You tend to make impulsive purchases late at night. Your spending peaks between 11PM–3AM when decision-making is weakest.',
      'eom_spender':
          'Your spending surges at month-end, possibly due to "treat yourself" psychology after receiving salary.',
      'freq_binger':
          'You make many small transactions in quick bursts. High transaction velocity is your key impulse trigger.',
      'controlled':
          'You demonstrate strong financial discipline with consistent, planned spending patterns.',
    };

    final tips = {
      'night_owl': '💡 Try setting a spending lock between 10PM–6AM',
      'eom_spender': '💡 Set a dedicated end-of-month fun budget in advance',
      'freq_binger': '💡 Introduce a 30-minute pause rule before buying',
      'controlled': '💡 Keep it up! You\'re in the top 35% of users',
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.card, AppTheme.accent.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(profile.archetypeEmoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('YOUR ARCHETYPE',
                      style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 10,
                          letterSpacing: 1.5)),
                  Text(profile.archetypeLabel,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(descriptions[profile.archetype] ?? '',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13, height: 1.5)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(tips[profile.archetype] ?? '',
                style:
                    const TextStyle(color: AppTheme.textPrimary, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _radarCard() {
    // Compute 6 behaviour dimensions
    final txns = profile.transactions;
    final lateNight = txns.where((t) => t.isLateNight).length / txns.length;
    final eom = txns.where((t) => t.isEndOfMonth).length / txns.length;
    final impulseRate = profile.impulseCount / txns.length;
    final highSpend =
        txns.where((t) => t.amount > profile.avgSpend * 2).length / txns.length;
    final weekend = txns.where((t) => t.isWeekend).length / txns.length;
    final avgRisk = profile.overallRiskScore;

    final dims = [
      ('Late Night', lateNight),
      ('End-of-Month', eom),
      ('Impulse Rate', impulseRate),
      ('High Spend', highSpend),
      ('Weekend', weekend),
      ('Avg Risk', avgRisk),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Behavioural Dimensions',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          ...dims.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(d.$1,
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 12)),
                        Text('${(d.$2 * 100).toInt()}%',
                            style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: d.$2.clamp(0.0, 1.0),
                        backgroundColor: AppTheme.cardBorder,
                        valueColor: AlwaysStoppedAnimation(
                          d.$2 > 0.6
                              ? AppTheme.red
                              : d.$2 > 0.35
                                  ? AppTheme.yellow
                                  : AppTheme.green,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _hourHeatmap() {
    // Count transactions per hour bucket
    final buckets = List<int>.filled(24, 0);
    for (final t in profile.transactions) {
      buckets[t.timestamp.hour]++;
    }
    final maxVal = buckets.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Spending by Hour of Day',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          SizedBox(
            height: 60,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(24, (h) {
                final intensity = maxVal > 0 ? buckets[h] / maxVal : 0.0;
                final isNight = h >= 23 || h <= 3;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300 + h * 20),
                          height: 4 + intensity * 50,
                          decoration: BoxDecoration(
                            color: isNight
                                ? AppTheme.red
                                    .withOpacity(0.4 + intensity * 0.6)
                                : AppTheme.accent
                                    .withOpacity(0.3 + intensity * 0.7),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['12a', '6a', '12p', '6p', '12a']
                .map((t) => Text(t,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 9)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _categoryBreakdown() {
    final catCount = <String, int>{};
    for (final t in profile.transactions) {
      catCount[t.category] = (catCount[t.category] ?? 0) + 1;
    }
    final sorted = catCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();
    final total = profile.transactions.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Spending Categories',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ...top.map((e) {
            final pct = e.value / total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(e.key,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12),
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: AppTheme.cardBorder,
                        valueColor:
                            const AlwaysStoppedAnimation(AppTheme.accent),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${e.value}',
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
