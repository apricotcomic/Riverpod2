import 'package:flutter/material.dart';
import 'package:nekocan/model/cats.dart';
import 'package:nekocan/common/cats_helper.dart';

class CatEdit extends StatefulWidget {
  final int id;
  final String name;
  final String gender;
  final String birthday;
  final String memo;

  const CatEdit(
      {Key? key,
      required this.id,
      required this.name,
      required this.gender,
      required this.birthday,
      required this.memo})
      : super(key: key);

  @override
  _CatEditState createState() => _CatEditState();
}

class _CatEditState extends State<CatEdit> {
  String inputName = ' ';
  String inputGender = '不明';
  String inputBirthday = ' ';
  String inputMemo = ' ';
  DateTime createdAt = DateTime.now();
  final List<String> _list = <String>['男の子', '女の子', '不明']; // 性別のDropdownの項目を設定
  String _selected = '不明'; // Dropdownの選択値を格納するエリア
  String value = '不明'; // Dropdownの初期値
  static const int textExpandedFlex = 1; // 見出しのexpaded flexの比率
  static const int dataExpandedFlex = 4; // 項目のexpanede flexの比率

  Cats? cats;
  bool isLoading = false;
  bool isFormValid = false;

// Stateのサブクラスを作成し、initStateをオーバーライドすると、wedgit作成時に処理を動かすことができる。
// ここでは、各項目の初期値を設定する
  @override
  void initState() {
    super.initState();

    inputName = widget.name;
    inputGender = widget.gender;
    _selected = widget.gender;
    inputBirthday = widget.birthday;
    inputMemo = widget.memo;
  }

// Dropdownの値の変更を行う
  void _onChanged(String? value) {
    setState(() {
      _selected = value!;
      inputGender = _selected;
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
          buildSaveButton(), // 保存ボタンを表示する
          IconButton(
            onPressed: () async {
              // ゴミ箱のアイコンが押されたときの処理を設定
              await CatsHelper.instance.delete(widget.id); // 指定されたidのデータを削除する
              Navigator.of(context).pop(); // 削除後に前の画面に戻る
            },
            icon: const Icon(Icons.delete), // ゴミ箱マークのアイコンを表示
          )
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
                      initialValue: widget.name,
                      decoration: const InputDecoration(
                        //labelText: '名前',
                        hintText: '名前を入力してください',
                      ),
                      validator: (name) => name != null && name.isEmpty
                          ? '名前は必ず入れてね'
                          : null, // validateを設定
                      onChanged: (name) => setState(() {
                        inputName = name;
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
                      initialValue: widget.birthday,
                      decoration: const InputDecoration(
                        hintText: '誕生日を入力してください',
                      ),
                      onChanged: (birthday) => setState(() {
                        inputBirthday = birthday;
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
                      initialValue: widget.memo,
                      decoration: const InputDecoration(
                        hintText: 'メモを入力してください',
                      ),
                      onChanged: (memo) => setState(() {
                        inputMemo = memo;
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
    final cat = Cats(
      // 画面の内容をcatにセット
      id: widget.id,
      name: inputName,
      birthday: inputBirthday,
      gender: inputGender,
      memo: inputMemo,
      createdAt: createdAt,
    );
    if (widget.id == 0) {
      await CatsHelper.instance.insert(cat); // catの内容で追加する
    } else {
      await CatsHelper.instance.update(cat); // catの内容で更新する
    }
    Navigator.of(context).pop(); // 前の画面に戻る
  }
}
