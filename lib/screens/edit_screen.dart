import 'package:flutter/material.dart';
import 'package:moor_ffi/database.dart';
import 'package:myownfrashcard/db/database.dart';
import 'package:myownfrashcard/main.dart';
import 'package:myownfrashcard/screens/word_list_screen.dart';
import 'package:toast/toast.dart';

enum EditStatus { ADD, EDIT }

class EditScreen extends StatefulWidget {
  final EditStatus status;
  final Word word;

  EditScreen({@required this.status, this.word});

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  TextEditingController questionController = TextEditingController();
  TextEditingController answerController = TextEditingController();

  String _titleText = '';

  bool _isQuestionEnabled = false;

  @override
  void initState() {
    super.initState();
    if (widget.status == EditStatus.ADD) {
      _isQuestionEnabled = true;
      _titleText = '新しい単語の追加';
      questionController.text = '';
      answerController.text = '';
    } else {
      _isQuestionEnabled = false;
      _titleText = '登録した単語の修正';
      questionController.text = widget.word.strQuestion;
      answerController.text = widget.word.strAnswer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _backToWordListScreen(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titleText),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.done),
              tooltip: '登録',
              onPressed: () => onWordRegisterd(),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 30.0,
              ),
              Center(
                child: Text(
                  '問題と答えを入力して「登録」ボタンを押してください',
                  style: TextStyle(fontSize: 12.0),
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              _questionInputPart(),
              SizedBox(
                height: 60.0,
              ),
              _answerInputPart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _questionInputPart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        children: <Widget>[
          Text(
            '問題',
            style: TextStyle(fontSize: 24.0),
          ),
          SizedBox(
            height: 30.0,
          ),
          TextField(
            enabled: _isQuestionEnabled,
            controller: questionController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          )
        ],
      ),
    );
  }

  Widget _answerInputPart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        children: <Widget>[
          Text(
            '答え',
            style: TextStyle(fontSize: 24.0),
          ),
          SizedBox(
            height: 30.0,
          ),
          TextField(
            controller: answerController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          )
        ],
      ),
    );
  }

  Future<bool> _backToWordListScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WordListScreen(),
      ),
    );
    return Future.value(false);
  }

  onWordRegisterd() {
    if (widget.status == EditStatus.ADD) {
      _insertWord();
    } else {
      _updateWord();
    }
  }

  _insertWord() async {
    if (questionController.text == '' || answerController.text == '') {
      Toast.show('問題と答えの両方を入力してください', context, duration: Toast.LENGTH_LONG);
      return;
    }

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('登録'),
              content: Text('登録しても良いですか？'),
              actions: <Widget>[
                FlatButton(
                  child: Text('はい'),
                  onPressed: () async {
                    var word = Word(
                      strQuestion: questionController.text,
                      strAnswer: answerController.text,
                      isMemorized: false,
                    );
                    try {
                      await database.addWord(word);
                      questionController.clear();
                      answerController.clear();
                      Toast.show('登録完了しました', context, duration: Toast.LENGTH_LONG);
                    } on SqliteException catch (e) {
                      Toast.show('この問題はすでに登録されているので登録できません。', context, duration: Toast.LENGTH_LONG);
                    } finally {
                      Navigator.pop(context);
                    }
                  },
                ),
                FlatButton(
                  child: Text('いいえ'),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ));

    return;
  }

  Future<void> _updateWord() async {
    if (questionController.text == '' || answerController.text == '') {
      Toast.show('問題と答えの両方を入力してください', context, duration: Toast.LENGTH_LONG);
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${questionController.text}の変更'),
        content: const Text('変更してもいいですか？'),
        actions: <Widget>[
          FlatButton(
            child: const Text('はい'),
            onPressed: () async {
              var word = Word(
                strQuestion: questionController.text,
                strAnswer: answerController.text,
                isMemorized: false,
              );

              try {
                await database.updateWord(word);
                Navigator.pop(context);
                _backToWordListScreen();
                Toast.show('修正が完了しました。', context, duration: Toast.LENGTH_LONG);
              } on SqliteException catch (e) {
                Toast.show('なんらかの問題が発生し登録できませんでした。:$e', context, duration: Toast.LENGTH_LONG);
                Navigator.pop(context);
              } finally {}
            },
          ),
          FlatButton(
            child: Text('いいえ'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }
}
