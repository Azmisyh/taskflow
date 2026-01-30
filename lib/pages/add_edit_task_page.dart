import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';
import '../services/task_service.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../widgets/custom_snackbar.dart';

class AddEditTaskPage extends StatefulWidget {
  final String? taskId;

  const AddEditTaskPage({super.key, this.taskId});

  @override
  State<AddEditTaskPage> createState() => _AddEditTaskPageState();
}

class _AddEditTaskPageState extends State<AddEditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final TaskService _taskService = TaskService();

  List<Category> _categories = [];
  Category? _selectedCategory;
  DateTime? _selectedDeadline;
  bool _isLoading = false;
  bool _isEditMode = false;
  Task? _existingTask;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.taskId != null;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _categories = await _taskService.getCategories();

      if (_isEditMode && widget.taskId != null) {
        final user = SupabaseService.currentUser;
        if (user != null) {
          _existingTask = await _taskService.getTaskById(
            widget.taskId!,
            user.id,
          );
          if (_existingTask != null) {
            _titleController.text = _existingTask!.title;
            _descriptionController.text = _existingTask!.description;
            _selectedCategory = _categories.firstWhere(
              (cat) => cat.id == _existingTask!.categoryId,
            );
            _selectedDeadline = _existingTask!.deadline;
          }
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _selectedDeadline ?? DateTime.now(),
        ),
      );

      if (time != null) {
        setState(() {
          _selectedDeadline = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      HapticFeedback.heavyImpact();
      CustomSnackBar.showError(context, 'Pilih kategori terlebih dahulu');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = SupabaseService.currentUser;
      if (user == null) return;

      if (_isEditMode && widget.taskId != null) {
        await _taskService.updateTask(
          taskId: widget.taskId!,
          userId: user.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          categoryId: _selectedCategory!.id,
          deadline: _selectedDeadline,
        );
      } else {
        await _taskService.createTask(
          userId: user.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          categoryId: _selectedCategory!.id,
          deadline: _selectedDeadline,
        );
      }

      if (!mounted) return;
      HapticFeedback.mediumImpact();
      CustomSnackBar.showSuccess(
        context,
        _isEditMode ? 'Tugas berhasil diupdate' : 'Tugas berhasil ditambahkan',
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      CustomSnackBar.showError(context, 'Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Tugas' : 'Tambah Tugas',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: _isLoading && !_isEditMode
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isEditMode ? Icons.edit : Icons.add_task,
                        size: 40,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title Field
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Judul Tugas',
                        hintText: 'Masukkan judul tugas',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: const TextStyle(fontSize: 16),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Judul tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Description Field
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi',
                        hintText: 'Masukkan deskripsi tugas (opsional)',
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      maxLines: 4,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    // Category Dropdown
                    DropdownButtonFormField<Category>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        prefixIcon: const Icon(Icons.category),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: _parseColor(category.color),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                category.name,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Pilih kategori';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Deadline Field
                    InkWell(
                      onTap: _selectDeadline,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.grey[600]),
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
                                    _selectedDeadline != null
                                        ? DateFormat(
                                            'dd MMMM yyyy, HH:mm',
                                          ).format(_selectedDeadline!)
                                        : 'Pilih deadline (opsional)',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _selectedDeadline != null
                                          ? Colors.black
                                          : Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_selectedDeadline != null)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _selectedDeadline = null;
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Save Button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveTask,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                _isEditMode ? 'Update Tugas' : 'Simpan Tugas',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }
}
