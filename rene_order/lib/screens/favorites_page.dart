import 'package:flutter/material.dart';
import '../models/product.dart';
import '../state/shop_state.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    final ids = ShopState.instance.favorites;
    final items = products.where((p) => ids.contains(p.id)).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: items.isEmpty
          ? const Center(child: Padding(padding: EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.favorite_border, size: 64), SizedBox(height: 12), Text('No favorites yet. Tap the heart on any flower you love.')])) )
          : LayoutBuilder(builder: (context, constraints) {
              final count = constraints.maxWidth >= 1100 ? 4 : constraints.maxWidth >= 760 ? 3 : constraints.maxWidth >= 360 ? 2 : 1;
              return GridView.builder(
                padding: const EdgeInsets.all(18),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: count, childAspectRatio: .70, crossAxisSpacing: 12, mainAxisSpacing: 12),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final product = items[i];
                  return ProductCard(
                    product: product,
                    onTap: () async {
                      await Navigator.pushNamed<String>(
                        context,
                        ProductDetailPage.routeName,
                        arguments: product,
                      );
                      if (mounted) setState(() {});
                    },
                    onChanged: () => setState(() {}),
                  );
                },
              );
            }),
    );
  }
}
