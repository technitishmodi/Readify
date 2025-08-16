import 'dart:ui';
import 'package:Readify/bookpage/boopageRead.dart';
import 'package:Readify/controller/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class Bookdetail extends StatelessWidget {
  final String coverUrl;
  final String imageUrl;
  final String title;
  final String author;
  final String description;
  final String aboutAuthor;
  final double rating;
  final int readCount;
  final int pageCount;

  const Bookdetail({
    super.key,
    required this.coverUrl,
    required this.imageUrl,
    required this.title,
    required this.author,
    required this.description,
    required this.aboutAuthor,
    this.rating = 4.8,
    this.readCount = 2100,
    this.pageCount = 320,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.light_mode_outlined, color: Colors.white),
            onPressed: () => Get.find<ThemeController>().toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () => _shareBook(),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border_outlined, color: Colors.white),
            onPressed: () => _showSnackBar("Bookmark coming soon!"),
          ),
        ],
      ),

      body: Stack(
        children: [
          /// Gradient + Background
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (rect) => LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.9),
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.9),
                ],
              ).createShader(rect),
              blendMode: BlendMode.darken,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: colorScheme.surfaceVariant),
              ),
            ),
          ),

          /// Scrollable Content
          DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.55,
            maxChildSize: 0.95,
            builder: (context, controller) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withOpacity(0.8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: ListView(
                      controller: controller,
                      children: [
                        /// Handle
                        Center(
                          child: Container(
                            width: 50,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        /// Floating Book Cover
                        Center(
                          child: Container(
                            height: screenSize.height * 0.28,
                            width: screenSize.width * 0.5,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.6),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Hero(
                                tag: title,
                                child: Image.network(imageUrl, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        ),

                        /// Title + Author
                        Center(
                          child: Column(
                            children: [
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "by $author",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// Stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _statCard(Icons.star, "${rating.toStringAsFixed(1)}"),
                            _statCard(Icons.people, "${(readCount / 1000).toStringAsFixed(1)}k"),
                            _statCard(Icons.menu_book, "$pageCount pages"),
                          ],
                        ),

                        const SizedBox(height: 30),

                        /// Description
                        _sectionTitle("Description", theme, colorScheme),
                        Text(
                          description,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 28),

                        /// About Author
                        _sectionTitle("About the Author", theme, colorScheme),
                        Text(
                          aboutAuthor,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),

      /// Floating Center Action Button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton.extended(
          onPressed: () => Get.to(() => Boopageread(pdfUrl: coverUrl)),
          backgroundColor: colorScheme.primary,
          icon: const Icon(Icons.menu_book_outlined, size: 26),
          label: const Text("Read Now", style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.purple.withOpacity(0.6), Colors.blue.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  void _shareBook() {
    Share.share(
      'Check out "$title" by $author - A must read!',
      subject: 'Book Recommendation: $title',
    );
  }

  void _showSnackBar(String message) {
    Get.snackbar(
      "Info",
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }
}
