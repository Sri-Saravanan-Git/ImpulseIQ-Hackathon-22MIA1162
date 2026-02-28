import os

pred = open('lib/features/prediction/prediction_screen.dart', 'w', encoding='utf-8')
pred.write("""import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../theme/app_theme.dart';
import '../../core/models/transaction.dart';
import 'package:intl/intl.dart';

class PredictionScreen extends StatelessWidget {
  final UserProfile profile;
  const PredictionScreen({super.key, required this.profile});

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
              FadeInUp(delay: const Duration(milliseconds: 200), child: _predictionSummary()),
              const SizedBox(height: 16),
              FadeInUp(delay: const Duration(milliseconds: 300), child: _transactionList(profile.transactions)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('PREDICTION ENGINE', style: TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 2)),
      SizedBox(height: 4),
      Text('Impulse Detection Feed', style: TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
    ],
  );

  Widget _predictionSummary() {
    final high = profile.transactions.where((t) => t.impulseScore > 0.7).length;
    final caution = profile.transactions.where((t) => t.impulseScore >= 0.4 && t.impulseScore <= 0.7).length;
    final safe = profile.transactions.where((t) => t.impulseScore < 0.4).length;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.cardBorder)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryBubble(high.toString(), 'High Risk', AppTheme.red),
          Container(height: 40, width: 1, color: AppTheme.cardBorder),
          _summaryBubble(caution.toString(), 'Caution', AppTheme.yellow),
          Container(height: 40, width: 1, color: AppTheme.cardBorder),
          _summaryBubble(safe.toString(), 'Safe', AppTheme.green),
        ],
      ),
    );
  }

  Widget _summaryBubble(String value, String label, Color color) => Column(
    children: [
      Text(value, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.w800)),
      Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
    ],
  );

  Widget _transactionList(List<Transaction> txns) {
    return Container(
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.cardBorder)),
      child: Column(children: txns.map((t) => _txnCard(t)).toList()),
    );
  }

  Widget _txnCard(Transaction t) {
    final risk = getRiskLevel(t.impulseScore);
    final fmt = NumberFormat.currency(symbol: 'Rs', decimalDigits: 0);
    final reasons = <String>[];
    if (t.isLateNight) reasons.add('Late night');
    if (t.isEndOfMonth) reasons.add('End of month');
    if (t.isWeekend) reasons.add('Weekend');
    if (t.amount > 1000) reasons.add('High amount');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.cardBorder))),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: risk.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(t.categoryEmoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.category, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                if (reasons.isNotEmpty) Text(reasons.join(' - '), style: const TextStyle(color: AppTheme.textMuted, fontSize: 10), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(fmt.format(t.amount), style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: risk.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: Text('\${(t.impulseScore * 100).toInt()}%', style: TextStyle(color: risk.color, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
""")
pred.close()
print("prediction_screen.dart written!")

nudge = open('lib/features/nudges/nudges_screen.dart', 'w', encoding='utf-8')
nudge.write("""import 'package:flutter/material.dart';
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
        'message': 'You have made \${profile.transactions.where((t) => t.isLateNight).length} late-night purchases. Late night spending increases impulse risk by 40 percent.',
        'color': AppTheme.accent,
        'action': 'Set a spending lock',
      },
      {
        'icon': '💰',
        'title': 'Smart Budget Tip',
        'message': '\${(profile.overallRiskScore * 100).toInt()}% of your transactions show impulse characteristics. Consider the 50/30/20 rule.',
        'color': AppTheme.green,
        'action': 'Create a budget',
      },
      {
        'icon': '⏰',
        'title': '24-Hour Rule',
        'message': 'Before any purchase over Rs \${(profile.avgSpend * 1.5).toInt()}, wait 24 hours. This eliminates 67% of impulse buys.',
        'color': AppTheme.yellow,
        'action': 'Activate cool-down',
      },
      {
        'icon': '📊',
        'title': 'Weekly Insight',
        'message': 'Your impulse spending is Rs \${profile.impulseSpend.toInt()} which is \${((profile.impulseSpend / profile.totalSpend) * 100).toInt()}% of total spend.',
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
      Text('Based on your \${profile.archetypeLabel} profile', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
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
            child: Text('-> \${nudge['action']}', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
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
              Text('\${3 + (profile.overallRiskScore * 10).toInt()} days in a row!', style: const TextStyle(color: AppTheme.green, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}
""")
nudge.close()
print("nudges_screen.dart written!")

sim = open('lib/features/simulation/simulation_screen.dart', 'w', encoding='utf-8')
sim.write("""import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../theme/app_theme.dart';
import '../../core/models/transaction.dart';
import '../../core/services/data_service.dart';
import 'package:intl/intl.dart';

class SimulationScreen extends StatefulWidget {
  final UserProfile profile;
  const SimulationScreen({super.key, required this.profile});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  String _selectedCategory = 'Fashion';
  double _amount = 500;
  int _hour = 14;
  Transaction? _result;

  final _categories = [
    'Food & Dining', 'Fashion', 'Gaming', 'Entertainment',
    'Electronics', 'Grocery', 'Travel', 'Health', 'Alcohol', 'Subscriptions'
  ];

  void _simulate() {
    final t = DataService.simulateTransaction(
      category: _selectedCategory,
      amount: _amount,
      avgSpend: widget.profile.avgSpend,
      archetype: widget.profile.archetype,
      hour: _hour,
    );
    setState(() => _result = t);
  }

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
              FadeInUp(delay: const Duration(milliseconds: 200), child: _controls()),
              const SizedBox(height: 16),
              FadeInUp(delay: const Duration(milliseconds: 300), child: _simulateButton()),
              if (_result != null) ...[
                const SizedBox(height: 20),
                FadeInUp(child: _resultCard(_result!)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('LIVE SIMULATOR', style: TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 2)),
      SizedBox(height: 4),
      Text('Test Any Transaction', style: TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
      SizedBox(height: 8),
      Text('See how the AI scores your spending in real-time', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
    ],
  );

  Widget _controls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Category', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _categories.map((cat) {
              final sel = cat == _selectedCategory;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? AppTheme.accent : AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? AppTheme.accent : AppTheme.cardBorder),
                  ),
                  child: Text(cat, style: TextStyle(color: sel ? Colors.white : AppTheme.textSecondary, fontSize: 11, fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Amount', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, letterSpacing: 1)),
              Text('Rs \${_amount.toInt()}', style: const TextStyle(color: AppTheme.accent, fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(activeTrackColor: AppTheme.accent, inactiveTrackColor: AppTheme.cardBorder, thumbColor: AppTheme.accent, overlayColor: AppTheme.accentGlow),
            child: Slider(value: _amount, min: 50, max: 10000, divisions: 199, onChanged: (v) => setState(() => _amount = v)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Time of Day', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, letterSpacing: 1)),
              Text('\${_hour.toString().padLeft(2, "0")}:00 \${_hour >= 23 || _hour <= 3 ? "Late Night" : _hour >= 18 ? "Evening" : "Day"}',
                  style: const TextStyle(color: AppTheme.accent, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(activeTrackColor: AppTheme.yellow, inactiveTrackColor: AppTheme.cardBorder, thumbColor: AppTheme.yellow, overlayColor: AppTheme.yellow.withValues(alpha: 0.2)),
            child: Slider(value: _hour.toDouble(), min: 0, max: 23, divisions: 23, onChanged: (v) => setState(() => _hour = v.toInt())),
          ),
        ],
      ),
    );
  }

  Widget _simulateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _simulate,
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bolt_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('ANALYZE TRANSACTION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _resultCard(Transaction t) {
    final risk = getRiskLevel(t.impulseScore);
    final fmt = NumberFormat.currency(symbol: 'Rs', decimalDigits: 0);
    final reasons = <String>[];
    if (t.isLateNight) reasons.add('Late night purchase detected');
    if (t.isEndOfMonth) reasons.add('End-of-month risk window');
    if (t.amount > widget.profile.avgSpend * 2) reasons.add('Amount is high vs your average spend');
    if (['Fashion', 'Gaming', 'Entertainment', 'Alcohol'].contains(_selectedCategory)) reasons.add('High-risk category');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: risk.color.withValues(alpha: 0.5), width: 2),
        boxShadow: [BoxShadow(color: risk.color.withValues(alpha: 0.15), blurRadius: 20)],
      ),
      child: Column(
        children: [
          const Text('AI VERDICT', style: TextStyle(color: AppTheme.textMuted, fontSize: 11, letterSpacing: 2)),
          const SizedBox(height: 16),
          Text('\${(t.impulseScore * 100).toInt()}', style: TextStyle(color: risk.color, fontSize: 64, fontWeight: FontWeight.w900)),
          Text('IMPULSE RISK SCORE', style: TextStyle(color: risk.color, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(color: risk.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
            child: Text('\${risk.emoji} \${risk.label}', style: TextStyle(color: risk.color, fontSize: 14, fontWeight: FontWeight.w700)),
          ),
          if (reasons.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Why this score?', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  ...reasons.map((r) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(r, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
""")
sim.close()
print("simulation_screen.dart written!")

print("\\nAll 3 files written successfully!")