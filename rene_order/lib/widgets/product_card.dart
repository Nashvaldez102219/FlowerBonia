import 'package:flutter/material.dart';
import '../models/product.dart';
import '../state/shop_state.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onChanged;
  final bool compact;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onChanged,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final state = ShopState.instance;
    final colors = Theme.of(context).colorScheme;
    final favorite = state.isFavorite(product.id);

    final radius = compact ? 10.0 : 9.0;
    final bodyPadding = compact
        ? const EdgeInsets.fromLTRB(7, 6, 7, 7)
        : const EdgeInsets.fromLTRB(7, 6, 7, 6);

    return Card(
      margin: EdgeInsets.zero,
      elevation: compact ? 0.6 : 1,
      shadowColor: Colors.black.withValues(alpha: .07),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(
          color: colors.outlineVariant.withValues(alpha: compact ? .70 : .45),
          width: compact ? 0.9 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: compact ? 53 : 50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  color: colors.surfaceContainerLowest,
                  child: Image.asset(
                    product.image,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: compact ? 4 : 5,
                  top: compact ? 4 : 5,
                  child: Material(
                    color: colors.surface.withValues(alpha: .94),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () async {
                        await state.toggleFavorite(product.id);
                        onChanged?.call();
                      },
                      child: Padding(
                        padding: EdgeInsets.all(compact ? 4 : 5),
                        child: Icon(
                          favorite ? Icons.favorite : Icons.favorite_border,
                          size: compact ? 15 : 17,
                          color: favorite
                              ? colors.primary
                              : colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                if (product.discount > 0)
                  Positioned(
                    left: 5,
                    bottom: 5,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 5 : 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-${product.discount}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: compact ? 8.5 : 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: compact ? 47 : 50,
            child: Padding(
              padding: bodyPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: compact ? 10.8 : 11.5,
                          height: 1.15,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: compact ? 8.7 : 9.2,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          '₱${product.price.toStringAsFixed(0)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: compact ? 14.5 : 15.5,
                          ),
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(7),
                        onTap: () async {
                          await state.addToCart(product.id);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(milliseconds: 900),
                              content: Text('${product.name} added to cart'),
                            ),
                          );
                          onChanged?.call();
                        },
                        child: Container(
                          width: compact ? 26 : 28,
                          height: compact ? 26 : 28,
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Icon(
                            Icons.add_shopping_cart_rounded,
                            size: compact ? 14 : 15,
                            color: colors.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: compact ? 3 : 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFB300),
                        size: 13,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: compact ? 9 : 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          product.sold,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: compact ? 9 : 9.5,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}
