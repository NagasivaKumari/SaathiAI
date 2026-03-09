class Skill {
  final String id;
  final String name;
  final String description;
  final String category;
  final String level;
  final String url;

  Skill({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.level,
    required this.url,
  });

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    category: json['category'] as String,
    level: json['level'] as String,
    url: json['url'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
    'level': level,
    'url': url,
  };
}
