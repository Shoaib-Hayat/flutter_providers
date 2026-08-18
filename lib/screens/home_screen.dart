import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/todo.dart';
import '../provider/todo_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _todoController =
  TextEditingController();

  final TextEditingController _searchController =
  TextEditingController();

  @override
  void dispose() {
    _todoController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // =========================
  // ADD TODO
  // =========================

  void _addTodo() {
    final title = _todoController.text.trim();

    if (title.isEmpty) {
      _showMessage('Please enter a todo');
      return;
    }

    context.read<TodoProvider>().addTodo(title);

    _todoController.clear();

    FocusScope.of(context).unfocus();
  }

  // =========================
  // MESSAGE
  // =========================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // =========================
  // EDIT TODO
  // =========================

  void _showEditDialog(Todo todo) {
    final controller = TextEditingController(
      text: todo.title,
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Todo'),

          content: TextField(
            controller: controller,
            autofocus: true,

            decoration: const InputDecoration(
              hintText: 'Enter todo title',
              border: OutlineInputBorder(),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                final newTitle =
                controller.text.trim();

                if (newTitle.isEmpty) {
                  return;
                }

                context
                    .read<TodoProvider>()
                    .updateTodo(
                  todo.id,
                  newTitle,
                );

                Navigator.pop(dialogContext);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // DELETE TODO
  // =========================

  void _deleteTodo(Todo todo) {
    context
        .read<TodoProvider>()
        .deleteTodo(todo.id);

    _showMessage('Todo deleted');
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        title: const Text(
          'My Todo App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,

        actions: [
          // =========================
          // DARK / LIGHT MODE
          // =========================

          Consumer<TodoProvider>(
            builder: (context, provider, child) {
              return IconButton(
                tooltip: 'Change Theme',

                onPressed: () {
                  provider.toggleTheme();
                },

                icon: Icon(
                  provider.isDarkMode
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
              );
            },
          ),

          // =========================
          // CLEAR COMPLETED
          // =========================

          Consumer<TodoProvider>(
            builder: (context, provider, child) {
              if (provider.completedTodos == 0) {
                return const SizedBox();
              }

              return IconButton(
                tooltip: 'Clear Completed',

                onPressed: () {
                  provider.clearCompleted();

                  _showMessage(
                    'Completed todos cleared',
                  );
                },

                icon: const Icon(
                  Icons.delete_sweep,
                ),
              );
            },
          ),
        ],
      ),

      // =========================
      // BODY
      // =========================

      body: SafeArea(
        child: Column(
          children: [
            // ADD TODO
            _buildInputSection(),

            const SizedBox(height: 6),

            // SEARCH
            _buildSearchSection(),

            const SizedBox(height: 6),

            // STATISTICS
            _buildStatistics(),

            const SizedBox(height: 6),

            // FILTERS
            _buildFilters(),

            const SizedBox(height: 4),

            // TODO LIST
            Expanded(
              child: Consumer<TodoProvider>(
                builder:
                    (context, provider, child) {
                  // LOADING
                  if (provider.isLoading) {
                    return const Center(
                      child:
                      CircularProgressIndicator(),
                    );
                  }

                  // ERROR
                  if (provider.errorMessage !=
                      null) {
                    return _buildErrorState(
                      provider.errorMessage!,
                    );
                  }

                  // EMPTY
                  if (provider
                      .filteredTodos
                      .isEmpty) {
                    return _buildEmptyState(
                      provider.currentFilter,
                      provider.searchQuery,
                    );
                  }

                  // LIST
                  return ListView.builder(
                    keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior
                        .onDrag,

                    padding:
                    const EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      16,
                    ),

                    itemCount: provider
                        .filteredTodos.length,

                    itemBuilder:
                        (context, index) {
                      final todo = provider
                          .filteredTodos[index];

                      return _buildTodoItem(
                        todo,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // ADD INPUT
  // =========================

  Widget _buildInputSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        10,
        16,
        0,
      ),

      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _todoController,

              textInputAction:
              TextInputAction.done,

              onSubmitted: (_) {
                _addTodo();
              },

              decoration: InputDecoration(
                hintText: 'Enter a todo',

                prefixIcon: const Icon(
                  Icons.task_alt,
                ),

                contentPadding:
                const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),

                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          SizedBox(
            height: 50,
            width: 50,

            child: ElevatedButton(
              onPressed: _addTodo,

              style:
              ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,

                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),

              child: const Icon(
                Icons.add,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // SEARCH
  // =========================

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),

      child: TextField(
        controller: _searchController,

        onChanged: (value) {
          context
              .read<TodoProvider>()
              .searchTodos(value);
        },

        decoration: InputDecoration(
          hintText: 'Search todos...',

          prefixIcon: const Icon(
            Icons.search,
          ),

          contentPadding:
          const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 12,
          ),

          suffixIcon:
          Consumer<TodoProvider>(
            builder:
                (context, provider, child) {
              if (provider.searchQuery
                  .isEmpty) {
                return const SizedBox();
              }

              return IconButton(
                onPressed: () {
                  _searchController.clear();

                  provider.clearSearch();
                },

                icon: const Icon(
                  Icons.clear,
                ),
              );
            },
          ),

          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // =========================
  // STATISTICS
  // =========================

  Widget _buildStatistics() {
    return Consumer<TodoProvider>(
      builder:
          (context, provider, child) {
        return Padding(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 16,
          ),

          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  provider.totalTodos,
                  Icons.list,
                ),
              ),

              const SizedBox(width: 6),

              Expanded(
                child: _buildStatCard(
                  'Pending',
                  provider.pendingTodos,
                  Icons.pending_actions,
                ),
              ),

              const SizedBox(width: 6),

              Expanded(
                child: _buildStatCard(
                  'Done',
                  provider.completedTodos,
                  Icons.check_circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================
  // STAT CARD
  // =========================

  Widget _buildStatCard(
      String title,
      int value,
      IconData icon,
      ) {
    return Card(
      margin: EdgeInsets.zero,

      child: Padding(
        padding:
        const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 4,
        ),

        child: Column(
          mainAxisSize:
          MainAxisSize.min,

          children: [
            Icon(
              icon,
              size: 20,
            ),

            const SizedBox(height: 2),

            Text(
              '$value',

              style:
              const TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            Text(
              title,

              style:
              const TextStyle(
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // FILTERS
  // =========================

  Widget _buildFilters() {
    return Consumer<TodoProvider>(
      builder:
          (context, provider, child) {
        return SingleChildScrollView(
          scrollDirection:
          Axis.horizontal,

          padding:
          const EdgeInsets.symmetric(
            horizontal: 16,
          ),

          child: Row(
            children: [
              _buildFilterButton(
                title: 'All',
                filter:
                TodoFilter.all,
                provider: provider,
              ),

              const SizedBox(width: 6),

              _buildFilterButton(
                title: 'Pending',
                filter:
                TodoFilter.pending,
                provider: provider,
              ),

              const SizedBox(width: 6),

              _buildFilterButton(
                title: 'Completed',
                filter:
                TodoFilter.completed,
                provider: provider,
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================
  // FILTER BUTTON
  // =========================

  Widget _buildFilterButton({
    required String title,
    required TodoFilter filter,
    required TodoProvider provider,
  }) {
    final isSelected =
        provider.currentFilter ==
            filter;

    return ChoiceChip(
      label: Text(title),

      selected: isSelected,

      onSelected: (_) {
        provider.changeFilter(
          filter,
        );
      },
    );
  }

  // =========================
  // TODO ITEM
  // =========================

  Widget _buildTodoItem(Todo todo) {
    return Card(
      margin:
      const EdgeInsets.only(
        bottom: 8,
      ),

      child: ListTile(
        dense: true,

        contentPadding:
        const EdgeInsets
            .symmetric(
          horizontal: 8,
          vertical: 0,
        ),

        leading: Checkbox(
          value:
          todo.isCompleted,

          onChanged: (_) {
            context
                .read<TodoProvider>()
                .toggleTodo(
              todo.id,
            );
          },
        ),

        title: Text(
          todo.title,

          maxLines: 2,
          overflow:
          TextOverflow.ellipsis,

          style: TextStyle(
            fontSize: 15,

            fontWeight:
            FontWeight.w500,

            decoration:
            todo.isCompleted
                ? TextDecoration
                .lineThrough
                : TextDecoration
                .none,

            color:
            todo.isCompleted
                ? Colors.grey
                : null,
          ),
        ),

        trailing: Row(
          mainAxisSize:
          MainAxisSize.min,

          children: [
            IconButton(
              tooltip: 'Edit',

              padding:
              const EdgeInsets.all(
                6,
              ),

              constraints:
              const BoxConstraints(),

              onPressed: () {
                _showEditDialog(
                  todo,
                );
              },

              icon:
              const Icon(
                Icons.edit,
                size: 20,
              ),
            ),

            const SizedBox(width: 8),

            IconButton(
              tooltip: 'Delete',

              padding:
              const EdgeInsets.all(
                6,
              ),

              constraints:
              const BoxConstraints(),

              onPressed: () {
                _deleteTodo(
                  todo,
                );
              },

              icon:
              const Icon(
                Icons.delete,
                color: Colors.red,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // EMPTY STATE
  // =========================

  Widget _buildEmptyState(
      TodoFilter filter,
      String searchQuery,
      ) {
    String message;

    if (searchQuery.isNotEmpty) {
      message = 'No todos found';
    } else {
      switch (filter) {
        case TodoFilter.all:
          message = 'No Todos Yet';
          break;

        case TodoFilter.pending:
          message =
          'No Pending Todos';
          break;

        case TodoFilter.completed:
          message =
          'No Completed Todos';
          break;
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [
          Icon(
            searchQuery.isNotEmpty
                ? Icons.search_off
                : Icons.task_alt,

            size: 70,

            color:
            Colors.grey.shade400,
          ),

          const SizedBox(height: 12),

          Text(
            message,

            style:
            const TextStyle(
              fontSize: 20,
              fontWeight:
              FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // ERROR STATE
  // =========================

  Widget _buildErrorState(
      String error,
      ) {
    return Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [
          const Icon(
            Icons.error_outline,
            size: 70,
            color: Colors.red,
          ),

          const SizedBox(height: 12),

          Text(
            error,

            style:
            const TextStyle(
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: () {
              context
                  .read<TodoProvider>()
                  .loadTodos();
            },

            child:
            const Text(
              'Try Again',
            ),
          ),
        ],
      ),
    );
  }
}