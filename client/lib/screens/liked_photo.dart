import 'package:flutter/material.dart';
import '../photo/photo.dart';
import '../photo/photo_db.dart';

class LikedPhotosPage extends StatelessWidget {
  const LikedPhotosPage({super.key});

  Future<Map<String, dynamic>> _fetchData() async {
    final allPhotosFuture = fetchPhotos();
    final likedIdsFuture = fetchLikedPhotos();

    final results = await Future.wait([allPhotosFuture, likedIdsFuture]);

    final allPhotos = (results[0] as List<Map<String, dynamic>>)
        .map((e) => Photo.fromMap(e))
        .toList();
    final likedIds = results[1] as List<String>;

    return {
      'allPhotos': allPhotos,
      'likedIds': likedIds,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('좋아요한 사진들'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allPhotos = snapshot.data!['allPhotos'] as List<Photo>;
          final likedIds = snapshot.data!['likedIds'] as List<String>;

          final likedPhotos =
              allPhotos.where((photo) => likedIds.contains(photo.id)).toList();

          if (likedPhotos.isEmpty) {
            return const Center(child: Text('좋아요한 사진이 없습니다.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 3 / 2,
            ),
            itemCount: likedPhotos.length,
            itemBuilder: (context, index) {
              final photo = likedPhotos[index];
              return Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Image.network(
                        photo.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        photo.author,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
