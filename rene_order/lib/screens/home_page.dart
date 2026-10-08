import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/section_title.dart';
import 'product_detail_page.dart';

class HomePage extends StatefulWidget {
  final ValueChanged<int> onNavigate;
  const HomePage({super.key, required this.onNavigate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? lastSelected;

  Future<void> _openProduct(Product product) async {
    final result = await Navigator.pushNamed<String>(
      context,
      ProductDetailPage.routeName,
      arguments: product,
    );

    if (!mounted || result == null) return;
    setState(() => lastSelected = result);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: 500,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/home-bg.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.surface.withValues(alpha: .97),
                      colors.surface.withValues(alpha: .78),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FLOWERBONIA',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: colors.primary,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Fresh flowers for little moments and big feelings.',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                height: 1.05,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Thoughtful bouquets, tulip arrangements, and soft floral gifts made to brighten someone’s day.',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                height: 1.5,
                              ),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            FilledButton.icon(
                              onPressed: () => widget.onNavigate(2),
                              icon: const Icon(Icons.local_florist),
                              label: const Text('Shop flowers'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => widget.onNavigate(1),
                              icon: const Icon(Icons.play_circle_outline),
                              label: const Text('Watch our story'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (lastSelected != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.primary.withValues(alpha: .18)),
              ),
              child: Row(
                children: [
                  Icon(Icons.favorite_rounded, color: colors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You liked: $lastSelected',
                      style: TextStyle(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Clear selection',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(() => lastSelected = null),
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 20, 0, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Expanded(
                      child: SectionTitle(
                        eyebrow: 'Featured',
                        title: 'Flowers loved at first sight',
                        subtitle:
                            'Swipe sideways to browse favorites. Tap a flower to open its Detail Page.',
                      ),
                    ),
                    TextButton(
                      onPressed: () => widget.onNavigate(2),
                      child: const Text('View all'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 232,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(right: 12),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 9),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return SizedBox(
                      width: 146,
                      child: ProductCard(
                        product: product,
                        compact: true,
                        onTap: () => _openProduct(product),
                        onChanged: () => setState(() {}),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
