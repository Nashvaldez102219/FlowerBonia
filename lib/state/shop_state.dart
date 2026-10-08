import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopState extends ChangeNotifier {
  ShopState._();
  static final ShopState instance = ShopState._();

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  final Set<String> _favorites = <String>{};
  Set<String> get favorites => Set.unmodifiable(_favorites);

  final Map<String, int> _cart = <String, int>{};
  Map<String, int> get cart => Map.unmodifiable(_cart);

  int get cartCount => _cart.values.fold(0, (a, b) => a + b);

  // The PDF lab still returns a product name for the "You liked" banner.
  String? _lastSelectedProduct;
  String? get lastSelectedProduct => _lastSelectedProduct;

  // Liked flowers are separate from Favorites. They appear in the
  // personalized Home carousel in newest-first order, without duplicates.
  final List<String> _likedProductIds = <String>[];
  List<String> get likedProductIds => List.unmodifiable(_likedProductIds);
  String? _likedOwnerUid;

  /// Called when Firebase Authentication confirms the signed-in user.
  /// Preferences are namespaced by UID so two accounts on the same phone
  /// will not share their liked-flower list.
  Future<void> loadLikedProductsForUser(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    _likedOwnerUid = uid;
    _likedProductIds
      ..clear()
      ..addAll(prefs.getStringList('flowerbonia_liked_$uid') ?? const []);
    _lastSelectedProduct = null;
    notifyListeners();
  }

  /// Called after Product Detail pops with the chosen flower name.
  /// Keeps the lab's return-data behavior and adds this flower to Home.
  Future<void> selectLikedProduct(String productName) async {
    final name = productName.trim();
    if (name.isEmpty) return;
    _lastSelectedProduct = name;

    final matches = products.where((product) => product.name == name);
    if (matches.isNotEmpty) {
      final id = matches.first.id;
      _likedProductIds.remove(id);
      _likedProductIds.insert(0, id);
    }
    notifyListeners();
    await _saveLikedProducts();
  }

  /// Remove a flower from the personalized Home carousel. The item will
  /// still be available in the full Products catalog.
  Future<void> removeLikedProduct(String id) async {
    if (!_likedProductIds.remove(id)) return;
    final removed = products.where((p) => p.id == id);
    if (removed.isNotEmpty && _lastSelectedProduct == removed.first.name) {
      _lastSelectedProduct = null;
    }
    notifyListeners();
    await _saveLikedProducts();
  }

  // Dismiss only the lab banner; keep the saved liked flowers.
  void clearLikedProduct() {
    if (_lastSelectedProduct == null) return;
    _lastSelectedProduct = null;
    notifyListeners();
  }

  Future<void> _saveLikedProducts() async {
    final uid = _likedOwnerUid;
    if (uid == null) return; // User profile is still being prepared.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('flowerbonia_liked_$uid', _likedProductIds);
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = prefs.getBool('darkMode') ?? false ? ThemeMode.dark : ThemeMode.light;
    _favorites
      ..clear()
      ..addAll(prefs.getStringList('favorites') ?? const []);
    _cart.clear();
    for (final row in prefs.getStringList('cart') ?? const []) {
      final parts = row.split(':');
      if (parts.length == 2) {
        final quantity = int.tryParse(parts[1]);
        if (quantity != null && quantity > 0) _cart[parts[0]] = quantity;
      }
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _themeMode == ThemeMode.dark);
  }

  bool isFavorite(String id) => _favorites.contains(id);

  Future<void> toggleFavorite(String id) async {
    if (!_favorites.add(id)) _favorites.remove(id);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites.toList());
  }

  Future<void> addToCart(String id) async {
    _cart[id] = (_cart[id] ?? 0) + 1;
    notifyListeners();
    await _saveCart();
  }

  Future<void> setQuantity(String id, int quantity) async {
    if (quantity <= 0) {
      _cart.remove(id);
    } else {
      _cart[id] = quantity;
    }
    notifyListeners();
    await _saveCart();
  }

  Future<void> removeFromCart(String id) async {
    _cart.remove(id);
    notifyListeners();
    await _saveCart();
  }

  Future<void> clearCart() async {
    _cart.clear();
    notifyListeners();
    await _saveCart();
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('cart', _cart.entries.map((e) => '${e.key}:${e.value}').toList());
  }
}
