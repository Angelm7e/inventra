import 'package:inventra/contracts/printerContract.dart';
import 'package:inventra/models/printerDevice.dart';
import 'package:inventra/services/dataBaseHelper.dart';

class PrinterService implements PrinterContract {
  final dbHelper = DatabaseHelper.instance;
  final String table = "printers";

  @override
  Future<List<PrinterDevice>> loadPrinters() async {
    final db = await dbHelper.database;

    final result = await db.query(table, orderBy: 'name');

    return result.map((e) => PrinterDevice.fromMap(e)).toList();
  }

  @override
  Future<int> addPrinter(PrinterDevice printer) async {
    try {
      final db = await dbHelper.database;

      final existing = await getPrinterByName(printer.name);
      if (existing != null) return -2;

      final result = await db.insert(table, printer.toMap());
      if (result > 0) {
        return result;
      }
      return -1;
    } catch (e) {
      return -1;
    }
  }

  @override
  Future<int> removePrinter(String id) async {
    final db = await dbHelper.database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<int> updatePrinter(PrinterDevice printer) async {
    try {
      final db = await dbHelper.database;

      final existing = await getPrinterByName(printer.name);
      if (existing != null && existing.id != printer.id) return -2;

      final result = await db.update(
        table,
        printer.toMap(),
        where: 'id = ?',
        whereArgs: [printer.id],
      );
      if (result > 0) {
        return result;
      }
      return -1;
    } catch (e) {
      return -1;
    }
  }

  @override
  Future<PrinterDevice?> getPrinterById(String id) async {
    final db = await dbHelper.database;
    final result = await db.query(table, where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? PrinterDevice.fromMap(result.first) : null;
  }

  @override
  Future<PrinterDevice?> getPrinterByName(String name) async {
    final db = await dbHelper.database;
    final result = await db.query(table, where: 'name = ?', whereArgs: [name]);
    return result.isNotEmpty ? PrinterDevice.fromMap(result.first) : null;
  }
}
