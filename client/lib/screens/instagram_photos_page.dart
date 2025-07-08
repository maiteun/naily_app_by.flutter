import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InstagramPhotosPage extends StatefulWidget {
  final String handle; // e.g. musee_nail

  const InstagramPhotosPage({Key? key, required this.handle}) : super(key: key);

  @override
  State<InstagramPhotosPage> createState() => _InstagramPhotosPageState();
}

class _InstagramPhotosPageState extends State<InstagramPhotosPage> {
  List<String> photos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInstagramPhotos();
  }

  Future<void> fetchInstagramPhotos() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse(
          'http://127.0.0.1:8080/instagram_posts?handle=${widget.handle}'));

      if (res.statusCode == 200) {
        final data = json.decode(res.body) as List<dynamic>;
        setState(() {
          photos = data.cast<String>();
          isLoading = false;
        });
      } else {
        print('❌ 서버 오류: ${res.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('❌ 네트워크 오류: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('@${widget.handle} 사진'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : photos.isEmpty
              ? const Center(child: Text('사진을 불러올 수 없습니다.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Image.network(
                        photos[index],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
    );
  }
}
