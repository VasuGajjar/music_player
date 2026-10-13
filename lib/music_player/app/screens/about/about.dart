import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    Widget link(IconData icon, String title, String subtitle, String url) => ListTile(
          onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: Icon(PhosphorIcons.arrowUpRight, size: 16, color: muted),
        );

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              leading: CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage('https://avatars.githubusercontent.com/u/57998277?v=4'),
              ),
              title: Text('Vasu Gajjar', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              subtitle: Text('Developer'),
            ),
            const SizedBox(height: 8),
            link(PhosphorIcons.instagramLogo, '@vasu_gajjar', 'Instagram', 'https://www.instagram.com/vasu_gajjar/'),
            link(PhosphorIcons.linkedinLogo, 'Vasu Gajjar', 'LinkedIn', 'https://www.linkedin.com/in/vasu-gajjar-ba22751b3/'),
            link(PhosphorIcons.githubLogo, 'VasuGajjar', 'GitHub', 'https://github.com/VasuGajjar'),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text('Made with Flutter', style: TextStyle(fontSize: 12, color: muted)),
            ),
          ],
        ),
      ),
    );
  }
}
