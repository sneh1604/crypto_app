// lib/screens/crypto_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_app/models/cryptocurrency.dart';
import 'package:crypto_app/providers/wishlist_provider.dart';
import 'package:crypto_app/widgets/price_chart_widget.dart';
import 'package:crypto_app/services/crypto_api_service.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class CryptoDetailScreen extends StatefulWidget {
  final CryptoCurrency crypto;

  const CryptoDetailScreen({
    Key? key,
    required this.crypto,
  }) : super(key: key);

  @override
  State<CryptoDetailScreen> createState() => _CryptoDetailScreenState();
}

class _CryptoDetailScreenState extends State<CryptoDetailScreen> {
  final CryptoApiService _apiService = CryptoApiService();
  bool _isLoading = true;
  Map<String, dynamic> _cryptoDetails = {};

  @override
  void initState() {
    super.initState();
    _fetchCryptoDetails();
  }

  Future<void> _fetchCryptoDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final details = await _apiService.getCryptoDetails(widget.crypto.id);
      setState(() {
        _cryptoDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching details: $e')),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final isInWishlist = wishlistProvider.isInWishlist(widget.crypto);
    
    // Determine the color based on price change
    final bool isPositive = widget.crypto.priceChangePercentage24h >= 0;
    final Color priceColor = isPositive ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(widget.crypto.image),
            ),
            const SizedBox(width: 8),
            Text(widget.crypto.name),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: isInWishlist ? Colors.red : null,
            ),
            onPressed: () {
              wishlistProvider.toggleWishlist(widget.crypto);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchCryptoDetails,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price Header
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${widget.crypto.currentPrice.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                isPositive
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: priceColor,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${isPositive ? '+' : ''}${widget.crypto.priceChangePercentage24h.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  color: priceColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(' (24h)'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Price Chart
                    PriceChartWidget(
                      cryptoId: widget.crypto.id,
                      lineColor: priceColor,
                    ),
                    
                    // Market Data
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Market Data',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          _buildMarketDataRow(
                            'Market Cap',
                            '\$${NumberFormat.compact().format(widget.crypto.marketCap)}',
                          ),
                          _buildMarketDataRow(
                            '24h Volume',
                            '\$${NumberFormat.compact().format(widget.crypto.totalVolume)}',
                          ),
                          _buildMarketDataRow(
                            'Circulating Supply',
                            '${NumberFormat.compact().format(widget.crypto.circulatingSupply)} ${widget.crypto.symbol.toUpperCase()}',
                          ),
                          if (widget.crypto.totalSupply != null)
                            _buildMarketDataRow(
                              'Total Supply',
                              '${NumberFormat.compact().format(widget.crypto.totalSupply)} ${widget.crypto.symbol.toUpperCase()}',
                            ),
                          _buildMarketDataRow(
                            'All-Time High',
                            '\$${_cryptoDetails['market_data']?['ath']?['usd']?.toStringAsFixed(2) ?? 'N/A'}',
                          ),
                        ],
                      ),
                    ),
                    
                    // Additional Info
                    if (_cryptoDetails['description']?['en'] != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'About ${widget.crypto.name}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _cryptoDetails['description']['en'],
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 10,
                              overflow: TextOverflow.ellipsis,
                            ),
                            TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('About ${widget.crypto.name}'),
                                    content: SingleChildScrollView(
                                      child: Text(_cryptoDetails['description']['en']),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text('Read More'),
                            ),
                          ],
                        ),
                      ),
                    
                    // Links and Resources
                    if (_cryptoDetails['links'] != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Links and Resources',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            if (_cryptoDetails['links']['homepage'][0] != '')
                              _buildLinkRow(
                                'Website',
                                _cryptoDetails['links']['homepage'][0],
                                Icons.language,
                              ),
                            if (_cryptoDetails['links']['blockchain_site'][0] != '')
                              _buildLinkRow(
                                'Explorer',
                                _cryptoDetails['links']['blockchain_site'][0],
                                Icons.explore,
                              ),
                            if (_cryptoDetails['links']['subreddit_url'] != '')
                              _buildLinkRow(
                                'Reddit',
                                _cryptoDetails['links']['subreddit_url'],
                                Icons.forum,
                              ),
                            if (_cryptoDetails['links']['repos_url']['github'].isNotEmpty)
                              _buildLinkRow(
                                'GitHub',
                                _cryptoDetails['links']['repos_url']['github'][0],
                                Icons.code,
                              ),
                          ],
                        ),
                      ),
                      
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMarketDataRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkRow(String title, String url, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(title),
          const Spacer(),
          TextButton(
            onPressed: () => _launchUrl(url),
            child: const Text('Visit'),
          ),
        ],
      ),
    );
  }
}