import 'dart:convert';
import 'package:http/http.dart' as http;

class LeaderboardEntry {
  final String username;
  final int coins;
  final int tasksCompleted;
  final int streak;
  final DateTime lastUpdated;

  LeaderboardEntry({
    required this.username,
    required this.coins,
    required this.tasksCompleted,
    required this.streak,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'coins': coins,
        'tasksCompleted': tasksCompleted,
        'streak': streak,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        username: json['username'] ?? 'Anonymous',
        coins: json['coins'] ?? 0,
        tasksCompleted: json['tasksCompleted'] ?? 0,
        streak: json['streak'] ?? 0,
        lastUpdated: json['lastUpdated'] != null
            ? DateTime.parse(json['lastUpdated'])
            : DateTime.now(),
      );
}

class GithubGistService {
  static const String _apiBase = 'https://api.github.com';
  // Public gist ID for the KawaiiQuest leaderboard (shared across all users)
  // This is a well-known public gist that anyone can read
  static const String _filename = 'kawaiiquest_scores.json';

  /// Fetch leaderboard from a public gist
  Future<List<LeaderboardEntry>> fetchLeaderboard(String gistId) async {
    try {
      final resp = await http.get(
        Uri.parse('$_apiBase/gists/$gistId'),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'X-GitHub-Api-Version': '2022-11-28',
        },
      );

      if (resp.statusCode == 404) return [];
      if (resp.statusCode != 200) {
        throw Exception('GitHub Gist fetch failed: ${resp.statusCode}');
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final files = data['files'] as Map<String, dynamic>?;
      if (files == null || !files.containsKey(_filename)) return [];

      final content = files[_filename]['content'] as String?;
      if (content == null) return [];

      final list = jsonDecode(content) as List<dynamic>;
      final entries = list
          .map((e) => LeaderboardEntry.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      
      // Sort by coins descending
      entries.sort((a, b) => b.coins.compareTo(a.coins));
      return entries;
    } catch (e) {
      throw Exception('Leaderboard fetch error: $e');
    }
  }

  /// Update user's score in the gist (requires GitHub token)
  Future<String> updateScore({
    required String gistId,
    required String githubToken,
    required LeaderboardEntry entry,
  }) async {
    // Fetch existing data
    List<LeaderboardEntry> entries = [];
    try {
      entries = await fetchLeaderboard(gistId);
    } catch (_) {}

    // Update or add this user's entry
    final idx = entries.indexWhere((e) => e.username == entry.username);
    if (idx >= 0) {
      entries[idx] = entry;
    } else {
      entries.add(entry);
    }

    // Sort by coins
    entries.sort((a, b) => b.coins.compareTo(a.coins));

    final content = jsonEncode(entries.map((e) => e.toJson()).toList());

    // Patch the gist
    final resp = await http.patch(
      Uri.parse('$_apiBase/gists/$gistId'),
      headers: {
        'Authorization': 'token $githubToken',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'files': {
          _filename: {'content': content}
        }
      }),
    );

    if (resp.statusCode != 200) {
      throw Exception('Gist update failed: ${resp.statusCode}');
    }

    return gistId;
  }

  /// Create a new gist for the leaderboard
  Future<String> createLeaderboardGist(String githubToken) async {
    final resp = await http.post(
      Uri.parse('$_apiBase/gists'),
      headers: {
        'Authorization': 'token $githubToken',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'description': 'KawaiiQuest Leaderboard',
        'public': true,
        'files': {
          _filename: {'content': '[]'}
        }
      }),
    );

    if (resp.statusCode != 201) {
      throw Exception('Gist creation failed: ${resp.statusCode}');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return data['id'] as String;
  }
}
