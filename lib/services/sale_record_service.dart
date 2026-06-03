import 'package:inventra/models/quoteItem.dart';
import 'package:inventra/models/sale_record.dart';
import 'package:inventra/services/dataBaseHelper.dart';
import 'package:sqflite/sqflite.dart';

class SaleRecordService {
  final dbHelper = DatabaseHelper.instance;
  final String table = 'sale_records';

  Future<List<SaleRecord>> getAllSales() async {
    final db = await dbHelper.database;
    final result = await db.query(table, orderBy: 'sold_at DESC, id DESC');
    return result.map((e) => SaleRecord.fromMap(e)).toList();
  }

  Future<void> addSaleRecordsFromItems(List<QuoteItem> items) async {
    if (items.isEmpty) return;

    final db = await dbHelper.database;
    final soldAt = DateTime.now();

    await db.transaction((txn) async {
      for (final item in items) {
        final record = SaleRecord(
          productId: item.product.id,
          productName: item.product.name,
          soldAt: soldAt,
          unitPrice: item.product.price,
          quantity: item.quantity,
        );

        await txn.insert(
          table,
          record.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }
    });
  }
}
