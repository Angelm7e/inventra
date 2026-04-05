import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:inventra/models/quoteItem.dart';
import 'package:inventra/utils/number_formatter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class QuotePdfService {
  static Future<Uint8List> loadAssetImage(String path) async {
    final ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  static Future<Uint8List> generateQuotePdfBytes(
    List<QuoteItem> items, {
    String? clientName,
  }) async {
    final pdf = pw.Document();
    Uint8List logoBytes;
    try {
      logoBytes = await loadAssetImage('assets/logo.jpg');
    } catch (_) {
      logoBytes = Uint8List(0);
    }

    final data = items
        .map(
          (e) => [
            e.product.name,
            '${e.quantity}',
            NumberFormatter.currency(e.product.price.toDouble()),
            NumberFormatter.currency(e.subtotal.toDouble()),
          ],
        )
        .toList();

    final total = items.fold<double>(0, (s, e) => s + e.subtotal);
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
              _header(logoBytes),
              pw.SizedBox(height: 20),
              _clientInfo(name),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
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
              pw.Row(
                // mainAxisAlignment: pw.MainAxisAlignment.end,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Nuestras cuentas bancarias',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'A nombre de: Massiel Moreta',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Banco Popular: 841619414',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        'Banco BHD: 26721880018',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        'Banco APAP: 100191327',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  pw.SizedBox(width: 100),
                  pw.Text(
                    'Gracias por confiar en nosotros',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  // pw.Spacer()
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _header(Uint8List logoBytes) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        if (logoBytes.isNotEmpty)
          pw.Image(pw.MemoryImage(logoBytes), width: 100)
        else
          pw.Text(
            'Dulce Euphoria',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
        pw.Column(
          children: [
            pw.Text(
              'Dulce Euphoria',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Santo Domingo Norte',
              style: pw.TextStyle(fontSize: 16, color: PdfColors.grey500),
            ),
            pw.Text(
              '809-209-0777',
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
}
