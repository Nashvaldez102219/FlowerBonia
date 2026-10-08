import 'package:flutter/material.dart';
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
