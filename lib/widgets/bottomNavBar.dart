import 'package:flutter/material.dart';
import 'package:inventra/provider/quoteProvider.dart';
import 'package:inventra/screens/homeScreen/homeScreen.dart';
import 'package:inventra/screens/inventory/inventoryListScreen.dart';
import 'package:inventra/screens/quote/quoteScreen.dart';
import 'package:inventra/screens/settingScreen/settingScreen.dart';
import 'package:inventra/utils/colors.dart';
import 'package:provider/provider.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[900] : Colors.white;

    return BottomAppBar(
      color: bgColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context,
            icon: Icons.home,
            label: "Inicio",
            isActive: currentIndex == 0,
            onTap: () {
              Navigator.pushNamed(context, HomeScreen.routeName);
            },
          ),

          Consumer<QuoteProvider>(
            builder: (context, quote, _) {
              final n = quote.totalQuantity;
              return _buildNavItem(
                context,
                icon: Icons.receipt_long,
                label: "Facturar",
                isActive: currentIndex == 1,
                badgeCount: n > 0 ? n : null,
                onTap: () {
                  Navigator.pushNamed(context, QuoteScreen.routeName);
                },
              );
            },
          ),
          // const SizedBox(width: 48),
          _buildNavItem(
            context,
            icon: Icons.inventory_rounded,
            label: "Inventario",
            isActive: currentIndex == 2,
            onTap: () {
              Navigator.pushNamed(context, InventoryListScreen.routeName);
            },
          ),
          _buildNavItem(
            context,
            icon: Icons.settings,
            label: "Configuracion",
            isActive: currentIndex == 3,
            onTap: () {
              Navigator.pushNamed(context, SettingScreen.routeName);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    Size base = MediaQuery.of(context).size;
    final badgeText = badgeCount != null && badgeCount > 99
        ? '99+'
        : '${badgeCount ?? ''}';
    return FittedBox(
      child: GestureDetector(
        onTap: () {
          onTap();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: isActive ? AppColors.lightPrimary : Colors.grey,
                ),
                if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.lightPrimary,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 22,
              child: FittedBox(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isActive ? AppColors.lightPrimary : Colors.grey,
                    fontSize: base.width * 0.45,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
