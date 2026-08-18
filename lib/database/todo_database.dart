import 'package:hive_flutter/hive_flutter.dart';

class TodoDatabase {
  static const String boxName = 'todos';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  Box get box => Hive.box(boxName);

  List<Map<String, dynamic>> getTodos() {
    final data = box.get('todo_list');

    if (data == null) {
      return [];
    }

    return List<Map<String, dynamic>>.from(
      (data as List).map(
            (item) => Map<String, dynamic>.from(item),
      ),
    );
  }

  Future<void> saveTodos(
      List<Map<String, dynamic>> todos,
      ) async {
    await box.put('todo_list', todos);
  }
}