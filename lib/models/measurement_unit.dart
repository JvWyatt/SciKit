enum MassUnit {
  mg,
  g;

  String get label => switch (this) {
        MassUnit.mg => 'mg',
        MassUnit.g => 'g',
      };

  static MassUnit fromLabel(String label) =>
      MassUnit.values.firstWhere((u) => u.label == label,
          orElse: () => MassUnit.g);
}

enum VolumeUnit {
  ml,
  l;

  String get label => switch (this) {
        VolumeUnit.ml => 'mL',
        VolumeUnit.l => 'L',
      };

  static VolumeUnit fromLabel(String label) =>
      VolumeUnit.values.firstWhere((u) => u.label == label,
          orElse: () => VolumeUnit.ml);
}

class ComponentUnit {
  const ComponentUnit._(this.mass, this.volume);

  final MassUnit? mass;
  final VolumeUnit? volume;

  bool get isMass => mass != null;
  bool get isVolume => volume != null;

  String get label => mass?.label ?? volume!.label;

  static const mg = ComponentUnit._(MassUnit.mg, null);
  static const g = ComponentUnit._(MassUnit.g, null);
  static const ml = ComponentUnit._(null, VolumeUnit.ml);
  static const l = ComponentUnit._(null, VolumeUnit.l);

  static const values = [mg, g, ml, l];

  static ComponentUnit fromLabel(String label) =>
      values.firstWhere((u) => u.label == label,
          orElse: () => ComponentUnit.g);

  @override
  bool operator ==(Object other) =>
      other is ComponentUnit &&
      other.mass == mass &&
      other.volume == volume;

  @override
  int get hashCode => Object.hash(mass, volume);
}
