import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:ui'; // Added for BackdropFilter
import 'addverse.dart' show oldTestamentBooks, newTestamentBooks;
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Verse> _verses = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  double _lastOffset = 0.0;
  Set<String> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _fetchVerses();
    _loadFavorites();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchVerses() async {
    setState(() {
      _isLoading = true;
    });
    final response = await http.get(
      Uri.parse('http://192.168.195.63:3000/verses'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _verses = data.map((json) => Verse.fromJson(json)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load verses.')));
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteIds = prefs.getStringList('favorite_verse_ids')?.toSet() ?? {};
    });
  }

  Future<void> _toggleFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteIds.contains(id)) {
        _favoriteIds.remove(id);
      } else {
        _favoriteIds.add(id);
      }
      prefs.setStringList('favorite_verse_ids', _favoriteIds.toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'My Library',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF22304A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.star_rounded, color: Colors.amber[400], size: 28),
            tooltip: 'Favorites',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FavoritesPage(
                    favoriteVerses: _verses
                        .where((v) => _favoriteIds.contains(v.id))
                        .toList(),
                    onUnfavorite: (verse) => _toggleFavorite(verse.id),
                  ),
                ),
              ).then((_) => _loadFavorites());
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fixed background image and overlay
          Positioned.fill(
            child: Image.asset('assets/pic3.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.45)),
          ),
          // Foreground content scrolls
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Section header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.bookmark, color: Color(0xFF22304A), size: 28),
                    SizedBox(width: 8),
                    Text(
                      'Your Saved Verses',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF22304A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (_isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (_verses.isEmpty) {
                        return const Center(child: Text('No verses found.'));
                      }
                      // Separate verses by testament
                      List<Verse> oldVerses = [];
                      List<Verse> newVerses = [];
                      List<Verse> favoriteVerses = [];
                      // Helper to extract the book name from the title
                      String extractBookName(
                        String title,
                        List<String> allBooks,
                      ) {
                        String t = title.trim().toLowerCase();
                        // Try to match the longest book name at the start
                        allBooks = List.from(allBooks)
                          ..sort((a, b) => b.length.compareTo(a.length));
                        for (final book in allBooks) {
                          final b = book.toLowerCase();
                          if (t.startsWith(b + ' ') || t == b) {
                            return book;
                          }
                        }
                        return '';
                      }

                      final allBooks = [
                        ...oldTestamentBooks,
                        ...newTestamentBooks,
                      ];
                      for (var verse in _verses) {
                        final book = extractBookName(verse.title, allBooks);
                        if (book.isNotEmpty) {
                          if (oldTestamentBooks.contains(book)) {
                            oldVerses.add(verse);
                          } else if (newTestamentBooks.contains(book)) {
                            newVerses.add(verse);
                          }
                        }
                        if (_favoriteIds.contains(verse.id)) {
                          favoriteVerses.add(verse);
                        }
                      }
                      // Sort helper for canonical order
                      int bookOrder(String book, List<String> orderList) {
                        final idx = orderList.indexOf(book);
                        return idx == -1 ? 999 : idx;
                      }

                      int chapterNum(String title) {
                        final parts = title.split(' ');
                        if (parts.length > 1) {
                          final chap = parts[1].split(':').first;
                          return int.tryParse(chap) ?? 0;
                        }
                        return 0;
                      }

                      int verseNum(String title) {
                        final parts = title.split(' ');
                        if (parts.length > 1 && parts[1].contains(':')) {
                          final v = parts[1].split(':').last;
                          return int.tryParse(v) ?? 0;
                        }
                        return 0;
                      }

                      // Sort Old Testament
                      oldVerses.sort((a, b) {
                        final aBook = a.title.split(' ').first;
                        final bBook = b.title.split(' ').first;
                        final cmp = bookOrder(
                          aBook,
                          oldTestamentBooks,
                        ).compareTo(bookOrder(bBook, oldTestamentBooks));
                        if (cmp != 0) return cmp;
                        final chapCmp = chapterNum(
                          a.title,
                        ).compareTo(chapterNum(b.title));
                        if (chapCmp != 0) return chapCmp;
                        return verseNum(a.title).compareTo(verseNum(b.title));
                      });
                      // Sort New Testament
                      newVerses.sort((a, b) {
                        final aBook = a.title.split(' ').first;
                        final bBook = b.title.split(' ').first;
                        final cmp = bookOrder(
                          aBook,
                          newTestamentBooks,
                        ).compareTo(bookOrder(bBook, newTestamentBooks));
                        if (cmp != 0) return cmp;
                        final chapCmp = chapterNum(
                          a.title,
                        ).compareTo(chapterNum(b.title));
                        if (chapCmp != 0) return chapCmp;
                        return verseNum(a.title).compareTo(verseNum(b.title));
                      });
                      // Sort Favorites
                      favoriteVerses.sort((a, b) {
                        // Use same sorting as old/new testament
                        final aBook = extractBookName(a.title, allBooks);
                        final bBook = extractBookName(b.title, allBooks);
                        final cmp = bookOrder(
                          aBook,
                          allBooks,
                        ).compareTo(bookOrder(bBook, allBooks));
                        if (cmp != 0) return cmp;
                        final chapCmp = chapterNum(
                          a.title,
                        ).compareTo(chapterNum(b.title));
                        if (chapCmp != 0) return chapCmp;
                        return verseNum(a.title).compareTo(verseNum(b.title));
                      });
                      return ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.zero,
                        controller: _scrollController,
                        children: [
                          SizedBox(height: 20), // Add space at the top
                          if (oldVerses.isNotEmpty) ...[
                            _SectionHeader(
                              title: 'Old Testament',
                              color: Colors.deepOrange,
                            ),
                            ...oldVerses.map(
                              (verse) => _VerseCard(
                                verse: verse,
                                accent: Colors.deepOrange,
                                onDelete: () => _confirmDelete(context, verse),
                                isFavorite: _favoriteIds.contains(verse.id),
                                onFavorite: () => _toggleFavorite(verse.id),
                              ),
                            ),
                          ],
                          if (newVerses.isNotEmpty) ...[
                            _SectionHeader(
                              title: 'New Testament',
                              color: Colors.indigo,
                            ),
                            ...newVerses.map(
                              (verse) => _VerseCard(
                                verse: verse,
                                accent: Colors.indigo,
                                onDelete: () => _confirmDelete(context, verse),
                                isFavorite: _favoriteIds.contains(verse.id),
                                onFavorite: () => _toggleFavorite(verse.id),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7B2F2F), Color(0xFFB24545)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.18),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: SizedBox(
          height: 58,
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/addverse');
              if (result == true) {
                _fetchVerses();
              }
            },
            icon: Icon(Icons.add, color: Colors.white, size: 28),
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
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              shape: StadiumBorder(),
              elevation: 0,
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _confirmDelete(BuildContext context, Verse verse) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Verse'),
        content: const Text('Are you sure you want to delete this verse?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _deleteVerse(verse.id);
    }
  }

  Future<void> _deleteVerse(String id) async {
    final url = Uri.parse('http://192.168.195.63:3000/verses/$id');
    final response = await http.delete(url);
    if (response.statusCode == 200) {
      final idx = _verses.indexWhere((v) => v.id == id);
      if (idx != -1) {
        final offset = _scrollController.offset;
        setState(() {
          _verses.removeAt(idx);
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(offset);
          }
        });
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Verse deleted.')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to delete verse.')));
    }
  }
}

class Verse {
  final String id;
  final String title;
  final String content;

  Verse({required this.id, required this.title, required this.content});

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      id: json['id'].toString(),
      title: json['title'],
      content: json['content'],
    );
  }
}

// Section header widget
class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader({required this.title, required this.color});
  @override
  Widget build(BuildContext context) {
    IconData icon = title.contains('Old')
        ? Icons.auto_stories_rounded
        : Icons.menu_book_rounded;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: color,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        Container(
          height: 3,
          width: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.5), color.withOpacity(0.1)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}

// Verse card widget
class _VerseCard extends StatelessWidget {
  final Verse verse;
  final Color accent;
  final VoidCallback onDelete;
  final bool isFavorite;
  final VoidCallback? onFavorite;
  final bool showFavorite;
  const _VerseCard({
    required this.verse,
    required this.accent,
    required this.onDelete,
    required this.isFavorite,
    this.onFavorite,
    this.showFavorite = true,
  });
  @override
  Widget build(BuildContext context) {
    // Choose icon and gradient based on accent color (testament)
    final isOld = accent == Colors.deepOrange;
    final gradient = LinearGradient(
      colors: isOld
          ? [Colors.orange.shade100, Colors.orange.shade50]
          : [Colors.indigo.shade100, Colors.indigo.shade50],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final icon = isOld ? Icons.auto_stories_rounded : Icons.menu_book_rounded;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.92, end: 1),
      duration: Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.only(bottom: 28),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.13),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Leading icon
                Container(
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.13),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(10),
                  child: Icon(icon, color: accent, size: 28),
                ),
                SizedBox(width: 16),
                // Verse content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        verse.title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: accent,
                          letterSpacing: 0.3,
                          fontFamily: 'Georgia',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        verse.content,
                        style: const TextStyle(
                          fontSize: 17,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Favorite icon (only if showFavorite is true)
                if (showFavorite && onFavorite != null)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: onFavorite,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: isFavorite
                              ? Colors.amber[700]
                              : Colors.amber[300],
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                // Delete icon
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: onDelete,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.red[400],
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FavoritesPage extends StatefulWidget {
  final List<Verse> favoriteVerses;
  final void Function(Verse) onUnfavorite;
  const FavoritesPage({
    required this.favoriteVerses,
    required this.onUnfavorite,
  });
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late List<Verse> _localFavorites;

  @override
  void initState() {
    super.initState();
    _localFavorites = List.from(widget.favoriteVerses);
  }

  void _removeFavorite(Verse verse) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Favorites'),
        content: const Text(
          'Are you sure you want to remove this verse from your favorites?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() {
        _localFavorites.removeWhere((v) => v.id == verse.id);
      });
      widget.onUnfavorite(verse);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF22304A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset('assets/pic3.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.45)),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: _localFavorites.isEmpty
                ? const Center(child: Text('No favorites yet.'))
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: [
                      _SectionHeader(
                        title: 'Favorites',
                        color: Colors.amber[800] ?? Colors.amber,
                      ),
                      ..._localFavorites.map(
                        (verse) => _VerseCard(
                          verse: verse,
                          accent: Colors.amber[800] ?? Colors.amber,
                          onDelete: () => _removeFavorite(verse),
                          isFavorite: true,
                          onFavorite: null,
                          showFavorite: false,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
