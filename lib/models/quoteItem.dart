import 'package:inventra/models/product.model.dart';

/// Item de la cotización: producto + cantidad
class QuoteItem {
  final Product product;
  final int quantity;

  const QuoteItem({
    required this.product,
    required this.quantity,
    required int subtotal,
  });

  int get subtotal => product.price * quantity;

  QuoteItem copyWith({int? quantity}) => QuoteItem(
    product: product,
    quantity: quantity ?? this.quantity,
    subtotal: subtotal,
  );
}
