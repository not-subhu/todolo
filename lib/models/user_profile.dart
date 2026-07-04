import 'dart:ui';

class UserProfile {
  String username;
  int totalCoinsEarned;
  int availableCoins;
  int tasksCompleted;
  int habitsCompleted;
  int currentStreak;
  int longestStreak;
  DateTime? lastActiveDate;
  String? geminiApiKey;
  String? todoistToken;
  String? githubGistId;
  bool pesteringEnabled;
  bool motivationEnabled;
  int pesterIntervalMinutes;
  DateTime createdAt;

  // ── Personalisation ───────────────────────────────────────
  /// Primary accent colour as ARGB int (null = default purple)
  int? primaryColorValue;
  /// 0.0 = minimal glass, 1.0 = maximum glass blur/opacity
  double glassLevel;
  bool isDarkMode;
  /// Asset path or file path for the header background image (null = default)
  String? headerImagePath;
  /// Motivational quote override (null = auto-rotate)
  String? motivationQuote;
  /// Custom pestering prompt template (null = default)
  String? customPesterPrompt;

  UserProfile({
    this.username = 'User',
    this.totalCoinsEarned = 0,
    this.availableCoins = 0,
    this.tasksCompleted = 0,
    this.habitsCompleted = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    this.geminiApiKey,
    this.todoistToken,
    this.githubGistId,
    this.pesteringEnabled = true,
    this.motivationEnabled = true,
    this.pesterIntervalMinutes = 30,
    DateTime? createdAt,
    this.primaryColorValue,
    this.glassLevel = 0.5,
    this.isDarkMode = true,
    this.headerImagePath,
    this.motivationQuote,
    this.customPesterPrompt,
  }) : createdAt = createdAt ?? DateTime.now();

  Color get primaryColor =>
      primaryColorValue != null ? Color(primaryColorValue!) : const Color(0xFF7C3AED);

  int get level => (totalCoinsEarned / 100).floor() + 1;
  int get xpInLevel => totalCoinsEarned % 100;
  int get xpToNextLevel => 100;
  double get levelProgress => xpInLevel / xpToNextLevel;

  String get levelTitle {
    if (level < 5)  return 'Sleepy Student';
    if (level < 10) return 'Aspiring Scholar';
    if (level < 20) return 'Diligent Senpai';
    if (level < 35) return 'Star Pupil';
    if (level < 50) return 'Honor Student';
    return 'Legend of the School';
  }

  void addCoins(int amount) {
    availableCoins += amount;
    totalCoinsEarned += amount;
  }

  bool spendCoins(int amount) {
    if (availableCoins >= amount) {
      availableCoins -= amount;
      return true;
    }
    return false;
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'totalCoinsEarned': totalCoinsEarned,
    'availableCoins': availableCoins,
    'tasksCompleted': tasksCompleted,
    'habitsCompleted': habitsCompleted,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'lastActiveDate': lastActiveDate?.toIso8601String(),
    'geminiApiKey': geminiApiKey,
    'todoistToken': todoistToken,
    'githubGistId': githubGistId,
    'pesteringEnabled': pesteringEnabled,
    'motivationEnabled': motivationEnabled,
    'pesterIntervalMinutes': pesterIntervalMinutes,
    'createdAt': createdAt.toIso8601String(),
    'primaryColorValue': primaryColorValue,
    'glassLevel': glassLevel,
    'isDarkMode': isDarkMode,
    'headerImagePath': headerImagePath,
    'motivationQuote': motivationQuote,
    'customPesterPrompt': customPesterPrompt,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    DateTime? parseSafe(String? s) {
      if (s == null) return null;
      try { return DateTime.parse(s); } catch (_) { return null; }
    }
    return UserProfile(
      username: json['username'] ?? 'User',
      totalCoinsEarned: json['totalCoinsEarned'] ?? 0,
      availableCoins: json['availableCoins'] ?? 0,
      tasksCompleted: json['tasksCompleted'] ?? 0,
      habitsCompleted: json['habitsCompleted'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastActiveDate: parseSafe(json['lastActiveDate']),
      geminiApiKey: json['geminiApiKey'],
      todoistToken: json['todoistToken'],
      githubGistId: json['githubGistId'],
      pesteringEnabled: json['pesteringEnabled'] ?? true,
      motivationEnabled: json['motivationEnabled'] ?? true,
      pesterIntervalMinutes: json['pesterIntervalMinutes'] ?? 30,
      createdAt: parseSafe(json['createdAt']) ?? DateTime.now(),
      primaryColorValue: json['primaryColorValue'],
      glassLevel: (json['glassLevel'] ?? 0.5).toDouble(),
      isDarkMode: json['isDarkMode'] ?? true,
      headerImagePath: json['headerImagePath'],
      motivationQuote: json['motivationQuote'],
      customPesterPrompt: json['customPesterPrompt'],
    );
  }
}
