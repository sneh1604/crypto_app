// lib/providers/wishlist_provider.dart
import 'package:flutter/material.dart';
import 'package:crypto_app/models/cryptocurrency.dart';

class WishlistProvider extends ChangeNotifier {
  final List<CryptoCurrency> _wishlist = [];

  List<CryptoCurrency> get wishlist => _wishlist;

  bool isInWishlist(CryptoCurrency crypto) {
    return _wishlist.any((item) => item.id == crypto.id);
  }

  void addToWishlist(CryptoCurrency crypto) {
    if (!isInWishlist(crypto)) {
      _wishlist.add(crypto);
      notifyListeners();
    }
  }

  void removeFromWishlist(CryptoCurrency crypto) {
    _wishlist.removeWhere((item) => item.id == crypto.id);
    notifyListeners();
  }

  void toggleWishlist(CryptoCurrency crypto) {
    if (isInWishlist(crypto)) {
      removeFromWishlist(crypto);
    } else {
      addToWishlist(crypto);
    }
  }
}