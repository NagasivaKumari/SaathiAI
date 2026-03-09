class UserProfile {
  final String email;
  final String name;
  final String? phone;
  final String username;
  final int points;
  final int level;
  final String? badge;

  UserProfile({
    required this.email,
    required this.name,
    this.phone,
    required this.username,
    this.points = 0,
    this.level = 1,
    this.badge,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
      username: json['username'] ?? '',
      points: json['points'] ?? 0,
      level: json['level'] ?? 1,
      badge: json['badge'],
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'name': name,
    'phone': phone,
    'username': username,
    'points': points,
    'level': level,
    'badge': badge,
  };
}

class Scheme {
  final String id;
  final String title;
  final String description;
  final List<String> eligibility;
  final String benefits;

  Scheme({
    required this.id,
    required this.title,
    required this.description,
    required this.eligibility,
    required this.benefits,
  });

  factory Scheme.fromJson(Map<String, dynamic> json) {
    return Scheme(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      eligibility: List<String>.from(json['eligibility'] ?? []),
      benefits: json['benefits'] ?? '',
    );
  }
}

class Skill {
  final String id;
  final String title;
  final String duration;
  final String provider;
  final List<String> modules;

  Skill({
    required this.id,
    required this.title,
    required this.duration,
    required this.provider,
    required this.modules,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      duration: json['duration'] ?? '',
      provider: json['provider'] ?? '',
      modules: List<String>.from(json['modules'] ?? []),
    );
  }
}

class MarketPrice {
  final String crop;
  final String mandi;
  final double currentPrice;
  final double expectedPrice;
  final String trend;

  MarketPrice({
    required this.crop,
    required this.mandi,
    required this.currentPrice,
    required this.expectedPrice,
    required this.trend,
  });

  factory MarketPrice.fromJson(Map<String, dynamic> json) {
    return MarketPrice(
      crop: json['crop'] ?? '',
      mandi: json['mandi'] ?? '',
      currentPrice: (json['currentPrice'] ?? 0.0).toDouble(),
      expectedPrice: (json['expectedPrice'] ?? 0.0).toDouble(),
      trend: json['trend'] ?? 'stable',
    );
  }
}
