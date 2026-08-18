import 'package:flutter/material.dart';

import '../database/todo_database.dart';
import '../models/todo.dart';

enum TodoFilter {
  all,
  pending,
  completed,
}

class TodoProvider extends ChangeNotifier {
  final TodoDatabase _database = TodoDatabase();

  final List<Todo> _todos = [];

  bool _isLoading = false;
  String? _errorMessage;

  TodoFilter _currentFilter = TodoFilter.all;
  String _searchQuery = '';

  ThemeMode _themeMode = ThemeMode.light;

  // =========================
  // GETTERS
  // =========================

  List<Todo> get todos => List.unmodifiable(_todos);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  TodoFilter get currentFilter => _currentFilter;

  String get searchQuery => _searchQuery;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  int get totalTodos => _todos.length;

  int get completedTodos =>
      _todos.where((todo) => todo.isCompleted).length;

  int get pendingTodos =>
      _todos.where((todo) => !todo.isCompleted).length;

  // =========================
  // FILTER + SEARCH
  // =========================

  List<Todo> get filteredTodos {
    List<Todo> result;

    switch (_currentFilter) {
      case TodoFilter.all:
        result = List.from(_todos);
        break;

      case TodoFilter.pending:
        result = _todos
            .where((todo) => !todo.isCompleted)
            .toList();
        break;

      case TodoFilter.completed:
        result = _todos
            .where((todo) => todo.isCompleted)
            .toList();
        break;
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();

      result = result.where((todo) {
        return todo.title.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  }

  // =========================
  // THEME
  // =========================

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }

    notifyListeners();
  }

  // =========================
  // SEARCH
  // =========================

  void searchTodos(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // =========================
  // FILTER
  // =========================

  void changeFilter(TodoFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  // =========================
  // LOADING
  // =========================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // =========================
  // LOAD TODOS
  // =========================

  Future<void> loadTodos() async {
    _setLoading(true);

    try {
      _errorMessage = null;

      final savedTodos = _database.getTodos();

      _todos.clear();

      for (final item in savedTodos) {
        _todos.add(
          Todo(
            id: item['id'].toString(),
            title: item['title'].toString(),
            isCompleted: item['isCompleted'] == true,
          ),
        );
      }
    } catch (e) {
      _errorMessage = 'Failed to load todos';
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // SAVE TODOS
  // =========================

  Future<void> _saveTodos() async {
    final data = _todos.map((todo) {
      return {
        'id': todo.id,
        'title': todo.title,
        'isCompleted': todo.isCompleted,
      };
    }).toList();

    await _database.saveTodos(data);
  }

  // =========================
  // ADD
  // =========================

  Future<void> addTodo(String title) async {
    final cleanTitle = title.trim();

    if (cleanTitle.isEmpty) {
      return;
    }

    _errorMessage = null;

    final todo = Todo(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: cleanTitle,
    );

    _todos.add(todo);

    notifyListeners();

    try {
      await _saveTodos();
    } catch (e) {
      _errorMessage = 'Failed to save todo';
      notifyListeners();
    }
  }

  // =========================
  // TOGGLE
  // =========================

  Future<void> toggleTodo(String id) async {
    final index = _todos.indexWhere(
          (todo) => todo.id == id,
    );

    if (index == -1) {
      return;
    }

    final todo = _todos[index];

    _todos[index] = todo.copyWith(
      isCompleted: !todo.isCompleted,
    );

    notifyListeners();

    try {
      await _saveTodos();
    } catch (e) {
      _errorMessage = 'Failed to update todo';
      notifyListeners();
    }
  }

  // =========================
  // DELETE
  // =========================

  Future<void> deleteTodo(String id) async {
    _todos.removeWhere(
          (todo) => todo.id == id,
    );

    notifyListeners();

    try {
      await _saveTodos();
    } catch (e) {
      _errorMessage = 'Failed to delete todo';
      notifyListeners();
    }
  }

  // =========================
  // UPDATE
  // =========================

  Future<void> updateTodo(
      String id,
      String newTitle,
      ) async {
    final cleanTitle = newTitle.trim();

    if (cleanTitle.isEmpty) {
      return;
    }

    final index = _todos.indexWhere(
          (todo) => todo.id == id,
    );

    if (index == -1) {
      return;
    }

    _todos[index] = _todos[index].copyWith(
      title: cleanTitle,
    );

    notifyListeners();

    try {
      await _saveTodos();
    } catch (e) {
      _errorMessage = 'Failed to update todo';
      notifyListeners();
    }
  }

  // =========================
  // CLEAR COMPLETED
  // =========================

  Future<void> clearCompleted() async {
    _todos.removeWhere(
          (todo) => todo.isCompleted,
    );

    notifyListeners();

    try {
      await _saveTodos();
    } catch (e) {
      _errorMessage = 'Failed to clear completed todos';
      notifyListeners();
    }
  }

  // =========================
  // CLEAR ERROR
  // =========================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}