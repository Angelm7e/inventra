import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:inventra/utils/colors.dart';

import '../models/product.model.dart';
import '../utils/number_formatter.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToQuote;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToQuote,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.grey[200],
      child: InkWell(
        onTap: onAddToQuote,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: product.image == null || product.image!.isEmpty
                      ? Container(
                          color: AppColors.lightPrimary,
                          child: const Center(
                            child: Icon(
                              Icons.cake_rounded,
                              size: 48,
                              color: AppColors.lightPrimary,
                            ),
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: product.image!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppColors.lightPrimary,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.lightPrimary,
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.lightPrimary,
                            child: const Center(
                              child: Icon(
                                Icons.cake_rounded,
                                size: 48,
                                color: AppColors.lightPrimary,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                NumberFormatter.currency(product.price.toDouble()),
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: onAddToQuote,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Cotizar'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
