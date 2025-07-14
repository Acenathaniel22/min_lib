import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui'; // Add this import at the top

const List<String> oldTestamentBooks = [
  'Genesis',
  'Exodus',
  'Leviticus',
  'Numbers',
  'Deuteronomy',
  'Joshua',
  'Judges',
  'Ruth',
  '1 Samuel',
  '2 Samuel',
  '1 Kings',
  '2 Kings',
  '1 Chronicles',
  '2 Chronicles',
  'Ezra',
  'Nehemiah',
  'Esther',
  'Job',
  'Psalm',
  'Proverbs',
  'Ecclesiastes',
  'Song of Solomon',
  'Isaiah',
  'Jeremiah',
  'Lamentations',
  'Ezekiel',
  'Daniel',
  'Hosea',
  'Joel',
  'Amos',
  'Obadiah',
  'Jonah',
  'Micah',
  'Nahum',
  'Habakkuk',
  'Zephaniah',
  'Haggai',
  'Zechariah',
  'Malachi',
];

const List<String> newTestamentBooks = [
  'Matthew',
  'Mark',
  'Luke',
  'John',
  'Acts',
  'Romans',
  '1 Corinthians',
  '2 Corinthians',
  'Galatians',
  'Ephesians',
  'Philippians',
  'Colossians',
  '1 Thessalonians',
  '2 Thessalonians',
  '1 Timothy',
  '2 Timothy',
  'Titus',
  'Philemon',
  'Hebrews',
  'James',
  '1 Peter',
  '2 Peter',
  '1 John',
  '2 John',
  '3 John',
  'Jude',
  'Revelation',
];

class AddVersePage extends StatefulWidget {
  @override
  _AddVersePageState createState() => _AddVersePageState();
}

class _AddVersePageState extends State<AddVersePage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedTestament;
  String? _selectedBook;
  String? _chapter;
  String? _verse;
  String _content = '';
  bool _isLoading = false;
  final TextEditingController _contentController = TextEditingController();

  List<String> get _bookList {
    if (_selectedTestament == 'Old Testament') return oldTestamentBooks;
    if (_selectedTestament == 'New Testament') return newTestamentBooks;
    return [];
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _fetchVerseContent() async {
    if (_selectedBook == null || _chapter == null || _verse == null) {
      setState(() {
        _content = '';
        _contentController.text = _content;
      });
      return;
    }
    final ref =
        '${_selectedBook!.replaceAll(' ', '+')}+${_chapter!}:${_verse!}';
    final url = Uri.parse('https://bible-api.com/$ref?translation=kjv');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _content = data['text'] ?? '';
        _contentController.text = _content;
      });
    } else {
      setState(() {
        _content = 'Verse not found.';
        _contentController.text = _content;
      });
    }
  }

  Future<void> _addVerse() async {
    setState(() => _isLoading = true);
    final url = Uri.parse('http://192.168.195.57:3000/verses');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': _selectedBook != null && _chapter != null && _verse != null
            ? '$_selectedBook $_chapter:$_verse'
            : '',
        'content': _content,
      }),
    );
    setState(() => _isLoading = false);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Verse added!')));
      Navigator.pop(context, true); // Return to previous page
    } else if (response.statusCode == 409) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This verse already exists in your library.')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add verse')));
    }
  }

  void _onChapterOrVerseChanged() {
    if (_selectedBook != null &&
        _chapter != null &&
        _verse != null &&
        _chapter!.isNotEmpty &&
        _verse!.isNotEmpty) {
      _fetchVerseContent();
    } else {
      setState(() {
        _content = '';
        _contentController.text = _content;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _contentController.text = _content;
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Verse', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF22304A),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Color(0xFFF5F6FA),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/pic2.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.3)),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.blueGrey.withOpacity(0.13),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(28.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Modern section header style
                            Padding(
                              padding: const EdgeInsets.only(bottom: 18.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 8,
                                    sigmaY: 8,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.blueGrey.withOpacity(
                                          0.25,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 18,
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.edit_note_rounded,
                                          color: Color(0xFF22304A),
                                          size: 22,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Select Verse',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF22304A),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Testament',
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              value: _selectedTestament,
                              items: ['Old Testament', 'New Testament']
                                  .map(
                                    (testament) => DropdownMenuItem(
                                      value: testament,
                                      child: Text(testament),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedTestament = val;
                                  _selectedBook = null;
                                  _chapter = null;
                                  _verse = null;
                                  _content = '';
                                  _contentController.text = _content;
                                });
                              },
                              validator: (val) =>
                                  val == null ? 'Select a testament' : null,
                            ),
                            SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Book',
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              value: _selectedBook,
                              items: _bookList
                                  .map(
                                    (book) => DropdownMenuItem(
                                      value: book,
                                      child: Text(book),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedBook = val;
                                  _chapter = null;
                                  _verse = null;
                                  _content = '';
                                  _contentController.text = _content;
                                });
                              },
                              validator: (val) =>
                                  val == null ? 'Select a book' : null,
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Chapter',
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) {
                                      _chapter = val;
                                      _onChapterOrVerseChanged();
                                    },
                                    validator: (val) =>
                                        val == null || val.isEmpty
                                        ? 'Enter chapter'
                                        : null,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Verse',
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) {
                                      _verse = val;
                                      _onChapterOrVerseChanged();
                                    },
                                    validator: (val) =>
                                        val == null || val.isEmpty
                                        ? 'Enter verse'
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Content',
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              controller: _contentController,
                              readOnly: true,
                              maxLines: 4,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 28),
                            _isLoading
                                ? Center(child: CircularProgressIndicator())
                                : SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate() &&
                                            _content.isNotEmpty) {
                                          _addVerse();
                                        }
                                      },
                                      icon: Icon(
                                        Icons.menu_book_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      label: Text(
                                        'Add Verse',
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      style:
                                          ElevatedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                            ),
                                            elevation: 7,
                                            shadowColor: Colors.brown
                                                .withOpacity(0.18),
                                            backgroundColor: const Color(
                                              0xFF7B2F2F,
                                            ), // Rich maroon
                                          ).copyWith(
                                            backgroundColor:
                                                MaterialStateProperty.resolveWith<
                                                  Color
                                                >((states) {
                                                  if (states.contains(
                                                    MaterialState.pressed,
                                                  )) {
                                                    return const Color(
                                                      0xFF5A2323,
                                                    ); // Darker maroon on press
                                                  }
                                                  return const Color(
                                                    0xFF7B2F2F,
                                                  ); // Default
                                                }),
                                          ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
