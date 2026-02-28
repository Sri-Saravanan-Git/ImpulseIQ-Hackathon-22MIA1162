import 'package:flutter/material.dart';
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
                child: Text('${(t.impulseScore * 100).toInt()}%', style: TextStyle(color: risk.color, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
