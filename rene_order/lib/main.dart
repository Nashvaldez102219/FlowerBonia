import 'package:flutter/material.dart';
import 'screens/about_page.dart';
import 'screens/cart_page.dart';
import 'screens/contact_page.dart';
import 'screens/favorites_page.dart';
import 'screens/home_page.dart';
import 'screens/products_page.dart';
import 'screens/product_detail_page.dart';
import 'screens/reviews_page.dart';
import 'state/shop_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ShopState.instance.load();
  runApp(const FlowerboniaApp());
}

class FlowerboniaApp extends StatefulWidget {
  const FlowerboniaApp({super.key});
  @override
  State<FlowerboniaApp> createState() => _FlowerboniaAppState();
}

class _FlowerboniaAppState extends State<FlowerboniaApp> {
  @override
  void initState() {
    super.initState();
    ShopState.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    ShopState.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final state = ShopState.instance;
    const seed = Color(0xFFD82972);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FLOWERBONIA',
      themeMode: state.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
        scaffoldBackgroundColor: const Color(0xFFFFFBFC),
        cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
        cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const ShopShell(),
        ProductDetailPage.routeName: (_) => const ProductDetailPage(),
      },
    );
  }
}

class ShopShell extends StatefulWidget {
  const ShopShell({super.key});
  @override
  State<ShopShell> createState() => _ShopShellState();
}

class _ShopShellState extends State<ShopShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final state = ShopState.instance;
    final pages = [
      HomePage(onNavigate: (i) => setState(() => index = i)),
      const AboutPage(),
      const ProductsPage(),
      const ReviewsPage(),
      const ContactPage(),
    ];
    final destinations = const [
      NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.info_outline), selectedIcon: Icon(Icons.info), label: 'About'),
      NavigationDestination(icon: Icon(Icons.local_florist_outlined), selectedIcon: Icon(Icons.local_florist), label: 'Products'),
      NavigationDestination(icon: Icon(Icons.reviews_outlined), selectedIcon: Icon(Icons.reviews), label: 'Reviews'),
      NavigationDestination(icon: Icon(Icons.contact_mail_outlined), selectedIcon: Icon(Icons.contact_mail), label: 'Contact'),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth >= 920;
      final content = Column(children: [
        if (desktop)
          Material(
            elevation: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Row(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.asset('assets/images/app_icon.png', width: 46, height: 46, fit: BoxFit.cover)),
                  const SizedBox(width: 10),
                  const Text('Flowerbonia', style: TextStyle(fontFamily: 'serif', fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: .2)),
                  const Spacer(),
                  ...List.generate(destinations.length, (i) => TextButton.icon(onPressed: () => setState(() => index = i), icon: destinations[i].icon, label: Text(destinations[i].label))),
                  const SizedBox(width: 6),
                  _UtilityButtons(onRefresh: () => setState(() {})),
                ]),
              ),
            ),
          )
        else
          AppBar(
            titleSpacing: 12,
            title: Row(children: [ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset('assets/images/app_icon.png', width: 36, height: 36)), const SizedBox(width: 8), const Flexible(child: Text('Flowerbonia', overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'serif', fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: .15)))]),
            actions: [_UtilityButtons(onRefresh: () => setState(() {}))],
          ),
        Expanded(child: IndexedStack(index: index, children: pages)),
      ]);
      return Scaffold(
        body: content,
        bottomNavigationBar: desktop ? null : NavigationBar(selectedIndex: index, onDestinationSelected: (i) => setState(() => index = i), destinations: destinations),
      );
    });
  }
}

class _UtilityButtons extends StatelessWidget {
  final VoidCallback onRefresh;
  const _UtilityButtons({required this.onRefresh});
  @override
  Widget build(BuildContext context) {
    final state = ShopState.instance;
    final dark = state.themeMode == ThemeMode.dark;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(tooltip: dark ? 'Light mode' : 'Dark mode', onPressed: state.toggleTheme, icon: Icon(dark ? Icons.light_mode : Icons.dark_mode)),
      IconButton(tooltip: 'Favorites', onPressed: () async { await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FavoritesPage())); onRefresh(); }, icon: Badge(label: Text('${state.favorites.length}'), isLabelVisible: state.favorites.isNotEmpty, child: const Icon(Icons.favorite_outline))),
      IconButton(tooltip: 'Cart', onPressed: () async { await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartPage())); onRefresh(); }, icon: Badge(label: Text('${state.cartCount}'), isLabelVisible: state.cartCount > 0, child: const Icon(Icons.shopping_cart_outlined))),
    ]);
  }
}
