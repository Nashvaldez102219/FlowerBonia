import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../state/shop_state.dart';
import 'contact_page.dart';

/// Replaces the old Contact tab in the main navigation.
/// Contact Us is still available from here, along with theme and logout.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _openContact(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Contact Us')),
          body: const ContactPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final state = ShopState.instance;
    final colors = Theme.of(context).colorScheme;
    final isDark = state.themeMode == ThemeMode.dark;
    final rawName = user?.displayName?.trim() ?? '';
    final name = rawName.isEmpty ? 'Flowerbonia Customer' : rawName;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'My Profile',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your account and shop settings',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 27,
                          backgroundColor: colors.primaryContainer,
                          child: Icon(Icons.person_rounded,
                              size: 30, color: colors.onPrimaryContainer),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (user?.email != null)
                                Text(
                                  user!.email!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: colors.onSurfaceVariant),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 6,
                        ),
                        leading: const Icon(Icons.contact_mail_outlined),
                        title: const Text('Contact Us'),
                        subtitle: const Text('Questions, orders, and inquiries'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _openContact(context),
                      ),
                      const Divider(height: 1),
                      SwitchListTile.adaptive(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 6,
                        ),
                        secondary: Icon(
                          isDark ? Icons.dark_mode_rounded : Icons.light_mode_outlined,
                        ),
                        title: const Text('Dark mode'),
                        subtitle: Text(isDark ? 'On' : 'Off'),
                        value: isDark,
                        onChanged: (_) => state.toggleTheme(),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 6,
                        ),
                        leading: Icon(Icons.logout_rounded, color: colors.error),
                        title: Text('Log out', style: TextStyle(color: colors.error)),
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
