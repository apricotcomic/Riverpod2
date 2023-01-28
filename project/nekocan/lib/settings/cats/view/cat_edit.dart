import 'package:flutter/material.dart';
import 'package:nekocan/model/cats.dart';
import 'package:nekocan/common/cats_helper.dart';

class CatEdit extends StatefulWidget {
  final int id;

  const CatEdit({Key? key, required this.id}) : super(key: key);

  @override
  _CatEditState createState() => _CatEditState();
}

class _CatEditState extends State<CatEdit> {
  String name = ' ';
  String birthday = ' ';
  String gender = '不明';
  String memo = ' ';
  DateTime createdAt = DateTime.now();
  final List<String> _list = <String>['男の子', '女の子', '不明']; // 性別のDropdownの項目を設定
  String _selected = '不明'; // Dropdownの選択値を格納するエリア
  String value = '不明'; // Dropdownの初期値
  static const int textExpandedFlex = 1; // 見出しのexpaded flexの比率
  static const int dataExpandedFlex = 4; // 項目のexpanede flexの比率

  late Cats? cats;
  bool isLoading = false;
  bool isFormValid = false;

// Stateのサブクラスを作成し、initStateをオーバーライドすると、wedgit作成時に処理を動かすことができる。
// ここでは、各項目の初期値を設定する
  @override
  void initState() {
    super.initState();

    if (widget.id != 0) {
      catData();
    }
  }

// initStateで動かす処理
// catsテーブルから指定されたidのデータを1件取得する
  Future catData() async {
    setState(() => isLoading = true);
    cats = await CatsHelper.instance.catData(widget.id);
    name = cats!.name;
    birthday = cats!.birthday;
    gender = cats!.gender;
    _selected = cats!.gender;
    memo = cats!.memo;
    createdAt = cats!.createdAt;
    setState(() => isLoading = false);
  }

// Dropdownの値の変更を行う
  void _onChanged(String? value) {
    setState(() {
      _selected = value!;
      gender = _selected;
      isFormValid = true;
    });
  }

// 詳細編集画面を表示する
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('猫編集'),
        actions: [
          buildSaveButton(),
          IconButton(
            onPressed: () async {
              // ゴミ箱のアイコンが押されたときの処理を設定
              await CatsHelper.instance.delete(widget.id); // 指定されたidのデータを削除する
              Navigator.of(context).pop(); // 削除後に前の画面に戻る
            },
            icon: const Icon(Icons.delete), // ゴミ箱マークのアイコンを表示
          ) // 保存ボタンを表示する
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(), // 「グルグル」の処理
            )
          : SingleChildScrollView(
              child: Column(children: <Widget>[
                Row(children: [
                  // 名前の行の設定
                  const Expanded(
                    // 見出し（名前）
                    flex: textExpandedFlex,
                    child: Text(
                      '名前',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    // 名前入力エリアの設定
                    flex: dataExpandedFlex,
                    child: TextFormField(
                      maxLines: 1,
                      initialValue: name,
                      decoration: const InputDecoration(
                        //labelText: '名前',
                        hintText: '名前を入力してください',
                      ),
                      validator: (name) => name != null && name.isEmpty
                          ? '名前は必ず入れてね'
                          : null, // validateを設定
                      onChanged: (name) => setState(() {
                        this.name = name;
                        isFormValid = true;
                      }),
                    ),
                  ),
                ]),
                // 性別の行の設定
                Row(children: [
                  const Expanded(
                    // 見出し（性別）
                    flex: textExpandedFlex,
                    child: Text(
                      '性別',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    // 性別をドロップダウンで設定
                    flex: dataExpandedFlex,
                    child: DropdownButton(
                      key: const ValueKey('gender'),
                      items:
                          _list.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      value: _selected,
                      onChanged: _onChanged,
                    ),
                  ),
                ]),
                Row(children: [
                  const Expanded(
                    // 見出し（誕生日）
                    flex: textExpandedFlex,
                    child: Text(
                      '誕生日',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    // 誕生日入力エリアの設定
                    flex: dataExpandedFlex,
                    child: TextFormField(
                      maxLines: 1,
                      initialValue: birthday,
                      decoration: const InputDecoration(
                        hintText: '誕生日を入力してください',
                      ),
                      onChanged: (birthday) => setState(() {
                        this.birthday = birthday;
                        isFormValid = true;
                      }),
                    ),
                  ),
                ]),
                Row(children: [
                  const Expanded(
                      // 見出し（メモ）
                      flex: textExpandedFlex,
                      child: Text(
                        'メモ',
                        textAlign: TextAlign.center,
                      )),
                  Expanded(
                    // メモ入力エリアの設定
                    flex: dataExpandedFlex,
                    child: TextFormField(
                      maxLines: 1,
                      initialValue: memo,
                      decoration: const InputDecoration(
                        hintText: 'メモを入力してください',
                      ),
                      onChanged: (memo) => setState(() {
                        this.memo = memo;
                        isFormValid = true;
                      }),
                    ),
                  ),
                ]),
              ]),
            ),
    );
  }

// 保存ボタンの設定
  Widget buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ElevatedButton(
        child: const Text('保存'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor:
              isFormValid ? Colors.redAccent : Colors.grey.shade700,
        ),
        onPressed: createOrUpdateCat, // 保存ボタンを押したら実行する処理を指定する
      ),
    );
  }

// 保存ボタンを押したとき実行する処理
  void createOrUpdateCat() async {
    if (widget.id == 0) {
      await createCat(); // insertの処理
    } else {
      await updateCat(); // updateの処理
    }

    Navigator.of(context).pop(); // 前の画面に戻る
  }

  // 更新処理の呼び出し
  Future updateCat() async {
    final cat = cats?.copy(
      // 画面の内容をcatにセット
      name: name,
      birthday: birthday,
      gender: gender,
      memo: memo,
    );

    await CatsHelper.instance.update(cat!); // catの内容で更新する
  }

  // 追加処理の呼び出し
  Future createCat() async {
    final cat = Cats(
      // 入力された内容をcatにセット
      id: widget.id,
      name: name,
      birthday: birthday,
      gender: gender,
      memo: memo,
      createdAt: createdAt,
    );
    await CatsHelper.instance.insert(cat); // catの内容で追加する
  }
}
