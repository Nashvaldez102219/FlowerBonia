import 'package:flutter/material.dart';
import '../models/product.dart';
import '../state/shop_state.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final state = ShopState.instance;
    final entries = state.cart.entries.toList();
    final total = entries.fold<double>(0, (sum, e) => sum + products.firstWhere((p) => p.id == e.key).price * e.value);
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: entries.isEmpty
          ? const Center(child: Padding(padding: EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.shopping_bag_outlined, size: 64), SizedBox(height: 12), Text('Your cart is empty. Add a flower and it will appear here.')])) )
          : Column(children: [
              Expanded(child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final entry = entries[i];
                  final p = products.firstWhere((x) => x.id == entry.key);
                  return Card(child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
                    ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.asset(p.image, width: 76, height: 76, fit: BoxFit.cover)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.name, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text('₱${p.price.toStringAsFixed(0)} each'), const SizedBox(height: 8), Row(children: [IconButton(onPressed: () async { await state.setQuantity(p.id, entry.value - 1); setState(() {}); }, icon: const Icon(Icons.remove_circle_outline)), Text('${entry.value}', style: const TextStyle(fontWeight: FontWeight.w800)), IconButton(onPressed: () async { await state.setQuantity(p.id, entry.value + 1); setState(() {}); }, icon: const Icon(Icons.add_circle_outline))]) ])),
                    IconButton(onPressed: () async { await state.removeFromCart(p.id); setState(() {}); }, icon: const Icon(Icons.delete_outline))
                  ])));
                },
              )),
              SafeArea(top: false, child: Padding(padding: const EdgeInsets.fromLTRB(16, 10, 16, 16), child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Total'), Text('₱${total.toStringAsFixed(0)}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900))])), FilledButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checkout demo ready. Connect your payment/order backend before publishing.'))), icon: const Icon(Icons.lock_outline), label: const Text('Checkout'))])))))
            ]),
    );
  }
}
