import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:inventra/models/invoice_line.dart';
import 'package:inventra/models/quoteItem.dart';
import 'package:inventra/services/dataBaseHelper.dart';
import 'package:inventra/utils/number_formatter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class QuotePdfService {
  static Future<Uint8List> loadAssetImage(String path) async {
    final ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  static List<Map<String, String>> _parseBankAccounts(dynamic raw) {
    if (raw == null) return [];

    try {
      if (raw is String && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded
              .whereType<Map<dynamic, dynamic>>()
              .map(
                (item) => item.map(
                  (key, value) =>
                      MapEntry(key.toString(), value?.toString() ?? ''),
                ),
              )
              .map((item) => item.cast<String, String>())
              .where(
                (item) =>
                    (item['bank'] ?? '').isNotEmpty &&
                    (item['account'] ?? '').isNotEmpty,
              )
              .toList();
        }
      }
    } catch (_) {}

    return [];
  }

  static Future<Uint8List> generateQuotePdfBytes(
    List<QuoteItem> items, {
    String? clientName,
  }) async {
    final lines = InvoiceLine.fromQuoteItems(items);

    final settings = await DatabaseHelper.instance.getBusinessSettings();
    final businessName = settings['name'] as String? ?? 'Mi negocio';
    final businessAddress = settings['address'] as String? ?? '';
    final businessPhone = settings['phone'] as String? ?? '';
    final logoPath = settings['logo_path'] as String?;
    final bankAccounts = _parseBankAccounts(
      settings['bank_accounts'],
    ).take(3).toList();

    final pdf = pw.Document();
    Uint8List logoBytes;
    if (logoPath != null && File(logoPath).existsSync()) {
      logoBytes = await File(logoPath).readAsBytes();
    } else {
      try {
        logoBytes = await loadAssetImage(
          'assets/branding/defaultProfileIMG.png',
        );
      } catch (_) {
        logoBytes = Uint8List(0);
      }
    }

    final data = lines
        .map(
          (e) => [
            e.productName,
            '${e.quantity}',
            NumberFormatter.currency(e.unitPrice.toDouble()),
            NumberFormatter.currency(e.lineSubtotal.toDouble()),
          ],
        )
        .toList();

    final total = lines.fold<double>(
      0,
      (s, e) => s + e.lineSubtotal.toDouble(),
    );
    final name = (clientName ?? '').trim().isEmpty
        ? 'Cliente'
        : clientName!.trim();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _header(logoBytes, businessName, businessAddress, businessPhone),
              pw.SizedBox(height: 20),
              _clientInfo(name),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                border: pw.TableBorder.all(
                  style: pw.BorderStyle.none,
                  width: 0,
                ),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0x6BD5EF),
                ),
                cellAlignment: pw.Alignment.topLeft,
                headerAlignment: pw.Alignment.topLeft,
                headers: ['Producto', 'Cantidad', 'Precio', 'Subtotal'],
                data: data,
              ),
              pw.Divider(thickness: 0.5),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Total: ${NumberFormatter.currency(total)}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Spacer(),
              _footer(bankAccounts),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _header(
    Uint8List logoBytes,
    String businessName,
    String businessAddress,
    String businessPhone,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        if (logoBytes.isNotEmpty)
          pw.Image(pw.MemoryImage(logoBytes), width: 100)
        else
          pw.Text(
            businessName,
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              businessName,
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            if (businessAddress.isNotEmpty)
              pw.Text(
                businessAddress,
                style: pw.TextStyle(fontSize: 16, color: PdfColors.grey500),
              ),
            if (businessPhone.isNotEmpty)
              pw.Text(
                businessPhone,
                style: pw.TextStyle(fontSize: 16, color: PdfColors.grey500),
              ),
          ],
        ),
        pw.Text('Cotización', style: pw.TextStyle(fontSize: 18)),
      ],
    );
  }

  static pw.Widget _clientInfo(String clientName) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Cliente: $clientName'),
        pw.Text('Fecha: ${DateTime.now().toString().split(' ')[0]}'),
        // pw.Text(
        //     'Cotización #: ${DateTime.now().millisecondsSinceEpoch % 10000}'),
      ],
    );
  }

  static pw.Widget _footer(List<Map<String, String>> bankAccounts) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        if (bankAccounts.isNotEmpty)
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Nuestras cuentas bancarias',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                ...bankAccounts.map(
                  (account) => pw.Text(
                    '${account['bank']}: ${account['account']}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          )
        else
          pw.Spacer(),
        pw.SizedBox(width: 24),
        pw.Text(
          'Gracias por confiar en nosotros',
          style: const pw.TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}
