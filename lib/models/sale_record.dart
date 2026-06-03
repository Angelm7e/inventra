class SaleRecord {
  final int? id;
  final int? productId;
  final String productName;
  final DateTime soldAt;
  final int unitPrice;
  final int quantity;

  const SaleRecord({
    this.id,
    this.productId,
    required this.productName,
    required this.soldAt,
    required this.unitPrice,
    required this.quantity,
  });

  int get total => unitPrice * quantity;

  factory SaleRecord.fromMap(Map<String, dynamic> json) => SaleRecord(
    id: json['id'],
    productId: json['product_id'],
    productName: json['product_name'],
    soldAt: DateTime.parse(json['sold_at']),
    unitPrice: json['unit_price'],
    quantity: json['quantity'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'product_id': productId,
    'product_name': productName,
    'sold_at': soldAt.toIso8601String(),
    'unit_price': unitPrice,
    'quantity': quantity,
  };
}
