import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';
import '../services/task_service.dart';
import '../models/task.dart';
import '../widgets/custom_snackbar.dart';
import 'add_edit_task_page.dart';

class TaskDetailPage extends StatefulWidget {
  final String taskId;

  const TaskDetailPage({super.key, required this.taskId});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final TaskService _taskService = TaskService();
  Task? _task;
  bool _isLoading = true;
  bool _isDeleting = false;
  bool _isToggling = false;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  Future<void> _loadTask() async {
    final user = SupabaseService.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final task = await _taskService.getTaskById(widget.taskId, user.id);
      setState(() {
        _task = task;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleStatus() async {
    final user = SupabaseService.currentUser;
    if (user == null || _task == null) return;

    setState(() {
      _isToggling = true;
    });

    try {
      await _taskService.toggleTaskStatus(widget.taskId, user.id);
      HapticFeedback.mediumImpact();
      CustomSnackBar.showSuccess(
        context,
        _task!.isCompleted ? 'Tugas ditandai belum selesai' : 'Tugas ditandai selesai',
      );
      await _loadTask();
    } catch (e) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      CustomSnackBar.showError(context, 'Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isToggling = false;
        });
      }
    }
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Hapus Tugas'),
        content: const Text('Apakah Anda yakin ingin menghapus tugas ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final user = SupabaseService.currentUser;
    if (user == null) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await _taskService.deleteTask(widget.taskId, user.id);
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      CustomSnackBar.showSuccess(context, 'Tugas berhasil dihapus');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      CustomSnackBar.showError(context, 'Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Tugas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          if (_task != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                HapticFeedback.selectionClick();
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddEditTaskPage(taskId: widget.taskId),
                  ),
                );
                if (mounted) {
                  _loadTask();
                }
              },
              tooltip: 'Edit',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _task == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Tugas tidak ditemukan',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _task!.isCompleted
                                  ? Colors.green.shade50
                                  : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _task!.isCompleted
                                    ? Colors.green
                                    : Colors.orange,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _task!.isCompleted
                                      ? Icons.check_circle
                                      : Icons.pending,
                                  size: 16,
                                  color: _task!.isCompleted
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _task!.isCompleted ? 'Selesai' : 'Belum Selesai',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _task!.isCompleted
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Title
                      Text(
                        _task!.title,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          decoration: _task!.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: _task!.isCompleted ? Colors.grey : null,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Category Card
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(_task!.categoryName)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getCategoryIcon(_task!.categoryName),
                                  color: _getCategoryColor(_task!.categoryName),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Kategori',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _task!.categoryName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: _getCategoryColor(_task!.categoryName),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Description Card
                      if (_task!.description.isNotEmpty) ...[
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.description,
                                        size: 20, color: Colors.grey[600]),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Deskripsi',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _task!.description,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Deadline Card
                      if (_task!.deadline != null) ...[
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: _isDeadlinePassed(_task!.deadline!)
                                      ? Colors.red
                                      : Colors.blue,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Deadline',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('dd MMMM yyyy, HH:mm')
                                            .format(_task!.deadline!),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: _isDeadlinePassed(_task!.deadline!)
                                              ? Colors.red
                                              : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Info Cards
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.access_time,
                                            size: 16, color: Colors.grey[600]),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Dibuat',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('dd/MM/yyyy').format(_task!.createdAt),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.update,
                                            size: 16, color: Colors.grey[600]),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Diupdate',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('dd/MM/yyyy').format(_task!.updatedAt),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Action Buttons
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isToggling ? null : _toggleStatus,
                          icon: _isToggling
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Icon(
                                  _task!.isCompleted ? Icons.undo : Icons.check_circle,
                                ),
                          label: Text(
                            _task!.isCompleted
                                ? 'Tandai Belum Selesai'
                                : 'Tandai Selesai',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _task!.isCompleted ? Colors.orange : Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: _isDeleting ? null : _deleteTask,
                          icon: _isDeleting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.red),
                                  ),
                                )
                              : const Icon(Icons.delete),
                          label: const Text(
                            'Hapus Tugas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
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

  bool _isDeadlinePassed(DateTime deadline) {
    return deadline.isBefore(DateTime.now()) &&
        !deadline.isAtSameMomentAs(DateTime.now());
  }
}
