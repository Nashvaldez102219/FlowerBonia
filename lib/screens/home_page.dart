import 'package:flutter/material.dart';
import '../models/product.dart';
import '../state/shop_state.dart';
import '../widgets/product_card.dart';
import '../widgets/section_title.dart';

class HomePage extends StatefulWidget {
  final ValueChanged<int> onNavigate;

  const HomePage({super.key, required this.onNavigate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final compact = screenWidth < 600;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Show lab result above the hero so it is visible when returning Home.
        ListenableBuilder(
          listenable: ShopState.instance,
          builder: (context, _) {
            final selected = ShopState.instance.lastSelectedProduct;
            if (selected == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.favorite_rounded, color: colors.primary, size: 20),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'You liked: $selected',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Clear selection',
                        onPressed: ShopState.instance.clearLikedProduct,
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        // Content-based height replaces the fixed 500px hero that overflowed.
        DecoratedBox(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/home-bg.jpg'),
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  colors.surface.withValues(alpha: .98),
                  colors.surface.withValues(alpha: .86),
                  colors.surface.withValues(alpha: .38),
                ],
              ),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: compact ? 450 : 410),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 22 : 42,
                      vertical: compact ? 42 : 56,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FLOWERBONIA',
                          style: TextStyle(
                            color: colors.primary,
                            letterSpacing: 2.1,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 13),
                        Text(
                          'Fresh flowers for little moments and big feelings.',
                          style: TextStyle(
                            fontSize: compact ? (screenWidth < 360 ? 27 : 31) : 43,
                            fontWeight: FontWeight.w700,
                            height: 1.16,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Thoughtful bouquets, tulip arrangements, and soft floral gifts made to brighten someone’s day.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: compact ? 14 : 17,
                            height: 1.65,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            FilledButton.icon(
                              onPressed: () => widget.onNavigate(2),
                              icon: const Icon(Icons.local_florist_outlined, size: 18),
                              label: const Text('Shop flowers'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => widget.onNavigate(1),
                              icon: const Icon(Icons.play_circle_outline, size: 18),
                              label: const Text('Watch our story'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // The existing Home product carousel becomes a personal "Liked Flowers"
        // collection after the first I LIKE THIS! selection. Before then, it
        // still displays the original featured products.
        ListenableBuilder(
          listenable: ShopState.instance,
          builder: (context, _) {
            final state = ShopState.instance;
            final likedIds = state.likedProductIds;
            final likedFlowers = <Product>[];
            for (final id in likedIds) {
              for (final flower in products) {
                if (flower.id == id) {
                  likedFlowers.add(flower);
                  break;
                }
              }
            }

            final hasLikes = likedFlowers.isNotEmpty;
            final shownFlowers = hasLikes ? likedFlowers : products;

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 26, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(
                    eyebrow: hasLikes ? 'Your collection' : 'Featured',
                    title: hasLikes ? 'Flowers you liked' : 'Flowers loved at first sight',
                    subtitle: hasLikes
                        ? 'Your I LIKE THIS! picks are saved here. Tap a flower to see it again.'
                        : 'Explore our bouquets. Tap a flower and press I LIKE THIS! to save it here.',
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => widget.onNavigate(2),
                      icon: const Icon(Icons.local_florist_outlined, size: 17),
                      label: Text(hasLikes ? 'Explore more' : 'View all flowers'),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: hasLikes ? 342 : 295,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: shownFlowers.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final flower = shownFlowers[index];
                        return SizedBox(
                          width: compact ? 173 : 194,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ProductCard(
                                  key: ValueKey('home-flower-${flower.id}'),
                                  product: flower,
                                  compact: true,
                                  onChanged: () {
                                    if (mounted) setState(() {});
                                  },
                                ),
                              ),
                              if (hasLikes) ...[
                                const SizedBox(height: 7),
                                SizedBox(
                                  height: 34,
                                  child: OutlinedButton.icon(
                                    onPressed: () => state.removeLikedProduct(flower.id),
                                    icon: const Icon(Icons.close_rounded, size: 15),
                                    label: const Text('Remove', style: TextStyle(fontSize: 12)),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
