class Scheme {
  final String id;
  final String name;
  final String description;
  final String eligibility;
  final String benefits;
  final String department;
  final String url;

  Scheme({
    required this.id,
    required this.name,
    required this.description,
    required this.eligibility,
    required this.benefits,
    required this.department,
    required this.url,
  });

  factory Scheme.fromJson(Map<String, dynamic> json) => Scheme(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    eligibility: json['eligibility'] as String,
    benefits: json['benefits'] as String,
    department: json['department'] as String,
    url: json['url'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'eligibility': eligibility,
    'benefits': benefits,
    'department': department,
    'url': url,
  };
}
