import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wordwrap/models/user.dart';
import 'package:wordwrap/models/word.dart';
import 'package:wordwrap/services/auth.dart';
import 'package:wordwrap/services/user.dart';
import 'package:wordwrap/services/user_words.dart';
import 'package:wordwrap/views/login.dart';
import 'package:wordwrap/widgets/word_edit.dart';
import 'package:wordwrap/widgets/word_grid.dart';
import 'package:wordwrap/widgets/word_list.dart';
import 'package:wordwrap/widgets/word_search.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  final _userWordsService = UserWordsService();
  final _userService = UserService();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _userService.getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
                width: 50.0, height: 50.0, child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          return const Center(child: Text('User does not exist'));
        } else {
          final user = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
                title: const SizedBox(
                  child: Text(""),
                ),
                actions: <Widget>[
                  if (_selectedIndex == 0)
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () async {
                        await AuthService.signOut();
                        if (mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const LoginView(),
                            ),
                          );
                        }
                      },
                    ),
                ]),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: () {
                  switch (_selectedIndex) {
                    case 0:
                      return StreamBuilder<QuerySnapshot>(
                        stream: _userWordsService.getAll(user.uid!, 1),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<Word> words = snapshot.data!.docs
                                .map((doc) => Word.fromJson(
                                    doc.data() as Map<String, dynamic>))
                                .toList();
                            return WordGrid(words: words);
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      );
                    case 1:
                      return WordSearch();
                    case 2:
                      return StreamBuilder<QuerySnapshot>(
                        stream: _userWordsService.getAll(user.uid!, 2),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<Word> words = snapshot.data!.docs
                                .map((doc) => Word.fromJson(
                                    doc.data() as Map<String, dynamic>))
                                .toList();
                            return WordList(words: words);
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      );
                    default:
                      return StreamBuilder<QuerySnapshot>(
                        stream: _userWordsService.getAll(user.uid!, 1),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<Word> words = snapshot.data!.docs
                                .map((doc) => Word.fromJson(
                                    doc.data() as Map<String, dynamic>))
                                .toList();
                            return WordEdit(words: words);
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      );
                  }
                }(),
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.school),
                  label: 'Learn',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book),
                  label: 'Library',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.edit),
                  label: 'Edit',
                ),
              ],
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
          );
        }
      },
    );
  }
}
