import 'package:nekocan/model/cats.dart';
import 'package:nekocan/common/db_helper.dart';

// catsテーブルのカラム名を設定
const String columnId = 'id';
const String columnName = 'name';
const String columnGender = 'gender';
const String columnBirthday = 'birthday';
const String columnMemo = 'memo';
const String columnCreatedAt = 'createdAt';

// catsテーブルのカラム名をListに設定
const List<String> columns = [
  columnId,
  columnName,
  columnGender,
  columnBirthday,
  columnMemo,
  columnCreatedAt,
];

// catsテーブルへのアクセスをまとめたクラス
class CatsHelper {
  // DbHelperをinstance化する
  static final CatsHelper instance = CatsHelper._createInstance();

  CatsHelper._createInstance();

  // catsテーブルのデータを全件取得する
  Future<List<Cats>> selectAllCats() async {
    final db = await DbHelper.instance.database;
    final catsData = await db.query('cats');          // 条件指定しないでcatsテーブルを読み込む

    return catsData.map((json) => Cats.fromJson(json)).toList();    // 読み込んだテーブルデータをListにパースしてreturn
  }

// _idをキーにして1件のデータを読み込む
  Future<Cats> catData(int id) async {
    final db = await  DbHelper.instance.database;
    var cat = [];
    cat = await db.query(
      'cats',
      columns: columns,
      where: 'id = ?',                     // 渡されたidをキーにしてcatsテーブルを読み込む
      whereArgs: [id],
    );
      return Cats.fromJson(cat.first);      // 1件だけなので.toListは不要
  }

// データをinsertする
  Future insert(Cats cats) async {
    final db = await  DbHelper.instance.database;
    return await db.insert(
      'cats',
      cats.toJson()                         // cats.dartで定義しているtoJson()で渡されたcatsをパースして書き込む
      );
  }

// データをupdateする
  Future update(Cats cats) async {
    final db = await  DbHelper.instance.database;
    return await db.update(
      'cats',
      cats.toJson(),
      where: 'id = ?',                   // idで指定されたデータを更新する
      whereArgs: [cats.id],
    );
  }

// データを削除する
  Future delete(int id) async {
    final db = await  DbHelper.instance.database;
    return await db.delete(
      'cats',
      where: 'id = ?',                   // idで指定されたデータを削除する
      whereArgs: [id],
    );
  }
}
