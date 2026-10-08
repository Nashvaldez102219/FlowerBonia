import 'package:flutter/material.dart';

import '../models/product.dart';
import '../screens/product_detail_page.dart';
import '../state/shop_state.dart';

/// A flower card that opens Product Detail when its photo, text,
/// card background, or the "View details" button is tapped.
///
/// The card opens its own detail route. [onLiked] receives the selected
/// flower name so Products/Favorites can switch to Home when it returns.
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onChanged;
  final bool compact;
  final ValueChanged<String>? onLiked;
  // Kept for source compatibility with older callers; navigation is handled
  // inside this card so an obsolete callback cannot suppress a tap.
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onChanged,
    this.compact = false,
    this.onTap,
    this.onLiked,
  });

  Future<void> _openDetails(BuildContext context) async {
    debugPrint('[Flowerbonia] Tapped details for ${product.id}: ${product.name}');

    // Bypass page callbacks and the named-route lookup for the actual tap.
    // A concrete MaterialPageRoute receives the Product directly, while
    // RouteSettings still carry its name/arguments for the navigation lab.
    try {
      final result = await Navigator.of(context, rootNavigator: true)
          .push<String>(
        MaterialPageRoute<String>(
          settings: RouteSettings(
            name: ProductDetailPage.routeName,
            arguments: product,
          ),
          builder: (_) => ProductDetailPage(selectedProduct: product),
        ),
      );

      if (result != null) {
        await ShopState.instance.selectLikedProduct(result);
        onLiked?.call(result);
      }
      if (context.mounted) onChanged?.call();
    } catch (error, stackTrace) {
      debugPrint('[Flowerbonia] Detail navigation ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!context.mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text('Cannot open product details: $error'),
          duration: const Duration(seconds: 8),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ShopState.instance;
    final colors = Theme.of(context).colorScheme;
    final favorite = state.isFavorite(product.id);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: .65)),
        borderRadius: BorderRadius.circular(17),
      ),
      child: InkWell(
        key: Key('product-card-${product.id}'),
        onTap: () => _openDetails(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: compact ? 43 : 46,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Explicit tap target for the photo (including blank
                  // space around an image fitted with BoxFit.contain).
                  InkWell(
                    key: Key('product-image-${product.id}'),
                    onTap: () => _openDetails(context),
                    child: ColoredBox(
                      color: colors.surfaceContainerLowest,
                      child: Image.asset(
                        product.image,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.local_florist_outlined,
                          size: 38,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 7,
                    right: 7,
                    child: Material(
                      color: colors.surface.withValues(alpha: .95),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () async {
                          await state.toggleFavorite(product.id);
                          onChanged?.call();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: Icon(
                            favorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 18,
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
                      left: 7,
                      bottom: 7,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          child: Text(
                            '-${product.discount}%',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: compact ? 57 : 54,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  compact ? 8 : 10,
                  8,
                  compact ? 8 : 10,
                  8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: compact ? 12 : 13,
                            height: 1.15,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      product.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            height: 1.15,
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '₱${product.price.toStringAsFixed(0)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontSize: compact ? 14 : 16,
                                  fontWeight: FontWeight.w800,
                                  color: colors.primary,
                                ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Tooltip(
                          message: 'Add to cart',
                          child: Material(
                            color: colors.primaryContainer,
                            borderRadius: BorderRadius.circular(9),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(9),
                              onTap: () async {
                                await state.addToCart(product.id);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: const Duration(seconds: 1),
                                    content: Text('${product.name} added to cart'),
                                  ),
                                );
                                onChanged?.call();
                              },
                              child: SizedBox(
                                width: 30,
                                height: 30,
                                child: Icon(
                                  Icons.add_shopping_cart_rounded,
                                  size: 16,
                                  color: colors.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Color(0xFFFFB300),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            product.sold,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    SizedBox(
                      height: 32,
                      child: FilledButton.tonal(
                        key: Key('view-details-${product.id}'),
                        onPressed: () => _openDetails(context),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('View details  ›',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
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
