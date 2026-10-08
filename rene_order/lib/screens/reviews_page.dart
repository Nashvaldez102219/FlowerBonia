import 'package:flutter/material.dart';
import '../widgets/section_title.dart';

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key});

  static const reviews = [
    ('Ana M.', '“Ang ganda ng flowers! Maayos ang arrangement at sobrang bagay pang-regalo. Ang saya ng nanay ko nang matanggap niya.”', 5),
    ('Carlo P.', '“Mabilis umorder at malinaw ang choices. Gustong-gusto ko yung red tulips, mukhang elegant pero hindi sobra.”', 5),
    ('Mika R.', '“Ang cute ng shop at ang dali gamitin ng favorites. Na-save ko muna yung gusto ko bago ako pumili.”', 5),
    ('Jessa L.', '“Maganda ang presentation at very fresh tingnan. Sulit para sa simpleng surprise sa kaibigan.”', 4),
    ('Paolo D.', '“Smooth gamitin sa phone. Nagustuhan ko rin na may dark mode at mabilis mag-add sa cart.”', 5),
    ('Bea S.', '“Simple pero classy. Ang soft ng pink theme at ang dali hanapin ng contact details.”', 5),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SectionTitle(eyebrow: 'Reviews', title: 'Sabi ng aming customers', subtitle: 'Mga simpleng salitang galing sa mga taong natuwa sa flowers at shopping experience.'),
        const SizedBox(height: 18),
        LayoutBuilder(builder: (context, constraints) {
          final count = constraints.maxWidth >= 900 ? 3 : constraints.maxWidth >= 560 ? 2 : 1;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: count, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.25),
            itemCount: reviews.length,
            itemBuilder: (_, index) {
              final r = reviews[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: List.generate(5, (i) => Icon(i < r.$3 ? Icons.star_rounded : Icons.star_border_rounded, size: 20, color: Theme.of(context).colorScheme.primary))),
                    const SizedBox(height: 14),
                    Expanded(child: Text(r.$2, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55))),
                    const SizedBox(height: 14),
                    Text(r.$1, style: const TextStyle(fontWeight: FontWeight.w900)),
                  ]),
                ),
              );
            },
          );
        })
      ],
    );
  }
}
