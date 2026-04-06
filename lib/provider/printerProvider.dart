import 'package:flutter/material.dart';
import 'package:inventra/contracts/printerContract.dart';
import 'package:inventra/models/printerDevice.dart';

class PrinterProvider extends ChangeNotifier {
  PrinterContract _printerService;

  PrinterProvider(this._printerService);

  List<PrinterDevice> _printers = [];

  List<PrinterDevice> get printers => _printers;

  Future<List<PrinterDevice>> loadPrinters() async {
    _printers = await _printerService.loadPrinters();
    notifyListeners();
    return _printers;
  }

  Future<int> addPrinter(PrinterDevice printer) async {
    final response = await _printerService.addPrinter(printer);
    await loadPrinters();
    return response;
  }

  Future<int> removePrinter(String id) async {
    final response = await _printerService.removePrinter(id);
    await loadPrinters();
    return response;
  }

  Future<int> updatePrinter(PrinterDevice printer) async {
    final response = await _printerService.updatePrinter(printer);
    await loadPrinters();
    return response;
  }

  Future<PrinterDevice?> getPrinterById(String id) async {
    return await _printerService.getPrinterById(id);
  }

  Future<PrinterDevice?> getPrinterByName(String name) async {
    return await _printerService.getPrinterByName(name);
  }
}
