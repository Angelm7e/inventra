import 'package:flutter/material.dart';
import 'package:inventra/models/product.model.dart';
import 'package:inventra/models/quoteItem.dart';

class QuoteProvider with ChangeNotifier {
  final List<QuoteItem> _quoteItems = [];

  void _onAddToQuote(Product product, {int quantity = 1}) {
    final i = _quoteItems.indexWhere((e) => e.product.id == product.id);
    if (i >= 0) {
      _quoteItems[i] = _quoteItems[i].copyWith(
        quantity: _quoteItems[i].quantity + quantity,
      );
    } else {
      _quoteItems.add(
        QuoteItem(
          product: product,
          quantity: quantity,
          subtotal: product.price * quantity,
        ),
      );
    }
    notifyListeners();
  }

  void _onUpdateQuantity(QuoteItem item, int quantity) {
    if (quantity <= 0) {
      _quoteItems.removeWhere((e) => e.product.id == item.product.id);
      notifyListeners();
      return;
    }
    final i = _quoteItems.indexWhere((e) => e.product.id == item.product.id);
    if (i >= 0) _quoteItems[i] = item.copyWith(quantity: quantity);
    notifyListeners();
  }

  void _onRemoveFromQuote(QuoteItem item) {
    _quoteItems.removeWhere((e) => e.product.id == item.product.id);
    notifyListeners();
  }

  void _onQuoteCleared() {
    _quoteItems.clear();
    notifyListeners();
  }
}
