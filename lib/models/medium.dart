import 'component.dart';
import 'measurement_unit.dart';

class Medium {
  Medium({
    required this.id,
    required this.name,
    required this.baseVolume,
    required this.baseVolumeUnit,
    required this.components,
  });

  int id;
  String name;
  double baseVolume;
  VolumeUnit baseVolumeUnit;
  List<Component> components;

  double get baseVolumeMl =>
      baseVolumeUnit == VolumeUnit.ml ? baseVolume : baseVolume * 1000;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'baseVolume': baseVolume,
        'baseVolumeUnit': baseVolumeUnit.label,
        'components': components.map((c) => c.toJson()).toList(),
      };

  factory Medium.fromJson(Map<String, dynamic> json) => Medium(
        id: json['id'] as int,
        name: json['name'] as String,
        baseVolume: (json['baseVolume'] as num).toDouble(),
        baseVolumeUnit: VolumeUnit.fromLabel(json['baseVolumeUnit'] as String),
        components: (json['components'] as List)
            .map((c) => Component.fromJson(c as Map<String, dynamic>))
            .toList(),
      );

  Medium copyWith({
    int? id,
    String? name,
    double? baseVolume,
    VolumeUnit? baseVolumeUnit,
    List<Component>? components,
  }) =>
      Medium(
        id: id ?? this.id,
        name: name ?? this.name,
        baseVolume: baseVolume ?? this.baseVolume,
        baseVolumeUnit: baseVolumeUnit ?? this.baseVolumeUnit,
        components: components ?? this.components,
      );
}
