class Sell {
  final String id;
  final String clientName;
  final double total;
  final int quantity;
  final List<String> items;
  final String createdAt;

  Sell({
    required this.id,
    required this.clientName,
    required this.total,
    required this.quantity,
    required this.items,
    required this.createdAt,
  });
}
