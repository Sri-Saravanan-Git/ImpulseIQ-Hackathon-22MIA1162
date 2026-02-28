import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'core/models/transaction.dart';
import 'core/services/data_service.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/behaviour/behaviour_screen.dart';
import 'features/prediction/prediction_screen.dart';
import 'features/nudges/nudges_screen.dart';
import 'features/simulation/simulation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const ImpulseApp());
}

class ImpulseApp extends StatelessWidget {
  const ImpulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ImpulseIQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  late UserProfile _userProfile;

  @override
  void initState() {
    super.initState();
    _userProfile = DataService.generateDemoUser();
  }

  List<Widget> get _screens => [
        DashboardScreen(profile: _userProfile),
        BehaviourScreen(profile: _userProfile),
        PredictionScreen(profile: _userProfile),
        NudgesScreen(profile: _userProfile),
        SimulationScreen(profile: _userProfile),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.dashboard_rounded, 'label': 'Dashboard'},
      {'icon': Icons.psychology_rounded, 'label': 'Behaviour'},
      {'icon': Icons.timeline_rounded, 'label': 'Predict'},
      {'icon': Icons.lightbulb_rounded, 'label': 'Nudges'},
      {'icon': Icons.play_circle_rounded, 'label': 'Simulate'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.cardBorder, width: 1)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = _currentIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _currentIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.accentGlow : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i]['icon'] as IconData,
                        color: selected ? AppTheme.accent : AppTheme.textMuted,
                        size: 22,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          color:
                              selected ? AppTheme.accent : AppTheme.textMuted,
                          fontSize: 10,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
