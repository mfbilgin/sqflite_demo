

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_demo/models/product.dart';

class DbHelper{
  Database? _db;

  Future<Database> get db async{
    _db ??= await initializeDb();
    return _db!;
  }

  Future<Database> initializeDb() async{
    String dbPath = join(await getDatabasesPath(), "etrade.db");
    var eTradeDb =  await openDatabase(dbPath,version: 1,onCreate: createDatabase);
    return eTradeDb;
  }
  void createDatabase(Database db, int version) async{
    await db.execute("Create table products(id integer primary key, name text, brand text,description text, unitPrice real, imagePath text)");
  }

  Future<int> add(Product product) async{
    Database db = await this.db;
    var result = await db.insert("products", product.toMap());
    return result;
  }
  Future<int> update(Product product) async{
    Database db = await this.db;
    var result = await db.update("products", product.toMap(), where: "id=?", whereArgs: [product.id]);
    return result;
  }
  Future<int?> delete(int id) async{
    Database db = await this.db;
    var result = await db.delete("products", where: "id=?", whereArgs: [id]);
    return result;
  }
  Future<List<Product>> getAll() async{
    Database db = await this.db;
    var result = await db.query("products");
    return List.generate(result.length, (index) => Product.fromObject(result[index]));
  }
  Future<Product?> getById(int id) async{
    final Database db = await this.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (!maps.isNotEmpty) {
      return null;
    }

    return Product.fromObject(maps.first);
  }

}
