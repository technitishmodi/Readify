import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAdmin extends StatelessWidget {
  const AboutAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('About Developer'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Hero Profile Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blueAccent.withOpacity(0.1),
                    Colors.blueAccent.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 70,
                      backgroundImage: AssetImage('assets/images/dev.jpg'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Nitish Modi',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.blueAccent.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Full Stack Developer & Cybersecurity Enthusiast',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // About Me Section
            _buildModernCard(
              context,
              title: 'About Me',
              icon: Icons.person_outline,
              content:
                  "I am a passionate Full Stack App Developer currently in my 3rd year of pursuing a Bachelor's degree in Computer Science Engineering at St. Andrews Institute of Technology and Management.\n\n"
                  "With a strong foundation in modern technologies such as Flutter and Dart, I specialize in crafting scalable, user-centric mobile applications. My focus lies in building intuitive UIs and clean architectures that deliver seamless digital experiences.\n\n"
                  "In addition to app development, I am a dedicated cybersecurity enthusiast with hands-on knowledge in areas like Network Security, Phishing Detection, Data Encryption & Decryption, Vulnerability Assessment, and the OWASP Top 10. My insights into ethical hacking and the dark web ecosystem further strengthen my approach to secure coding and threat mitigation.\n\n"
                  "By combining development and security expertise, I aim to create impactful, resilient software that not only functions beautifully but stands strong against evolving digital threats.",
            ),

            const SizedBox(height: 24),

            // Contact Section
            _buildModernContactSection(context),

            const SizedBox(height: 24),

            // Social Media
            _buildSocialMediaSection(context),

            const SizedBox(height: 32),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '  ${DateTime.now().year} Nitish Modi. All rights reserved.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernCard(BuildContext context,
      {required String title,
      required IconData icon,
      required String content}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: Colors.blueAccent),
              const SizedBox(width: 16),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernContactSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.contact_mail, size: 24, color: Colors.blueAccent),
              const SizedBox(width: 16),
              Text(
                'Contact Me',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.email,
            label: 'Email',
            value: 'nubhawbarnwal@gmail.com',
            onTap: () => _launchEmail('nubhawbarnwal@gmail.com'),
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.phone,
            label: 'Phone',
            value: '8434997573',
            onTap: () => _launchPhone('8434997573'),
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.code,
            label: 'GitHub',
            value: 'github.com/technitishmodi',
            onTap: () => _launchUrl('https://github.com/technitishmodi'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.blueAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.public, size: 24, color: Colors.blueAccent),
              const SizedBox(width: 16),
              Text(
                'Social Media',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon(FontAwesomeIcons.instagram,
                  () => _launchUrl('https://www.instagram.com/nitishmodi21/')),
              const SizedBox(width: 16),
              _buildSocialIcon(
                  Icons.link,
                  () => _launchUrl(
                      'https://www.linkedin.com/in/nitish-modi-206205294/')),
              const SizedBox(width: 16),
              _buildSocialIcon(Icons.public,
                  () => _launchUrl('https://nitishmodi.netlify.appp')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.blueAccent.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 24,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
