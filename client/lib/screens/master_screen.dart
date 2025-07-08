import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MasterScreen extends StatefulWidget {
  final String role;
  const MasterScreen({Key? key, required this.role}) : super(key: key);

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> reservations = [];
  List<Map<String, dynamic>> likes = [];
  Map<String, int> categoryCounts = {};

  static const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZwcnNwcWFqcWp4Y2dkc3dhd2hoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4NDczNDYsImV4cCI6MjA2NzQyMzM0Nn0.TO5qtptiYhr_DezGXap9IKi50M7U_nrGs_YL1fNg4gk';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);

    await fetchReservations();
    await fetchLikes();

    setState(() => isLoading = false);
  }

  Future<void> fetchReservations() async {
    print("🔷 [REQ] GET /reservations");
    try {
      final response =
          await http.get(Uri.parse('http://127.0.0.1:8080/reservations'));

      print("📥 [RES] ${response.statusCode} ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final List<Map<String, dynamic>> filtered = data
            .where((r) => r['place']
                .toString()
                .toLowerCase()
                .replaceAll(' ', '') == 'nailstudio')
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        setState(() {
          reservations = filtered;
        });
      } else {
        print("❌ 예약 조회 실패: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ 예약 조회 실패: $e");
    }
  }

  Future<void> fetchLikes() async {
    print("🔷 [REQ] GET /generate-weekly-report-ts");
    try {
      final likesRes = await http.get(
        Uri.parse(
            'https://vprspqajqjxcgdswawhh.supabase.co/functions/v1/generate-weekly-report-ts'),
        headers: {
          'Authorization': 'Bearer $supabaseAnonKey',
        },
      );

      print("📥 [RES] ${likesRes.statusCode} ${likesRes.body}");

      if (likesRes.statusCode != 200) return;

      final List<dynamic> likeData = json.decode(likesRes.body);

      final photosRes = await http.get(
        Uri.parse(
            'https://vprspqajqjxcgdswawhh.supabase.co/rest/v1/photos?select=id,designer,image_path'),
        headers: {
          'apikey': supabaseAnonKey,
          'Authorization': 'Bearer $supabaseAnonKey',
        },
      );

      print("📥 [RES] photos ${photosRes.statusCode} ${photosRes.body}");

      if (photosRes.statusCode != 200) return;

      final List<dynamic> photos = json.decode(photosRes.body);

      final idToPhoto = {
        for (var p in photos) p['id']: p,
      };

      List<Map<String, dynamic>> nailstudioLikes = [];
      Map<String, int> catCounts = {};

      for (var like in likeData) {
        final photo = idToPhoto[like['photo_id']];
        if (photo != null &&
            photo['designer'].toString().toLowerCase() == 'nailstudio') {
          nailstudioLikes.add({
            ...like,
            'image_path': photo['image_path'],
          });

          final imagePath = photo['image_path'];
          final category = imagePath.split('/').last.split(RegExp(r'[0-9.]'))[0];
          catCounts[category] = (catCounts[category] ?? 0) + 1;
        }
      }

      setState(() {
        likes = nailstudioLikes;
        categoryCounts = catCounts;
      });
    } catch (e) {
      print("❌ 좋아요 조회 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관리자 - nailstudio 내역'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📅 예약 내역 (${reservations.length})',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...reservations.map((r) => Card(
                          child: ListTile(
                            title: Text('예약자: ${r['user']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('시간: ${r['time']}'),
                                Text('서비스: ${r['service']}'),
                              ],
                            ),
                          ),
                        )),
                    const SizedBox(height: 24),
                    Text(
                      '❤️ 좋아요 내역 (${likes.length})',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: likes.map((like) {
                        final imgPath =
                            'https://vprspqajqjxcgdswawhh.supabase.co/storage/v1/object/public/${like['image_path']}';
                        return SizedBox(
                          width: 120,
                          child: Column(
                            children: [
                              Image.network(
                                imgPath,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                              Text(
                                like['photo_id'].toString().substring(0, 8),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '📊 카테고리별 좋아요 수',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...categoryCounts.entries.map((e) => ListTile(
                          title: Text(e.key),
                          trailing: Text('${e.value}개'),
                        )),
                  ],
                ),
              ),
            ),
    );
  }
}
