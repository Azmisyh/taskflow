import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';
import '../services/task_service.dart';
import '../models/task.dart';
import '../widgets/empty_state.dart';
import '../widgets/skeleton_loader.dart';
import 'task_list_page.dart';
import 'add_edit_task_page.dart';
import 'task_detail_page.dart';
import 'profile_page.dart';
import 'statistics_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    if (user == null) {
      return;
    }

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

  // Get today's tasks
  List<Task> get _todayTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _tasks.where((task) {
      if (task.deadline == null) return false;
      final taskDate = DateTime(
        task.deadline!.year,
        task.deadline!.month,
        task.deadline!.day,
      );
      return taskDate == today && !task.isCompleted;
    }).toList();
  }

  // Get overdue tasks
  List<Task> get _overdueTasks {
    final now = DateTime.now();
    return _tasks.where((task) {
      if (task.deadline == null || task.isCompleted) return false;
      return task.deadline!.isBefore(now);
    }).toList();
  }

  // Get upcoming tasks (next 3 days)
  List<Task> get _upcomingTasks {
    final now = DateTime.now();
    final threeDaysLater = now.add(const Duration(days: 3));
    return _tasks.where((task) {
      if (task.deadline == null || task.isCompleted) return false;
      return task.deadline!.isAfter(now) && task.deadline!.isBefore(threeDaysLater);
    }).take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TaskFlow',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StatisticsPage()),
              );
            },
            tooltip: 'Statistik',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TaskListPage()),
              ).then((_) => _loadData());
            },
            tooltip: 'Cari Tugas',
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () async {
              HapticFeedback.selectionClick();
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
              if (mounted) {
                _loadData();
              }
            },
            tooltip: 'Profile',
          ),
        ],
      ),
      body: _isLoading
          ? ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SkeletonLoader(width: 200, height: 32),
                const SizedBox(height: 8),
                const SkeletonLoader(width: 150, height: 16),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(child: SkeletonLoader(width: double.infinity, height: 120)),
                    const SizedBox(width: 16),
                    Expanded(child: SkeletonLoader(width: double.infinity, height: 120)),
                  ],
                ),
                const SizedBox(height: 16),
                const SkeletonLoader(width: double.infinity, height: 120),
                const SizedBox(height: 32),
                ...List.generate(3, (_) => const TaskCardSkeleton()),
              ],
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFF2196F3),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header dengan greeting
                    const Text(
                      'Selamat Datang! 👋',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kelola tugas harian Anda dengan mudah',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Progress Card dengan completion rate
                    _ProgressCard(
                      totalTasks: _totalTasks,
                      completedTasks: _completedTasks,
                      pendingTasks: _pendingTasks,
                      completionRate: _completionRate,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Statistik Cards
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Total',
                            value: _totalTasks.toString(),
                            icon: Icons.assignment,
                            color: Colors.blue,
                            gradient: [Colors.blue.shade400, Colors.blue.shade600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Selesai',
                            value: _completedTasks.toString(),
                            icon: Icons.check_circle,
                            color: Colors.green,
                            gradient: [Colors.green.shade400, Colors.green.shade600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Pending',
                            value: _pendingTasks.toString(),
                            icon: Icons.pending_actions,
                            color: Colors.orange,
                            gradient: [Colors.orange.shade400, Colors.orange.shade600],
                          ),
                        ),
                      ],
                    ),
                    
                    // Overdue Tasks Alert
                    if (_overdueTasks.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _AlertCard(
                        icon: Icons.warning_amber_rounded,
                        title: 'Tugas Terlambat',
                        message: 'Anda memiliki ${_overdueTasks.length} tugas yang sudah melewati deadline',
                        color: Colors.red,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const TaskListPage(),
                            ),
                          ).then((_) => _loadData());
                        },
                      ),
                    ],
                    
                    // Today's Tasks
                    if (_todayTasks.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _SectionHeader(
                        title: 'Tugas Hari Ini',
                        count: _todayTasks.length,
                        onSeeAll: () {
                          HapticFeedback.selectionClick();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const TaskListPage(),
                            ),
                          ).then((_) => _loadData());
                        },
                      ),
                      const SizedBox(height: 12),
                      ..._todayTasks.take(3).map((task) => _TaskCard(
                        task: task,
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TaskDetailPage(taskId: task.id),
                            ),
                          );
                          if (mounted) {
                            _loadData();
                          }
                        },
                      )),
                    ],
                    
                    // Upcoming Tasks
                    if (_upcomingTasks.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _SectionHeader(
                        title: 'Tugas Mendatang',
                        count: _upcomingTasks.length,
                        onSeeAll: () {
                          HapticFeedback.selectionClick();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const TaskListPage(),
                            ),
                          ).then((_) => _loadData());
                        },
                      ),
                      const SizedBox(height: 12),
                      ..._upcomingTasks.map((task) => _TaskCard(
                        task: task,
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TaskDetailPage(taskId: task.id),
                            ),
                          );
                          if (mounted) {
                            _loadData();
                          }
                        },
                      )),
                    ],
                    
                    // Recent Tasks (if no today/upcoming)
                    if (_todayTasks.isEmpty && _upcomingTasks.isEmpty && _tasks.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _SectionHeader(
                        title: 'Tugas Terbaru',
                        count: _tasks.length,
                        onSeeAll: () {
                          HapticFeedback.selectionClick();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const TaskListPage(),
                            ),
                          ).then((_) => _loadData());
                        },
                      ),
                      const SizedBox(height: 12),
                      ..._tasks.take(5).map((task) => _TaskCard(
                        task: task,
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TaskDetailPage(taskId: task.id),
                            ),
                          );
                          if (mounted) {
                            _loadData();
                          }
                        },
                      )),
                    ],
                    
                    // Empty State
                    if (_tasks.isEmpty) ...[
                      const SizedBox(height: 24),
                      EmptyState(
                        icon: Icons.task_alt,
                        title: 'Belum ada tugas',
                        message: 'Tambahkan tugas baru untuk memulai mengelola tugas harian Anda',
                        actionLabel: 'Tambah Tugas',
                        onAction: () async {
                          HapticFeedback.lightImpact();
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AddEditTaskPage(),
                            ),
                          );
                          if (mounted) {
                            _loadData();
                          }
                        },
                      ),
                    ],
                    
                    const SizedBox(height: 80), // Space for FAB
                  ],
                ),
              ),
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
            _loadData();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Tugas'),
        backgroundColor: const Color(0xFF2196F3),
      ),
    );
  }
}

// Progress Card Widget
class _ProgressCard extends StatelessWidget {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final double completionRate;

  const _ProgressCard({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.completionRate,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progress Hari Ini',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${(completionRate * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: completionRate,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ProgressStat(label: 'Selesai', value: completedTasks, color: Colors.green),
                _ProgressStat(label: 'Pending', value: pendingTasks, color: Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _ProgressStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: $value',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}

// Section Header Widget
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback onSeeAll;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text('Lihat Semua'),
        ),
      ],
    );
  }
}

// Alert Card Widget
class _AlertCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final VoidCallback onTap;

  const _AlertCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
    required this.onTap,
  });

  Color get _lightColor => Color.alphaBlend(
        color.withValues(alpha: 0.1),
        Colors.white,
      );
  
  Color get _borderColor => Color.alphaBlend(
        color.withValues(alpha: 0.3),
        Colors.white,
      );
  
  Color get _iconBgColor => Color.alphaBlend(
        color.withValues(alpha: 0.15),
        Colors.white,
      );
  
  Color get _textColor => Color.alphaBlend(
        color.withValues(alpha: 0.9),
        Colors.black,
      );
  
  Color get _subTextColor => Color.alphaBlend(
        color.withValues(alpha: 0.7),
        Colors.black,
      );

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: _lightColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: _subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

// Task Card Widget
class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const _TaskCard({
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.deadline != null &&
        task.deadline!.isBefore(DateTime.now()) &&
        !task.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOverdue ? Colors.red.shade200 : Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getCategoryColor(task.categoryName).withValues(alpha: 0.1),
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
                        color: task.isCompleted ? Colors.grey : null,
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
                            color: _getCategoryColor(task.categoryName)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            task.categoryName,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getCategoryColor(task.categoryName),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (task.deadline != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: isOverdue ? Colors.red : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(task.deadline!),
                            style: TextStyle(
                              fontSize: 12,
                              color: isOverdue ? Colors.red : Colors.grey.shade600,
                              fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (task.isCompleted)
                const Icon(Icons.check_circle, color: Colors.green, size: 24)
              else if (isOverdue)
                const Icon(Icons.warning, color: Colors.red, size: 24)
              else
                Icon(Icons.radio_button_unchecked, color: Colors.grey.shade400, size: 24),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Hari ini';
    } else if (taskDate == today.add(const Duration(days: 1))) {
      return 'Besok';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final List<Color> gradient;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
