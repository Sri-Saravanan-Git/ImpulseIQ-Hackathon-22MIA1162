import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import '../../theme/app_theme.dart';
import '../../core/models/transaction.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  final UserProfile profile;
  const DashboardScreen({super.key, required this.profile});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _gaugeController;
  late Animation<double> _gaugeAnimation;

  @override
  void initState() {
    super.initState();
    _gaugeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _gaugeAnimation = Tween<double>(
      begin: 0,
      end: widget.profile.overallRiskScore,
    ).animate(CurvedAnimation(
      parent: _gaugeController,
      curve: Curves.easeOutCubic,
    ));
    _gaugeController.forward();
  }

  @override
  void dispose() {
    _gaugeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final risk = getRiskLevel(profile.overallRiskScore);
    final fmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              FadeInDown(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ImpulseIQ',
                            style: TextStyle(
                              color: AppTheme.accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            )),
                        const SizedBox(height: 4),
                        const Text('Financial Behaviour',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            )),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: Row(
                        children: [
                          Text(profile.archetypeEmoji,
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(profile.archetypeLabel,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Risk Gauge Card
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: _buildRiskGaugeCard(risk),
              ),

              const SizedBox(height: 16),

              // Stats Row
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: Row(
                  children: [
                    Expanded(
                        child: _statCard(
                            'Total Spend',
                            fmt.format(profile.totalSpend),
                            Icons.account_balance_wallet_rounded,
                            AppTheme.accent)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _statCard(
                            'Impulse Spend',
                            fmt.format(profile.impulseSpend),
                            Icons.warning_amber_rounded,
                            AppTheme.red)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _statCard(
                            'Impulse Txns',
                            '${profile.impulseCount}',
                            Icons.flash_on_rounded,
                            AppTheme.yellow)),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Spending Chart
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: _buildSpendingChart(),
              ),

              const SizedBox(height: 16),

              // Recent Transactions
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: _buildRecentTransactions(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiskGaugeCard(RiskLevel risk) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: risk.color.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text('Impulse Risk Score',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                letterSpacing: 1,
              )),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _gaugeAnimation,
            builder: (context, _) {
              final score = _gaugeAnimation.value;
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 160,
                    child: PieChart(
                      PieChartData(
                        startDegreeOffset: 180,
                        sectionsSpace: 0,
                        centerSpaceRadius: 55,
                        sections: [
                          PieChartSectionData(
                            value: score,
                            color: risk.color,
                            radius: 18,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: 1 - score,
                            color: AppTheme.cardBorder,
                            radius: 14,
                            showTitle: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${(score * 100).toInt()}',
                        style: TextStyle(
                          color: risk.color,
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        risk.label,
                        style: TextStyle(
                          color: risk.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _riskLegend('SAFE', AppTheme.green, '0–40'),
              _riskLegend('CAUTION', AppTheme.yellow, '40–70'),
              _riskLegend('HIGH', AppTheme.red, '70–100'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _riskLegend(String label, Color color, String range) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 9, fontWeight: FontWeight.w700)),
            Text(range,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 9)),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildSpendingChart() {
    final txns =
        widget.profile.transactions.take(10).toList().reversed.toList();
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
          const Text('Recent Spending Pattern',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                backgroundColor: Colors.transparent,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: AppTheme.cardBorder, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: List.generate(txns.length, (i) {
                  final t = txns[i];
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: t.amount / widget.profile.avgSpend,
                        color: t.isImpulse ? AppTheme.red : AppTheme.accent,
                        width: 14,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _dot(AppTheme.accent, 'Normal'),
              const SizedBox(width: 16),
              _dot(AppTheme.red, 'Impulse'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color, String label) => Row(
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        ],
      );

  Widget _buildRecentTransactions() {
    final txns = widget.profile.transactions.take(5).toList();
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
          const Text('Recent Transactions',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ...txns.map((t) => _txnTile(t)),
        ],
      ),
    );
  }

  Widget _txnTile(Transaction t) {
    final risk = getRiskLevel(t.impulseScore);
    final fmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(t.categoryEmoji, style: const TextStyle(fontSize: 20)))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.category,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                Text(DateFormat('MMM d, h:mm a').format(t.timestamp),
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(fmt.format(t.amount),
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: risk.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('${(t.impulseScore * 100).toInt()}%',
                    style: TextStyle(
                        color: risk.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
