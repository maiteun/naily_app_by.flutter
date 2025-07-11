import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReservationPage extends StatefulWidget {
  final int shopId;
  final String shopName;

  const ReservationPage({super.key, required this.shopId, required this.shopName});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  List<Map<String, dynamic>> availableTimes = [];
  Map<String, dynamic>? selectedTime;

  @override
  void initState() {
    super.initState();
    fetchAvailableTimes();
  }

  Future<void> fetchAvailableTimes() async {
    final res = await http.get(Uri.parse('http://localhost:8080/shops'));
    if (res.statusCode == 200) {
      final shops = json.decode(res.body) as List;
      final shop = shops.firstWhere((s) => s['name'] == widget.shopName);
      setState(() {
        availableTimes = List<Map<String, dynamic>>.from(shop['availableTimes']);
      });
    }
  }

  Future<void> confirmReservation() async {
    if (selectedTime == null) return;

    final confirm = await showDialog<bool>(
      context: context,


      builder: (context) => AlertDialog(
        title: const Text('Reservation'),
        content: Text(
            '${selectedTime!['time']} - ${selectedTime!['service']} 예약하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('NO'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('YES'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await makeReservation();
    }
  }

  Future<void> makeReservation() async {
    final res = await http.post(
      Uri.parse('http://localhost:8080/reservations'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user': 'user', // 현재 로그인한 사용자 이름
        'place': widget.shopName,
        'time': selectedTime!['time'],
        'service': selectedTime!['service'],
      }),
    );

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('RESERVATION COMPLETED!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.shopName} Reservation'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            'Available Time Slots',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: availableTimes.length,
              itemBuilder: (context, index) {
                final time = availableTimes[index];
                final isSelected = selectedTime == time;
                return ListTile(
                  title: Text('${time['time']} - ${time['service']}'),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    setState(() {
                      selectedTime = time;
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: selectedTime != null ? confirmReservation : null,
              child: const Text('Reserve Now'),
            ),
          ),
        ],
      ),
    );
  }
}




