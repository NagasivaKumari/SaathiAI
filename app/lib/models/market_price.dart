class MarketPrice {
  final String commodity;
  final String market;
  final double price;
  final String unit;
  final DateTime date;

  MarketPrice({
    required this.commodity,
    required this.market,
    required this.price,
    required this.unit,
    required this.date,
  });

  factory MarketPrice.fromJson(Map<String, dynamic> json) => MarketPrice(
    commodity: json['commodity'] as String,
    market: json['market'] as String,
    price: (json['price'] as num).toDouble(),
    unit: json['unit'] as String,
    date: DateTime.parse(json['date'] as String),
  );

  Map<String, dynamic> toJson() => {
    'commodity': commodity,
    'market': market,
    'price': price,
    'unit': unit,
    'date': date.toIso8601String(),
  };
}
