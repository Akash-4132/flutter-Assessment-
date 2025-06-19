import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class NoteDatabaseService {
  NoteDatabaseService._privateConstructor();
  static final NoteDatabaseService instance = NoteDatabaseService._privateConstructor();

  Database? _database;

  // Return database instance or initialize if null
  Future<Database> getDatabaseInstance() async {
    if (_database != null) return _database!;
    _database = await initializeDatabase();
    return _database!;
  }

  // Initialize and create database if it doesn't exist
  Future<Database> initializeDatabase() async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String databasePath = join(appDirectory.path, 'notes_database.db');

    return openDatabase(
      databasePath,
      version: 1,
      onCreate: _createDbSchema,
    );
  }

  // Database table creation logic
  Future<void> _createDbSchema(Database db, int version) async {
    await db.execute(
      '''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT
      )
      '''
    );
  }

  // Insert a new note
  Future<bool> insertNote({
    required String title,
    required String description,
  }) async {
    final db = await getDatabaseInstance();
    final insertResult = await db.insert("notes", {
      "title": title,
      "description": description,
    });

    return insertResult > 0;
  }

  // Retrieve all notes
  Future<List<Map<String, dynamic>>> fetchAllNotes() async {
    final db = await getDatabaseInstance();
    return await db.query("notes");
  }

  // Update a note
  Future<bool> modifyNote({
    required int id,
    required String title,
    required String description,
  }) async {
    final db = await getDatabaseInstance();
    final updateResult = await db.update(
      "notes",
      {
        "title": title,
        "description": description,
      },
      where: "id = ?",
      whereArgs: [id],
    );

    return updateResult > 0;
  }

  // Delete a note
  Future<bool> removeNote({required int id}) async {
    final db = await getDatabaseInstance();
    final deleteResult = await db.delete(
      "notes",
      where: "id = ?",
      whereArgs: [id],
    );

    return deleteResult > 0;
  }
}
