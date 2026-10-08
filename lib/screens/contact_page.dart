import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/section_title.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SectionTitle(eyebrow: 'Contact', title: 'Let’s make someone’s day bloom', subtitle: 'Questions about an order, bouquet, or special request? Send us a message.'),
        const SizedBox(height: 20),
        LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth > 820;
          final info = Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Image.asset('assets/images/contact-img.png', height: 220, fit: BoxFit.contain),
                const SizedBox(height: 16),
                const _ContactRow(svg: 'assets/svg/phone.svg', title: 'Phone', value: '+63 900 123 4567'),
                const _ContactRow(svg: 'assets/svg/mail.svg', title: 'Email', value: 'hello@reneordershop.com'),
                const _ContactRow(svg: 'assets/svg/location.svg', title: 'Location', value: 'Philippines'),
                const _ContactRow(svg: 'assets/svg/clock.svg', title: 'Shop hours', value: 'Mon–Sat • 9:00 AM–6:00 PM'),
              ]),
            ),
          );
          final form = Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text('Send a message', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                const TextField(decoration: InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                const TextField(keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                const TextField(maxLines: 5, decoration: InputDecoration(labelText: 'Message', alignLabelWithHint: true, border: OutlineInputBorder())),
                const SizedBox(height: 14),
                FilledButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message prepared. Connect this form to your email or backend before publishing.'))), icon: const Icon(Icons.send_rounded), label: const Text('Send message')),
              ]),
            ),
          );
          return wide ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: info), const SizedBox(width: 18), Expanded(child: form)]) : Column(children: [info, const SizedBox(height: 16), form]);
        })
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  final String svg;
  final String title;
  final String value;
  const _ContactRow({required this.svg, required this.title, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(children: [
      Container(width: 46, height: 46, padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(14)), child: SvgPicture.asset(svg, colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onPrimaryContainer, BlendMode.srcIn))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), Text(value)]))
    ]),
  );
}
