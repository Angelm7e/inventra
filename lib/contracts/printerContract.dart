import 'package:inventra/models/printerDevice.dart';

abstract class PrinterContract {
  Future<List<PrinterDevice>> loadPrinters();
  Future<int> addPrinter(PrinterDevice printer);
  Future<int> removePrinter(String id);
  Future<int> updatePrinter(PrinterDevice printer);
  Future<PrinterDevice?> getPrinterById(String id);
  Future<PrinterDevice?> getPrinterByName(String name);
}
