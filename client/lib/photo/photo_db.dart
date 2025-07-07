import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase 클라이언트
final supabase = Supabase.instance.client;

/// photos 테이블에서 사진 목록을 가져오는 함수
Future<List<Map<String, dynamic>>> fetchPhotos() async {
  try {
    final List<dynamic> data = await supabase.from('photos').select();
    print('Fetched data: $data');
    return data.cast<Map<String, dynamic>>();
  } catch (e) {
    print('Error fetching photos: $e');
    rethrow;
  }
}


/// 새로운 사진을 추가하는 함수
Future<void> insertPhoto({
  required String designer,
  required String imagePath,
}) async {
  try {
    final response = await supabase.from('photos').insert([
      {
        'designer': designer,
        'image_path': imagePath,
      }
    ]);
    // response에는 상태 코드만 오고, 특별한 에러는 throw됨
  } catch (e) {
    rethrow;
  }
}

/// 특정 id의 사진을 삭제하는 함수
Future<void> deletePhoto(String id) async {
  try {
    final response =
        await supabase.from('photos').delete().eq('id', id);
  } catch (e) {
    rethrow;
  }
}
Future<List<String>> fetchLikedPhotos() async {
  final userId = Supabase.instance.client.auth.currentUser!.id;
  final response = await supabase.from('likes')
      .select('photo_id')
      .eq('user_id', userId);

  return response.map<String>((e) => e['photo_id'] as String).toList();
}

Future<void> insertLike(String photoId) async {
  await supabase.from('likes').insert({
    'user_id': Supabase.instance.client.auth.currentUser!.id,
    'photo_id': photoId,
  });
}
//좋아요 표시
Future<void> deleteLike(String photoId) async {
  await supabase.from('likes')
      .delete()
      .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
      .eq('photo_id', photoId);
}
