import 'package:flutter/foundation.dart';

import '../../../models/component.dart';
import '../../../models/measurement_unit.dart';
import '../../../models/medium.dart';
import '../data/media_library_repository.dart';

class MediaLibraryState extends ChangeNotifier {
  MediaLibraryState() {
    _load();
  }

  final MediaLibraryRepository _repository = MediaLibraryRepository.instance;

  List<Medium> _media = [];
  bool _isLoaded = false;

  List<Medium> get media => List.unmodifiable(_media);
  bool get isLoaded => _isLoaded;

  Future<void> _load() async {
    try {
      final rows = await _repository.getMedia();
      final result = <Medium>[];
      for (final row in rows) {
        final id = row['id'] as int;
        final componentsRows = await _repository.getComponents(id);
        result.add(Medium(
          id: id,
          name: row['name'] as String,
          baseVolume: (row['base_volume'] as num).toDouble(),
          baseVolumeUnit:
              VolumeUnit.fromLabel(row['base_volume_unit'] as String),
          components: componentsRows
              .map((c) => Component(
                    name: c['name'] as String,
                    amount: (c['amount'] as num).toDouble(),
                    unit: ComponentUnit.fromLabel(c['unit'] as String),
                  ))
              .toList(),
        ));
      }
      _media = result;
      _isLoaded = true;
    } catch (_) {
      _isLoaded = true;
    } finally {
      notifyListeners();
    }
  }

  Medium? byId(int id) {
    for (final m in _media) {
      if (m.id == id) {
        return m;
      }
    }
    return null;
  }

  Future<void> createMedium({
    required String name,
    required double baseVolume,
    required VolumeUnit baseVolumeUnit,
    required List<Component> components,
  }) async {
    final id = await _repository.insertMedia(
      name: name,
      baseVolume: baseVolume,
      baseVolumeUnit: baseVolumeUnit.label,
      components: components.map((c) => c.toJson()).toList(),
    );
    _media.add(Medium(
      id: id,
      name: name,
      baseVolume: baseVolume,
      baseVolumeUnit: baseVolumeUnit,
      components: List.of(components),
    ));
    _sort();
    notifyListeners();
  }

  Future<void> updateMedium(
    int id, {
    required String name,
    required double baseVolume,
    required VolumeUnit baseVolumeUnit,
    required List<Component> components,
  }) async {
    await _repository.updateMedia(
      id: id,
      name: name,
      baseVolume: baseVolume,
      baseVolumeUnit: baseVolumeUnit.label,
      components: components.map((c) => c.toJson()).toList(),
    );
    final index = _media.indexWhere((m) => m.id == id);
    if (index >= 0) {
      _media[index] = Medium(
        id: id,
        name: name,
        baseVolume: baseVolume,
        baseVolumeUnit: baseVolumeUnit,
        components: List.of(components),
      );
    }
    _sort();
    notifyListeners();
  }

  Future<void> deleteMedium(int id) async {
    await _repository.deleteMedia(id);
    _media.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  void _sort() {
    _media.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }
}
