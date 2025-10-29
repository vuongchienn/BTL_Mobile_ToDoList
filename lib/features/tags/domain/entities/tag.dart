class Tag {
  final int id;
  final String name;
  final bool isAdminCreated;
  final int? userId;

  Tag({
    required this.id,
    required this.name,
    required this.isAdminCreated,
    this.userId,
  });
}