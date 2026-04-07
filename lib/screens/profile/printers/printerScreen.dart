import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:inventra/models/printerDevice.dart';
import 'package:inventra/provider/printerProvider.dart';
import 'package:inventra/screens/profile/printers/addPrinterScreen.dart';
import 'package:inventra/utils/colors.dart';
import 'package:inventra/widgets/bottomNavBar.dart';
import 'package:provider/provider.dart';

class PrintersScreen extends StatefulWidget {
  const PrintersScreen({super.key});

  static const String routeName = '/printersScreen';

  @override
  State<PrintersScreen> createState() => _PrintersScreenState();
}

class _PrintersScreenState extends State<PrintersScreen> {
  int _listRefreshKey = 0;

  PrinterProvider get _printerProvider =>
      Provider.of<PrinterProvider>(context, listen: false);

  void _refreshList() {
    setState(() => _listRefreshKey++);
  }

  Future<void> _openAddPrinter() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const AddPrintersScreen()),
    );
    if (mounted) _refreshList();
  }

  Future<void> _openEditPrinter(PrinterDevice printer) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => AddPrintersScreen(printerToEdit: printer),
      ),
    );
    if (mounted) _refreshList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Impresoras')),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshList();
          await _printerProvider.loadPrinters();
        },
        child: Center(
          child: FutureBuilder<List<PrinterDevice>>(
            key: ValueKey(_listRefreshKey),
            future: _printerProvider.loadPrinters(),
            builder:
                (
                  BuildContext context,
                  AsyncSnapshot<List<PrinterDevice>> snapshot,
                ) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error cargando productos.'),
                    );
                  }
                  return snapshot.data!.isEmpty
                      ? _buildEmpty(context)
                      : ListView(
                          children: snapshot.data!.map((printer) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                child: Slidable(
                                  startActionPane: ActionPane(
                                    motion: const StretchMotion(),
                                    children: [
                                      CustomSlidableAction(
                                        padding: EdgeInsets.zero,
                                        onPressed: (context) =>
                                            _onEdit(printer),
                                        backgroundColor: AppColors.lightSuccess,
                                        borderRadius: BorderRadius.circular(10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.edit,
                                              size: 26,
                                              color: Colors.white,
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Editar',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      SizedBox(width: 5),

                                      CustomSlidableAction(
                                        padding: EdgeInsets.zero,
                                        onPressed: (context) =>
                                            _onDelete(printer),
                                        backgroundColor: AppColors.lightError,
                                        borderRadius: BorderRadius.circular(10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              size: 26,
                                              color: Colors.white,
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Eliminar',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      SizedBox(width: 5),
                                    ],
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: AppColors.lightPrimary
                                            .withOpacity(0.3),
                                        width: 1.2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.12),
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.print,
                                              color: AppColors.lightPrimary
                                                  .withValues(alpha: 0.8),
                                              size: 22,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              printer.name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18,
                                              ),
                                            ),
                                            Spacer(),
                                            Chip(
                                              label: Text(printer.type),
                                              backgroundColor: AppColors
                                                  .lightSecondary
                                                  .withAlpha(30),
                                              labelStyle: TextStyle(
                                                color: AppColors.lightSecondary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.dns,
                                              size: 18,
                                              color: AppColors.lightPrimary
                                                  .withValues(alpha: 0.8),
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              "Dirección IP: ",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                printer.address,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.usb,
                                              size: 18,
                                              color: AppColors.lightPrimary
                                                  .withValues(alpha: 0.8),
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              "Puerto: ",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15,
                                              ),
                                            ),
                                            Text(
                                              printer.port.toString(),
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddPrinter,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.print_outlined,
            size: 80,
            color: AppColors.lightSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes impresoras configuradas',
            style: TextStyle(fontSize: 18, color: AppColors.lightTextSecondary),
          ),
          Text(
            'Agrega impresoras para imprimir tus tickets de venta',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.lightTextSecondary.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(),
              onPressed: _openAddPrinter,
              child: Text("Agregar impresoras"),
            ),
          ),
        ],
      ),
    );
  }

  void _onEdit(PrinterDevice printer) {
    _openEditPrinter(printer);
  }

  void _onDelete(PrinterDevice printer) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: '¿Estás seguro de que deseas eliminar la impresora ',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                TextSpan(
                  text: printer.name,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(
                  text: '?',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
                ),
                TextButton(
                  onPressed: () async {
                    await _printerProvider.removePrinter(printer.id);
                    if (dialogContext.mounted)
                      Navigator.of(dialogContext).pop();
                    if (mounted) _refreshList();
                  },
                  child: const Text(
                    'Eliminar',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
