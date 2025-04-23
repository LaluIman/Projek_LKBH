import 'dart:convert';
import 'package:aplikasi_lkbh_unmul/Screen/News/Model/news_response.dart';
import 'package:http/http.dart' as http;

class ApiCaller {
  final String url = "https://berita-indo-api-next.vercel.app/api/antara-news/politik";
  
  // Static cache variables
  static NewsResponse? _cachedNews;
  static DateTime? _lastFetchTime;
  static const cacheDuration = Duration(minutes: 5);
  
  // Singleton pattern to ensure only one instance exists
  static final ApiCaller _instance = ApiCaller._internal();
  
  factory ApiCaller() {
    return _instance;
  }
  
  ApiCaller._internal();

  Future<NewsResponse> fetchNews() async {
    // Check if we have valid cached data
    if (_cachedNews != null && _lastFetchTime != null) {
      final difference = DateTime.now().difference(_lastFetchTime!);
      if (difference < cacheDuration) {
        // Return cached data if it's still fresh
        return _cachedNews!;
      }
    }
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        // Parse and cache the response
        _cachedNews = NewsResponse.fromJson(jsonDecode(response.body));
        _lastFetchTime = DateTime.now();
        return _cachedNews!;
      } else {
        // If API call fails but we have cached data, return it
        if (_cachedNews != null) {
          return _cachedNews!;
        }
        throw Exception("Failed to fetch news: ${response.statusCode}");
      }
    } catch (e) {
      // If error occurs but we have cached data, return it
      if (_cachedNews != null) {
        return _cachedNews!;
      }
      throw Exception("Network error: $e");
    }
  }
}