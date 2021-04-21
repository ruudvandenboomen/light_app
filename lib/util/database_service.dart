import "dart:async";
import "package:light_app/objects/light.dart";
import "package:light_app/objects/preset.dart";
import "package:path/path.dart";
import "package:sqflite/sqflite.dart";

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  Database _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal() {
    initDatabase();
  }

  static Future _onConfigure(Database db) async {
    await db.execute("PRAGMA foreign_keys = ON");
  }

  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await initDatabase();
    return _database;
  }

  initDatabase() async {
    return await openDatabase(join(await getDatabasesPath(), "light_app.db"),
        // When the database is first created, create a table to store data.
        onCreate: (db, version) async {
      await db.execute(
        """
          CREATE TABLE presets(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT)
        """,
      );
      await db.execute(
        """
          CREATE TABLE lights(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            turnedOn INTEGER,
            brightness REAL,
            preset_id INTEGER,
            FOREIGN KEY(preset_id) REFERENCES presets(id) ON DELETE CASCADE
          );
        """,
      );
    },
        // Set the version. This executes the onCreate function and provides a
        // path to perform database upgrades and downgrades.
        version: 1,
        onConfigure: _onConfigure);
  }

  Future<int> insertPreset(Preset preset) async {
    Database db = await _instance.database;

    int id = await db.insert("presets", preset.toMap());
    for (var light in preset.lights) {
      await db.insert("lights", light.toMap(id));
    }
    return id;
  }

  Future<void> deletePreset(int id) async {
    Database db = await _instance.database;

    await db.delete(
      "presets",
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> updatePreset(Preset preset) async {
    Database db = await _instance.database;

    int id = await db.update("presets", preset.toMap(),
        where: "id = ?", whereArgs: [preset.id]);
    for (var light in preset.lights) {
      Map<String, dynamic> lightMap = light.toMap(id);
      lightMap.remove("preset_id");
      await db
          .update("lights", lightMap, where: "id = ?", whereArgs: [light.id]);
    }
  }

  Future<List<Preset>> getPresets() async {
    Database db = await _instance.database;

    final List<Map<String, dynamic>> presets = await db.query("presets");
    List<Preset> presetsResult = [];
    for (int i = 0; i < presets.length; i++) {
      List<Map<String, dynamic>> lights = await db.query("lights",
          where: "preset_id = ?", whereArgs: [presets[i]["id"]]);
      Preset preset = Preset.fromDB(
          presets[i]["id"],
          presets[i]["name"],
          lights
              .map((light) => Light.fromDB(light["id"], light["name"],
                  light["brightness"], light["turnedOn"] == 0 ? false : true))
              .toList());
      presetsResult.add(preset);
    }
    return presetsResult;
  }
}
