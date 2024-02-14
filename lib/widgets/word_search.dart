import 'package:flutter/material.dart';
import 'package:wordwrap/models/word.dart';
import 'package:wordwrap/views/word.dart';

class WordSearch extends StatelessWidget {
  WordSearch({super.key});

  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 200.0,
              height: 200.0,
              child: Image.asset('assets/icon.png'),
            ),
            const SizedBox(height: 32.0),
            SearchBar(
              controller: controller,
              hintText: 'Type a word',
              padding: const MaterialStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16.0)),
              leading: const Icon(Icons.search),
              onSubmitted: (value) => navigateToWordPage(context, controller),
            ),
            const SizedBox(height: 16.0),
            FilledButton(
              onPressed: () => navigateToWordPage(context, controller),
              style: ButtonStyle(
                elevation: MaterialStateProperty.all<double>(6.0),
              ),
              child: const Text('Search'),
            ),
          ],
        ),
      ),
    );
  }

  void navigateToWordPage(
      BuildContext context, TextEditingController controller) {
    Word word = Word(
      word: controller.text,
      status: 0,
      notes: [],
      addedOn: DateTime.now(),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WordView(wd: word),
      ),
    );
  }
}
