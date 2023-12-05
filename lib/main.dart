import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unsplash Flutter App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.purple[200],
        appBarTheme: AppBarTheme(
          color: Colors.deepPurple[900],
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class Photo {
  Photo({
    required this.id,
    required this.description,
    required this.imageUrl,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] as String,
      description: json['description'] != null ? json['description'] as String : 'No description',
      imageUrl: json['urls']['regular'] as String,
    );
  }
  final String id;
  final String description;
  final String imageUrl;
}

class UnsplashApi {
  static const String apiKey = 'tACkK8zx_wVYlLaBtAmh86X8AXAgD4tkEkLpmSOr1Xo';
  static const String apiUrl = 'https://api.unsplash.com';
  static const int perPage = 10;

  static Future<List<Map<String, dynamic>>> searchPhotos(String query, int page) async {
    final http.Response response = await http.get(
      Uri.parse('$apiUrl/search/photos?query=$query&page=$page&per_page=$perPage'),
      headers: <String, String>{'Authorization': 'Client-ID $apiKey'},
    );

    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body);
      final List<Map<String, dynamic>> results = List<Map<String, dynamic>>.from(data['results'] as List<dynamic>);
      return List<Map<String, dynamic>>.from(results.map((dynamic item) => item as Map<String, dynamic>));
    } else {
      throw Exception('Failed to load photos');
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Photo> _photos = <Photo>[];
  int _page = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final List<Map<String, dynamic>> photos = await UnsplashApi.searchPhotos('nature', _page);
    setState(() {
      _photos.addAll(photos.map((Map<String, dynamic> json) => Photo.fromJson(json)));
      _page++;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadPhotos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Unsplash Flutter App',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildPhotoList(),
    );
  }

  Widget _buildPhotoList() {
    return ListView.builder(
      itemCount: _photos.length + 1, // Add 1 for loading indicator
      itemBuilder: (BuildContext context, int index) {
        if (index < _photos.length) {
          final Photo photo = _photos[index];
          final String limitedDescription =
              photo.description.length > 50 ? '${photo.description.substring(0, 50)}...' : photo.description;

          return GestureDetector(
            onTap: () {
              // Handle photo click here, for example, open a larger image
              _showLargerImage(photo.imageUrl);
            },
            child: SizedBox(
              height: 80,
              child: ListTile(
                title: Text(
                  limitedDescription,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                contentPadding: const EdgeInsets.all(8.0),
                leading: SizedBox(
                  width: 80,
                  height: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      photo.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }

  // Function to show a larger image (you can implement this according to your requirements)
  void _showLargerImage(String imageUrl) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: SizedBox(
            width: 360, // Adjust as needed
            height: 360, // Adjust as needed
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}
