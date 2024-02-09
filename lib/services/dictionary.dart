import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:wordwrap/models/dictionary.dart';

final Logger _logger = Logger('WordService');
final CollectionReference<Map<String, dynamic>> _dictionary =
    FirebaseFirestore.instance.collection('dictionary');
final _storageRef = FirebaseStorage.instance.ref();

class DictionaryService {
  Future<Dictionary> getWord(String word) async {
    try {
      final docSnapshot = await _dictionary.doc(word).get();
      if (docSnapshot.exists) {
        return Dictionary.fromJson(docSnapshot.data()!);
      } else {
        final wordFromAPI = await _getWordFromAPI(word);
        await _dictionary.doc(word).set(wordFromAPI.toJson());
        return wordFromAPI;
      }
    } catch (e) {
      _logger.severe('Failed to fetch word: $e');
      throw Exception('Failed to fetch word');
    }
  }

  Future<String> getImageUrl(String word) async {
    final pathRef = _storageRef.child('images/$word');
    String downloadUrl = await pathRef.getDownloadURL();

    return downloadUrl;
  }

  Future<void> uploadImage(String word, File file) async {
    final ref = _storageRef.child('images/$word');
    await ref.putFile(file);
  }

  Future<void> fixImages() async {
    final ListResult result = await _storageRef.child('images').listAll();

    for (final Reference ref in result.items) {
      if (!ref.name.endsWith('.webp') && !ref.name.endsWith('.png')) {
        continue;
      }

      final String docId =
          ref.name.replaceAll('.webp', '').replaceAll('.png', '');

      // Download the old file
      final Uint8List? data = await ref.getData();

      // Upload the data to a new file
      final Reference newRef = _storageRef.child('images/$docId');
      await newRef.putData(data!);

      // Delete the old file
      await ref.delete();

      print("fixed $docId");
    }
  }

  Future<Dictionary> _getWordFromAPI(String word) async {
    final response = await http.get(
        Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word'));
    if (response.statusCode == 200) {
      final wordsRaw = json.decode(response.body);
      Dictionary word =
          wordsRaw.map((word) => Dictionary.fromJson(word)).toList()[0];
      return word;
    } else {
      _logger.severe(
          'Failed to fetch word ${response.statusCode}: ${response.body}');
      throw Exception('Failed to fetch word');
    }
  }
}
