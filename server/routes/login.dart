// import 'dart:convert';
// import 'package:dart_frog/dart_frog.dart';
// import 'package:sqlite3/sqlite3.dart';

// // DB 연결
// final db = sqlite3.open('myapp_fixed.db');

// Future<Response> onRequest(RequestContext context) async {
//   // CORS 프리플라이트(OPTIONS) 요청 처리
//   if (context.request.method == HttpMethod.options) {
//     return Response(
//       statusCode: 204,
//       headers: {
//         'Access-Control-Allow-Origin': '*',
//         'Access-Control-Allow-Methods': 'POST, OPTIONS',
//         'Access-Control-Allow-Headers': 'Content-Type',
//       },
//     );
//   }

//   // 요청 body 읽기
//   final body = await context.request.body();
//   final data = jsonDecode(body);

//   final username = data['username'];
//   final password = data['password'];

//   // DB 조회
//   final stmt = db.prepare(
//     'SELECT role FROM users WHERE username = ? AND password = ?'
//   );

//   final result = stmt.select([username, password]);
//   stmt.dispose();

//   if (result.isEmpty) {
//     return Response.json(
//       body: {'status': 'fail'},
//       statusCode: 401,
//       headers: {
//         'Access-Control-Allow-Origin': '*',
//       },
//     );
//   }

//   final role = result.first['role'] as String;

//   return Response.json(
//     body: {
//       'status': 'success',
//       'role': role,
//     },
//     headers: {
//       'Access-Control-Allow-Origin': '*',
//     },
//   );
// }