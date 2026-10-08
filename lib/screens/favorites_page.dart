import 'package:flutter/material.dart';
import '../models/product.dart';
import '../state/shop_state.dart';
import '../widgets/product_card.dart';

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
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_border_rounded, size: 60),
                    SizedBox(height: 12),
                    Text('No favorites yet. Tap a heart on a flower you love.', textAlign: TextAlign.center),
                  ],
                ),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final columns = width >= 1050 ? 4 : width >= 720 ? 3 : width >= 350 ? 2 : 1;
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisExtent: width < 350 ? 330 : 306,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    final product = items[index];
                    return ProductCard(
                      product: product,
                      onLiked: (name) {
                        if (!mounted) return;
                        // Detail has already popped; now close Favorites and
                        // let the shell switch back to Home with the lab result.
                        Navigator.of(context).pop(name);
                      },
                      onChanged: () => setState(() {}),
                    );
                  },
                );
              },
            ),
    );
  }
}
