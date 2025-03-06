import 'dart:convert';

import 'package:aplikasi_lkbh_unmul/Screen/User/News/Model/news_response.dart';
import 'package:http/http.dart' as http;

class ApiCaller {
  final String url = "https://berita-indo-api-next.vercel.app/api/antara-news/politik";

  Future<NewsResponse> fetchNews() async {
  final response = await http.get(Uri.parse(url));
  
  if (response.statusCode == 200) {
    return NewsResponse.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to fetch news");
  }
}
}