import 'package:sqflite/sqflite.dart';

/// Abre la base de datos local. Cada herramienta tendrá su propio espacio
/// de almacenamiento; SCIKIT reserva tablas únicamente para su núcleo.
Future<Database> _openDb() async {
  return openDatabase(
    'scikit.db',
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE media (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          base_volume REAL NOT NULL,
          base_volume_unit TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE components (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          media_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          amount REAL NOT NULL,
          unit TEXT NOT NULL,
          sort_order INTEGER NOT NULL,
          FOREIGN KEY (media_id) REFERENCES media (id) ON DELETE CASCADE
        )
      ''');
    },
    onConfigure: (db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    },
  );
}

class MediaLibraryRepository {
  MediaLibraryRepository._();

  static final MediaLibraryRepository instance = MediaLibraryRepository._();

  Database? _db;

  Future<Database> get _database async {
    _db ??= await _openDb();
    return _db!;
  }

  Future<List<Map<String, dynamic>>> getMedia() async {
    final db = await _database;
    return db.query('media', orderBy: 'name COLLATE NOCASE');
  }

  Future<List<Map<String, dynamic>>> getComponents(int mediaId) async {
    final db = await _database;
    return db.query('components',
        where: 'media_id = ?',
        whereArgs: [mediaId],
        orderBy: 'sort_order');
  }

  Future<int> insertMedia({
    required String name,
    required double baseVolume,
    required String baseVolumeUnit,
    required List<Map<String, dynamic>> components,
  }) async {
    final db = await _database;
    return db.transaction((txn) async {
      final id = await txn.insert('media', {
        'name': name,
        'base_volume': baseVolume,
        'base_volume_unit': baseVolumeUnit,
      });
      for (var i = 0; i < components.length; i++) {
        await _insertComponent(txn, id, components[i], i);
      }
      return id;
    });
  }

  Future<void> updateMedia({
    required int id,
    required String name,
    required double baseVolume,
    required String baseVolumeUnit,
    required List<Map<String, dynamic>> components,
  }) async {
    final db = await _database;
    await db.transaction((txn) async {
      await txn.update(
        'media',
        {
          'name': name,
          'base_volume': baseVolume,
          'base_volume_unit': baseVolumeUnit,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      await txn.delete('components', where: 'media_id = ?', whereArgs: [id]);
      for (var i = 0; i < components.length; i++) {
        await _insertComponent(txn, id, components[i], i);
      }
    });
  }

  Future<void> deleteMedia(int id) async {
    final db = await _database;
    await db.delete('media', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> _insertComponent(
    DatabaseExecutor txn,
    int mediaId,
    Map<String, dynamic> component,
    int index,
  ) async {
    await txn.insert('components', {
      'media_id': mediaId,
      'name': component['name'],
      'amount': component['amount'],
      'unit': component['unit'],
      'sort_order': index,
    });
  }
}
