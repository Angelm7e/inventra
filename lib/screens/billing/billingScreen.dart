import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inventra/models/printerDevice.dart';
import 'package:inventra/models/product.model.dart';
import 'package:inventra/models/quoteItem.dart';
import 'package:inventra/provider/billing_provider.dart';
import 'package:inventra/provider/printerProvider.dart';
import 'package:inventra/provider/productProvider.dart';
import 'package:inventra/screens/catalog/catalogScreen.dart';
import 'package:inventra/screens/catalog/catalog_cart_target.dart';
import 'package:inventra/screens/profile/printers/addPrinterScreen.dart';
import 'package:inventra/services/printerService/printingService.dart';
import 'package:inventra/services/productService.dart';
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

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  static const routeName = '/billingScreen';

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
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

  static const List<Map<String, dynamic>> _itemsToPrint = [
    {'name': 'Product 1', 'quantity': 1, 'price': 100, 'subtotal': 100},
    {'name': 'Product 2', 'quantity': 1, 'price': 100, 'subtotal': 100},
    {'name': 'Product 3', 'quantity': 1, 'price': 100, 'subtotal': 100},
    {'name': 'Product 4', 'quantity': 1, 'price': 100, 'subtotal': 100},
  ];

  double _totalFor(List<QuoteItem> items) =>
      items.fold<double>(0, (s, e) => s + e.subtotal);

  @override
  Widget build(BuildContext context) {
    final billing = context.watch<BillingProvider>();
    final items = billing.billingItems;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              Navigator.pushNamed(context, CatalogScreen.routeName);
            },
            icon: const Icon(Icons.add, color: AppColors.lightPrimary),
          ),
        ],
        title: const Text(
          'Facturar',
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
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.point_of_sale_rounded,
                        size: 20,
                        color: Colors.green.shade800,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Venta: al generar la factura se descuenta el inventario '
                          'según las cantidades facturadas. Usa Cotización para solo presupuestar.',
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
              Expanded(child: _buildList(context, billing)),
            if (items.isNotEmpty) _buildTotalAndActions(context, billing),
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
              'Tu factura está vacía',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.lightTextSecondary,
              ),
            ),
            Text(
              'Agrega productos para generar la factura',
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
                    arguments: CatalogCartTarget.billing,
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

  Widget _buildList(BuildContext context, BillingProvider billing) {
    final items = billing.billingItems;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _BillingItemCard(
          item: item,
          onUpdateQuantity: (q) => billing.updateQuantity(item, q),
          onRemove: () => billing.removeFromBilling(item),
        );
      },
    );
  }

  Widget _buildTotalAndActions(BuildContext context, BillingProvider billing) {
    final items = billing.billingItems;
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
            // icon: const Icon(Icons.receipt_long_rounded),
            label: const Text(
              'Generar factura',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              padding: const EdgeInsets.symmetric(vertical: 15),
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
        title: const Text('Vaciar factura'),
        content: const Text(
          '¿Quieres eliminar todos los productos de tu factura?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              context.read<BillingProvider>().clearBilling();
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
        title: const Text('Datos para la factura'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Agregar nombre de quien recibe la factura',
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

  Future<String?> _validateBillingStock(List<QuoteItem> items) async {
    final products = await ProductService().getAllProducts();
    final byId = <int, Product>{};
    for (final p in products) {
      if (p.id != null) byId[p.id!] = p;
    }
    for (final item in items) {
      final id = item.product.id;
      if (id == null) {
        return 'El producto "${item.product.name}" no se puede facturar (sin id).';
      }
      final p = byId[id];
      if (p == null) {
        return 'No se encontró "${item.product.name}" en inventario.';
      }
      if (item.quantity > p.quantity) {
        return 'Stock insuficiente para "${item.product.name}" '
            '(disponible ${p.quantity}, en factura ${item.quantity}).';
      }
    }
    return null;
  }

  Future<String?> _applyBillingDeduction(
    BuildContext context,
    List<QuoteItem> items,
  ) async {
    final productProvider = context.read<ProductProvider>();
    final products = await ProductService().getAllProducts();
    final byId = <int, Product>{};
    for (final p in products) {
      if (p.id != null) byId[p.id!] = p;
    }
    for (final item in items) {
      final id = item.product.id;
      if (id == null) continue;
      final p = byId[id];
      if (p == null) continue;
      final newQty = p.quantity - item.quantity;
      if (newQty < 0) {
        return 'Error al descontar "${item.product.name}"';
      }
      final updated = Product(
        id: p.id,
        name: p.name,
        quantity: newQty,
        price: p.price,
        category: p.category,
        description: p.description,
        image: p.image,
      );
      final r = await productProvider.updateProduct(updated);
      if (r < 0) {
        return 'No se pudo actualizar inventario de "${item.product.name}"';
      }
      byId[id] = updated;
    }
    return null;
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
                  'Factura PDF',
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
                      final items = List<QuoteItem>.from(
                        context.read<BillingProvider>().billingItems,
                      );
                      final stockErr = await _validateBillingStock(items);
                      if (stockErr != null) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(stockErr),
                              backgroundColor: Colors.orange.shade900,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                        return;
                      }
                      final bytes = await QuotePdfService.generateQuotePdfBytes(
                        items,
                        clientName: clientName,
                      );
                      await _savePdfToDownloads(bytes);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      final invErr = await _applyBillingDeduction(
                        context,
                        items,
                      );
                      if (!context.mounted) return;
                      if (invErr != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'PDF guardado. Revisa inventario: $invErr',
                            ),
                            backgroundColor: Colors.orange.shade900,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else {
                        context.read<BillingProvider>().clearBilling();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Factura guardada e inventario actualizado',
                            ),
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
                      final items = List<QuoteItem>.from(
                        context.read<BillingProvider>().billingItems,
                      );
                      final stockErr = await _validateBillingStock(items);
                      if (stockErr != null) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(stockErr),
                              backgroundColor: Colors.orange.shade900,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                        return;
                      }
                      final bytes = await QuotePdfService.generateQuotePdfBytes(
                        items,
                        clientName: clientName,
                      );
                      await _sharePdf(bytes);
                      clientNameController.clear();
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      final invErr = await _applyBillingDeduction(
                        context,
                        items,
                      );
                      if (!context.mounted) return;
                      if (invErr != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'PDF compartido. Revisa inventario: $invErr',
                            ),
                            backgroundColor: Colors.orange.shade900,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else {
                        context.read<BillingProvider>().clearBilling();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Factura enviada e inventario actualizado',
                            ),
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
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _sharePdf(List<int> bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/dulce_euphoria_invoice.pdf');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Dulce Euphoria - Factura');
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
      '${directory.path}/dulce_euphoria_invoice_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(bytes);
  }

  Future<void> _printOnPrinter(
    BuildContext scaffoldContext,
    PrinterDevice printer,
    // List<Map<String, dynamic>> items,
  ) async {
    final messenger = ScaffoldMessenger.of(scaffoldContext);

    if (printer.type != 'network') {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'La impresión por Bluetooth no está disponible con este flujo.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (printer.address.trim().isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('La impresora no tiene una dirección IP válida.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text('Enviando a ${printer.name}…'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      final ok = await PrintingService(
        ip: printer.address.trim(),
        port: printer.port ?? 9100,
      ).printInvoice(_itemsToPrint);
      if (!scaffoldContext.mounted) return;
      if (!ok) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo conectar con la impresora. Revise IP y puerto.',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.lightError,
          ),
        );
        return;
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text('Impresión enviada a ${printer.name}.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.lightSuccess,
        ),
      );
    } catch (e, st) {
      debugPrint('Error al imprimir: $e\n$st');
      if (!scaffoldContext.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('No se pudo imprimir: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.lightError,
        ),
      );
    }
  }

  Future<void> showAvailablePrinters(BuildContext scaffoldContext) async {
    final provider = Provider.of<PrinterProvider>(
      scaffoldContext,
      listen: false,
    );
    await provider.loadPrinters();
    if (!scaffoldContext.mounted) return;

    showModalBottomSheet(
      context: scaffoldContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final printers = Provider.of<PrinterProvider>(
          sheetContext,
          listen: true,
        ).printers;

        return Stack(
          children: [
            DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.25,
              maxChildSize: 0.6,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Impresoras disponibles',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: printers.isEmpty
                            ? Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Center(
                                    child: Text(
                                      'No hay impresoras disponibles',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.lightPrimary,
                                      minimumSize: const Size(
                                        double.infinity,
                                        50,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(sheetContext);
                                      Navigator.pushNamed(
                                        scaffoldContext,
                                        AddPrintersScreen.routeName,
                                      );
                                    },
                                    child: Text(
                                      'Agregar impresora',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: printers.length,
                                itemBuilder: (context, index) {
                                  final printer = printers[index];
                                  return ListTile(
                                    leading: Icon(
                                      Icons.print,
                                      color: AppColors.lightPrimary,
                                    ),
                                    title: Text(printer.name),
                                    subtitle: Text(
                                      '${printer.address}:${printer.port ?? 9100} · ${printer.type}',
                                    ),
                                    onTap: () {
                                      Navigator.pop(sheetContext);
                                      _printOnPrinter(scaffoldContext, printer);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void showPrintInvoice(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // isDismissible: false,
      builder: (sheetContext) {
        return Stack(
          children: [
            DraggableScrollableSheet(
              initialChildSize: 0.27,
              minChildSize: 0.27,
              maxChildSize: 0.27,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      // Indicador draggable
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      const SizedBox(height: 12),
                      Text(
                        'Tipo de impresora',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.lightPrimary,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () async {
                          Navigator.pop(sheetContext);
                          await showAvailablePrinters(parentContext);
                        },
                        child: Text(
                          'Impresora de red',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.lightPrimary),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () {},
                        child: Text(
                          'Impresora de bluetooth',
                          style: TextStyle(
                            color: AppColors.lightPrimary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // void showPrintBillingAction(BuildContext parentContext) {
  //   showModalBottomSheet(
  //     context: parentContext,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     // isDismissible: false,
  //     builder: (sheetContext) {
  //       return Stack(
  //         children: [
  //           DraggableScrollableSheet(
  //             initialChildSize: 0.27,
  //             minChildSize: 0.27,
  //             maxChildSize: 0.27,
  //             builder: (context, scrollController) {
  //               return Container(
  //                 padding: const EdgeInsets.all(16),
  //                 decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   borderRadius: const BorderRadius.vertical(
  //                     top: Radius.circular(20),
  //                   ),
  //                   border: Border.all(color: Colors.grey[300]!, width: 1),
  //                 ),
  //                 child: Column(
  //                   // crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     const SizedBox(height: 12),
  //                     // Indicador draggable
  //                     Container(
  //                       width: 40,
  //                       height: 4,
  //                       decoration: BoxDecoration(
  //                         color: Colors.grey[400],
  //                         borderRadius: BorderRadius.circular(10),
  //                       ),
  //                     ),
  //                     const SizedBox(height: 12),
  //                     Text(
  //                       'Generar factura',
  //                       style: TextStyle(
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 12),
  //                     FilledButton(
  //                       style: FilledButton.styleFrom(
  //                         backgroundColor: AppColors.lightPrimary,
  //                         minimumSize: const Size(double.infinity, 50),
  //                       ),
  //                       onPressed: () async {
  //                         Navigator.pop(sheetContext);
  //                         await showAvailablePrinters(parentContext);
  //                       },
  //                       child: Text(
  //                         'Imprimir factura',
  //                         style: TextStyle(color: Colors.white, fontSize: 16),
  //                       ),
  //                     ),
  //                     const SizedBox(height: 12),
  //                     OutlinedButton(
  //                       style: OutlinedButton.styleFrom(
  //                         side: BorderSide(color: AppColors.lightPrimary),
  //                         minimumSize: const Size(double.infinity, 50),
  //                       ),
  //                       onPressed: () {
  //                         Navigator.pop(sheetContext);
  //                         _showClientNameDialog(context);
  //                       },
  //                       child: Text(
  //                         'Generar PDF',
  //                         style: TextStyle(
  //                           color: AppColors.lightPrimary,
  //                           fontSize: 16,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               );
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}

class _BillingItemCard extends StatelessWidget {
  final QuoteItem item;
  final void Function(int quantity) onUpdateQuantity;
  final VoidCallback onRemove;

  const _BillingItemCard({
    required this.item,
    required this.onUpdateQuantity,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final atMax = item.quantity >= item.product.quantity;
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
                    'Stock disponible: ${item.product.quantity}',
                    style: TextStyle(
                      color: atMax
                          ? Colors.orange.shade800
                          : AppColors.lightTextSecondary.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: atMax ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
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
                        onPressed: !atMax
                            ? () => onUpdateQuantity(item.quantity + 1)
                            : null,
                        icon: Icon(
                          Icons.add,
                          size: 18,
                          color: !atMax ? Colors.white : AppColors.lightPrimary,
                        ),
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
