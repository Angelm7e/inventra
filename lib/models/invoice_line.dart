import 'package:inventra/models/quoteItem.dart';

/// Línea de venta unificada: sirve para impresión térmica, exportación y totales.
/// Se construye a partir de [QuoteItem] (carrito de facturación/cotización).
class InvoiceLine {
  final String productName;
  final int quantity;
  final int unitPrice;

  const InvoiceLine({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  int get lineSubtotal => unitPrice * quantity;

  factory InvoiceLine.fromQuoteItem(QuoteItem item) {
    return InvoiceLine(
      productName: item.product.name,
      quantity: item.quantity,
      unitPrice: item.product.price,
    );
  }

  static List<InvoiceLine> fromQuoteItems(List<QuoteItem> items) {
    return items.map(InvoiceLine.fromQuoteItem).toList();
  }
}
