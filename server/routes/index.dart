import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response.json(body: {
    'message': '🌸 Nailshop API (Dart Frog) is running!',
    'endpoints': [
      '/login',
      '/shops',
      '/reservations'
    ]
  });
}
