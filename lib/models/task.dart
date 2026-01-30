class Task {
  final String id;
  final String title;
  final String description;
  final String categoryId;
  final String categoryName;
  final bool isCompleted;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.isCompleted,
    this.deadline,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      categoryId: json['category_id'] as String? ?? json['categoryId'] as String? ?? '',
      categoryName: json['category_name'] as String? ?? json['categoryName'] as String? ?? '',
      isCompleted: json['is_completed'] as bool? ?? json['isCompleted'] as bool? ?? false,
      deadline: json['deadline'] != null 
          ? DateTime.parse(json['deadline'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String? ?? json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String? ?? json['updatedAt'] as String),
      userId: json['user_id'] as String? ?? json['userId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category_id': categoryId,
      'category_name': categoryName,
      'is_completed': isCompleted,
      'deadline': deadline?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_id': userId,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    String? categoryName,
    bool? isCompleted,
    DateTime? deadline,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      isCompleted: isCompleted ?? this.isCompleted,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }
}
