import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/section_title.dart';
import 'product_detail_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String query = '';

  Future<void> _openProduct(Product product) async {
    await Navigator.pushNamed<String>(
      context,
      ProductDetailPage.routeName,
      arguments: product,
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final filtered = products
        .where(
          (p) =>
              p.name.toLowerCase().contains(query.toLowerCase()) ||
              p.description.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      children: [
        const SectionTitle(
          eyebrow: 'Products',
          title: 'Pick your perfect bouquet',
          subtitle:
              'Browse the full flower collection. Tap a product to view details, save a favorite, or add it to your cart.',
        ),
        const SizedBox(height: 10),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, size: 20),
                labelText: 'Search flowers',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => query = value),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: filtered.length,
              itemBuilder: (_, index) {
                final product = filtered[index];
                return ProductCard(
                  product: product,
                  onTap: () => _openProduct(product),
                  onChanged: () => setState(() {}),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
