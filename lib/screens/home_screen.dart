// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:crypto_app/models/cryptocurrency.dart';
import 'package:crypto_app/screens/crypto_detail_screen.dart';
import 'package:crypto_app/screens/wishlist_screen.dart';
import 'package:crypto_app/services/crypto_api_service.dart';
import 'package:crypto_app/widgets/crypto_list_tile.dart';
import 'package:crypto_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CryptoApiService _apiService = CryptoApiService();
  List<CryptoCurrency> _cryptocurrencies = [];
  bool _isLoading = false;
  String _sortBy = 'market_cap';
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _fetchCryptocurrencies();
  }

  Future<void> _fetchCryptocurrencies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cryptos = await _apiService.getTopCryptocurrencies();
      setState(() {
        _cryptocurrencies = cryptos;
        _isLoading = false;
      });
      _sortCryptocurrencies();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  void _sortCryptocurrencies() {
    setState(() {
      switch (_sortBy) {
        case 'name':
          _cryptocurrencies.sort((a, b) => _sortAscending
              ? a.name.compareTo(b.name)
              : b.name.compareTo(a.name));
          break;
        case 'price':
          _cryptocurrencies.sort((a, b) => _sortAscending
              ? a.currentPrice.compareTo(b.currentPrice)
              : b.currentPrice.compareTo(a.currentPrice));
          break;
        case 'change':
          _cryptocurrencies.sort((a, b) => _sortAscending
              ? a.priceChangePercentage24h.compareTo(b.priceChangePercentage24h)
              : b.priceChangePercentage24h.compareTo(a.priceChangePercentage24h));
          break;
        case 'market_cap':
        default:
          _cryptocurrencies.sort((a, b) => _sortAscending
              ? a.marketCap.compareTo(b.marketCap)
              : b.marketCap.compareTo(a.marketCap));
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
        final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto App'),
        actions: [
          // Theme toggle button
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.of(context).pushNamed(WishlistScreen.routeName);
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              if (value == _sortBy) {
                setState(() {
                  _sortAscending = !_sortAscending;
                });
              } else {
                setState(() {
                  _sortBy = value;
                });
              }
              _sortCryptocurrencies();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'market_cap',
                child: Text('Sort by Market Cap'),
              ),
              const PopupMenuItem(
                value: 'name',
                child: Text('Sort by Name'),
              ),
              const PopupMenuItem(
                value: 'price',
                child: Text('Sort by Price'),
              ),
              const PopupMenuItem(
                value: 'change',
                child: Text('Sort by 24h Change'),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCryptocurrencies,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _cryptocurrencies.isEmpty
                ? const Center(child: Text('No cryptocurrencies found'))
                : ListView.builder(
                    itemCount: _cryptocurrencies.length,
                    itemBuilder: (context, index) {
                      final crypto = _cryptocurrencies[index];
                      return CryptoListTile(
                        crypto: crypto,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CryptoDetailScreen(
                                crypto: crypto,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
      ),
    );
  }
}