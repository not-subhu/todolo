import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'providers/habits_provider.dart';
import 'providers/rewards_provider.dart';
import 'providers/tasks_provider.dart';
import 'screens/add_task_screen.dart';
import 'screens/home_screen.dart';
import 'screens/rewards_screen.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'widgets/kawaii_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService().initialize();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const ScreechApp());
}

class ScreechApp extends StatelessWidget {
  const ScreechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => TasksProvider()..load()),
        ChangeNotifierProvider(create: (_) => HabitsProvider()..load()),
        ChangeNotifierProvider(create: (_) => RewardsProvider()..load()),
      ],
      child: Consumer<AppProvider>(
        builder: (ctx, app, _) {
          if (app.isLoading) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: _SplashScreen(),
            );
          }
          return MaterialApp(
            title: 'Screech',
            theme: app.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}

// ── Splash ────────────────────────────────────────────────────────────────
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: ScreechColors.bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets_rounded, color: ScreechColors.primaryLit, size: 56),
            SizedBox(height: 16),
            CircularProgressIndicator(color: ScreechColors.primary),
          ],
        ),
      ),
    );
  }
}

// ── App shell ─────────────────────────────────────────────────────────────
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;
  bool _showPester = false;
  String _pesterMsg = '';

  static const _screens = [HomeScreen(), RewardsScreen()];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // widget may have been disposed before first frame
      _setup();
      // Re-configure NotificationService whenever the profile changes
      // (Gemini key, pester toggle, interval, custom prompt, etc.)
      context.read<AppProvider>().addListener(_onProfileChanged);
    });
  }

  @override
  void dispose() {
    // Remove listener before teardown, then stop any live pester timers
    // so they don't fire into a dead widget tree.
    context.read<AppProvider>().removeListener(_onProfileChanged);
    NotificationService().stopAll();
    super.dispose();
  }

  void _onProfileChanged() => _configureNotifications();

  void _setup() {
    _configureNotifications();

    // Retry success: tell the user their queued task pester messages arrived
    NotificationService().setRetrySuccessCallback((taskTitle) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Pester messages ready for "$taskTitle" ~',
            style: GoogleFonts.inter(
                color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: ScreechColors.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ));
      }
    });

    // When a task is added but both AI models are unavailable, tell the user
    context.read<TasksProvider>().setOnPesterQueued(() {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Your tasks will be added soon _winks_',
            style: GoogleFonts.inter(
                color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: ScreechColors.accent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ));
      }
    });
  }

  /// Configures NotificationService from the current profile.
  /// Safe to call repeatedly — replaces the previous configuration.
  void _configureNotifications() {
    if (!mounted) return;
    final app = context.read<AppProvider>();
    NotificationService().configure(
      username: app.profile.username,
      geminiKey: app.profile.geminiApiKey,
      customPrompt: app.profile.customPesterPrompt,
      pesteringEnabled: app.profile.pesteringEnabled,
      intervalMinutes: app.profile.pesterIntervalMinutes,
      onPester: (msg) {
        if (app.profile.pesteringEnabled && mounted) {
          setState(() {
            _pesterMsg = msg;
            _showPester = true;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: ScreechColors.bg,
          body: IndexedStack(
            index: _tab,
            children: _screens,
          ),
          bottomNavigationBar: _buildBottomBar(),
          floatingActionButton: _buildFAB(context),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        ),
        if (_showPester)
          PesterOverlay(
            message: _pesterMsg,
            onDismiss: () => setState(() => _showPester = false),
            onGoToTask: () => setState(() {
              _showPester = false;
              _tab = 0;
            }),
          ),
      ],
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: ScreechColors.primary,
      elevation: 6,
      onPressed: () {
        final app = context.read<AppProvider>();
        final tasksP = context.read<TasksProvider>();
        Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (_, __, ___) => AddTaskScreen(
            geminiKey: app.profile.geminiApiKey ?? '',
            onTasksAdded: (newTasks) async {
              await tasksP.addTasks(newTasks);
            },
          ),
          transitionsBuilder: (_, anim, __, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 280),
        ));
      },
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      color: ScreechColors.bgCard,
      elevation: 0,
      notchMargin: 8,
      shape: const CircularNotchedRectangle(),
      child: SizedBox(
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _tabItem(0, Icons.view_list_rounded, Icons.view_list_outlined, 'Home'),
            const SizedBox(width: 60), // FAB gap
            _tabItem(1, Icons.card_giftcard_rounded, Icons.card_giftcard_outlined, 'Rewards'),
          ],
        ),
      ),
    );
  }

  Widget _tabItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final selected = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? activeIcon : inactiveIcon,
              color: selected ? ScreechColors.primary : ScreechColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                color: selected ? ScreechColors.primary : ScreechColors.textMuted,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
