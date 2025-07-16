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

// Accurate maxChapters for all books
final Map<String, int> maxChapters = {
  'Genesis': 50,
  'Exodus': 40,
  'Leviticus': 27,
  'Numbers': 36,
  'Deuteronomy': 34,
  'Joshua': 24,
  'Judges': 21,
  'Ruth': 4,
  '1 Samuel': 31,
  '2 Samuel': 24,
  '1 Kings': 22,
  '2 Kings': 25,
  '1 Chronicles': 29,
  '2 Chronicles': 36,
  'Ezra': 10,
  'Nehemiah': 13,
  'Esther': 10,
  'Job': 42,
  'Psalm': 150,
  'Proverbs': 31,
  'Ecclesiastes': 12,
  'Song of Solomon': 8,
  'Isaiah': 66,
  'Jeremiah': 52,
  'Lamentations': 5,
  'Ezekiel': 48,
  'Daniel': 12,
  'Hosea': 14,
  'Joel': 3,
  'Amos': 9,
  'Obadiah': 1,
  'Jonah': 4,
  'Micah': 7,
  'Nahum': 3,
  'Habakkuk': 3,
  'Zephaniah': 3,
  'Haggai': 2,
  'Zechariah': 14,
  'Malachi': 4,
  'Matthew': 28,
  'Mark': 16,
  'Luke': 24,
  'John': 21,
  'Acts': 28,
  'Romans': 16,
  '1 Corinthians': 16,
  '2 Corinthians': 13,
  'Galatians': 6,
  'Ephesians': 6,
  'Philippians': 4,
  'Colossians': 4,
  '1 Thessalonians': 5,
  '2 Thessalonians': 3,
  '1 Timothy': 6,
  '2 Timothy': 4,
  'Titus': 3,
  'Philemon': 1,
  'Hebrews': 13,
  'James': 5,
  '1 Peter': 5,
  '2 Peter': 3,
  '1 John': 5,
  '2 John': 1,
  '3 John': 1,
  'Jude': 1,
  'Revelation': 22,
};
// For maxVerses, recommend using a separate Dart file or code generator for all chapters/verses, but here is a fallback for chapters 1-150 with 176 verses max (for Psalms), and a few accurate examples:
final Map<String, Map<int, int>> maxVerses = {
  'Genesis': {
    1: 31,
    2: 25,
    3: 24,
    4: 26,
    5: 32,
    6: 22,
    7: 24,
    8: 22,
    9: 29,
    10: 32,
    11: 32,
    12: 20,
    13: 18,
    14: 24,
    15: 21,
    16: 16,
    17: 27,
    18: 33,
    19: 38,
    20: 18,
    21: 34,
    22: 24,
    23: 20,
    24: 67,
    25: 34,
    26: 35,
    27: 46,
    28: 22,
    29: 35,
    30: 43,
    31: 55,
    32: 32,
    33: 20,
    34: 31,
    35: 29,
    36: 43,
    37: 36,
    38: 30,
    39: 23,
    40: 23,
    41: 57,
    42: 38,
    43: 34,
    44: 34,
    45: 28,
    46: 34,
    47: 31,
    48: 22,
    49: 33,
    50: 26,
  },
  'Exodus': {
    1: 22,
    2: 25,
    3: 22,
    4: 31,
    5: 23,
    6: 30,
    7: 25,
    8: 32,
    9: 35,
    10: 29,
    11: 10,
    12: 51,
    13: 22,
    14: 31,
    15: 27,
    16: 36,
    17: 16,
    18: 27,
    19: 25,
    20: 26,
    21: 36,
    22: 31,
    23: 33,
    24: 18,
    25: 40,
    26: 37,
    27: 21,
    28: 43,
    29: 46,
    30: 38,
    31: 18,
    32: 35,
    33: 23,
    34: 35,
    35: 35,
    36: 38,
    37: 29,
    38: 31,
    39: 43,
    40: 38,
  },
  'Galatians': {1: 24, 2: 21, 3: 29, 4: 31, 5: 26, 6: 18},
  // Add more books and chapters as needed for full accuracy
};

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

  int get _maxChapter {
    if (_selectedBook == null) return 150;
    return maxChapters[_selectedBook!] ?? 150;
  }

  int get _maxVerse {
    if (_selectedBook == null || _chapter == null) return 176;
    final chapterNum = int.tryParse(_chapter ?? '') ?? 1;
    return maxVerses[_selectedBook!]?[chapterNum] ?? 176;
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
    final url = Uri.parse('http://192.168.195.63:3000/verses');
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
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Chapter',
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    value: _chapter,
                                    items:
                                        List.generate(
                                              _maxChapter,
                                              (i) => (i + 1).toString(),
                                            )
                                            .map(
                                              (ch) => DropdownMenuItem(
                                                value: ch,
                                                child: Text(ch),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _chapter = val;
                                        _verse = null;
                                        _onChapterOrVerseChanged();
                                      });
                                    },
                                    validator: (val) =>
                                        val == null ? 'Select chapter' : null,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Verse',
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    value: _verse,
                                    items:
                                        List.generate(
                                              _maxVerse,
                                              (i) => (i + 1).toString(),
                                            )
                                            .map(
                                              (v) => DropdownMenuItem(
                                                value: v,
                                                child: Text(v),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _verse = val;
                                        _onChapterOrVerseChanged();
                                      });
                                    },
                                    validator: (val) =>
                                        val == null ? 'Select verse' : null,
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
                                : Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF7B2F2F),
                                          Color(0xFFB24545),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(32),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.redAccent.withOpacity(
                                            0.18,
                                          ),
                                          blurRadius: 16,
                                          offset: Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 58,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          if (_formKey.currentState!
                                                  .validate() &&
                                              _content.isNotEmpty) {
                                            _addVerse();
                                          }
                                        },
                                        icon: Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                        label: Text(
                                          'Add Verse',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 18,
                                          ),
                                          shape: StadiumBorder(),
                                          elevation: 0,
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                        ),
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
