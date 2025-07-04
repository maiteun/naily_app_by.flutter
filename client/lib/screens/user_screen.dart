import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class UserScreen extends StatefulWidget {
  final String role;

  const UserScreen({super.key, required this.role});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> with TickerProviderStateMixin {
  final LatLng center = LatLng(37.2479789, 127.0776135);

  TabController? _tabController;

  int? selectedShopIndex;

  final List<Map<String, dynamic>> shops = [
    {
      'name': 'Nail Studio',
      'color': Colors.purple,
      'location': LatLng(37.2479789, 127.0776135)
    },
    {
      'name': 'Nail shop1',
      'color': Colors.red,
      'location': LatLng(37.251, 127.081)
    },
    {
      'name': 'Nail shop2',
      'color': Colors.blue,
      'location': LatLng(37.2475, 127.0725)
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Now'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: FlutterMap(
                    options: MapOptions(
                      center: center,
                      zoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: shops.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final shop = entry.value;
                          return Marker(
                            point: shop['location'],
                            width: 40,
                            height: 40,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedShopIndex = idx;
                                });
                              },
                              child: Icon(Icons.store, color: shop['color']),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: shops.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final shop = entry.value;
                      return _shopButton(idx, shop['name'], shop['color']);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.grey.shade100,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.purple,
              unselectedLabelColor: Colors.black,
              tabs: const [
                Tab(text: 'Wedding Nails'),
                Tab(text: 'Summer Nails'),
                Tab(text: 'Kitsch Nails'),
                Tab(text: 'One color Nails'),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: TabBarView(
              controller: _tabController,
              children: [
                _sampleGallery(),
                _sampleGallery(),
                _sampleGallery(),
                _sampleGallery(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shopButton(int idx, String name, Color color) {
    final isSelected = selectedShopIndex == idx;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? Colors.white : color.withOpacity(0.2),
          foregroundColor: Colors.black,
        ),
        onPressed: () {
          if (isSelected) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$name 예약 페이지로 이동합니다')),
            );
          } else {
            setState(() {
              selectedShopIndex = idx;
            });
          }
        },
        child: Text(name),
      ),
    );
  }

  Widget _sampleGallery() {
    final samples = [
      {'name': 'Serenity Nails', 'rating': '4.8 (120 reviews)'},
      {'name': 'Glamour Nails', 'rating': '4.9 (150 reviews)'},
      {'name': 'Blissful Nails', 'rating': '4.7 (90 reviews)'},
      {'name': 'Chic Nails', 'rating': '4.6 (110 reviews)'},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 3 / 2,
      ),
      itemCount: samples.length,
      itemBuilder: (context, index) {
        final item = samples[index];
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  color: Colors.orange.shade100,
                  child: const Center(child: Icon(Icons.image, size: 40)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(item['rating']!),
              ),
            ],
          ),
        );
      },
    );
  }
}
