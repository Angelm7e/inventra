import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventra/models/sale_record.dart';
import 'package:inventra/services/sale_record_service.dart';
import 'package:inventra/utils/colors.dart';
import 'package:inventra/utils/number_formatter.dart';
import 'package:inventra/widgets/bottomNavBar.dart';
import 'package:inventra/widgets/drawer.dart';

class SellsScreen extends StatefulWidget {
  const SellsScreen({super.key});
  static const routeName = '/sellsScreen';

  @override
  State<SellsScreen> createState() => _SellsScreenState();
}

class _SellsScreenState extends State<SellsScreen> {
  late Future<List<SaleRecord>> _salesFuture;
  final _dateFormatter = DateFormat('dd/MM/yyyy hh:mm a');

  @override
  void initState() {
    super.initState();
    _salesFuture = SaleRecordService().getAllSales();
  }

  Future<void> _reload() async {
    setState(() {
      _salesFuture = SaleRecordService().getAllSales();
    });
    await _salesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(title: const Text('Ventas')),
      body: FutureBuilder<List<SaleRecord>>(
        future: _salesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudieron cargar las ventas.',
                  style: TextStyle(color: AppColors.lightError),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final sales = snapshot.data ?? [];
          if (sales.isEmpty) return _buildEmpty();

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sales.length + 1,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == 0) return _buildSummary(sales);
                return _SaleRecordTile(
                  sale: sales[index - 1],
                  soldAt: _dateFormatter.format(sales[index - 1].soldAt),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildEmpty() {
    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 160),
          Icon(Icons.sell_outlined, size: 82, color: AppColors.lightSecondary),
          SizedBox(height: 16),
          Text(
            'Todavia no hay ventas registradas',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Cuando generes una factura, aqui veras cada producto vendido con su fecha, precio y cantidad.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.lightTextSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(List<SaleRecord> sales) {
    final units = sales.fold<int>(0, (sum, sale) => sum + sale.quantity);
    final total = sales.fold<int>(0, (sum, sale) => sum + sale.total);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.lightPrimary.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryValue(label: 'Registros', value: '${sales.length}'),
          ),
          Expanded(
            child: _SummaryValue(label: 'Unidades', value: '$units'),
          ),
          Expanded(
            child: _SummaryValue(
              label: 'Total vendido',
              value: NumberFormatter.currency(total.toDouble()),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          alignment: Alignment.centerLeft,
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.lightTextPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SaleRecordTile extends StatelessWidget {
  final SaleRecord sale;
  final String soldAt;

  const _SaleRecordTile({required this.sale, required this.soldAt});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.lightPrimary.withValues(alpha: 0.16)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.lightPrimary.withValues(alpha: 0.1),
          child: const Icon(Icons.receipt_long, color: AppColors.lightPrimary),
        ),
        title: Text(
          sale.productName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '$soldAt\n${sale.quantity} x ${NumberFormatter.currency(sale.unitPrice.toDouble())}',
          ),
        ),
        trailing: Text(
          NumberFormatter.currency(sale.total.toDouble()),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.lightPrimary,
          ),
        ),
      ),
    );
  }
}
