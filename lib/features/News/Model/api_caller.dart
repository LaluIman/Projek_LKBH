import 'dart:convert';
import 'package:aplikasi_lkbh_unmul/features/News/Model/news_response.dart';
import 'package:http/http.dart' as http;

class ApiCaller {
  final String url = "https://berita-indo-api-next.vercel.app/api/antara-news/hukum";
  
  static NewsResponse? _cachedNews;
  static DateTime? _lastFetchTime;
  static const cacheDuration = Duration(minutes: 5);
  
  static final ApiCaller _instance = ApiCaller._internal();
  
  factory ApiCaller() {
    return _instance;
  }
  
  ApiCaller._internal();

  Future<NewsResponse> fetchNews() async {
    if (_cachedNews != null && _lastFetchTime != null) {
      final difference = DateTime.now().difference(_lastFetchTime!);
      if (difference < cacheDuration) {
        return _cachedNews!;
      }
    }
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        _cachedNews = NewsResponse.fromJson(jsonDecode(response.body));
        _lastFetchTime = DateTime.now();
        return _cachedNews!;
      } else {
        if (_cachedNews != null) {
          return _cachedNews!;
        }
        throw Exception("Failed to fetch news: ${response.statusCode}");
      }
    } catch (e) {
      if (_cachedNews != null) {
        return _cachedNews!;
      }
      throw Exception("Network error: $e");
    }
  }
}