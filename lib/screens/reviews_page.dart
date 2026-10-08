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
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1020 ? 3 : width >= 630 ? 2 : 1;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          children: [
            const SectionTitle(
              eyebrow: 'Reviews',
              title: 'Sabi ng aming customers',
              subtitle: 'Thoughts and lovely experiences from our flower-loving customers.',
            ),
            const SizedBox(height: 18),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisExtent: 268,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemBuilder: (_, index) {
                final review = reviews[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              i < review.$3 ? Icons.star_rounded : Icons.star_border_rounded,
                              size: 19,
                              color: const Color(0xFFF1B237),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              review.$2,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.55),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(review.$1, style: const TextStyle(fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
