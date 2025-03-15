// lib/models/cryptocurrency.dart
class CryptoCurrency {
  final String id;
  final String symbol;
  final String name;
  final String image;
  final double currentPrice;
  final double marketCap;
  final int marketCapRank;
  final double totalVolume;
  final double priceChangePercentage24h;
  final double circulatingSupply;
  final double? totalSupply;
  final double? maxSupply;

  CryptoCurrency({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.marketCap,
    required this.marketCapRank,
    required this.totalVolume,
    required this.priceChangePercentage24h,
    required this.circulatingSupply,
    this.totalSupply,
    this.maxSupply,
  });

  factory CryptoCurrency.fromJson(Map<String, dynamic> json) {
    return CryptoCurrency(
      id: json['id'],
      symbol: json['symbol'],
      name: json['name'],
      image: json['image'],
      currentPrice: json['current_price'].toDouble(),
      marketCap: json['market_cap'].toDouble(),
      marketCapRank: json['market_cap_rank'],
      totalVolume: json['total_volume'].toDouble(),
      priceChangePercentage24h: json['price_change_percentage_24h'].toDouble(),
      circulatingSupply: json['circulating_supply'].toDouble(),
      totalSupply: json['total_supply']?.toDouble(),
      maxSupply: json['max_supply']?.toDouble(),
    );
  }
}