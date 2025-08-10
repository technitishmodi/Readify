import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAdmin extends StatelessWidget {
  const AboutAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Developer'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/images/dev.jpg'),
            ),
            const SizedBox(height: 20),
            Text(
              'Nitish Modi',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Developer & Cyber Security Enthusiast',
              style: TextStyle(color: Colors.blue),
            ),
            const SizedBox(height: 10),
            const Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _buildInfoCard(context,
                title: 'About Me',
                content:
                    "I am a passionate Full Stack App Developer currently in my 3rd year of pursuing a Bachelor’s degree in Computer Science Engineering at St. Andrews Institute of Technology and Management.\n\n"
                    "With a strong foundation in modern technologies such as Flutter and Dart, I specialize in crafting scalable, user-centric mobile applications. My focus lies in building intuitive UIs and clean architectures that deliver seamless digital experiences.\n\n"
                    "___I independently designed and developed Readify___.\n\n"
                    "In addition to app development, I am a dedicated cybersecurity enthusiast with hands-on knowledge in areas like Network Security, Phishing Detection, Data Encryption & Decryption, Vulnerability Assessment, and the OWASP Top 10. My insights into ethical hacking and the dark web ecosystem further strengthen my approach to secure coding and threat mitigation.\n\n"
                    "By combining development and security expertise, I aim to create impactful, resilient software that not only functions beautifully but stands strong against evolving digital threats."),
            const SizedBox(height: 30),
            _buildInfoCard(
              context,
              title: 'About Readify',
              content:
                  'Readify is a modern, community-powered mobile application designed to enhance the way users access and share eBooks. Built with Flutter and Dart, Readify allows anyone to upload, read, and listen to PDFs in a beautifully designed, interactive environment. The app combines the power of Firebase and Supabase to provide secure user authentication, efficient cloud storage, and real-time features that keep the experience fast and reliable.\n\n'
                  '🔐 Secure Sign-In\n'
                  'Sign in seamlessly with Google using Firebase Authentication.\n\n'
                  '📤 Upload eBooks\n'
                  'Share your favorite books by uploading PDFs along with a title, author name, and cover image.\n\n'
                  '📖 In-App Reading\n'
                  'Enjoy a distraction-free reading experience with a built-in PDF viewer that supports bookmarks and dark mode.\n\n'
                  '🗣️ Text-to-Speech (TTS)\n'
                  'Turn any eBook into an audiobook with our integrated text-to-speech functionality.\n\n'
                  '💬 Community Thoughts\n'
                  'Connect with other readers by sharing posts, liking thoughts, and participating in the community.\n\n'
                  '📚 Request Books\n'
                  'Can’t find a book? Request it from the community and get notified when it’s uploaded.\n\n'
                  '📁 Personal Library\n'
                  'Easily access and manage the books you’ve uploaded to your personal collection.\n\n'
                  '📈 Trending Books\n'
                  'Discover popular and highly engaged books within the Readify community.\n\n'
                  '🖌️ Responsive UI\n'
                  'A clean, user-friendly interface optimized for all screen sizes with support for light and dark modes.\n',
            ),
            const SizedBox(height: 20),
            _buildContactSection(context),
            const SizedBox(height: 20),
            _buildSocialMediaLinks(),
            const SizedBox(height: 30),
            Text(
              '© ${DateTime.now().year} Readify. All rights reserved.',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context,
      {required String title, required String content}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Me',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 15),
            _buildContactItem(
              icon: Icons.email,
              label: 'Email',
              value: 'nubhawbarnwal@gmail.com', // Your email
              onTap: () => _launchEmail('nubhawbarnwal@gmail.com'),
            ),
            const Divider(height: 30),
            _buildContactItem(
              icon: Icons.phone,
              label: 'Phone',
              value: '8434997573', // Your phone
              onTap: () => _launchPhone('8434997573'),
            ),
            const Divider(height: 30),
            _buildContactItem(
              icon: Icons.code,
              label: 'GitHub',
              value: 'github.com/yourusername', // Your GitHub
              onTap: () => _launchUrl('https://github.com/yourusername'),
            ),
          ],
        ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.blue),
          const SizedBox(width: 15),
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

  Widget _buildSocialMediaLinks() {
    return Column(
      children: [
        const Text(
          'Connect With Me',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(FontAwesomeIcons.instagram,
                () => _launchUrl('https://www.instagram.com/nitishmodi21/')),
            const SizedBox(width: 20),
            _buildSocialIcon(
                Icons.link,
                () => _launchUrl(
                    'https://www.linkedin.com/in/nitish-modi-206205294/')),
            const SizedBox(width: 20),
            _buildSocialIcon(
                Icons.public, () => _launchUrl('https://yourwebsite.com')),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 30, color: Colors.blue),
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
