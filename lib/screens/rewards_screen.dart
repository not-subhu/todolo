import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/reward.dart';
import '../providers/app_provider.dart';
import '../providers/rewards_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/kawaii_widgets.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<RewardsProvider, AppProvider>(
      builder: (context, rewards, app, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(
              'Rewards Shop',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: KawaiiColors.textPrimary,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CoinDisplay(
                  coins: app.profile.availableCoins,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Big coin banner
                      GlassCard(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: KawaiiColors.gold.withAlpha(30),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('🪙', style: TextStyle(fontSize: 32)),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Balance',
                                  style: GoogleFonts.nunito(
                                    color: KawaiiColors.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '${app.profile.availableCoins} coins',
                                  style: GoogleFonts.nunito(
                                    color: KawaiiColors.gold,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms),
                      const SizedBox(height: 20),
                      const SectionHeader(
                        title: '🛍️ Available Rewards',
                        subtitle: 'Spend your hard-earned coins!',
                      ),
                    ],
                  ),
                ),
              ),

              // Available rewards grid
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _RewardCard(
                      reward: rewards.available[i],
                      canAfford:
                          app.profile.availableCoins >= rewards.available[i].cost,
                      onBuy: () => _buy(context, rewards.available[i], rewards, app),
                      index: i,
                    ),
                    childCount: rewards.available.length,
                  ),
                ),
              ),

              // Add custom reward
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: GestureDetector(
                    onTap: () => _showAddReward(context, rewards),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: KawaiiColors.sakuraPink.withAlpha(60),
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_circle_outline,
                              color: KawaiiColors.sakuraPink),
                          const SizedBox(width: 8),
                          Text(
                            'Add custom reward~',
                            style: GoogleFonts.nunito(
                              color: KawaiiColors.sakuraPink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Purchased rewards
              if (rewards.purchased.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: const SectionHeader(
                      title: '✅ Claimed Rewards',
                      subtitle: 'You enjoyed these!',
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final r = rewards.purchased[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GlassCard(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Text(r.emoji, style: const TextStyle(fontSize: 24)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    r.name,
                                    style: GoogleFonts.nunito(
                                      color: KawaiiColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.check_circle,
                                    color: KawaiiColors.priorityLow, size: 20),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: rewards.purchased.length,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _buy(
    BuildContext context,
    Reward reward,
    RewardsProvider rewards,
    AppProvider app,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: KawaiiColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Buy ${reward.name}?',
          style: GoogleFonts.nunito(
            color: KawaiiColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(reward.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(
              reward.description,
              style: GoogleFonts.nunito(color: KawaiiColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            CoinDisplay(coins: reward.cost, showLabel: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Nah', style: GoogleFonts.nunito(color: KawaiiColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes! ✨'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await app.spendCoins(reward.cost);
      if (success) {
        await rewards.purchaseReward(reward.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${reward.emoji} Enjoy your reward, you\'ve earned it! ٩(◕‿◕)۶',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
              ),
              backgroundColor: KawaiiColors.sakuraPink,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Not enough coins! Complete more tasks first~ (´；ω；`)',
                style: GoogleFonts.nunito(),
              ),
              backgroundColor: KawaiiColors.coral,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _showAddReward(BuildContext context, RewardsProvider rewards) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: KawaiiColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _AddRewardSheet(rewards: rewards),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final Reward reward;
  final bool canAfford;
  final VoidCallback onBuy;
  final int index;

  const _RewardCard({
    required this.reward,
    required this.canAfford,
    required this.onBuy,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: canAfford ? onBuy : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: canAfford ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [KawaiiColors.cardDark, KawaiiColors.cardMid],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: canAfford
                  ? KawaiiColors.sakuraPink.withAlpha(40)
                  : KawaiiColors.textMuted.withAlpha(30),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(reward.emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              Text(
                reward.name,
                style: GoogleFonts.nunito(
                  color: KawaiiColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CoinDisplay(coins: reward.cost, fontSize: 14),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: canAfford
                          ? KawaiiColors.sakuraPink
                          : KawaiiColors.cardMid,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      canAfford ? Icons.shopping_bag_outlined : Icons.lock_outline,
                      color: canAfford ? Colors.white : KawaiiColors.textMuted,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
            .animate(delay: Duration(milliseconds: index * 80))
            .fadeIn(duration: 300.ms)
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.0, 1.0),
              duration: 300.ms,
            ),
      ),
    );
  }
}

class _AddRewardSheet extends StatefulWidget {
  final RewardsProvider rewards;

  const _AddRewardSheet({required this.rewards});

  @override
  State<_AddRewardSheet> createState() => _AddRewardSheetState();
}

class _AddRewardSheetState extends State<_AddRewardSheet> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  int _cost = 50;
  String _emoji = '🎁';

  final List<String> _emojis = ['🎁', '🍕', '🎮', '📺', '🧋', '🛁', '🎵', '📖', '🎨', '🌸'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: KawaiiColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Custom Reward~ ✨',
            style: GoogleFonts.nunito(
              color: KawaiiColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 16),
          // Emoji picker
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _emojis.length,
              itemBuilder: (ctx, i) => GestureDetector(
                onTap: () => setState(() => _emoji = _emojis[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(right: 8),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _emoji == _emojis[i]
                        ? KawaiiColors.sakuraPink
                        : KawaiiColors.cardMid,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(_emojis[i], style: const TextStyle(fontSize: 22)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: KawaiiColors.textPrimary),
            decoration: const InputDecoration(labelText: 'Reward name'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descCtrl,
            style: const TextStyle(color: KawaiiColors.textPrimary),
            decoration: const InputDecoration(labelText: 'Description (optional)'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('🪙', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Cost: $_cost coins',
                style: GoogleFonts.nunito(color: KawaiiColors.textPrimary),
              ),
              Expanded(
                child: Slider(
                  value: _cost.toDouble(),
                  min: 10,
                  max: 300,
                  divisions: 29,
                  activeColor: KawaiiColors.sakuraPink,
                  onChanged: (v) => setState(() => _cost = v.toInt()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: const Text('Add Reward!'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    final reward = Reward(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      cost: _cost,
      emoji: _emoji,
    );
    await widget.rewards.addReward(reward);
    if (mounted) Navigator.pop(context);
  }
}
