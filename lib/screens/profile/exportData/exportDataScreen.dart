import 'package:flutter/material.dart';
import 'package:inventra/services/dataBaseHelper.dart';
import 'package:inventra/utils/colors.dart';

class ExportDataScreen extends StatelessWidget {
  const ExportDataScreen({super.key});

  static const String routeName = '/exportData';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exportar datos')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Exportar productos en JSON'),
              subtitle: const Text('Genera y comparte un respaldo del inventario.'),
              onTap: () async {
                await DatabaseHelper.instance.shareBackup();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Backup exportado con éxito.'),
                    backgroundColor: AppColors.lightSuccess,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
