import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart';


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

  final TextEditingController shopIdController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController serviceController = TextEditingController();

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
    try {
      final response =
          await http.get(Uri.parse('http://127.0.0.1:8080/reservations'));

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
      }
    } catch (e) {
      print("❌ 예약 조회 실패: $e");
    }
  }

  Future<void> fetchLikes() async {
    try {
      final likesRes = await http.get(
        Uri.parse(
            'https://vprspqajqjxcgdswawhh.supabase.co/functions/v1/generate-weekly-report-ts'),
        headers: {
          'Authorization': 'Bearer $supabaseAnonKey',
        },
      );

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
      print(" 좋아요 조회 실패: $e");
    }
  }

  Future<void> sendEmail(Map<String, dynamic> reservation) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8080/send_email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'to': 'yesje1@khu.ac.kr',
        'subject': 'Your nail reservation is confirmed',
        'body':
            'Dear ${reservation['user']}, your reservation at ${reservation['place']} on ${reservation['time']} for ${reservation['service']} has been confirmed.',
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Email sent")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: ${response.body}")),
      );
    }
  }

  Future<void> cancelReservation(Map<String, dynamic> reservation) async {
    final response = await http.delete(
      Uri.parse('http://127.0.0.1:8080/reservations'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user': reservation['user'],
        'place': reservation['place'],
        'time': reservation['time'],
        'service': reservation['service'],
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservation Canceled.')),
      );
      fetchReservations();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cancellation Failed : ${response.body}')),
      );
    }
  }

  Future<void> addAvailableTime() async {
    final shopId = int.tryParse(shopIdController.text.trim());
    final time = timeController.text.trim();
    final service = serviceController.text.trim();
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8080/available_times'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'shop_id': shopId,
        'time': time,
        'service': service,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예약 가능 시간이 추가되었습니다.')),
      );
      shopIdController.clear();
      timeController.clear();
      serviceController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('추가 실패: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADMIN PAGE☑️ - nailstudio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'logout',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          )
        ],
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
                      'RESERVATION LIST (${reservations.length})',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...reservations.map((r) => Card(
                          child: ListTile(
                            title: Text('client: ${r['user']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('TIME: ${r['time']}'),
                                Text('SERVICE: ${r['service']}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check,
                                      color: Colors.green),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("✅ 확인되었습니다.")),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.mail,
                                      color: Colors.blue),
                                  onPressed: () {
                                    sendEmail(r);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel,
                                      color: Colors.red),
                                  onPressed: () {
                                    cancelReservation(r);
                                  },
                                ),
                              ],
                            ),
                          ),
                        )),
                    const SizedBox(height: 24),
                    Text(
                      'LIKED LIST (${likes.length})',
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
                        final imagePath = like['image_path'] as String;
                        final fileName = imagePath
                            .split('/')
                            .last
                            .replaceAll('.jpg', '')
                            .replaceAll('.png', '');

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
                                fileName,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'LIKED REPORT',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...categoryCounts.entries.map((e) => ListTile(
                          title: Text(e.key),
                          trailing: Text('${e.value}개'),
                        )),
                    const SizedBox(height: 24),
                    const Divider(),
                    const Text(
                      'ADD AVAILABLE TIME➕',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: shopIdController,
                      decoration: const InputDecoration(
                        labelText: 'Shop ID',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: timeController,
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: serviceController,
                      decoration: const InputDecoration(
                        labelText: 'Service',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: addAvailableTime,
                      child: const Text('ADD'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

