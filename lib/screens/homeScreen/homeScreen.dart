import 'package:flutter/material.dart';
import 'package:inventra/models/printerDevice.dart';
import 'package:inventra/provider/printerProvider.dart';
import 'package:inventra/screens/catalog/catalogScreen.dart';
import 'package:inventra/screens/profile/printers/addPrinterScreen.dart';
import 'package:inventra/services/printerService/printingService.dart';
import 'package:inventra/utils/colors.dart';
import 'package:inventra/widgets/bottomNavBar.dart';
import 'package:inventra/widgets/drawer.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/homeScreen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Líneas de ejemplo para la factura de prueba (sustituir por datos reales cuando existan).
  static const List<Map<String, dynamic>> _sampleInvoiceItems = [
    {'name': 'Product 1', 'quantity': 1, 'price': 100, 'subtotal': 100},
    {'name': 'Product 2', 'quantity': 1, 'price': 100, 'subtotal': 100},
    {'name': 'Product 3', 'quantity': 1, 'price': 100, 'subtotal': 100},
    {'name': 'Product 4', 'quantity': 1, 'price': 100, 'subtotal': 100},
  ];

  Future<void> _printOnPrinter(
    BuildContext scaffoldContext,
    PrinterDevice printer,
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
      ).printInvoice(_sampleInvoiceItems);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(title: const Text('Home Screen')),
      body: Column(
        children: [
          Text('Welcome to the Home Screen!'),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, CatalogScreen.routeName);
            },
            child: Text('Go to Catalog'),
          ),
          TextButton(
            onPressed: () {
              showPrintInvoice(context);
            },
            child: Text('Print Invoice'),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        // onTabSelected: (index) {},
      ),
    );
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
}
