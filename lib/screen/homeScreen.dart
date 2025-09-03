import 'dart:async';
import 'package:Readify/bookdetails/bookdetail.dart';
import 'package:Readify/components/bookcard.dart';
import 'package:Readify/controller/Bookcontroller.dart';
import 'package:Readify/controller/bookmark_controller.dart';
import 'package:Readify/models/bookmodel.dart';
import 'package:Readify/pages/CategoryBooksPage.dart';
import 'package:Readify/profilepage/ProFilepage.dart';
import 'package:Readify/profilepage/TrendingBooksPage.dart';
import 'package:Readify/screen/aboutAdmin.dart';
import 'package:Readify/screen/admin_page.dart';
import 'package:Readify/screen/reading_analytics_screen.dart';
import 'package:Readify/screen/reading_goals_screen.dart';
import 'package:Readify/screen/ai_insights_screen.dart';
import 'package:Readify/screen/smart_bookmarks_screen.dart';
import 'package:Readify/screen/signup_screen.dart';
import 'package:Readify/th&&re/request_book.dart';
import 'package:Readify/th&&re/thoughts_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

class HomePage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String? userPhoto;

  const HomePage({
    super.key,
    required this.userName,
    required this.userEmail,
    this.userPhoto,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final RxBool _isSearching = false.obs;
  final RxList<Bookmodel> _searchResults = <Bookmodel>[].obs;
  final RxString _selectedCategory = ''.obs;
  final _searchDebouncer = Debouncer(milliseconds: 300);
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
    
    // Debug: Print user info on initialization
    print('HomePage initialized with:');
    print('  userName: ${widget.userName}');
    print('  userEmail: ${widget.userEmail}');
    print('  Admin check: ${widget.userEmail == "modinitish905@gmail.com"}');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchDebouncer.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Sign Out",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              "Sign Out",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        // Show loading indicator
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        final bookController = Get.find<BookController>();
        bookController.clearAllData();
        
        await FirebaseFirestore.instance.clearPersistence();
        await GoogleSignIn().signOut();
        await FirebaseAuth.instance.signOut();

        // Close loading indicator
        Get.back();

        // Navigate to SignupScreen and clear navigation stack
        Get.offAll(() => const SignupScreen());
      } catch (e) {
        // Close loading indicator if still open
        if (Get.isDialogOpen ?? false) Get.back();
        
        _showErrorSnackBar('Failed to sign out. Please try again.');
      }
    }
  }

  Future<void> _refreshData() async {
    try {
      final bookController = Get.find<BookController>();
      await Future.wait([
        bookController.fetchBooks(),
        bookController.fetchUserBooks(),
      ]);
    } catch (e) {
      _showErrorSnackBar('Failed to refresh data');
    }
  }

  void _searchBooks(String query) {
    _searchDebouncer.run(() {
      if (query.isEmpty) {
        _isSearching.value = false;
        _searchResults.clear();
        return;
      }

      _isSearching.value = true;
      final bookController = Get.find<BookController>();
      final lowerCaseQuery = query.toLowerCase();
      
      _searchResults.value = bookController.bookData.where((book) {
        final titleMatch = book.title?.toLowerCase().contains(lowerCaseQuery) ?? false;
        final authorMatch = book.auther?.toLowerCase().contains(lowerCaseQuery) ?? false;
        return titleMatch || authorMatch;
      }).toList();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _isSearching.value = false;
    _searchResults.clear();
    _searchFocusNode.unfocus();
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _filterBooksByCategory(String category) {
    final bookController = Get.find<BookController>();
    if (category.isEmpty) {
      // Show all books
      bookController.fetchBooks();
    } else {
      // Filter books by category
      final filteredBooks = bookController.bookData.where((book) => 
        book.category?.toLowerCase() == category.toLowerCase()).toList();
      bookController.bookData.value = filteredBooks;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bookController = Get.put(BookController());
    final bookmarkController = Get.put(BookmarkController());
    final isAdmin = widget.userEmail == 'modinitish905@gmail.com';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: colorScheme.surface,
        appBar: _buildAppBar(colorScheme),
        drawer: _ModernDrawer(
          userName: widget.userName,
          userEmail: widget.userEmail,
          userPhoto: widget.userPhoto,
          onSignOut: _signOut,
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: colorScheme.primary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildHeaderSection(theme, colorScheme),
                _buildMainContent(theme, colorScheme, bookController),
              ],
            ),
          ),
        ),
        floatingActionButton: isAdmin ? null : FloatingActionButton.extended(
          onPressed: () {
            FocusScope.of(context).unfocus();
            Get.to(() => ThoughtsPage());
          },
          icon: const Icon(Icons.chat_bubble_outline),
          label: const Text('Share Thoughts'),
          tooltip: 'Share your thoughts with the community',
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme colorScheme) {
    return AppBar(
  title: Text(
    'Readify',
    style: const TextStyle(
      color: Colors.white, // since blueAccent is dark, keep text white
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
  ),
  backgroundColor: Colors.blueAccent, // changed to blueAccent
  foregroundColor: Colors.white, // icons/text color
  elevation: 0,
  actions: [
    IconButton(
      icon: const Icon(Icons.search_outlined),
      onPressed: () {
        showSearch(
          context: context,
          delegate: _ModernBookSearchDelegate(Get.find<BookController>().bookData),
        );
      },
      tooltip: 'Search books',
    ),
    IconButton(
      icon: const Icon(Icons.request_page_outlined),
      onPressed: () {
        FocusScope.of(context).unfocus();
        Get.to(() => RequestBookPage());
      },
      tooltip: 'Request a book',
    ),
  ],
);

  }

  Widget _buildHeaderSection(ThemeData theme, ColorScheme colorScheme) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(theme, colorScheme),
            const SizedBox(height: 24),
            _buildSearchBar(colorScheme),
            const SizedBox(height: 16),
            Obx(() => _isSearching.value 
                ? _buildSearchResults(theme, colorScheme)
                : _buildCategoryChips(colorScheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${widget.userName}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Discover your next read',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onPrimary.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        _UserAvatar(
          userPhoto: widget.userPhoto,
          userName: widget.userName,
          userEmail: widget.userEmail,
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: _searchBooks,
        decoration: InputDecoration(
          hintText: 'Search books, authors...',
          prefixIcon: Icon(Icons.search_outlined, color: colorScheme.onSurfaceVariant),
          suffixIcon: Obx(() => _isSearching.value
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _clearSearch,
                )
              : const SizedBox.shrink()),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Results',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: Obx(() => _searchResults.isEmpty
              ? Center(
                  child: Text(
                    'No books found',
                    style: TextStyle(color: colorScheme.onPrimary.withOpacity(0.7)),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final book = _searchResults[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _BookCard(
                        book: book,
                        onTap: () => _navigateToBookDetail(book),
                      ),
                    );
                  },
                )),
        ),
      ],
    );
  }

  Widget _buildCategoryChips(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Browse Categories',
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _CategoryChip('All', Icons.apps_outlined, colorScheme, ''),
              _CategoryChip('Romance', Icons.favorite_outline, colorScheme, 'Romance'),
              _CategoryChip('Travel', Icons.travel_explore_outlined, colorScheme, 'Travel'),
              _CategoryChip('Horror', Icons.psychology_outlined, colorScheme, 'Horror'),
              _CategoryChip('Document', Icons.description_outlined, colorScheme, 'Document'),
              _CategoryChip('Fiction', Icons.auto_stories_outlined, colorScheme, 'Fiction'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(ThemeData theme, ColorScheme colorScheme, BookController bookController) {
    return Obx(() => _isSearching.value
        ? const SliverToBoxAdapter(child: SizedBox.shrink())
        : SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _TrendingSection(
                    theme: theme,
                    colorScheme: colorScheme,
                    bookController: bookController,
                    onBookTap: _navigateToBookDetail,
                  ),
                  const SizedBox(height: 32),
                  _UserLibrarySection(
                    theme: theme,
                    colorScheme: colorScheme,
                    bookController: bookController,
                    onBookTap: _navigateToBookDetail,
                  ),
                ],
              ),
            ),
          ));
  }

  void _navigateToBookDetail(Bookmodel book) {
    FocusScope.of(context).unfocus();
    Get.to(() => Bookdetail(
          coverUrl: book.bookUrl ?? '',
          title: book.title ?? '',
          author: book.auther ?? '',
          description: book.descriptions ?? '',
          aboutAuthor: book.aboutAuthor ?? '',
          imageUrl: book.imageUrl ?? '',
          bookId: book.id,
          category: book.category,
        ));
  }
}

// Extracted Components
class _ModernDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String? userPhoto;
  final VoidCallback onSignOut;

  const _ModernDrawer({
    required this.userName,
    required this.userEmail,
    this.userPhoto,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isAdmin = userEmail == 'modinitish905@gmail.com';
    
    return NavigationDrawer(
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: colorScheme.primaryContainer),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: colorScheme.surface,
                child: userPhoto != null
                    ? ClipOval(
                        child: Image.network(
                          userPhoto!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.person_outline,
                            size: 30,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.person_outline,
                        size: 30,
                        color: colorScheme.onSurface,
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                userName,
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                userEmail,
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (isAdmin) ...[
          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('Admin Dashboard'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const AdminPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.library_books_outlined),
            title: const Text('My Library'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => Profilepage(
                userName: userName,
                userEmail: userEmail,
                userPhoto: userPhoto,
              ));
            },
          ),
        ] else ...[
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.library_books_outlined),
            title: const Text('My Library'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => Profilepage(
                userName: userName,
                userEmail: userEmail,
                userPhoto: userPhoto,
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics_outlined),
            title: const Text('Reading Analytics'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const ReadingAnalyticsScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: const Text('Reading Goals'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const ReadingGoalsScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.psychology_outlined),
            title: const Text('AI Insights'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const AIInsightsScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_outlined),
            title: const Text('Smart Bookmarks'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const SmartBookmarksScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Admin'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const AboutAdmin());
            },
          ),
        ],
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout_outlined),
          title: const Text('Sign Out'),
          onTap: onSignOut,
        ),
      ],
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final String? userPhoto;
  final String userName;
  final String userEmail;
  final ColorScheme colorScheme;

  const _UserAvatar({
    this.userPhoto,
    required this.userName,
    required this.userEmail,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => Profilepage(
            userName: userName,
            userEmail: userEmail,
            userPhoto: userPhoto,
          )),
      child: CircleAvatar(
        radius: 24,
        backgroundColor: colorScheme.surface,
        child: userPhoto != null
            ? ClipOval(
                child: Image.network(
                  userPhoto!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.person_outline,
                    color: colorScheme.onSurface,
                  ),
                ),
              )
            : Icon(
                Icons.person_outline,
                color: colorScheme.onSurface,
              ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final ColorScheme colorScheme;
  final String categoryValue;

  const _CategoryChip(this.label, this.icon, this.colorScheme, this.categoryValue);

  @override
  Widget build(BuildContext context) {
    final bookController = Get.find<BookController>();
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        onSelected: (_) {
          if (categoryValue.isEmpty) {
            // Navigate to TrendingBooksPage for "All" category
            Get.to(() => TrendingBooksPage(bookController: bookController));
          } else {
            // Navigate to CategoryBooksPage for specific category
            Get.to(() => CategoryBooksPage(
              categoryName: categoryValue,
              categoryIcon: icon,
              bookController: bookController,
            ));
          }
        },
        backgroundColor: colorScheme.surface,
        selectedColor: colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final Bookmodel book;
  final VoidCallback onTap;

  const _BookCard({
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Bookcard(
      coverUrl: book.imageUrl ?? '',
      title: book.title ?? '',
      onTap: onTap,
      bookUrl: book.bookUrl ?? '',
    );
  }
}

class _TrendingSection extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;
  final BookController bookController;
  final Function(Bookmodel) onBookTap;

  const _TrendingSection({
    required this.theme,
    required this.colorScheme,
    required this.bookController,
    required this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trending Now',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Get.to(() => TrendingBooksPage(
                    bookController: bookController,
                  )),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: Obx(() => ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: bookController.bookData.length,
                itemBuilder: (context, index) {
                  final book = bookController.bookData[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _BookCard(
                      book: book,
                      onTap: () => onBookTap(book),
                    ),
                  );
                },
              )),
        ),
      ],
    );
  }
}

class _UserLibrarySection extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;
  final BookController bookController;
  final Function(Bookmodel) onBookTap;

  const _UserLibrarySection({
    required this.theme,
    required this.colorScheme,
    required this.bookController,
    required this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Library',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (bookController.userBooks.isEmpty) {
            return _EmptyLibraryCard(colorScheme: colorScheme);
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bookController.userBooks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final book = bookController.userBooks[index];
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onBookTap(book),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Book Cover with modern styling
                        Container(
                          width: 90,
                          height: 130,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: colorScheme.surfaceContainerHighest,
                            image: book.imageUrl != null && book.imageUrl!.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(book.imageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: book.imageUrl == null || book.imageUrl!.isEmpty
                              ? Center(
                                  child: Icon(
                                    Icons.book, 
                                    size: 40, 
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        // Book Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.title ?? 'No Title',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "By ${book.auther ?? 'Unknown Author'}",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star,
                                          color: Colors.amber,
                                          size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          (double.tryParse(book.ratings ?? '0')?.toStringAsFixed(1)) ?? '0.0',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  if (bookController.isUserBookOwner(book)) ...[
                                    IconButton(
                                      icon: Icon(Icons.edit, 
                                        color: colorScheme.primary, 
                                        size: 20),
                                      onPressed: () => _showEditDialog(context, book),
                                      tooltip: 'Edit Book',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, 
                                        color: Colors.red, 
                                        size: 20),
                                      onPressed: () => _showDeleteDialog(context, book),
                                      tooltip: 'Delete Book',
                                    ),
                                  ] else
                                    Text(
                                      "\$${book.price?.toStringAsFixed(2) ?? '0.00'}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  void _showEditDialog(BuildContext context, Bookmodel book) {
    final bookController = Get.find<BookController>();
    bookController.populateEditForm(book);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Book'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bookController.title,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bookController.des,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bookController.authorname,
                decoration: const InputDecoration(labelText: 'Author'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bookController.aboutauthor,
                decoration: const InputDecoration(labelText: 'About Author'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              bookController.clearEditForm();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await bookController.editUserBook(
                book.id!,
                newTitle: bookController.title.text,
                newDescription: bookController.des.text,
                newAuthorName: bookController.authorname.text,
                newAboutAuthor: bookController.aboutauthor.text,
              );
              bookController.clearEditForm();
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Bookmodel book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: Text('Are you sure you want to delete "${book.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final bookController = Get.find<BookController>();
              await bookController.deleteUserBook(book.id!);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _EmptyLibraryCard extends StatelessWidget {
  final ColorScheme colorScheme;

  const _EmptyLibraryCard({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No books in your library yet',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernBookSearchDelegate extends SearchDelegate {
  final List<Bookmodel> books;

  _ModernBookSearchDelegate(this.books);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final results = books.where((book) {
      final titleMatch = book.title?.toLowerCase().contains(query.toLowerCase()) ?? false;
      final authorMatch = book.auther?.toLowerCase().contains(query.toLowerCase()) ?? false;
      return titleMatch || authorMatch;
    }).toList();

    if (results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No books found', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final book = results[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: book.imageUrl != null
                  ? Image.network(
                      book.imageUrl!,
                      width: 50,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.book, size: 50),
                    )
                  : const Icon(Icons.book, size: 50),
            ),
            title: Text(
              book.title ?? 'No Title',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(book.auther ?? 'Unknown Author'),
            onTap: () {
              Get.to(() => Bookdetail(
                    coverUrl: book.bookUrl ?? '',
                    title: book.title ?? '',
                    author: book.auther ?? '',
                    description: book.descriptions ?? '',
                    aboutAuthor: book.aboutAuthor ?? '',
                    imageUrl: book.imageUrl ?? '',
                    bookId: book.id,
                    category: book.category,
                  ));
              close(context, null);
            },
          ),
        );
      },
    );
  }
}  