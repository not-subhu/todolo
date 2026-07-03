import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'providers/tasks_provider.dart';
import 'providers/habits_provider.dart';
import 'providers/rewards_provider.dart';
import 'screens/home_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/habits_screen.dart';
import 'screens/rewards_screen.dart';
import 'screens/settings_screen.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'widgets/kawaii_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Bootstrap shared-prefs BEFORE any provider calls load() so _prefs is
  // never null when providers read persisted data.
  await DatabaseService().initialize();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const KawaiiQuestApp());
}

class KawaiiQuestApp extends StatelessWidget {
  const KawaiiQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // AppProvider.initialize() re-uses the already-open SharedPreferences
        // instance so it completes synchronously fast.
        ChangeNotifierProvider(create: (_) => AppProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => TasksProvider()..load()),
        ChangeNotifierProvider(create: (_) => HabitsProvider()..load()),
        ChangeNotifierProvider(create: (_) => RewardsProvider()..load()),
      ],
      child: MaterialApp(
        title: 'KawaiiQuest',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const AppShell(),
      ),
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
  bool _showPester = false;
  String _pesterMessage = '';

  final List<Widget> _screens = const [
    HomeScreen(),
    TasksScreen(),
    HabitsScreen(),
    RewardsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _setupNotifications());
  }

  void _setupNotifications() {
    final app = context.read<AppProvider>();
    final tasks = context.read<TasksProvider>();
    NotificationService().configure(
      username: app.profile.username,
      geminiKey: app.profile.geminiApiKey,
      onPester: (msg) {
        if (app.profile.pesteringEnabled && mounted) {
          _showPesterOverlay(msg);
        }
      },
    );
    // Actually start the periodic pester timer if the user has it enabled.
    if (app.profile.pesteringEnabled) {
      NotificationService().startPestering(
        pendingTasks: tasks.tasks,
        intervalMinutes: app.profile.pesterIntervalMinutes,
      );
    }
  }

  void _showPesterOverlay(String message) {
    setState(() {
      _pesterMessage = message;
      _showPester = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, app, _) {
        if (app.isLoading) {
          return const Scaffold(
            backgroundColor: KawaiiColors.deepPurple,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('✨', style: TextStyle(fontSize: 64)),
                  SizedBox(height: 20),
                  CircularProgressIndicator(color: KawaiiColors.sakuraPink),
                  SizedBox(height: 16),
                  Text('Loading KawaiiQuest~',
                      style: TextStyle(color: KawaiiColors.textSecondary)),
                ],
              ),
            ),
          );
        }

        return Stack(
          children: [
            Scaffold(
              body: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.bgGradient,
                ),
                child: IndexedStack(
                  index: _currentIndex,
                  children: _screens,
                ),
              ),
              bottomNavigationBar: _buildBottomNav(),
            ),
            if (_showPester)
              PesterOverlay(
                message: _pesterMessage,
                onDismiss: () => setState(() => _showPester = false),
                onGoToTask: () {
                  setState(() {
                    _showPester = false;
                    _currentIndex = 1;
                  });
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildBottomNav() {
    const items = [
      BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.checklist_rounded), label: 'Tasks'),
      BottomNavigationBarItem(icon: Icon(Icons.loop_rounded), label: 'Habits'),
      BottomNavigationBarItem(icon: Icon(Icons.card_giftcard_rounded), label: 'Rewards'),
      BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: KawaiiColors.midPurple,
        border: Border(
          top: BorderSide(color: KawaiiColors.lavender.withAlpha(40), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: items,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: KawaiiColors.sakuraPink,
        unselectedItemColor: KawaiiColors.textMuted,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
      ),
    );
  }
}
