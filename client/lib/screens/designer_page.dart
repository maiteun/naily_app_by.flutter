import 'package:flutter/material.dart';

class DesignerPage extends StatelessWidget {
  final String author;

  const DesignerPage({super.key, required this.author});

  @override
  Widget build(BuildContext context) {
    final designerInfo = _getDesignerInfo(author);
    final works = _getDesignerWorks(author);

    return Scaffold(
      appBar: AppBar(
        title: Text(author),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📝 위치 & 설명
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '위치: ${designerInfo['location'] ?? '알 수 없음'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    designerInfo['description'] ?? '설명이 없습니다.',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // 🖼 작품 갤러리
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                '$author 님의 작품들',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: works.length,
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Container(
                    color: Colors.pink.shade100,
                    child: Center(
                      child: Text(
                        works[index],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// ✨ 디자이너별 정보 반환 (클래스 안에 정의)
  Map<String, String> _getDesignerInfo(String author) {
    switch (author) {
      case '@nailstudio':
        return {
          'location': '서울 강남구',
          'description': '감각적인 웨딩 네일과 심플한 원컬러를 전문으로 합니다.',
        };
      case '@glamnails':
        return {
          'location': '서울 마포구',
          'description': '화려한 디자인과 글리터를 잘하는 글램 네일입니다.',
        };
      case '@blissnails':
        return {
          'location': '서울 송파구',
          'description': '편안한 분위기와 트렌디한 디자인을 제공합니다.',
        };
      case '@chicnails':
        return {
          'location': '서울 용산구',
          'description': '시크하고 모던한 스타일을 추구합니다.',
        };
      default:
        return {
          'location': '알 수 없음',
          'description': '설명이 없습니다.',
        };
    }
  }

  /// ✨ 디자이너별 작품 목록 반환 (클래스 안에 정의)
  List<String> _getDesignerWorks(String author) {
    return List.generate(4, (index) => '작품 ${index + 1}');
  }
}
