import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

class PrintingService {
  final String ip;
  final int port;

  PrintingService({required this.ip, this.port = 9100});

  Future<NetworkPrinter?> _connect() async {
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(PaperSize.mm80, profile);

    final result = await printer.connect(ip, port: port);

    if (result != PosPrintResult.success) {
      print("Error conectando: $result");
      return null;
    }

    return printer;
  }

  /// Devuelve `false` si no se pudo conectar a la impresora.
  Future<bool> printInvoice(List<Map<String, dynamic>> items) async {
    final printer = await _connect();
    if (printer == null) return false;

    _printHeader(printer);
    _printBody(printer, items);
    _printFooter(printer);

    printer.cut();
    printer.disconnect();
    return true;
  }

  // Invoice header with business info
  void _printHeader(NetworkPrinter printer) {
    printer.text(
      "MI NEGOCIO SRL",
      styles: PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    printer.text("RNC: 123456789", styles: PosStyles(align: PosAlign.center));
    printer.text(
      "Tel: 809-000-0000",
      styles: PosStyles(align: PosAlign.center),
    );

    printer.hr();
  }

  // All of this will be dynamic base on the items and the bussines confi

  // Invoice body with items, quantities, prices, and totals
  void _printBody(NetworkPrinter printer, List<Map<String, dynamic>> items) {
    double total = 0;

    for (var item in items) {
      final name = item['name'];
      final qty = item['quantity'];
      final price = item['price'];
      final subtotal = qty * price;

      total += subtotal;

      printer.row([
        PosColumn(text: name, width: 6),
        PosColumn(
          text: "x$qty",
          width: 2,
          styles: PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: subtotal.toStringAsFixed(2),
          width: 4,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    printer.hr();

    printer.row([
      PosColumn(text: "TOTAL", width: 6, styles: PosStyles(bold: true)),
      PosColumn(
        text: total.toStringAsFixed(2),
        width: 6,
        styles: PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);
  }

  // Invoice footer with thank you message and date/time
  void _printFooter(NetworkPrinter printer) {
    printer.hr();

    printer.text(
      "Gracias por su compra",
      styles: PosStyles(align: PosAlign.center),
    );

    printer.text(
      DateTime.now().toString(),
      styles: PosStyles(align: PosAlign.center),
    );
  }
}
