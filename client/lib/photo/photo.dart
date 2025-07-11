class Photo {
  final String id;
  final String author;
  final String imageUrl;
  Photo({required this.id, required this.author, required this.imageUrl});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'author': author,
      'imageUrl': imageUrl,
    };
  }
  factory Photo.fromMap(Map<String, dynamic> map) {
    final baseUrl =
       'https://vprspqajqjxcgdswawhh.supabase.co/storage/v1/object/public/';
   return Photo(
     id: map['id'],
      author: map['designer'],
     imageUrl: '$baseUrl${map['image_path']}',
  );
}
}
