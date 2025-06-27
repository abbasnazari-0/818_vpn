class PlanModel {
  final int id;
  final String planName;
  final int day;
  final double discount_price;
  final double real_price;
  final double mass;

  PlanModel({
    required this.id,
    required this.planName,
    required this.day,
    required this.discount_price,
    required this.real_price,
    required this.mass,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] as int,
      planName: json['plan_name'] as String,
      day: json['day'] as int,
      discount_price: (json['discount_price'] as num).toDouble(),
      real_price: (json['real_price'] as num).toDouble(),
      mass: (json['mass'] as num).toDouble(),
    );
  }
}
