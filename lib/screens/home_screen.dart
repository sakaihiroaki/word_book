import 'package:flutter/material.dart';
import 'package:myownfrashcard/parts/button_with_icon.dart';
import 'package:myownfrashcard/screens/test_screen.dart';
import 'package:myownfrashcard/screens/word_list_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isIncludedMemorizedWords = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(child: Image.asset('assets/images/image_title.png')),
            _titleText(),
            Divider(
              height: 30.0,
              indent: 8.0,
              endIndent: 8.0,
              color: Colors.white,
            ),
            ButtonWithIcon(
              onPressed: () => _startTestScreen(context, isIncludedMemorizedWords),
              icon: Icon(Icons.play_arrow),
              label: '確認テストする',
              color: Colors.indigo,
            ),
            const SizedBox(
              height: 10.0,
            ),
//            _radioButtons(),
            _switch(),
            const SizedBox(
              height: 40.0,
            ),
            ButtonWithIcon(
              onPressed: () => _startWordListScreen(context),
              icon: Icon(Icons.list),
              label: '単語一覧を見る',
              color: Colors.grey,
            ),
            const SizedBox(
              height: 120.0,
            ),
            const Text(
              'powered by Hiropon 2020',
              style: TextStyle(fontFamily: 'Mont'),
            ),
            const SizedBox(
              height: 16.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleText() {
    return Column(
      children: <Widget>[
        const Text(
          'めぐこの単語帳',
          style: TextStyle(fontSize: 40.0),
        ),
        const Text(
          "Meguko's Flashcard",
          style: TextStyle(fontSize: 24.0, fontFamily: 'Mont'),
        ),
      ],
    );
  }

  Widget _switch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SwitchListTile(
        title: const Text('暗記済みの単語を含む'),
        value: isIncludedMemorizedWords,
        onChanged: (value) {
          setState(() {
            isIncludedMemorizedWords = value;
          });
        },
        secondary: Icon(Icons.sort),
      ),
    );
  }

  Widget _radioButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 50.0),
      child: Column(
        children: <Widget>[
          RadioListTile(
            value: false,
            groupValue: isIncludedMemorizedWords,
            onChanged: (value) => _onRadioSelected(value),
            title: const Text(
              '暗記済みの単語を除外する',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          RadioListTile(
            value: true,
            groupValue: isIncludedMemorizedWords,
            onChanged: (value) => _onRadioSelected(value),
            title: const Text(
              '暗記済みの単語を含む',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }

  _onRadioSelected(value) {
    setState(() {
      isIncludedMemorizedWords = value;
      print('$valueが選ばれたで');
    });
  }

  _startWordListScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WordListScreen(),
      ),
    );
  }

  _startTestScreen(BuildContext context, bool isIncludedMemorizedWords) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestScreen(
          isIncludedMemorizedWords: isIncludedMemorizedWords,
        ),
      ),
    );
  }
}
