class TagModel {
  final int id;
  final String name;
  final bool isAdminCreated;
  final int? userId;

  TagModel({
    required this.id,
    required this.name,
    required this.isAdminCreated,
    this.userId,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'],
      name: json['name'],
      isAdminCreated: json['is_admin_created'] == 1 || json['is_admin_created'] == true,
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_admin_created': isAdminCreated,
      'user_id': userId,
    };
  }
}