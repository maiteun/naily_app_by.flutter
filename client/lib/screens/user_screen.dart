import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../photo/photo.dart';
import '../photo/photo_db.dart';
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
  Set<String> likedPhotos = {}; // ❤️ 상태 저장

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
    _loadLikedPhotos();
  }

  Future<void> _loadLikedPhotos() async {
    final liked = await fetchLikedPhotos(); // user_id 기반 좋아요 목록
    setState(() {
      likedPhotos = liked.toSet();
    });
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
                        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                _galleryFromSupabase('wedding'),
                _galleryFromSupabase('summer'),
                _galleryFromSupabase('kits'),
                _galleryFromSupabase('one'),
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
          backgroundColor: isSelected ? Colors.blueGrey : color.withOpacity(0.2),
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

  Widget _galleryFromSupabase(String category) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchPhotos(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final maps = snapshot.data!;
        final photos = maps.map((e) => Photo.fromMap(e)).toList();

        final filtered = photos.where((photo) {
          return photo.imageUrl.contains(category);
        }).toList();

        if (filtered.isEmpty) {
          return const Center(child: Text('No photos available.'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 3 / 2,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final photo = filtered[index];
            final isLiked = likedPhotos.contains(photo.id);

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
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DesignerPage(
                                  designerName: photo.author,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            photo.author,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.favorite,
                            color: isLiked ? Colors.red : Colors.grey,
                          ),
                          onPressed: () async {
                            setState(() {
                              if (isLiked) {
                                likedPhotos.remove(photo.id);
                              } else {
                                likedPhotos.add(photo.id);
                              }
                            });

                            if (isLiked) {
                              await deleteLike(photo.id);
                            } else {
                              await insertLike(photo.id);
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'reservation_page.dart';
// import 'designer_page.dart';

// class UserScreen extends StatefulWidget {
//   final String role;

//   const UserScreen({super.key, required this.role});

//   @override
//   State<UserScreen> createState() => _UserScreenState();
// }

// class _UserScreenState extends State<UserScreen> with TickerProviderStateMixin {
//   final LatLng center = LatLng(37.2479789, 127.0776135);

//   TabController? _tabController;

//   int? selectedShopIndex;

//   final List<Map<String, dynamic>> shops = [
//     {
//       'name': 'Nail Studio',
//       'color': Colors.purple,
//       'location': LatLng(37.2479789, 127.0776135)
//     },
//     {
//       'name': 'Nail shop1',
//       'color': Colors.red,
//       'location': LatLng(37.251, 127.081)
//     },
//     {
//       'name': 'Nail shop2',
//       'color': Colors.blue,
//       'location': LatLng(37.2475, 127.0725)
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_tabController == null) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Available Now'),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             SizedBox(
//               height: 300,
//               child: Row(
//                 children: [
//                   Expanded(
//                     flex: 2,
//                     child: FlutterMap(
//                       options: MapOptions(
//                         center: center,
//                         zoom: 15.0,
//                       ),
//                       children: [
//                         TileLayer(
//                           urlTemplate:
//                               'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
//                           subdomains: const ['a', 'b', 'c'],
//                         ),
//                         MarkerLayer(
//                           markers: shops.asMap().entries.map((entry) {
//                             final idx = entry.key;
//                             final shop = entry.value;
//                             return Marker(
//                               point: shop['location'],
//                               width: 40,
//                               height: 40,
//                               child: GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     selectedShopIndex = idx;
//                                   });
//                                 },
//                                 child:
//                                     Icon(Icons.store, color: shop['color']),
//                               ),
//                             );
//                           }).toList(),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     flex: 1,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: shops.asMap().entries.map((entry) {
//                         final idx = entry.key;
//                         final shop = entry.value;
//                         return _shopButton(
//                             idx, shop['name'], shop['color']);
//                       }).toList(),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               color: Colors.grey.shade100,
//               child: TabBar(
//                 controller: _tabController,
//                 labelColor: Colors.purple,
//                 unselectedLabelColor: Colors.black,
//                 tabs: const [
//                   Tab(text: 'Wedding Nails'),
//                   Tab(text: 'Summer Nails'),
//                   Tab(text: 'Kitsch Nails'),
//                   Tab(text: 'One color Nails'),
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: 500,
//               child: TabBarView(
//                 controller: _tabController,
//                 children: [
//                   _sampleGallery(),
//                   _sampleGallery(),
//                   _sampleGallery(),
//                   _sampleGallery(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _shopButton(int idx, String name, Color color) {
//     final isSelected = selectedShopIndex == idx;
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: OutlinedButton(
//         style: OutlinedButton.styleFrom(
//           backgroundColor:
//               isSelected ? Colors.blueGrey : color.withOpacity(0.2),
//           foregroundColor: Colors.black,
//         ),
//         onPressed: () {
//           if (isSelected) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => ReservationPage(
//                   shopId: idx + 1,
//                   shopName: name,
//                 ),
//               ),
//             );
//           } else {
//             setState(() {
//               selectedShopIndex = idx;
//             });
//           }
//         },
//         child: Text(name),
//       ),
//     );
//   }

//   Widget _sampleGallery() {
//   return FutureBuilder<List<Map<String, dynamic>>>(
//     future: fetchPhotos(),
//     builder: (context, snapshot) {
//       if (!snapshot.hasData) {
//         return const Center(child: CircularProgressIndicator());
//       }

//       final maps = snapshot.data!;
//       final photos = maps.map((e) => Photo.fromMap(e)).toList();

//       return GridView.builder(
//         padding: const EdgeInsets.all(12),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           mainAxisSpacing: 8,
//           crossAxisSpacing: 8,
//           childAspectRatio: 3 / 2,
//         ),
//         itemCount: photos.length,
//         itemBuilder: (context, index) {
//           final photo = photos[index];
//           return Card(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: Image.network(
//                     photo.imageUrl,
//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(photo.author,
//                       style: const TextStyle(fontWeight: FontWeight.bold)),
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     },
//   );
// }



// }
