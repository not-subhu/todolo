import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class TodoistService {
  static const String _baseUrl = 'https://api.todoist.com/rest/v2';
  final String token;
  TodoistService(this.token);

  bool get isValid => token.isNotEmpty;

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  Future<List<Task>> fetchTasks() async {
    try {
      final resp = await http.get(
        Uri.parse('$_baseUrl/tasks'),
        headers: _headers,
      );
      if (resp.statusCode != 200) {
        throw Exception('Todoist fetch failed: ${resp.statusCode}');
      }
      final list = jsonDecode(resp.body) as List<dynamic>;
      return list.map((e) => _todoistToTask(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      throw Exception('Todoist error: $e');
    }
  }

  Future<bool> closeTask(String todoistId) async {
    try {
      final resp = await http.post(
        Uri.parse('$_baseUrl/tasks/$todoistId/close'),
        headers: _headers,
      );
      return resp.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  Task _todoistToTask(Map<String, dynamic> json) {
    DateTime? dueDate;
    if (json['due'] != null) {
      final due = json['due'] as Map<String, dynamic>;
      final dateStr = due['date'] as String?;
      if (dateStr != null) {
        dueDate = DateTime.tryParse(dateStr);
      }
    }

    int priority;
    switch (json['priority']) {
      case 4:
        priority = TaskPriority.urgent.index;
        break;
      case 3:
        priority = TaskPriority.high.index;
        break;
      case 2:
        priority = TaskPriority.medium.index;
        break;
      default:
        priority = TaskPriority.low.index;
    }

    return Task(
      title: json['content'] ?? 'Untitled',
      description: json['description'] ?? '',
      dueDate: dueDate,
      priority: TaskPriority.values[priority],
      todoistId: json['id']?.toString(),
    );
  }
}
