import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/section_title.dart';

class ProductsPage extends StatefulWidget {
  final VoidCallback? onProductLiked;

  const ProductsPage({super.key, this.onProductLiked});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = products.where((p) =>
        p.name.toLowerCase().contains(query.toLowerCase()) ||
        p.description.toLowerCase().contains(query.toLowerCase())).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Always display two products side by side, including on phones:
        // 1 2 / 3 4 / 5 6 / 7 8.
        const columns = 2;
        // Give cards extra vertical room on narrow devices to prevent overflow.
        final cardHeight = constraints.maxWidth < 380 ? 328.0 : 310.0;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
          children: [
            const SectionTitle(
              eyebrow: 'Products',
              title: 'Pick your perfect bouquet',
              subtitle: 'Browse our collection, save a favorite, or add flowers to your cart.',
            ),
            const SizedBox(height: 18),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: TextField(
                  onChanged: (value) => setState(() => query = value),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded, size: 20),
                    labelText: 'Search flowers',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: filtered.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: Text('No matching flowers found.')),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisExtent: cardHeight,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemBuilder: (_, index) {
                          final product = filtered[index];
                          return ProductCard(
                            product: product,
                            onLiked: (name) {
                              widget.onProductLiked?.call();
                            },
                            onChanged: () => setState(() {}),
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
