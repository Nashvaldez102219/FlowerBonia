import 'package:flutter/material.dart';
import '../models/product.dart';
import '../state/shop_state.dart';

class ProductDetailPage extends StatefulWidget {
  static const routeName = '/product-detail';

  final Product? selectedProduct;

  const ProductDetailPage({super.key, this.selectedProduct});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Product? _product;
  bool _allowPop = false;
  bool _dialogOpen = false;

  Product get product {
    final current = widget.selectedProduct ?? _product;
    if (current != null) return current;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Product) {
      _product = args;
      return args;
    }

    throw StateError(
      'A Product was not provided to ProductDetailPage.',
    );
  }

  Future<bool> _confirmBack() async {
    if (_dialogOpen) return false;
    _dialogOpen = true;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Go back without choosing?'),
        content: const Text(
          'You have not selected “I LIKE THIS!” yet. Do you want to return to the shop?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Go back'),
          ),
        ],
      ),
    );

    _dialogOpen = false;
    return result ?? false;
  }

  Future<void> _requestBack() async {
    if (_allowPop || !mounted) return;

    final shouldLeave = await _confirmBack();
    if (!mounted || !shouldLeave) return;

    setState(() => _allowPop = true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _likeAndReturn(String productName) {
    if (!mounted) return;

    setState(() => _allowPop = true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pop(productName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = product;
    final state = ShopState.instance;
    final colors = Theme.of(context).colorScheme;
    final favorite = state.isFavorite(item.id);

    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _requestBack();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            tooltip: 'Back',
            onPressed: _requestBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: Text(item.name),
          actions: [
            IconButton(
              tooltip: favorite ? 'Remove from favorites' : 'Add to favorites',
              onPressed: () async {
                await state.toggleFavorite(item.id);
                if (mounted) setState(() {});
              },
              icon: Icon(
                favorite ? Icons.favorite : Icons.favorite_border,
                color: favorite ? colors.primary : null,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AspectRatio(
                        aspectRatio: 1.15,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerLowest,
                              border: Border.all(color: colors.outlineVariant),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Image.asset(
                              item.image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Icon(
                                  Icons.local_florist_rounded,
                                  size: 74,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '₱${item.price.toStringAsFixed(0)}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoChip(
                            icon: Icons.star_rounded,
                            label: item.rating.toStringAsFixed(1),
                          ),
                          _InfoChip(
                            icon: Icons.shopping_bag_outlined,
                            label: item.sold,
                          ),
                          if (item.discount > 0)
                            _InfoChip(
                              icon: Icons.local_offer_outlined,
                              label: '${item.discount}% off',
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        item.description,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(height: 1.55),
                      ),
                      const SizedBox(height: 22),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await state.addToCart(item.id);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(milliseconds: 900),
                              content: Text('${item.name} added to cart'),
                            ),
                          );
                          setState(() {});
                        },
                        icon: const Icon(Icons.add_shopping_cart_rounded),
                        label: const Text('Add to cart'),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: () => _likeAndReturn(item.name),
                          icon: const Icon(Icons.favorite_rounded),
                          label: const Text(
                            'I LIKE THIS!',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tap “I LIKE THIS!” to return this product name to Home.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.primary),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
