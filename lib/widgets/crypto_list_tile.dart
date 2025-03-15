// lib/widgets/crypto_list_tile.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_app/models/cryptocurrency.dart';
import 'package:crypto_app/providers/wishlist_provider.dart';

class CryptoListTile extends StatelessWidget {
  final CryptoCurrency crypto;
  final Function()? onTap;

  const CryptoListTile({
    Key? key,
    required this.crypto,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final bool isInWishlist = wishlistProvider.isInWishlist(crypto);

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundImage: NetworkImage(crypto.image),
      ),
      title: Text(crypto.name),
      subtitle: Text(crypto.symbol.toUpperCase()),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${crypto.currentPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${crypto.priceChangePercentage24h >= 0 ? '+' : ''}${crypto.priceChangePercentage24h.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: crypto.priceChangePercentage24h >= 0
                      ? Colors.green
                      : Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: isInWishlist ? Colors.red : Colors.grey,
            ),
            onPressed: () {
              wishlistProvider.toggleWishlist(crypto);
            },
          ),
        ],
      ),
    );
  }
}