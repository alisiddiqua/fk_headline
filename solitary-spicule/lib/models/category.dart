class WPCategory {
  final int id;
  final String name;
  final int count;

  WPCategory({
    required this.id,
    required this.name,
    required this.count,
  });

  factory WPCategory.fromJson(Map<String, dynamic> json) {
    return WPCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}
