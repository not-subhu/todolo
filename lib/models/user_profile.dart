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

  UserProfile({
    this.username = 'Student-chan',
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
  }) : createdAt = createdAt ?? DateTime.now();

  int get level => (totalCoinsEarned / 100).floor() + 1;
  int get xpInLevel => totalCoinsEarned % 100;
  int get xpToNextLevel => 100;
  double get levelProgress => xpInLevel / xpToNextLevel;

  String get levelTitle {
    if (level < 5) return 'Sleepy Student';
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
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    DateTime? parseSafe(String? s) {
      if (s == null) return null;
      try { return DateTime.parse(s); } catch (_) { return null; }
    }
    return UserProfile(
      username: json['username'] ?? 'Student-chan',
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
    );
  }
}
