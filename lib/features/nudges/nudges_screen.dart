import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../theme/app_theme.dart';
import '../../core/models/transaction.dart';

class NudgesScreen extends StatelessWidget {
  final UserProfile profile;
  const NudgesScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final nudges = [
      {
        'icon': '🧠',
        'title': 'Pattern Detected',
        'message': 'You have made ${profile.transactions.where((t) => t.isLateNight).length} late-night purchases. Late night spending increases impulse risk by 40 percent.',
        'color': AppTheme.accent,
        'action': 'Set a spending lock',
      },
      {
        'icon': '💰',
        'title': 'Smart Budget Tip',
        'message': '${(profile.overallRiskScore * 100).toInt()}% of your transactions show impulse characteristics. Consider the 50/30/20 rule.',
        'color': AppTheme.green,
        'action': 'Create a budget',
      },
      {
        'icon': '⏰',
        'title': '24-Hour Rule',
        'message': 'Before any purchase over Rs ${(profile.avgSpend * 1.5).toInt()}, wait 24 hours. This eliminates 67% of impulse buys.',
        'color': AppTheme.yellow,
        'action': 'Activate cool-down',
      },
      {
        'icon': '📊',
        'title': 'Weekly Insight',
        'message': 'Your impulse spending is Rs ${profile.impulseSpend.toInt()} which is ${((profile.impulseSpend / profile.totalSpend) * 100).toInt()}% of total spend.',
        'color': AppTheme.red,
        'action': 'See breakdown',
      },
    ];

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
              ...nudges.asMap().entries.map((entry) => FadeInUp(
                delay: Duration(milliseconds: 150 * entry.key),
                child: Padding(padding: const EdgeInsets.only(bottom: 14), child: _nudgeCard(entry.value)),
              )),
              const SizedBox(height: 8),
              FadeInUp(delay: const Duration(milliseconds: 800), child: _streakCard()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('AI NUDGES', style: TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 2)),
      const SizedBox(height: 4),
      const Text('Personalized Recommendations', style: TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Text('Based on your ${profile.archetypeLabel} profile', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
    ],
  );

  Widget _nudgeCard(Map<String, dynamic> nudge) {
    final color = nudge['color'] as Color;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(nudge['icon'] as String, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Text(nudge['title'] as String, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 12),
          Text(nudge['message'] as String, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Text('-> ' + (nudge['action'] as String), style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _streakCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.green.withValues(alpha: 0.2), AppTheme.card], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Controlled Spending Streak', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('${3 + (profile.overallRiskScore * 10).toInt()} days in a row!', style: const TextStyle(color: AppTheme.green, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}
