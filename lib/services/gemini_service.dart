import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

// ── Model identifiers ──────────────────────────────────────────────────────
// Primary: Gemma 3 27B instruction-tuned (largest available open model)
// Fallback: Gemini 2.5 Flash Lite (lighter, faster)
const _kPrimary  = 'gemma-3-27b-it';
const _kFallback = 'gemini-2.5-flash-lite';

const _kBase = 'https://generativelanguage.googleapis.com/v1beta/models';

class GeminiService {
  final String apiKey;
  GeminiService(this.apiKey);

  bool get isValid => apiKey.isNotEmpty;

  // ── Core generator with primary→fallback cascade ──────────────────────────
  Future<String> _generate(
    String prompt, {
    double temperature = 0.85,
    int maxTokens = 1024,
  }) async {
    // Try primary model first, then fallback
    for (final model in [_kPrimary, _kFallback]) {
      try {
        final resp = await http
            .post(
              Uri.parse('$_kBase/$model:generateContent'),
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
                  'temperature': temperature,
                  'maxOutputTokens': maxTokens,
                },
              }),
            )
            .timeout(const Duration(seconds: 30));

        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body);
          return data['candidates'][0]['content']['parts'][0]['text'] as String;
        }
        // 503 / 429 → model unavailable, try fallback
        if (resp.statusCode == 503 || resp.statusCode == 429) continue;
        // Other errors → throw
        throw Exception('API ${resp.statusCode}: ${resp.body}');
      } on TimeoutException {
        // Timeout → try fallback
        continue;
      }
    }
    throw const _BothModelsUnavailableException();
  }

  // ── Task parsing ─────────────────────────────────────────────────────────
  Future<List<ParsedTask>> parseTasksFromText(String text) async {
    final prompt = '''
You are a smart task extraction assistant for a student productivity app called Screech.
Extract all tasks/todos from the text below and return them as a JSON array.

For each task, identify:
- title: short task name (max 60 chars)
- description: any additional details (can be empty string)
- priority: "low", "medium", "high", or "urgent"
- hasDueDate: true/false
- dueDateHint: time/date hint like "tomorrow", "friday", "3pm", or null

Input text:
"$text"

Respond ONLY with valid JSON array, no markdown, no extra text:
[{"title":"...","description":"...","priority":"medium","hasDueDate":false,"dueDateHint":null}]
''';

    final result = await _generate(prompt, temperature: 0.3, maxTokens: 800);
    final clean = result
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    final list = jsonDecode(clean) as List<dynamic>;
    return list.map((e) => ParsedTask.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  // ── Pester message batch generator ───────────────────────────────────────
  /// Generates 15 mock/pester messages for a given task and returns them as a
  /// `List&lt;String&gt;`. The messages are stored per-task so the same set is reused
  /// (avoiding repeated API calls) until the task is completed.
  Future<List<String>> generatePesterBatch({
    required String taskTitle,
    required String username,
    String? customPrompt,
  }) async {
    final promptTemplate = customPrompt ??
        '''You are an outspoken, dramatic anime character who REALLY wants a student named "$username" to finish their task: "$taskTitle".

Imagine a specific character with a strong personality — could be a tsundere rival, a disappointed sensei, a chaotic gremlin friend, a dramatic villain, etc. Commit to the character fully.

Generate exactly 15 short messages (2-4 lines each) mocking/pestering the user about this task. Vary the tone: scolding, disappointed, chaotic, slightly threatening, begrudgingly supportive, existentially dramatic. Use kaomoji like (╯°□°）╯︵ ┻━┻ (；´д｀)ゞ ٩(ఠ益ఠ)۶ (◕‿◕) (｡•́︿•̀｡). Reference anime tropes. Make them punchy and personal.

Return ONLY a JSON array of 15 strings, no markdown:
["message 1","message 2",...]''';

    final result = await _generate(promptTemplate, temperature: 1.0, maxTokens: 2000);
    final clean = result
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    final list = jsonDecode(clean) as List<dynamic>;
    return list.cast<String>();
  }

  // ── Single pester (fallback / on-demand) ─────────────────────────────────
  Future<String> generatePesterMessage({
    required String taskTitle,
    required String username,
    required bool isUrgent,
  }) async {
    final prompt = '''
You are a dramatic anime character pestering a student named "$username" about their task: "$taskTitle".
${isUrgent ? "The task is OVERDUE. Be very dramatic." : "The task is still pending. Be sarcastic."}

Write ONE short pester message (2-3 lines). Use kaomoji. Be punchy and personal.
Write ONLY the message:
''';
    try {
      return await _generate(prompt);
    } catch (_) {
      return _fallback(taskTitle, username, isUrgent);
    }
  }

  // ── Motivation caption ────────────────────────────────────────────────────
  Future<String> generateMotivationCaption(String username, int streak) async {
    final prompt = '''
You are a supportive anime character speaking to a student named "$username" who has a task streak of $streak days.
Write a short (2-3 lines) heartfelt anime-style motivational message. Use kaomoji sparingly. Write ONLY the message:
''';
    try {
      return await _generate(prompt);
    } catch (_) {
      return streak > 0
          ? '$streak days strong! Keep going, $username~ (◕‿◕✿)'
          : 'Every legend starts somewhere. Begin now, $username! ✨';
    }
  }

  String _fallback(String task, String username, bool urgent) {
    final msgs = [
      'Yare yare... $username-san, "$task" is STILL there. My disappointment is immeasurable. (｡•́︿•̀｡)',
      'NANI?! You haven\'t touched "$task" yet?! This isn\'t a training arc! ٩(ఠ益ఠ)۶',
      'H-hey! Not like I CARE about "$task" but... you should do it. Idiot. (╯°□°）╯',
      '$username! The power of procrastination... I underestimated you. (；´д｀)ゞ',
      '${urgent ? "⚠️ OVERDUE:" : "Reminder:"} "$task" won\'t do itself, $username-kun! (ノ°▽°)ノ',
    ];
    msgs.shuffle();
    return msgs.first;
  }
}

// ── Exception sentinel ────────────────────────────────────────────────────
class _BothModelsUnavailableException implements Exception {
  const _BothModelsUnavailableException();
  @override
  String toString() => 'Both Gemini models are currently unavailable.';
}

bool isBothModelsUnavailable(Object e) => e is _BothModelsUnavailableException;

// ── Parsed task ───────────────────────────────────────────────────────────
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
      case 'low':    p = TaskPriority.low;    break;
      case 'high':   p = TaskPriority.high;   break;
      case 'urgent': p = TaskPriority.urgent; break;
      default:       p = TaskPriority.medium;
    }
    return Task(title: title, description: description, priority: p);
  }
}
