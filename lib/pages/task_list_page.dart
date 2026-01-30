import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';
import '../services/task_service.dart';
import '../models/task.dart';
import '../widgets/empty_state.dart';
import '../widgets/skeleton_loader.dart';
import 'add_edit_task_page.dart';
import 'task_detail_page.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final TaskService _taskService = TaskService();
  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];
  bool _isLoading = true;
  TaskFilter _currentFilter = TaskFilter.all;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final user = SupabaseService.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final tasks = await _taskService.getTasks(user.id);
      setState(() {
        _allTasks = tasks;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    setState(() {
      switch (_currentFilter) {
        case TaskFilter.all:
          _filteredTasks = _allTasks;
          break;
        case TaskFilter.completed:
          _filteredTasks = _allTasks.where((t) => t.isCompleted).toList();
          break;
        case TaskFilter.pending:
          _filteredTasks = _allTasks.where((t) => !t.isCompleted).toList();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Tugas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          PopupMenuButton<TaskFilter>(
            icon: const Icon(Icons.filter_list),
            onSelected: (filter) {
              setState(() {
                _currentFilter = filter;
                _applyFilter();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: TaskFilter.all,
                child: Row(
                  children: [
                    Icon(Icons.list, size: 20),
                    SizedBox(width: 8),
                    Text('Semua'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: TaskFilter.completed,
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 20, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Selesai'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: TaskFilter.pending,
                child: Row(
                  children: [
                    Icon(Icons.pending, size: 20, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Belum Selesai'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Semua',
                    isSelected: _currentFilter == TaskFilter.all,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _currentFilter = TaskFilter.all;
                        _applyFilter();
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Selesai',
                    isSelected: _currentFilter == TaskFilter.completed,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _currentFilter = TaskFilter.completed;
                        _applyFilter();
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Belum Selesai',
                    isSelected: _currentFilter == TaskFilter.pending,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _currentFilter = TaskFilter.pending;
                        _applyFilter();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          // Task List
          Expanded(
            child: _isLoading
                ? ListView(
                    padding: const EdgeInsets.all(16),
                    children: List.generate(
                      5,
                      (_) => const TaskCardSkeleton(),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadTasks,
                    color: const Color(0xFF2196F3),
                    child: _filteredTasks.isEmpty
                        ? EmptyState(
                            icon: Icons.assignment_outlined,
                            title: _currentFilter == TaskFilter.all
                                ? 'Belum ada tugas'
                                : _currentFilter == TaskFilter.completed
                                    ? 'Belum ada tugas selesai'
                                    : 'Belum ada tugas pending',
                            message: _currentFilter == TaskFilter.all
                                ? 'Tambahkan tugas baru untuk memulai mengelola tugas harian Anda'
                                : 'Tidak ada tugas dengan status ini',
                            actionLabel: _currentFilter == TaskFilter.all
                                ? 'Tambah Tugas'
                                : null,
                            onAction: _currentFilter == TaskFilter.all
                                ? () async {
                                    HapticFeedback.lightImpact();
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const AddEditTaskPage(),
                                      ),
                                    );
                                    if (mounted) {
                                      _loadTasks();
                                    }
                                  }
                                : null,
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredTasks.length,
                            itemBuilder: (context, index) {
                              final task = _filteredTasks[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  onTap: () async {
                                    HapticFeedback.lightImpact();
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => TaskDetailPage(
                                          taskId: task.id,
                                        ),
                                      ),
                                    );
                                    if (mounted) {
                                      _loadTasks();
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: _getCategoryColor(task.categoryName)
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            _getCategoryIcon(task.categoryName),
                                            color: _getCategoryColor(task.categoryName),
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                task.title,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  decoration: task.isCompleted
                                                      ? TextDecoration.lineThrough
                                                      : null,
                                                  color: task.isCompleted
                                                      ? Colors.grey
                                                      : null,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: _getCategoryColor(
                                                              task.categoryName)
                                                          .withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      task.categoryName,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: _getCategoryColor(
                                                            task.categoryName),
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  if (task.deadline != null) ...[
                                                    const SizedBox(width: 8),
                                                    Icon(
                                                      Icons.calendar_today,
                                                      size: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      _formatDate(task.deadline!),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: _isDeadlinePassed(task.deadline!)
                                                            ? Colors.red
                                                            : Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (task.isCompleted)
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 28,
                                          )
                                        else
                                          Icon(
                                            Icons.radio_button_unchecked,
                                            color: Colors.grey[400],
                                            size: 28,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          HapticFeedback.mediumImpact();
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddEditTaskPage(),
            ),
          );
          if (mounted) {
            _loadTasks();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Tugas'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Color _getCategoryColor(String categoryName) {
    final colors = {
      'Work': Colors.red,
      'Personal': Colors.blue,
      'Shopping': Colors.green,
      'Health': Colors.purple,
      'Education': Colors.orange,
    };
    return colors[categoryName] ?? Colors.grey;
  }

  IconData _getCategoryIcon(String categoryName) {
    final icons = {
      'Work': Icons.work,
      'Personal': Icons.person,
      'Shopping': Icons.shopping_cart,
      'Health': Icons.favorite,
      'Education': Icons.school,
    };
    return icons[categoryName] ?? Icons.category;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Hari ini ${DateFormat('HH:mm').format(date)}';
    } else if (taskDate == today.add(const Duration(days: 1))) {
      return 'Besok ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }
  }

  bool _isDeadlinePassed(DateTime deadline) {
    return deadline.isBefore(DateTime.now()) &&
        !deadline.isAtSameMomentAs(DateTime.now());
  }
}

enum TaskFilter { all, completed, pending }

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.blue,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
