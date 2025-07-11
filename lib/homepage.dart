import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Verse>> _versesFuture;

  @override
  void initState() {
    super.initState();
    _versesFuture = fetchVerses();
  }

  Future<List<Verse>> fetchVerses() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/verses'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Verse.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load verses');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Library')),
      body: FutureBuilder<List<Verse>>(
        future: _versesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No verses found.'));
          } else {
            final verses = snapshot.data!;
            return ListView.builder(
              itemCount: verses.length,
              itemBuilder: (context, index) {
                final verse = verses[index];
                return ListTile(
                  title: Text(verse.title),
                  subtitle: Text(verse.content),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/addverse');
          if (result == true) {
            setState(() {
              _versesFuture = fetchVerses();
            });
          }
        },
        label: const Text('Add Verse'),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
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
