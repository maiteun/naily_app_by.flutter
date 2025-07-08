import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

/// [GET] /instagram_posts?handle=username
Future<Response> onRequest(RequestContext context) async {
  final handle = context.request.uri.queryParameters['handle'];

  if (handle == null || handle.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Missing Instagram handle'},
    );
  }

  try {
    final url = Uri.parse('https://www.instagram.com/$handle/');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      return Response.json(
        statusCode: 500,
        body: {'error': 'Failed to fetch Instagram page'},
      );
    }

    final document = parse(response.body);
    final scripts = document.getElementsByTagName('script');

    final scriptTag = scripts.firstWhere(
      (s) => s.text.contains('window._sharedData'),
      orElse: () => throw Exception('Could not find shared data script'),
    );

    final scriptText = scriptTag.text.replaceFirst('window._sharedData = ', '').replaceAll(';', '');
    final sharedData = json.decode(scriptText);
    final edges = sharedData['entry_data']['ProfilePage'][0]['graphql']['user']['edge_owner_to_timeline_media']['edges'];

    final imageUrls = edges.take(4).map((e) => e['node']['display_url']).toList();

    return Response.json(
      body: {'images': imageUrls},
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Failed to extract image URLs', 'details': e.toString()},
    );
  }
}
