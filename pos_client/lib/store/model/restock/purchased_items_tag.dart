import 'package:sqflite/sqflite.dart';

/// 進貨品項標籤，包含標籤編號、標籤名稱、標籤顏色

class PurchasedItemsTag {
  final int? id;
  final String name;
  final String color;

  PurchasedItemsTag({
    this.id,
    required this.name,
    required this.color,
  });

  factory PurchasedItemsTag.fromJson(Map<String, dynamic> json) {
    return PurchasedItemsTag(
      id: json['id'],
      name: json['name'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'color': color,
    };
  }
}

class PurchasedItemsTagProvider {
  // ignore: avoid_init_to_null
  late Database? db = null;
  String tableName = 'purchased_items_tag';
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
            name text not null,
            color text
          )
          ''');
      },
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
    );
    await db!.execute('''
          create table if not exists $tableName ( 
            id integer primary key autoincrement, 
            name text not null,
            color text
          )
          ''');
    return db;
  }

  Future<int> insert(PurchasedItemsTag item) async {
    db ??= await open();
    int id = await db!.insert(tableName, item.toMap());
    return id;
  }

  Future<PurchasedItemsTag> getItem(int id) async {
    db ??= await open();
    List<Map<String, dynamic>> maps = await db!.query(tableName, where: 'id = ?', whereArgs: [id]);
    return PurchasedItemsTag.fromJson(maps.first);
  }

  Future<PurchasedItemsTag?> getItemByName(String name) async {
    db ??= await open();
    List<Map<String, dynamic>> maps = await db!.query(tableName, where: 'name = ?', whereArgs: [name]);
    if (maps.isEmpty) {
      return null;
    }
    return PurchasedItemsTag.fromJson(maps.first);
  }

  Future<List<PurchasedItemsTag>> getAll() async {
    db ??= await open();
    List<Map<String, dynamic>> maps = await db!.query(tableName);
    List<PurchasedItemsTag> items = [];
    for (var map in maps) {
      items.add(PurchasedItemsTag.fromJson(map));
    }
    return items;
  }

  Future update(PurchasedItemsTag item) async {
    db ??= await open();
    await db!.update(tableName, item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future delete(int id) async {
    db ??= await open();
    await db!.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
