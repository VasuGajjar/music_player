import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../music_player.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        borderRadius: BorderRadius.circular(Constant.radiusLarge),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(Constant.paddingMedium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8, left: 16, top: 4),
                  child: Text('About', style: TextStyles.h2Bold),
                ),
              ),
              const ListTile(
                leading: CircleAvatar(
                  radius: 26,
                  backgroundImage: NetworkImage('https://avatars.githubusercontent.com/u/57998277?v=4'),
                ),
                title: Text('Vasu Gajjar', style: TextStyles.p1Bold),
                subtitle: Text('Developer'),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Connect with me', style: TextStyles.p1Bold),
                ),
              ),
              ListTile(
                onTap: launchInsta,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                leading: IconButton(
                  onPressed: launchInsta,
                  icon: const Icon(PhosphorIcons.instagramLogo),
                  color: AppColor.red,
                ),
                title: const Text('@vasu_gajjar', style: TextStyles.p1Bold),
                subtitle: const Text('Instagram'),
              ),
              ListTile(
                onTap: launchLinkedin,
                minVerticalPadding: 4,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                leading: IconButton(
                  onPressed: launchLinkedin,
                  icon: const Icon(PhosphorIcons.linkedinLogo),
                  color: AppColor.skyBlue,
                ),
                title: const Text('Vasu Gajjar', style: TextStyles.p1Bold),
                subtitle: const Text('Linkedin'),
              ),
              ListTile(
                onTap: launchGithub,
                minVerticalPadding: 4,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                leading: IconButton(
                  onPressed: launchGithub,
                  icon: const Icon(PhosphorIcons.githubLogo),
                  color: AppColor.darkGray,
                ),
                title: const Text('VasuGajjar', style: TextStyles.p1Bold),
                subtitle: const Text('Github'),
              ),
              const Text('Made with Love ❤️ in Flutter', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  void launchInsta() => _launchUrl('https://www.instagram.com/vasu_gajjar/');

  void launchLinkedin() => _launchUrl('https://www.linkedin.com/in/vasu-gajjar-ba22751b3/');

  void launchGithub() => _launchUrl('https://github.com/VasuGajjar');

  Future<void> _launchUrl(String url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}
