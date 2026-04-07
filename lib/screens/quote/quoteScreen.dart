import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inventra/models/quoteItem.dart';
import 'package:inventra/provider/quoteProvider.dart';
import 'package:inventra/screens/catalog/catalogScreen.dart';
import 'package:inventra/screens/catalog/catalog_cart_target.dart';
import 'package:inventra/services/quote_pdf_service.dart';
import 'package:inventra/utils/colors.dart';
import 'package:inventra/utils/number_formatter.dart';
import 'package:inventra/widgets/bottomNavBar.dart';
import 'package:inventra/widgets/drawer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cross_file/cross_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  static const routeName = '/quoteScreen';

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  late TextEditingController clientNameController;
  @override
  void dispose() {
    super.dispose();
    clientNameController.dispose();
  }

  @override
  void initState() {
    super.initState();
    clientNameController = TextEditingController();
  }

  double _totalFor(List<QuoteItem> items) =>
      items.fold<double>(0, (s, e) => s + e.subtotal);

  @override
  Widget build(BuildContext context) {
    final quote = context.watch<QuoteProvider>();
    final items = quote.quoteItems;

    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (items.isNotEmpty)
            IconButton(
              onPressed: () => _confirmClear(context),
              icon: const Icon(Icons.delete_outline_rounded),
              color: AppColors.lightTextSecondary,
            ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                CatalogScreen.routeName,
                arguments: CatalogCartTarget.quote,
              );
            },
            icon: const Icon(Icons.add, color: AppColors.lightPrimary),
          ),
        ],
        title: const Text(
          'Cotización',
          style: TextStyle(color: AppColors.lightTextPrimary),
        ),
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Material(
                color: AppColors.lightPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: AppColors.lightPrimary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Solo presupuesto: generar la cotización no resta del inventario. '
                          'La venta y el descuento de stock se hacen en Facturar.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.35,
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (items.isEmpty)
              _buildEmpty(context)
            else
              Expanded(child: _buildList(context, quote)),
            if (items.isNotEmpty) _buildTotalAndActions(context, quote),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 80,
              color: AppColors.lightSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Tu cotización está vacía',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.lightTextSecondary,
              ),
            ),
            Text(
              'Elige productos del catálogo (verás stock disponible)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.lightTextSecondary.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    CatalogScreen.routeName,
                    arguments: CatalogCartTarget.quote,
                  );
                },
                child: const Text('Agregar productos'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, QuoteProvider quote) {
    final items = quote.quoteItems;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _QuoteItemCard(
          item: item,
          onUpdateQuantity: (q) => quote.updateQuantity(item, q),
          onRemove: () => quote.removeFromQuote(item),
          forQuote: true,
        );
      },
    );
  }

  Widget _buildTotalAndActions(BuildContext context, QuoteProvider quote) {
    final items = quote.quoteItems;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              Text(
                NumberFormatter.currency(_totalFor(items)),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _showClientNameDialog(context),
            icon: const Icon(Icons.picture_as_pdf_rounded),
            label: const Text(
              'Generar cotización (PDF)',
              style: TextStyle(color: Colors.white),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vaciar cotización'),
        content: const Text(
          '¿Quieres eliminar todos los productos de tu cotización?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              context.read<QuoteProvider>().clearQuote();
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
            ),
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
  }

  void _showClientNameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Datos para la cotización'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nombre del cliente (aparecerá en el PDF de cotización)',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: clientNameController,
              decoration: const InputDecoration(
                hintText: 'Nombre del cliente',
                border: OutlineInputBorder(),
                filled: true,
              ),
              textCapitalization: TextCapitalization.words,
              onSubmitted: (_) => _onClientNameSubmitted(
                context,
                dialogContext,
                clientNameController.text,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (clientNameController.text.isNotEmpty &&
                  clientNameController.text.trim() != "") {
                _onClientNameSubmitted(
                  context,
                  dialogContext,
                  clientNameController.text,
                );
              } else {
                // Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor, ingrese un nombre')),
                );
                return;
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    // .then((_) => clientNameController.dispose());
  }

  void _onClientNameSubmitted(
    BuildContext context,
    BuildContext dialogContext,
    String clientName,
  ) {
    Navigator.pop(dialogContext);
    _showPdfActionsSheet(context, clientName);
  }

  void _showPdfActionsSheet(BuildContext context, String clientName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.35,
        minChildSize: 0.25,
        maxChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.lightBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const Text(
                  'Cotización PDF',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                FilledButton.icon(
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Guardar en Descargas'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.lightPrimary,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () async {
                    try {
                      final pdfItems = context.read<QuoteProvider>().quoteItems;
                      final bytes = await QuotePdfService.generateQuotePdfBytes(
                        pdfItems,
                        clientName: clientName,
                      );
                      await _savePdfToDownloads(bytes);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('PDF guardado en Descargas'),
                            backgroundColor: AppColors.lightPrimary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 15),
                OutlinedButton.icon(
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('Compartir PDF'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: AppColors.lightPrimary),
                    foregroundColor: AppColors.lightPrimary,
                  ),
                  onPressed: () async {
                    try {
                      final pdfItems = context.read<QuoteProvider>().quoteItems;
                      final bytes = await QuotePdfService.generateQuotePdfBytes(
                        pdfItems,
                        clientName: clientName,
                      );
                      await _sharePdf(bytes);
                      clientNameController.clear();
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _sharePdf(List<int> bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/dulce_euphoria_quote.pdf');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Dulce Euphoria - Cotización');
  }

  Future<void> _savePdfToDownloads(List<int> bytes) async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted)
        throw Exception('Permiso de almacenamiento denegado');
    }
    final directory = Platform.isAndroid
        ? Directory('/storage/emulated/0/Download')
        : await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/dulce_euphoria_quote_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(bytes);
  }
}

class _QuoteItemCard extends StatelessWidget {
  final QuoteItem item;
  final void Function(int quantity) onUpdateQuantity;
  final VoidCallback onRemove;
  final bool forQuote;

  const _QuoteItemCard({
    required this.item,
    required this.onUpdateQuantity,
    required this.onRemove,
    this.forQuote = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.lightBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${NumberFormatter.currency(double.parse(item.product.price.toString()))} c/u',
                    style: const TextStyle(
                      color: AppColors.lightTextSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'En inventario: ${item.product.quantity}',
                    style: TextStyle(
                      color: AppColors.lightTextSecondary.withValues(
                        alpha: 0.9,
                      ),
                      fontSize: 12,
                    ),
                  ),
                  if (forQuote && item.quantity > item.product.quantity) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Cantidad superior al stock (solo referencia en cotización)',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton.filled(
                        onPressed: item.quantity > 1
                            ? () => onUpdateQuantity(item.quantity - 1)
                            : null,
                        icon: Icon(
                          Icons.remove,
                          size: 18,
                          color: item.quantity > 1
                              ? Colors.white
                              : AppColors.lightPrimary,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.lightPrimary,
                          foregroundColor: AppColors.lightBackground,
                          minimumSize: const Size(36, 36),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton.filled(
                        onPressed: () => onUpdateQuantity(item.quantity + 1),
                        icon: const Icon(Icons.add, size: 18),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.lightPrimary,
                          foregroundColor: AppColors.lightBackground,
                          minimumSize: const Size(36, 36),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  NumberFormatter.currency(item.subtotal.toDouble()),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightPrimary,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.lightTextSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
