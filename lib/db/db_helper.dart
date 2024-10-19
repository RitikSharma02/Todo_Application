import 'package:sqflite/sqflite.dart';
import 'package:todo_list/Models/task.dart';

class DBHelper {
  static Database? _db;
  static final int _version = 1;
  static final String _tableName = 'tasks';

  // Initialize the database
  static Future<void> initDb() async {
    if (_db != null) {
      return;
    }
    try {
      String _path = await getDatabasesPath() +
          '/tasks.db'; // Fixed path separator
      _db = await openDatabase(
        _path,
        version: _version,
        onCreate: (db, version) {
          print("Creating a new database");
          return db.execute(
            "CREATE TABLE $_tableName ("
                "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                "title STRING, "
                "description TEXT, "
                "isCompleted INTEGER, "
                "date STRING, "
                "startTime STRING, "
                "endTime STRING, "
                "color INTEGER, "
                "remind INTEGER, "
                "repeat STRING"
                ")",
          );
        },
      );
    } catch (e) {
      print("Error initializing the database: $e");
    }
  }


  // Insert a task into the database
  static Future<int> insert(Task? task) async{
    return await _db?.insert(_tableName, task!.toJson())??1;
  }

  // static Future<int> insertTask(Map<String, dynamic> task) async {
  //   return await _db!.insert(_tableName, task);
  // }

  // Get all tasks from the database
  static Future<List<Map<String, dynamic>>> getTasks() async {
    return await _db!.query(_tableName);
  }

  // Update a task in the database
  // static Future<int> updateTask(int id, Map<String, dynamic> task) async {
  //   return await _db!.update(
  //     _tableName,
  //     task,
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  // }

//sql stream ''' this is

  static Future<int> update(int id) async {
    return await _db!.rawUpdate('''
    UPDATE tasks
    SET isCompleted = ?
    WHERE id = ?
  ''', [1, id]);
  }


// Fetch all tasks from the database
  static Future<List<Map<String, dynamic>>> query() async {
    return await _db?.query(_tableName) ?? [];
  }

// delete the task

static delete(Task task) async {
return await _db!.delete(_tableName, where: 'id = ?', whereArgs: [task.id]);
}



  static Future<int> updateTask(Task task) async {
    return await _db!.update(
      'tasks', // The name of your table
      {
        'title': task.title,
        'description': task.description,
        'date': task.date,
        'startTime': task.startTime,
        'endTime': task.endTime,
        'remind': task.remind,
        'repeat': task.repeat,
        'color': task.color,
        'isCompleted': task.isCompleted,
      },
      where: 'id = ?', // The condition for which row to update
      whereArgs: [task.id], // The value to match in the condition
    );
  }

}

