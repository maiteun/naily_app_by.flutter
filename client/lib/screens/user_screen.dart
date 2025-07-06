import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'reservation_page.dart';
import 'designer_page.dart';

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 300,
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
                                child:
                                    Icon(Icons.store, color: shop['color']),
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
                        return _shopButton(
                            idx, shop['name'], shop['color']);
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
            SizedBox(
              height: 500,
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
      ),
    );
  }

  Widget _shopButton(int idx, String name, Color color) {
    final isSelected = selectedShopIndex == idx;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor:
              isSelected ? Colors.blueGrey : color.withOpacity(0.2),
          foregroundColor: Colors.black,
        ),
        onPressed: () {
          if (isSelected) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReservationPage(
                  shopId: idx + 1,
                  shopName: name,
                ),
              ),
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
    {'author': '@nailstudio'},
    {'author': '@nailshop1'},
    {'author': '@nailshop2'},
    {'author': '@nailshop3'},
  ];

  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.all(12),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 6,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1,
    ),
    itemCount: samples.length,
    itemBuilder: (context, index) {
      final item = samples[index];
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.orange.shade100,
                child: const Center(child: Icon(Icons.image, size: 40)),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DesignerPage(
                        author: item['author']!,
                      ),
                    ),
                  );
                },
                child: Text(
                  item['author']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    backgroundColor: Colors.white70,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}


}
