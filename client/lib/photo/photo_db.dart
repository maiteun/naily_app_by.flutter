import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase 클라이언트
final supabase = Supabase.instance.client;

/// 📷 photos 테이블에서 사진 목록을 가져오기
Future<List<Map<String, dynamic>>> fetchPhotos() async {
  try {
    final List<dynamic> data = await supabase.from('photos').select();
    print('Fetched photos: $data');
    return data.cast<Map<String, dynamic>>();
  } catch (e) {
    print('Error fetching photos: $e');
    rethrow;
  }
}

/// 📷 photos 테이블에 새 사진 추가
Future<void> insertPhoto({
  required String designer,
  required String imagePath,
}) async {
  try {
    await supabase.from('photos').insert([
      {
        'designer': designer,
        'image_path': imagePath,
      }
    ]);
  } catch (e) {
    print('Error inserting photo: $e');
    rethrow;
  }
}

/// 📷 특정 ID의 사진 삭제
Future<void> deletePhoto(String id) async {
  try {
    await supabase.from('photos').delete().eq('id', id);
  } catch (e) {
    print('Error deleting photo: $e');
    rethrow;
  }
}

/// ❤️ 현재 로그인한 사용자가 좋아요한 photo_id 목록 가져오기
Future<List<String>> fetchLikedPhotos() async {
  final userId = Supabase.instance.client.auth.currentUser?.id;

  if (userId == null) {
    print("[❌] fetchLikedPhotos: no logged-in user");
    return [];
  }

  final response = await supabase
      .from('likes')
      .select('photo_id')
      .eq('user_id', userId);

  print("[✅] fetchLikedPhotos: found ${response.length} liked photos");
  return response.map<String>((e) => e['photo_id'] as String).toList();
}


Future<void> insertLike(String photoId) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;

  if (userId == null) {
    print("[❌] 로그인된 유저가 없습니다.");
    return;
  }

  print("[❤️] Insert Like: userId=$userId, photoId=$photoId");

  await supabase.from('likes').insert({
    'user_id': userId,
    'photo_id': photoId,
  });
}



Future<void> deleteLike(String photoId) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;

  print("💔 deleteLike() 호출됨: userId=$userId, photoId=$photoId");

  if (userId == null) {
    print("[❌] 로그인된 유저가 없습니다. delete 취소");
    return;
  }

  try {
    await supabase.from('likes')
      .delete()
      .eq('user_id', userId)
      .eq('photo_id', photoId);
    print("[✅] 좋아요 delete 성공");
  } catch (e) {
    print("[❌] 좋아요 delete 실패: $e");
  }
}

