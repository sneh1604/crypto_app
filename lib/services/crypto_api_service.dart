// lib/services/crypto_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto_app/models/cryptocurrency.dart';

class CryptoApiService {
  static const String baseUrl = 'https://api.coingecko.com/api/v3';

  Future<List<CryptoCurrency>> getTopCryptocurrencies() async {
    final response = await http.get(
      Uri.parse('$baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => CryptoCurrency.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load cryptocurrencies');
    }
  }

  Future<Map<String, dynamic>> getCryptoDetails(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/coins/$id?localization=false&tickers=false&market_data=true&community_data=true&developer_data=false&sparkline=false'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load cryptocurrency details');
    }
  }

  Future<List<List<dynamic>>> getHistoricalMarketData(
      String id, int days) async {
    final response = await http.get(
      Uri.parse('$baseUrl/coins/$id/market_chart?vs_currency=usd&days=$days'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<List<dynamic>>.from(data['prices']);
    } else {
      throw Exception('Failed to load historical data');
    }
  }
}