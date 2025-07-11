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
    final url = Uri.parse('https://bible-api.com/$ref');
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
    final url = Uri.parse('http://10.0.2.2:3000/verses');
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
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(
                          0.65,
                        ), // semi-transparent
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Select Verse',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20),
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
                                : ElevatedButton.icon(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate() &&
                                          _content.isNotEmpty) {
                                        _addVerse();
                                      }
                                    },
                                    icon: Icon(Icons.add),
                                    label: Text(
                                      'Add',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF22304A),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16,
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
