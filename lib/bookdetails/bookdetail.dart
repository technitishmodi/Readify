import 'dart:ui';
import 'dart:io';
import 'package:Readify/bookpage/boopageRead.dart';
import 'package:Readify/bookpage/listening_screen.dart';
import 'package:Readify/controller/theme_controller.dart';
import 'package:Readify/controller/bookmark_controller.dart';
import 'package:Readify/models/bookmodel.dart';
import 'package:Readify/profilepage/ProFilepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

final _auth = FirebaseAuth.instance;

class Bookdetail extends StatefulWidget {
  final String coverUrl;
  final String imageUrl;
  final String title;
  final String author;
  final String description;
  final String aboutAuthor;
  final double rating;
  final int readCount;
  final int pageCount;
  final String? bookId;
  final String? category;

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
    this.bookId,
    this.category,
  });

  @override
  State<Bookdetail> createState() => _BookdetailState();
}

class _BookdetailState extends State<Bookdetail> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final BookmarkController bookmarkController = Get.put(BookmarkController());

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () => _shareBook(),
            tooltip: 'Share Book',
          ),
          Obx(() {
            final isBookmarked = widget.bookId != null
                ? bookmarkController.isBookmarked(widget.bookId!)
                : false;

            return IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isBookmarked
                      ? Icons.bookmark
                      : Icons.bookmark_border_outlined,
                  color: isBookmarked ? Colors.blueAccent : Colors.white,
                  key: ValueKey(isBookmarked),
                ),
              ),
              onPressed: () => _handleBookmark(),
              tooltip: isBookmarked ? 'Remove Bookmark' : 'Add Bookmark',
            );
          }),
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
                widget.imageUrl,
                fit: BoxFit.contain, // keeps full image visible
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) =>
                    Container(color: colorScheme.surfaceContainerHighest),
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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(36)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withOpacity(0.8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
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
                                      color: Colors.blueAccent.withOpacity(0.6),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Hero(
                                    tag: widget.title,
                                    child: Image.network(
                                      widget.imageUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => Container(
                                        color:
                                            colorScheme.surfaceContainerHighest,
                                        child: const Icon(Icons.book, size: 50),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            /// Title + Author
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    widget.title,
                                    textAlign: TextAlign.center,
                                    style:
                                        theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "by ${widget.author}",
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
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
                                _statCard(Icons.star,
                                    "${widget.rating.toStringAsFixed(1)}"),
                                _statCard(Icons.people,
                                    "${(widget.readCount / 1000).toStringAsFixed(1)}k"),
                                _statCard(Icons.menu_book,
                                    "${widget.pageCount} pages"),
                              ],
                            ),

                            const SizedBox(height: 30),

                            /// Description
                            _sectionTitle("Description", theme, colorScheme),
                            Text(
                              widget.description,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.6,
                              ),
                            ),

                            const SizedBox(height: 28),

                            /// About Author
                            _sectionTitle(
                                "About the Author", theme, colorScheme),
                            Text(
                              widget.aboutAuthor,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),

      /// Floating Action Buttons
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton.extended(
              onPressed: () => Get.to(() => ListeningScreen(
                    pdfUrl: widget.coverUrl,
                    bookTitle: widget.title,
                    author: widget.author,
                    coverImageUrl: widget.imageUrl,
                  )),
              backgroundColor: Colors.blueAccent.shade400,
              heroTag: "listen",
              icon: const Icon(Icons.headphones, size: 24),
              label: const Text("Listen", style: TextStyle(fontSize: 14)),
            ),
            FloatingActionButton.extended(
              onPressed: () => Get.to(() => Boopageread(
                    pdfUrl: widget.coverUrl,
                    bookId: widget.bookId ?? '',
                    bookTitle: widget.title,
                  )),
              backgroundColor: Colors.blueAccent,
              heroTag: "read",
              icon: const Icon(Icons.menu_book_outlined, size: 26),
              label: const Text("Read Now", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.blueAccent.withOpacity(0.8),
            Colors.blueAccent.shade700.withOpacity(0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
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
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  void _shareBook() async {
    try {
      final bookTitle = widget.title;
      final bookAuthor = widget.author;
      final bookUrl = widget.coverUrl;
      final imageUrl = widget.imageUrl;

      // Show sharing options dialog
      Get.dialog(
        AlertDialog(
          title: const Text('Share Book'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (bookUrl.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  title: const Text('Share PDF File'),
                  subtitle: const Text('Download and share the actual PDF'),
                  onTap: () async {
                    Get.back();
                    await _shareFile(
                        bookUrl,
                        '${bookTitle.replaceAll(' ', '_')}.pdf',
                        'application/pdf');
                  },
                ),
              if (imageUrl.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.image, color: Colors.blue),
                  title: const Text('Share Cover Image'),
                  subtitle: const Text('Download and share the book cover'),
                  onTap: () async {
                    Get.back();
                    await _shareFile(
                        imageUrl,
                        '${bookTitle.replaceAll(' ', '_')}_cover.jpg',
                        'image/jpeg');
                  },
                ),
              ListTile(
                leading: const Icon(Icons.text_fields, color: Colors.green),
                title: const Text('Share Book Details'),
                subtitle: const Text('Share as text with links'),
                onTap: () async {
                  Get.back();
                  await Share.share(
                    '📚 Book Recommendation: "$bookTitle"\n'
                    '👤 Author: $bookAuthor\n\n'
                    '📖 Description: ${widget.description}\n\n'
                    '🔗 PDF Link: $bookUrl\n'
                    '🖼️ Cover: $imageUrl\n\n'
                    'Shared from Readify App',
                    subject: 'Book Recommendation: $bookTitle',
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showSnackBar('Failed to share book: ${e.toString()}');
    }
  }

  Future<void> _shareFile(String url, String fileName, String mimeType) async {
    try {
      // Show loading dialog
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // Download the file
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to download file');
      }

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');

      // Write file
      await file.writeAsBytes(response.bodyBytes);

      Get.back(); // Close loading dialog

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path, mimeType: mimeType)],
        text: 'Shared from Readify app',
      );
    } catch (e) {
      Get.back(); // Close loading dialog if open
      _showSnackBar('Failed to share file: ${e.toString()}');
    }
  }

  void _handleBookmark() async {
    final user = _auth.currentUser;
    if (user == null) {
      _showSnackBar("Please sign in to bookmark books");
      return;
    }

    // Create a Bookmodel object for bookmarking
    final book = Bookmodel(
      id: widget.bookId,
      title: widget.title,
      auther: widget.author,
      descriptions: widget.description,
      aboutAuthor: widget.aboutAuthor,
      imageUrl: widget.imageUrl,
      bookUrl: widget.coverUrl,
      ratings: widget.rating.toString(),
      category: widget.category,
      visibility: 'public',
    );

    await bookmarkController.toggleBookmark(book);

    // Navigate to profile page after bookmarking
    if (bookmarkController.isBookmarked(widget.bookId!)) {
      await Future.delayed(const Duration(milliseconds: 500));
      Get.to(() => Profilepage(
            userName: user.displayName ?? 'User',
            userEmail: user.email ?? '',
            userPhoto: user.photoURL,
          ));
    }
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
