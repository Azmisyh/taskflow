import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/task_service.dart';
import '../models/task.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = SupabaseService.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final tasks = await _taskService.getTasks(user.id);
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  int get _totalTasks => _tasks.length;
  int get _completedTasks => _tasks.where((t) => t.isCompleted).length;
  int get _pendingTasks => _tasks.where((t) => !t.isCompleted).length;
  double get _completionRate => _totalTasks > 0 ? _completedTasks / _totalTasks : 0.0;

  // Get tasks by category
  Map<String, int> get _tasksByCategory {
    final map = <String, int>{};
    for (var task in _tasks) {
      map[task.categoryName] = (map[task.categoryName] ?? 0) + 1;
    }
    return map;
  }

  // Get tasks by completion status this week
  int get _completedThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return _tasks.where((task) {
      if (!task.isCompleted) return false;
      return task.updatedAt.isAfter(weekStart);
    }).length;
  }

  // Get overdue count
  int get _overdueCount {
    final now = DateTime.now();
    return _tasks.where((task) {
      if (task.deadline == null || task.isCompleted) return false;
      return task.deadline!.isBefore(now);
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistik',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFF2196F3),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overall Stats
                    _StatCard(
                      title: 'Total Tugas',
                      value: _totalTasks.toString(),
                      icon: Icons.assignment,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Selesai',
                            value: _completedTasks.toString(),
                            icon: Icons.check_circle,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _StatCard(
                            title: 'Pending',
                            value: _pendingTasks.toString(),
                            icon: Icons.pending_actions,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Completion Rate
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tingkat Penyelesaian',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${(_completionRate * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2196F3),
                                  ),
                                ),
                                Icon(
                                  _completionRate >= 0.8
                                      ? Icons.emoji_events
                                      : _completionRate >= 0.5
                                          ? Icons.thumb_up
                                          : Icons.trending_up,
                                  size: 40,
                                  color: _completionRate >= 0.8
                                      ? Colors.amber
                                      : _completionRate >= 0.5
                                          ? Colors.green
                                          : Colors.blue,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: _completionRate,
                                minHeight: 12,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF2196F3),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Weekly Stats
                    const Text(
                      'Statistik Minggu Ini',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _WeeklyStat(
                              icon: Icons.check_circle,
                              label: 'Selesai',
                              value: _completedThisWeek.toString(),
                              color: Colors.green,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey.shade300,
                            ),
                            _WeeklyStat(
                              icon: Icons.warning,
                              label: 'Terlambat',
                              value: _overdueCount.toString(),
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Tasks by Category
                    if (_tasksByCategory.isNotEmpty) ...[
                      const Text(
                        'Tugas per Kategori',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._tasksByCategory.entries.map((entry) {
                        final percentage = _totalTasks > 0
                            ? (entry.value / _totalTasks)
                            : 0.0;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          _getCategoryIcon(entry.key),
                                          color: _getCategoryColor(entry.key),
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          entry.key,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${entry.value} tugas',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: percentage,
                                    minHeight: 6,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _getCategoryColor(entry.key),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${(percentage * 100).toStringAsFixed(1)}% dari total',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
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
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _WeeklyStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
