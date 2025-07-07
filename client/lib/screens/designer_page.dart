import 'package:flutter/material.dart';
import '../photo/photo.dart';
import '../photo/photo_db.dart';

class DesignerPage extends StatelessWidget {
  final String designerName;

  const DesignerPage({super.key, required this.designerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$designerName의 작품들'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchPhotos(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final maps = snapshot.data!;
          final designerPhotos = maps
              .map((e) => Photo.fromMap(e))
              .where((photo) => photo.author == designerName)
              .toList();

          if (designerPhotos.isEmpty) {
            return Center(child: Text('$designerName의 작품이 없습니다.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 3 / 2,
            ),
            itemCount: designerPhotos.length,
            itemBuilder: (context, index) {
              final photo = designerPhotos[index];
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
