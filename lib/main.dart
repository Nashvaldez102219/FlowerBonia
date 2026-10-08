import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'screens/about_page.dart';
import 'screens/auth_page.dart';
import 'screens/cart_page.dart';
import 'screens/favorites_page.dart';
import 'screens/home_page.dart';
import 'screens/product_detail_page.dart';
import 'screens/products_page.dart';
import 'screens/profile_page.dart';
import 'screens/reviews_page.dart';
import 'services/user_service.dart';
import 'state/shop_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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

  void _refresh() {
    if (mounted) setState(() {});
  }

  ThemeData _theme(Brightness brightness) {
    const pink = Color(0xFFD82972);
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: pink,
        brightness: brightness,
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFFFFBFC)
          : base.scaffoldBackgroundColor,
      cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        height: 65,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flowerbonia',
      themeMode: ShopState.instance.themeMode,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      home: const AuthGate(),
      routes: {
        // Preserve the named route and return-value navigation lab.
        ProductDetailPage.routeName: (_) => const ProductDetailPage(),
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // Keep the same stream when ShopState rebuilds MaterialApp. Creating a
  // new auth stream on every cart/like update can briefly reset navigation.
  late final Stream<User?> _authState;

  @override
  void initState() {
    super.initState();
    _authState = FirebaseAuth.instance.authStateChanges();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authState,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingPage();
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Login error: ${snapshot.error}', textAlign: TextAlign.center),
            )),
          );
        }
        final user = snapshot.data;
        if (user == null) return const AuthPage();
        return UserBootstrap(key: ValueKey(user.uid), user: user);
      },
    );
  }
}

class UserBootstrap extends StatefulWidget {
  final User user;

  const UserBootstrap({super.key, required this.user});

  @override
  State<UserBootstrap> createState() => _UserBootstrapState();
}

class _UserBootstrapState extends State<UserBootstrap> {
  late Future<void> _setupFuture;

  @override
  void initState() {
    super.initState();
    _setupFuture = _prepareUser();
  }

  Future<void> _prepareUser() async {
    await UserService.instance.ensureCurrentUserProfile();
    await ShopState.instance.loadLikedProductsForUser(widget.user.uid);
  }

  void _retry() {
    setState(() {
      _setupFuture = _prepareUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _setupFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LoadingPage();
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Flowerbonia')),
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_rounded, size: 56),
                      const SizedBox(height: 12),
                      const Text('Could not load your Firestore profile.', textAlign: TextAlign.center),
                      const SizedBox(height: 10),
                      Text('${snapshot.error}', textAlign: TextAlign.center),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: _retry,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Try again'),
                      ),
                      TextButton(
                        onPressed: () => FirebaseAuth.instance.signOut(),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return const ShopShell();
      },
    );
  }
}

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/app_icon.png', width: 84, height: 84),
              const SizedBox(height: 14),
              Text('FLOWERBONIA', style: GoogleFonts.playfairDisplay(
                fontSize: 21, fontWeight: FontWeight.w700,
              )),
              const SizedBox(height: 18),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
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

  void _navigateTo(int newIndex) {
    if (newIndex < 0 || newIndex > 4) return;
    setState(() => index = newIndex);
  }

  void _refreshShell() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onNavigate: _navigateTo),
      const AboutPage(),
      ProductsPage(onProductLiked: () => _navigateTo(0)),
      const ReviewsPage(),
      const ProfilePage(),
    ];

    const destinations = [
      NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.info_outline_rounded), selectedIcon: Icon(Icons.info_rounded), label: 'About'),
      NavigationDestination(icon: Icon(Icons.local_florist_outlined), selectedIcon: Icon(Icons.local_florist_rounded), label: 'Products'),
      NavigationDestination(icon: Icon(Icons.reviews_outlined), selectedIcon: Icon(Icons.reviews_rounded), label: 'Reviews'),
      NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Five desktop nav buttons should only appear when there is enough space.
        final desktop = constraints.maxWidth >= 1150;
        return Scaffold(
          body: Column(
            children: [
              if (desktop)
                _DesktopHeader(
                  currentIndex: index,
                  destinations: destinations,
                  onNavigate: _navigateTo,
                  onRefresh: _refreshShell,
                  onProductLiked: () => _navigateTo(0),
                )
              else
                _MobileHeader(
                  onRefresh: _refreshShell,
                  onProductLiked: () => _navigateTo(0),
                ),
              Expanded(child: IndexedStack(index: index, children: pages)),
            ],
          ),
          bottomNavigationBar: desktop
              ? null
              : NavigationBar(
                  selectedIndex: index,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  onDestinationSelected: _navigateTo,
                  destinations: destinations,
                ),
        );
      },
    );
  }
}

/// Compact mobile bar: only brand + favorites + cart.
/// Account, Contact Us, theme and logout now live under Profile.
class _MobileHeader extends StatelessWidget {
  final VoidCallback onRefresh;
  final VoidCallback onProductLiked;

  const _MobileHeader({
    required this.onRefresh,
    required this.onProductLiked,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 10,
      toolbarHeight: 58,
      title: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              Image.asset(
                'assets/images/app_icon.png',
                width: 30,
                height: 30,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 6),
              Expanded(
                // Scale the *brand only*, so "Flowerbonia" never reads "Flo...".
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Flowerbonia',
                      maxLines: 1,
                      softWrap: false,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        _UtilityButtons(
          onRefresh: onRefresh,
          onProductLiked: onProductLiked,
        ),
        const SizedBox(width: 3),
      ],
    );
  }
}

class _DesktopHeader extends StatelessWidget {
  final int currentIndex;
  final List<NavigationDestination> destinations;
  final ValueChanged<int> onNavigate;
  final VoidCallback onRefresh;
  final VoidCallback onProductLiked;

  const _DesktopHeader({
    required this.currentIndex,
    required this.destinations,
    required this.onNavigate,
    required this.onRefresh,
    required this.onProductLiked,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(
            children: [
              Image.asset('assets/images/app_icon.png', width: 42, height: 42),
              const SizedBox(width: 10),
              Text('Flowerbonia', style: GoogleFonts.playfairDisplay(
                fontSize: 21, fontWeight: FontWeight.w700,
              )),
              const Spacer(),
              ...List.generate(destinations.length, (i) {
                final selected = currentIndex == i;
                return TextButton.icon(
                  onPressed: () => onNavigate(i),
                  style: TextButton.styleFrom(
                    foregroundColor: selected ? colors.primary : colors.onSurfaceVariant,
                  ),
                  icon: selected ? destinations[i].selectedIcon : destinations[i].icon,
                  label: Text(destinations[i].label),
                );
              }),
              const SizedBox(width: 12),
              _UtilityButtons(
                onRefresh: onRefresh,
                onProductLiked: onProductLiked,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Favorites and cart stay accessible; account actions moved to Profile.
class _UtilityButtons extends StatelessWidget {
  final VoidCallback onRefresh;
  final VoidCallback onProductLiked;

  const _UtilityButtons({
    required this.onRefresh,
    required this.onProductLiked,
  });

  @override
  Widget build(BuildContext context) {
    final state = ShopState.instance;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          tooltip: 'Favorites',
          onPressed: () async {
            final result = await Navigator.of(context).push<String>(
              MaterialPageRoute<String>(builder: (_) => const FavoritesPage()),
            );
            if (!context.mounted) return;
            if (result != null) {
              onProductLiked();
            }
            onRefresh();
          },
          icon: Badge(
            label: Text('${state.favorites.length}'),
            isLabelVisible: state.favorites.isNotEmpty,
            child: const Icon(Icons.favorite_border_rounded, size: 22),
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          tooltip: 'Cart',
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CartPage()),
            );
            onRefresh();
          },
          icon: Badge(
            label: Text('${state.cartCount}'),
            isLabelVisible: state.cartCount > 0,
            child: const Icon(Icons.shopping_cart_outlined, size: 22),
          ),
        ),
      ],
    );
  }
}
