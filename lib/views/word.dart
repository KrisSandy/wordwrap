import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:wordwrap/models/dictionary.dart';
import 'package:wordwrap/models/word.dart';
import 'package:wordwrap/services/dictionary.dart';
import 'package:wordwrap/services/user.dart';
import 'package:wordwrap/services/user_words.dart';
import 'package:wordwrap/utils/utils.dart';

class WordView extends StatefulWidget {
  const WordView({
    super.key,
    required this.wd,
  });

  final Word wd;

  @override
  State<WordView> createState() => _WordViewState();
}

class _WordViewState extends State<WordView> {
  final DictionaryService _wordService = DictionaryService();
  final UserWordsService _userWordsService = UserWordsService();
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Dictionary>(
      future: _wordService.getWord(widget.wd.word),
      builder: (BuildContext context, AsyncSnapshot<Dictionary> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Word not found')),
            );
          });
          return Container();
        } else {
          Dictionary dict = snapshot.data!;
          final phoneticWithAudio = dict.phonetics.firstWhere(
            (phonetic) => phonetic.audio != null && phonetic.audio!.isNotEmpty,
            orElse: () => dict.phonetics[0], // Default value
          );

          return Scaffold(
            appBar: AppBar(
              title: Text(Utils.capitalizeFirstWord(dict.word)),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              Utils.capitalizeFirstWord(dict.word),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (phoneticWithAudio.audio != null &&
                              phoneticWithAudio.audio!.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.volume_up),
                              onPressed: () {
                                final player = AudioPlayer();
                                player
                                    .play(UrlSource(phoneticWithAudio.audio!));
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              FutureBuilder<String>(
                                future: _wordService.getImageUrl(dict.word),
                                builder: (BuildContext context,
                                    AsyncSnapshot<String> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Container();
                                  } else {
                                    return Center(
                                      child: SizedBox(
                                        height: 300,
                                        width: 300,
                                        child: Image.network(snapshot.data!),
                                      ),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Meaning',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...dict.meanings.map((meaning) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      '${meaning.partOfSpeech}:',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    ...meaning.definitions.map((definition) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            const Text(
                                              '\u2022',
                                              style: TextStyle(
                                                fontSize: 16,
                                                height: 1.55,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    definition.definition,
                                                    textAlign: TextAlign.left,
                                                    softWrap: true,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .color!
                                                          .withOpacity(0.6),
                                                      height: 1.55,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  definition.example != null &&
                                                          definition.example!
                                                              .isNotEmpty
                                                      ? Text(
                                                          "Example: ${definition.example}",
                                                          textAlign:
                                                              TextAlign.left,
                                                          softWrap: true,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodySmall!
                                                                .color!
                                                                .withOpacity(
                                                                    0.6),
                                                            fontStyle: FontStyle
                                                                .italic,
                                                          ),
                                                        )
                                                      : Container(),
                                                  const SizedBox(height: 5),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                          ],
                                        ),
                                      );
                                    }),
                                    const SizedBox(height: 10),
                                  ],
                                );
                              }),
                              const SizedBox(height: 10),
                              const Text(
                                'Notes',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...widget.wd.notes.map((note) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      const Text(
                                        '\u2022',
                                        style: TextStyle(
                                          fontSize: 16,
                                          height: 1.55,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: Text(
                                          note,
                                          textAlign: TextAlign.left,
                                          softWrap: true,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .color!
                                                .withOpacity(0.6),
                                            height: 1.55,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                );
                              }),
                              if (widget.wd.status == 1)
                                TextButton.icon(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    final TextEditingController controller =
                                        TextEditingController();

                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Add Note'),
                                          content: TextField(
                                            controller: controller,
                                            maxLines: null,
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('OK'),
                                              onPressed: () async {
                                                final user = await _userService
                                                    .getUser();
                                                widget.wd.notes
                                                    .add(controller.text);
                                                _userWordsService.update(
                                                    user.uid!, widget.wd);
                                                if (mounted) {
                                                  Navigator.of(context).pop();
                                                }
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  label: const Text('Add Note'),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (widget.wd.status != 0)
                            FilledButton(
                              onPressed: () async {
                                final user = await _userService.getUser();
                                _userWordsService.delete(user.uid!, dict.word);
                                if (mounted) {
                                  Navigator.pop(context);
                                }
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.red),
                              ),
                              child: const Text('Delete'),
                            ),
                          const SizedBox(width: 10),
                          _buildAddButtonBasedOnStatus(context, widget.wd),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildAddButtonBasedOnStatus(BuildContext context, Word word) {
    switch (word.status) {
      case 0:
        return FilledButton.tonal(
          onPressed: () async {
            word.status = 1;
            final user = await _userService.getUser();
            _userWordsService.add(user.uid!, word);
            if (mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text('Add to Learn'),
        );
      case 2:
        return FilledButton.tonal(
          onPressed: () async {
            word.status = 1;
            final user = await _userService.getUser();
            _userWordsService.update(user.uid!, word);
            if (mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text('Add to Learn'),
        );
      default:
        return FilledButton.tonal(
          onPressed: () async {
            word.status = 2;
            final user = await _userService.getUser();
            _userWordsService.update(user.uid!, word);
            if (mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text('Mastered'),
        );
    }
  }
}
