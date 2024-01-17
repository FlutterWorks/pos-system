import 'package:sqflite/sqflite.dart';

/// 進貨訂單，包含進貨單邊號、廠商編號、進貨日期、進貨總金額、備註

class RestockOrder {
  final int? id;
  final int vendorId;
  final DateTime date;
  final double total;
  final String? note;

  RestockOrder({
    this.id,
    required this.vendorId,
    required this.date,
    required this.total,
    this.note,
  });

  factory RestockOrder.fromJson(Map<String, dynamic> json) {
    return RestockOrder(
      id: json['id'],
      vendorId: json['vendorId'],
      date: DateTime.parse(json['date']),
      total: json['total'],
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'vendorId': vendorId,
      'date': date.toIso8601String(),
      'total': total,
      if (note != null) 'note': note,
    };
  }
}

class RestockOrderProvider {
  // ignore: avoid_init_to_null
  late Database? db = null;
  String tableName = 'restock_order';
  String dbName = 'pos.db';
  Future open() async {
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + dbName;
    db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          create table $tableName ( 
            id integer primary key autoincrement, 
            vendorId integer not null,
            date text not null,
            total real not null,
            note text
          )
          ''');
      },
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
    );
    await db!.execute('''
          create table if not exists $tableName ( 
            id integer primary key autoincrement, 
            vendorId integer not null,
            date text not null,
            total real not null,
            note text
          )
          ''');
  }

  Future<int> insert(RestockOrder restockOrder) async {
    await open();
    int result = await db!.insert(tableName, restockOrder.toJson());
    return result;
  }

  Future<RestockOrder?> getItem(int id) async {
    await open();
    List<Map<String, dynamic>> maps = await db!.query(tableName, where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isNotEmpty) {
      return RestockOrder.fromJson(maps.first);
    }
    return null;
  }

  Future<List<RestockOrder>> getAll() async {
    await open();
    List<Map<String, dynamic>> maps = await db!.query(tableName);
    List<RestockOrder> result = [];
    for (var map in maps) {
      result.add(RestockOrder.fromJson(map));
    }
    return result;
  }

  Future<int> update(RestockOrder restockOrder) async {
    await open();
    int result = await db!.update(tableName, restockOrder.toJson(), where: 'id = ?', whereArgs: [restockOrder.id]);
    return result;
  }

  Future<int> delete(int id) async {
    await open();
    int result = await db!.delete(tableName, where: 'id = ?', whereArgs: [id]);
    return result;
  }
}
