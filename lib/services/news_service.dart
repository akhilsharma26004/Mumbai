import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/article_model.dart';

class NewsService {
  static const _apiKey = 'b9049acb7ae6460f83a7f8f602820a40';

  static Future<List<Article>> fetchTopHeadlines() async {
    const url = 'https://newsapi.org/v2/top-headlines?country=in&apiKey=$_apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final articles = jsonData['articles'] as List;
      return articles.map((json) => Article.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load top headlines');
    }
  }

  static Future<List<Article>> fetchTeslaNews() async {
    final url =
        'https://newsapi.org/v2/everything?q=tesla&from=2025-05-17&sortBy=publishedAt&apiKey=$_apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final articles = jsonData['articles'] as List;
      return articles.map((json) => Article.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load Tesla news');
    }
  }
}
