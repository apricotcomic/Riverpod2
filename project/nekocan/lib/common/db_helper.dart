import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// テーブルへのアクセスをまとめたクラス
class DbHelper {
  // DbHelperをinstance化する
  static final DbHelper instance = DbHelper._createInstance();
  static Database? _database;

  DbHelper._createInstance();

  // databaseをオープンしてインスタンス化する
  Future<Database> get database async {
    return _database ??= await _initDB(); // 初回だったら_initDB()=DBオープンする
  }

  // データベースをオープンする
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'nekocan.db'); // nekocan.dbのパスを取得する

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate, // nekocan.dbがなかった時の処理を指定する（DBは勝手に作られる）
    );
  }

  // データベースがなかった時の処理
  Future _onCreate(Database database, int version) async {
    //catsテーブルをcreateする
    _catsCreate(database, version);
  }

  Future _catsCreate(Database database, int version) async {
    //catsテーブルをcreateする
    await database.execute('''
      CREATE TABLE cats(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        gender TEXT,
        birthday TEXT,
        memo TEXT,
        createdAt TEXT
      )
    ''');
  }
}
