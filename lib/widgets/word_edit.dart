import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';

import 'package:wordwrap/models/word.dart';
import 'package:wordwrap/services/dictionary.dart';
import 'package:wordwrap/utils/utils.dart';

class WordEdit extends StatefulWidget {
  const WordEdit({super.key, required this.words});

  final List<Word> words;

  @override
  State<WordEdit> createState() => _WordEditState();
}

class _WordEditState extends State<WordEdit> {
  final Logger _log = Logger('WordEdit');

  final _dictionaryService = DictionaryService();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: widget.words.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  Utils.capitalizeFirstWord(widget.words[index].word),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .color!
                          .withOpacity(0.7)),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.upload),
                  onPressed: () async {
                    final localContext = context;
                    final ImagePicker picker = ImagePicker();
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.gallery);

                    if (image != null) {
                      final File file = File(image.path);
                      try {
                        await _dictionaryService.uploadImage(
                            widget.words[index].word, file);
                      } catch (e) {
                        if (mounted) {
                          _log.severe("ImageUploadError: $e");
                          ScaffoldMessenger.of(localContext).showSnackBar(
                            const SnackBar(
                              content: Text('Unable to upload image'),
                            ),
                          );
                        }
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(localContext).showSnackBar(
                          const SnackBar(
                            content: Text('No image selected'),
                          ),
                        );
                      }
                    }
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        ElevatedButton(
            onPressed: () {
              _dictionaryService.fixImages();
            },
            child: const Text('Fix Images')),
      ],
    );
  }
}
