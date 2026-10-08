import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../widgets/section_title.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});
  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late final VideoPlayerController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/video/about.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        if (mounted) setState(() => _ready = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SectionTitle(eyebrow: 'About us', title: 'Flowers with warmth, color, and care', subtitle: 'FLOWERBONIA is a mini flower shop built around easy gifting, beautiful arrangements, and a soft modern aesthetic.'),
        const SizedBox(height: 24),
        LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth > 850;
          final video = ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: AspectRatio(
              aspectRatio: _ready ? _controller.value.aspectRatio : 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: colors.surfaceContainerHighest),
                  if (_ready) VideoPlayer(_controller) else const Center(child: CircularProgressIndicator()),
                  if (_ready)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: .45)])),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FilledButton.tonalIcon(
                              onPressed: () => setState(() => _controller.value.isPlaying ? _controller.pause() : _controller.play()),
                              icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
                              label: Text(_controller.value.isPlaying ? 'Pause video' : 'Play video'),
                            )
                          ],
                        ),
                      ),
                    )
                ],
              ),
            ),
          );
          final story = Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Our little flower story', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Text('We believe flowers do not need a special occasion. A simple bouquet can say “salamat,” “ingat,” “congratulations,” or “I remembered you.” Our collection focuses on joyful colors, clean arrangements, and easy ordering.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.65)),
                const SizedBox(height: 18),
                const _Value(icon: Icons.favorite_rounded, title: 'Made for meaningful moments', text: 'From birthdays to simple surprises, every arrangement is designed to feel personal.'),
                const _Value(icon: Icons.local_florist_rounded, title: 'Fresh-looking design', text: 'Our product style celebrates tulips, roses, greens, and soft romantic palettes.'),
                const _Value(icon: Icons.phone_android_rounded, title: 'Easy mobile shopping', text: 'Save favorites, add items to cart, and browse comfortably in light or dark mode.'),
              ]),
            ),
          );
          return wide ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: video), const SizedBox(width: 24), Expanded(child: story)]) : Column(children: [video, const SizedBox(height: 18), story]);
        })
      ],
    );
  }
}

class _Value extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  const _Value({required this.icon, required this.title, required this.text});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CircleAvatar(child: Icon(icon)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(text)]))
    ]),
  );
}
