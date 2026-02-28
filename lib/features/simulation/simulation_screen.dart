import 'package:flutter/material.dart';
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
              Text('Rs ${_amount.toInt()}', style: const TextStyle(color: AppTheme.accent, fontSize: 18, fontWeight: FontWeight.w700)),
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
              Text('${_hour.toString().padLeft(2, "0")}:00 ${_hour >= 23 || _hour <= 3 ? "Late Night" : _hour >= 18 ? "Evening" : "Day"}',
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
          Text('${(t.impulseScore * 100).toInt()}', style: TextStyle(color: risk.color, fontSize: 64, fontWeight: FontWeight.w900)),
          Text('IMPULSE RISK SCORE', style: TextStyle(color: risk.color, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(color: risk.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
            child: Text('${risk.emoji} ${risk.label}', style: TextStyle(color: risk.color, fontSize: 14, fontWeight: FontWeight.w700)),
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
