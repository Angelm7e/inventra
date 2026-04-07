import 'package:flutter/material.dart';
import 'package:inventra/models/product.model.dart';
import 'package:inventra/models/quoteItem.dart';

/// Carrito de facturación (venta). Independiente de [QuoteProvider] (cotización).
class BillingProvider with ChangeNotifier {
  final List<QuoteItem> _billingItems = [];

  List<QuoteItem> get billingItems => List.unmodifiable(_billingItems);

  int get totalQuantity =>
      _billingItems.fold<int>(0, (sum, e) => sum + e.quantity);

  int _quantityInCartForProduct(int? productId) {
    if (productId == null) return 0;
    return _billingItems
        .where((e) => e.product.id == productId)
        .fold<int>(0, (s, e) => s + e.quantity);
  }

  /// Stock disponible para seguir agregando este producto al carrito de factura.
  int availableToAdd(Product product) {
    final inCart = _quantityInCartForProduct(product.id);
    return (product.quantity - inCart).clamp(0, 1 << 30);
  }

  void addToBilling(Product product, {int quantity = 1}) {
    final canAdd = availableToAdd(product);
    if (canAdd <= 0) return;
    final q = quantity.clamp(1, canAdd);
    final i = _billingItems.indexWhere((e) => e.product.id == product.id);
    if (i >= 0) {
      _billingItems[i] = _billingItems[i].copyWith(
        quantity: _billingItems[i].quantity + q,
      );
    } else {
      _billingItems.add(
        QuoteItem(
          product: product,
          quantity: q,
          subtotal: product.price * q,
        ),
      );
    }
    notifyListeners();
  }

  void updateQuantity(QuoteItem item, int quantity) {
    if (quantity <= 0) {
      _billingItems.removeWhere((e) => e.product.id == item.product.id);
      notifyListeners();
      return;
    }
    final maxQty = item.product.quantity;
    final q = quantity.clamp(1, maxQty);
    final i = _billingItems.indexWhere((e) => e.product.id == item.product.id);
    if (i >= 0) {
      _billingItems[i] = item.copyWith(quantity: q);
    }
    notifyListeners();
  }

  void removeFromBilling(QuoteItem item) {
    _billingItems.removeWhere((e) => e.product.id == item.product.id);
    notifyListeners();
  }

  void clearBilling() {
    _billingItems.clear();
    notifyListeners();
  }
}
