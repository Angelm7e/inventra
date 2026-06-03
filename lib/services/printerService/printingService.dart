import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:inventra/models/invoice_line.dart';
import 'package:inventra/services/dataBaseHelper.dart';

class PrintingService {
  final String ip;
  final int port;

  PrintingService({required this.ip, this.port = 9100});

  Future<NetworkPrinter?> _connect() async {
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(PaperSize.mm80, profile);

    final result = await printer.connect(ip, port: port);

    if (result != PosPrintResult.success) {
      debugPrint("Error conectando: $result");
      return null;
    }

    return printer;
  }

  Future<bool> printInvoice(List<InvoiceLine> lines) async {
    if (lines.isEmpty) return false;

    final printer = await _connect();
    if (printer == null) return false;

    final settings = await DatabaseHelper.instance.getBusinessSettings();
    _printHeader(printer, settings);
    _printBody(printer, lines);
    _printFooter(printer);

    printer.cut();
    printer.disconnect();
    return true;
  }

  // Invoice header with business info
  void _printHeader(NetworkPrinter printer, Map<String, dynamic> settings) {
    final businessName = _setting(settings, 'name', fallback: 'Mi negocio');
    final taxId = _setting(settings, 'tax_id');
    final address = _setting(settings, 'address');
    final phone = _setting(settings, 'phone');

    printer.text(
      businessName,
      styles: PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    if (taxId.isNotEmpty) {
      printer.text("RNC: $taxId", styles: PosStyles(align: PosAlign.center));
    }
    if (address.isNotEmpty) {
      printer.text(address, styles: PosStyles(align: PosAlign.center));
    }
    if (phone.isNotEmpty) {
      printer.text("Tel: $phone", styles: PosStyles(align: PosAlign.center));
    }

    printer.hr();
  }

  String _setting(
    Map<String, dynamic> settings,
    String key, {
    String fallback = '',
  }) {
    final value = settings[key]?.toString().trim() ?? '';
    return value.isEmpty ? fallback : value;
  }

  // All of this will be dynamic base on the items and the bussines confi

  // Invoice body with items, quantities, prices, and totals
  void _printBody(NetworkPrinter printer, List<InvoiceLine> lines) {
    double total = 0;

    printer.row([
      PosColumn(text: 'Producto', width: 5, styles: PosStyles(bold: true)),
      PosColumn(
        text: 'Precio',
        width: 2,
        styles: PosStyles(align: PosAlign.right, bold: true),
      ),
      PosColumn(
        text: 'Cant',
        width: 2,
        styles: PosStyles(align: PosAlign.right, bold: true),
      ),
      PosColumn(
        text: 'Total',
        width: 3,
        styles: PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);

    for (final line in lines) {
      final subtotal = line.lineSubtotal.toDouble();
      total += subtotal;

      final name = line.productName.length > 20
          ? '${line.productName.substring(0, 17)}...'
          : line.productName;

      printer.row([
        PosColumn(text: name, width: 5),
        PosColumn(
          text: _money(line.unitPrice),
          width: 2,
          styles: PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: 'x${line.quantity}',
          width: 2,
          styles: PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: _money(subtotal),
          width: 3,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    printer.hr();

    printer.row([
      PosColumn(text: 'TOTAL', width: 6, styles: PosStyles(bold: true)),
      PosColumn(
        text: _money(total),
        width: 6,
        styles: PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);
  }

  String _money(num value) => value.toStringAsFixed(2);

  // Invoice footer with thank you message and date/time
  void _printFooter(NetworkPrinter printer) {
    printer.hr();

    printer.text(
      "Gracias por su compra",
      styles: PosStyles(align: PosAlign.center),
    );

    printer.text(
      "Fecha: ${DateTime.now().toString().split(' ')[0]}",
      styles: PosStyles(align: PosAlign.center),
    );
  }
}
