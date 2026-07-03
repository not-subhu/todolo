import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/github_gist_service.dart';
import '../theme/app_theme.dart';
import '../widgets/kawaii_widgets.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final _gistIdCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  List<LeaderboardEntry> _entries = [];
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _error;
  final _gistService = GithubGistService();

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppProvider>().profile;
    if (profile.githubGistId != null) {
      _gistIdCtrl.text = profile.githubGistId!;
      _fetchLeaderboard(profile.githubGistId!);
    }
  }

  Future<void> _fetchLeaderboard(String gistId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final entries = await _gistService.fetchLeaderboard(gistId);
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not load leaderboard: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateScore() async {
    final app = context.read<AppProvider>();
    final profile = app.profile;
    final gistId = profile.githubGistId;
    final token = _tokenCtrl.text.trim();

    if (gistId == null || gistId.isEmpty) {
      setState(() => _error = 'Set your Gist ID in settings first!');
      return;
    }

    setState(() {
      _isUpdating = true;
      _error = null;
    });

    try {
      final entry = LeaderboardEntry(
        username: profile.username,
        coins: profile.totalCoinsEarned,
        tasksCompleted: profile.tasksCompleted,
        streak: profile.longestStreak,
        lastUpdated: DateTime.now(),
      );

      if (token.isNotEmpty) {
        await _gistService.updateScore(
          gistId: gistId,
          githubToken: token,
          entry: entry,
        );
        await _fetchLeaderboard(gistId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✨ Score updated! Check your ranking~ (◕‿◕✿)',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
            ),
            backgroundColor: KawaiiColors.sakuraPink,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _error = 'Update failed: $e');
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, app, _) {
        final profile = app.profile;
        final myRank = _entries.indexWhere((e) => e.username == profile.username);

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(
              'Leaderboard',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                color: KawaiiColors.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: KawaiiColors.lavender),
                onPressed: profile.githubGistId != null
                    ? () => _fetchLeaderboard(profile.githubGistId!)
                    : null,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            child: Column(
              children: [
                // Setup card
                if (profile.githubGistId == null || profile.githubGistId!.isEmpty)
                  _buildSetupCard(app)
                else ...[
                  // My rank card
                  if (myRank >= 0) _buildMyRankCard(myRank, profile),
                  const SizedBox(height: 16),

                  // Update score
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Update your score',
                          style: GoogleFonts.nunito(
                            color: KawaiiColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _tokenCtrl,
                          obscureText: true,
                          style: const TextStyle(color: KawaiiColors.textPrimary),
                          decoration: const InputDecoration(
                            labelText: 'GitHub Personal Access Token',
                            hintText: 'ghp_... (needs Gist write access)',
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isUpdating ? null : _updateScore,
                            child: Text(
                              _isUpdating ? 'Updating...' : '📤 Submit my score',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Error
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _error!,
                        style: GoogleFonts.nunito(
                          color: KawaiiColors.coral,
                          fontSize: 13,
                        ),
                      ),
                    ),

                  // Leaderboard list
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: KawaiiColors.sakuraPink,
                      ),
                    )
                  else if (_entries.isEmpty)
                    KawaiiEmptyState(
                      emoji: '🏆',
                      title: 'No scores yet!',
                      subtitle:
                          'Be the first to submit your score and dominate~ (ﾉ≧∀≦)ﾉ',
                    )
                  else ...[
                    const SectionHeader(title: '🏆 Rankings'),
                    ..._entries.asMap().entries.map((e) =>
                        _buildRankEntry(e.key, e.value, profile.username)),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSetupCard(AppProvider app) {
    return GlassCard(
      child: Column(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'Set up Leaderboard',
            style: GoogleFonts.nunito(
              color: KawaiiColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the shared Gist ID for your friend group\'s leaderboard. Get it from your group admin!',
            style: GoogleFonts.nunito(
              color: KawaiiColors.textSecondary,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _gistIdCtrl,
            style: const TextStyle(color: KawaiiColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'GitHub Gist ID',
              hintText: 'e.g. abc123def456...',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final id = _gistIdCtrl.text.trim();
                if (id.isEmpty) return;
                final updated = app.profile;
                updated.githubGistId = id;
                await app.updateProfile(updated);
                await _fetchLeaderboard(id);
              },
              child: const Text('Join Leaderboard!'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyRankCard(int rank, profile) {
    final medals = ['🥇', '🥈', '🥉'];
    final medal = rank < 3 ? medals[rank] : '🏅';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: KawaiiColors.sakuraPink.withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(medal, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Rank',
                style: GoogleFonts.nunito(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                '#${rank + 1} — ${profile.username}',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('🪙', style: TextStyle(fontSize: 18)),
              Text(
                '${profile.totalCoinsEarned}',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildRankEntry(int rank, LeaderboardEntry entry, String myUsername) {
    final isMe = entry.username == myUsername;
    final medals = {0: '🥇', 1: '🥈', 2: '🥉'};
    final medal = medals[rank] ?? '${rank + 1}.';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe
            ? KawaiiColors.sakuraPink.withAlpha(30)
            : KawaiiColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMe
              ? KawaiiColors.sakuraPink.withAlpha(80)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              medal,
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.username + (isMe ? ' (you!)' : ''),
                  style: GoogleFonts.nunito(
                    color: isMe
                        ? KawaiiColors.sakuraPink
                        : KawaiiColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${entry.tasksCompleted} tasks · 🔥 ${entry.streak} streak',
                  style: GoogleFonts.nunito(
                    color: KawaiiColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          CoinDisplay(coins: entry.coins, fontSize: 15),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: rank * 80))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.05, end: 0);
  }
}
