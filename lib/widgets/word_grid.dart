import 'package:flutter/material.dart';
import 'package:wordwrap/models/word.dart';
import 'package:wordwrap/utils/utils.dart';
import 'package:wordwrap/views/word.dart';

class WordGrid extends StatefulWidget {
  const WordGrid({
    super.key,
    required this.words,
  });

  final List<Word> words;

  @override
  State<WordGrid> createState() => _WordGridState();
}

class _WordGridState extends State<WordGrid> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: widget.words.length,
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemBuilder: (context, index) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Center(
                  child: ListTile(
                    title: Center(
                      child: Text(
                        Utils.capitalizeFirstWord(widget.words[index].word),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .color!
                                .withOpacity(0.7)),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              WordView(wd: widget.words[index]),
                        ),
                      );
                    },
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Added ${DateTime.now().difference(widget.words[index].addedOn).inDays} days ago',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
