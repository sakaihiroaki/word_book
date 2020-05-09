import 'package:flutter/material.dart';
import 'package:myownfrashcard/db/database.dart';
import 'package:myownfrashcard/main.dart';

enum TestStatus { BEFORE_START, SHOW_QUESTION, SHOW_ANSWER, FINISHED }

class TestScreen extends StatefulWidget {
  final bool isIncludedMemorizedWords;
  TestScreen({this.isIncludedMemorizedWords});

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int _numberOfQuestion = 0;
  String _textQuestion = '';
  String _textAnswer = '';
  bool _isMemorized = false;

  bool _isQuestionCardVisible = false;
  bool _isAnswerCardVisible = false;
  bool _isCheckBoxVisible = false;
  bool _isFabVisible = false;

  List<Word> _testDataList = List();
  TestStatus _testStatus;

  int _index = 0;
  Word _currentWord;

  @override
  void initState() {
    super.initState();
    _getTestData();
  }

  Future<void> _getTestData() async {
    if (widget.isIncludedMemorizedWords) {
      _testDataList = await database.allWords;
    } else {
      _testDataList = await database.allWordsExcludeMemorized;
    }
    _testDataList.shuffle();
    _testStatus = TestStatus.BEFORE_START;
    setState(() {
      _numberOfQuestion = _testDataList.length;
      _isQuestionCardVisible = false;
      _isAnswerCardVisible = false;
      _isCheckBoxVisible = false;
      _isFabVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    var isInclude = widget.isIncludedMemorizedWords;
    return WillPopScope(
      onWillPop: () => _finishiTestScreen(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('確認テスト'),
        ),
        floatingActionButton: _isFabVisible
            ? FloatingActionButton(
                onPressed: () => _goNextStatus(),
                child: Icon(Icons.navigate_next),
                tooltip: '次に進む',
              )
            : null,
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                const SizedBox(
                  height: 10.0,
                ),
                _numberOfQuestionPart(),
                const SizedBox(
                  height: 30.0,
                ),
                _questionCardPart(),
                const SizedBox(
                  height: 10.0,
                ),
                _answerCardPart(),
                const SizedBox(
                  height: 10.0,
                ),
                _isMemorizedCheckPart(),
              ],
            ),
            _endMessage(),
          ],
        ),
      ),
    );
  }

  Widget _numberOfQuestionPart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          '残り問題数',
          style: TextStyle(fontSize: 14.0),
        ),
        const SizedBox(width: 30.0),
        Text(
          _numberOfQuestion.toString(),
          style: const TextStyle(fontSize: 24.0),
        ),
      ],
    );
  }

  Widget _questionCardPart() {
    if (_isQuestionCardVisible == false) {
      return Container();
    }
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Image.asset('assets/images/image_flash_question.png'),
        Text(
          _textQuestion,
          style: TextStyle(fontSize: 24.0, color: Colors.blueGrey),
        ),
      ],
    );
  }

  Widget _answerCardPart() {
    if (_isAnswerCardVisible == false) {
      return Container();
    }
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Image.asset('assets/images/image_flash_answer.png'),
        Text(
          _textAnswer,
          style: const TextStyle(fontSize: 24.0),
        )
      ],
    );
  }

  Widget _isMemorizedCheckPart() {
    if (_isCheckBoxVisible == false) {
      return Container();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Checkbox(
          value: _isMemorized,
          onChanged: (value) {
            setState(() {
              _isMemorized = value;
            });
          },
        ),
        const Text(
          '暗記済の場合はチェックを入れてください',
          style: TextStyle(fontSize: 12.0),
        )
      ],
    );
//    return Padding(
//      padding: const EdgeInsets.symmetric(horizontal: 40.0),
//      child: CheckboxListTile(
//        title: const Text(
//          '暗記済の場合はチェックを入れてください',
//          style: TextStyle(fontSize: 12.0),
//        ),
//        value: _isMemorized,
//        onChanged: (value) {
//          setState(
//            () {
//              _isMemorized = value;
//            },
//          );
//        },
//      ),
//    );
  }

  Widget _endMessage() {
    if (_testStatus != TestStatus.FINISHED) {
      return Container();
    }
    return const Center(
      child: Text(
        'テスト終了',
        style: TextStyle(fontSize: 50),
      ),
    );
  }

  _goNextStatus() async {
    switch (_testStatus) {
      case TestStatus.BEFORE_START:
        _testStatus = TestStatus.SHOW_QUESTION;
        _showQuestion();
        break;
      case TestStatus.SHOW_QUESTION:
        _testStatus = TestStatus.SHOW_ANSWER;
        _showAnswer();
        break;
      case TestStatus.SHOW_ANSWER:
        await _updateMemorizedFlag();
        if (_numberOfQuestion <= 0) {
          setState(() {
            _isFabVisible = false;
            _testStatus = TestStatus.FINISHED;
          });
        } else {
          _testStatus = TestStatus.SHOW_QUESTION;
          _showQuestion();
        }
        break;
      case TestStatus.FINISHED:
        break;
    }
  }

  void _showQuestion() {
    _currentWord = _testDataList[_index];
    setState(() {
      _isQuestionCardVisible = true;
      _isAnswerCardVisible = false;
      _isCheckBoxVisible = false;
      _isFabVisible = true;
      _textQuestion = _currentWord.strQuestion;
    });
    _numberOfQuestion -= 1;
    _index += 1;
  }

  void _showAnswer() {
    setState(() {
      _isQuestionCardVisible = true;
      _isAnswerCardVisible = true;
      _isCheckBoxVisible = true;
      _isFabVisible = true;
      _textAnswer = _currentWord.strAnswer;
      _isMemorized = _currentWord.isMemorized;
    });
  }

  Future<void> _updateMemorizedFlag() async {
    var updateWord = Word(
      strQuestion: _currentWord.strQuestion,
      strAnswer: _currentWord.strAnswer,
      isMemorized: _isMemorized,
    );
    await database.updateWord(updateWord);
    print(updateWord.toString());
  }

  Future<bool> _finishiTestScreen() async {
    return await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('テスト終了'),
            content: Text('テストを終了してもいいですか？'),
            actions: <Widget>[
              FlatButton(
                child: Text('はい'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('いいえ'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
        ) ??
        false;
  }
}
