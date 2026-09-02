import 'measurement_unit.dart';

class Component {
  Component({
    required this.name,
    required this.amount,
    required this.unit,
  });

  String name;
  double amount;
  ComponentUnit unit;

  Map<String, dynamic> toJson() => {
        'name': name,
        'amount': amount,
        'unit': unit.label,
      };

  factory Component.fromJson(Map<String, dynamic> json) => Component(
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
        unit: ComponentUnit.fromLabel(json['unit'] as String),
      );
}
