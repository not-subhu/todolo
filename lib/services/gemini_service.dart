import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  final String apiKey;
  GeminiService(this.apiKey);

  bool get isValid => apiKey.isNotEmpty;

  Future<String> _generate(String prompt) async {
    final resp = await http.post(
      Uri.parse(_baseUrl),
      // Key goes in a request header, not the URL, to avoid leaking it
      // in server access logs, analytics, or browser network tabs.
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey,
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.8,
          'maxOutputTokens': 1024,
        },
      }),
    );

    if (resp.statusCode != 200) {
      throw Exception('Gemini error: ${resp.statusCode} ${resp.body}');
    }

    final data = jsonDecode(resp.body);
    return data['candidates'][0]['content']['parts'][0]['text'] as String;
  }

  /// Parse a free-text paragraph into a list of tasks
  Future<List<ParsedTask>> parseTasksFromText(String text) async {
    final prompt = '''
You are a smart task extraction assistant for a student productivity app.
Given the following paragraph, extract all tasks/todos from it and format them as a JSON array.

For each task, identify:
- title: short task name (max 60 chars)
- description: any additional details (can be empty)
- priority: "low", "medium", "high", or "urgent"
- hasDueDate: true/false
- dueDateHint: any time/date hint like "tomorrow", "friday", "3pm" (or null)

Input text:
"$text"

Respond ONLY with valid JSON array, no markdown, no extra text:
[{"title":"...","description":"...","priority":"medium","hasDueDate":false,"dueDateHint":null}]
''';

    try {
      final result = await _generate(prompt);
      // Clean up possible markdown code blocks
      final clean = result
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final list = jsonDecode(clean) as List<dynamic>;
      return list.map((e) => ParsedTask.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      // Fallback: treat whole text as one task
      return [ParsedTask(title: text.length > 60 ? text.substring(0, 60) : text)];
    }
  }

  /// Generate a creative anime-style pestering notification
  Future<String> generatePesterMessage({
    required String taskTitle,
    required String username,
    required bool isUrgent,
    int? minutesUntilDue,
  }) async {
    final urgencyNote = isUrgent
        ? 'The task is VERY URGENT and overdue!'
        : minutesUntilDue != null
            ? 'Due in $minutesUntilDue minutes.'
            : 'No specific due time but needs to be done.';

    final prompt = '''
You are an anime character sending a notification to a procrastinating student named "$username".
Task they are avoiding: "$taskTitle"
Context: $urgencyNote

Write ONE short, creative, anime-style notification message (2-4 lines max).
Use:
- Anime speech patterns and dramatic flair
- Kaomoji like (；´д｀)ゞ (◕‿◕✿) ヾ(≧▽≦*)o (╯°□°）╯︵ ┻━┻ (≧◡≦) ♡
- Vary between playful, dramatic, disappointed, cheerleader, and slightly threatening tones
- Reference anime tropes (rival character, training arc, final boss, power of friendship, etc.)
- Keep it SHORT and punchy
- No emojis from standard set, only kaomoji
- Make it feel real and personal, not generic

Examples of tone variety:
- "Yare yare... Another 'five more minutes', $username-san? Even my dead ancestors are disappointed. (｡•́︿•̀｡)"
- "NANI?! You haven't started $taskTitle yet?! The power of procrastination... I didn't expect it to be THIS strong! (╯°□°）╯︵ ┻━┻"  
- "H-hey! I believe in you, $username-chan! You can do it! ٩(◕‿◕)۶ ...but seriously please start now ok"

Write ONLY the message, no labels or explanations:
''';

    try {
      return await _generate(prompt);
    } catch (e) {
      return _fallbackPesterMessage(taskTitle, username, isUrgent);
    }
  }

  /// Generate a motivation caption for the anime girl
  Future<String> generateMotivationCaption(String username, int streak) async {
    final prompt = '''
You are a cute anime girl character who is the spirit guide and biggest fan of a student named "$username".
They have a current study/task streak of $streak days.

Write a short, heartfelt, anime-style motivational message (2-3 lines).
Use:
- Warm, encouraging anime girl voice
- Kaomoji sparingly
- Reference their streak if it's > 0
- Make it feel genuine and personal, not generic
- Slightly dramatic but sweet

Write ONLY the message:
''';

    try {
      return await _generate(prompt);
    } catch (e) {
      return streak > 0
          ? '$streak days strong! I\'ve been watching you grow~ Keep going, you\'re amazing! (◕‿◕✿)'
          : 'Every journey starts with one step! I believe in you with my whole heart ♡';
    }
  }

  String _fallbackPesterMessage(String task, String username, bool urgent) {
    final messages = [
      'Yare yare... $username-san, "$task" is still waiting for you. Even my ancestors are watching (and judging). (｡•́︿•̀｡)',
      'NANI?! You haven\'t touched "$task" yet?! This isn\'t a training arc, this is the FINAL BOSS! ٩(ఠ益ఠ)۶',
      'H-hey... I\'m not mad. I\'m just... *sniffles* disappointed about "$task". (；´д｀)ゞ',
      'Oi, $username! The power of friendship demands you DO "$task" RIGHT NOW! (ノ°▽°)ノ',
      '${urgent ? "EMERGENCY" : "Friendly reminder"}: "$task" won\'t complete itself! Even the main character has to actually DO things! ┐(￣ヘ￣)┌',
    ];
    messages.shuffle();
    return messages.first;
  }
}

class ParsedTask {
  final String title;
  final String description;
  final String priority;
  final bool hasDueDate;
  final String? dueDateHint;

  ParsedTask({
    required this.title,
    this.description = '',
    this.priority = 'medium',
    this.hasDueDate = false,
    this.dueDateHint,
  });

  factory ParsedTask.fromJson(Map<String, dynamic> json) => ParsedTask(
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        priority: json['priority'] ?? 'medium',
        hasDueDate: json['hasDueDate'] ?? false,
        dueDateHint: json['dueDateHint'],
      );

  Task toTask() {
    TaskPriority p;
    switch (priority) {
      case 'low':
        p = TaskPriority.low;
        break;
      case 'high':
        p = TaskPriority.high;
        break;
      case 'urgent':
        p = TaskPriority.urgent;
        break;
      default:
        p = TaskPriority.medium;
    }
    return Task(title: title, description: description, priority: p);
  }
}
