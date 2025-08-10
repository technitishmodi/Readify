import 'dart:async';
import 'package:Readify/bookdetails/bookdetail.dart';
import 'package:Readify/components/bookcard.dart';
import 'package:Readify/components/bookcard123.dart';
import 'package:Readify/controller/Bookcontroller.dart';
import 'package:Readify/models/bookmodel.dart';
import 'package:Readify/profilepage/ProFilepage.dart';
import 'package:Readify/profilepage/TrendingBooksPage.dart';
import 'package:Readify/screen/aboutAdmin.dart';
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
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

class HomePage extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String? userPhoto;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  HomePage({
    super.key,
    required this.userName,
    required this.userEmail,
    this.userPhoto,
  });

  void signOut(BuildContext context) async {
    // Clear controller data first
    final bookController = Get.find<BookController>();
    bookController.clearAllData();

    // Clear Firestore cache
    await FirebaseFirestore.instance.clearPersistence();

    // Sign out from Firebase
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  Future<void> _refreshData(BuildContext context) async {
    final bookController = Get.find<BookController>();
    await bookController.fetchBooks();
    await bookController.fetchUserBooks(); // Add this line
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF4E6EFF),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color(0xFF4E6EFF).withOpacity(0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: userPhoto != null
                        ? ClipOval(
                            child: Image.network(
                              userPhoto!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 40,
                            color: const Color(0xFF4E6EFF),
                          ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    userEmail,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text(
                'Home',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.book, color: Colors.white),
              title: const Text(
                'My Library',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Profilepage(
                              userName: '',
                              userEmail: '',
                            )));
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.white),
              title: const Text(
                'About Admin',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AboutAdmin()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => signOut(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    BookController bookController = Get.put(BookController());
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 375;
    final TextEditingController searchController = TextEditingController();
    final FocusNode searchFocusNode = FocusNode();
    final RxBool isSearching = false.obs;
    final RxList<Bookmodel> searchResults = <Bookmodel>[].obs;
    final _searchDebouncer = Debouncer(milliseconds: 300);

    void searchBooks(String query) {
      _searchDebouncer.run(() {
        if (query.isEmpty) {
          isSearching.value = false;
          searchResults.clear();
          return;
        }

        isSearching.value = true;
        final lowerCaseQuery = query.toLowerCase();
        searchResults.value = bookController.bookData.where((book) {
          final titleMatch =
              book.title?.toLowerCase().contains(lowerCaseQuery) ?? false;
          final authorMatch =
              book.auther?.toLowerCase().contains(lowerCaseQuery) ?? false;
          return titleMatch || authorMatch;
        }).toList();
      });
    }

    void clearSearch() {
      searchController.clear();
      isSearching.value = false;
      searchResults.clear();
      searchFocusNode.unfocus();
    }

    Widget _buildSearchResultsSection() {
      return Column(
        children: [
          Text(
            "Search Results",
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontSize: isSmallScreen ? 18 : 20,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: isSmallScreen ? 180 : 210,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final book = searchResults[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Bookcard(
                    coverUrl: book.imageUrl ?? '',
                    title: book.title ?? '',
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      Get.to(() => Bookdetail(
                            coverUrl: book.bookUrl ?? '',
                            title: book.title ?? '',
                            author: book.auther ?? '',
                            description: book.descriptions ?? '',
                            aboutAuthor: book.aboutAuthor ?? '',
                            imageUrl: book.imageUrl ?? '',
                          ));
                    },
                    bookUrl: '',
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
      );
    }

    return GestureDetector(
      onTap: () {
        searchFocusNode.unfocus();
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            child: Text(
              "Readify",
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          backgroundColor: const Color(0xFF4E6EFF),
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                searchFocusNode.unfocus();
                showSearch(
                  context: context,
                  delegate: BookSearchDelegate(bookController.bookData),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.bookmark_add),
              onPressed: () {
                FocusScope.of(context).unfocus();
                Get.to(() => RequestBookPage());
              },
            ),
          ],
        ),
        drawer: _buildDrawer(context),
        body: RefreshIndicator(
          onRefresh: () => _refreshData(context),
          color: const Color(0xFF4E6EFF),
          backgroundColor: Colors.white,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 25),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4E6EFF),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hello, $userName",
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isSmallScreen ? 20 : 24,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Discover your next read",
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: isSmallScreen ? 14 : 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              Get.to(Profilepage(
                                userName: userName,
                                userEmail: userEmail,
                              ));
                            },
                            child: CircleAvatar(
                              radius: isSmallScreen ? 20 : 25,
                              backgroundColor: Colors.white,
                              child:
                                  Icon(Icons.person, color: Color(0xFF4E6EFF)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 15 : 25),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: searchController,
                          focusNode: searchFocusNode,
                          decoration: InputDecoration(
                            hintText: "Search books, authors...",
                            border: InputBorder.none,
                            prefixIcon:
                                Icon(Icons.search, color: Color(0xFFA0AEC0)),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 12 : 15,
                              horizontal: 15,
                            ),
                            suffixIcon: Obx(() => isSearching.value
                                ? IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: clearSearch,
                                  )
                                : SizedBox.shrink()),
                          ),
                          onChanged: searchBooks,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Obx(() {
                        if (isSearching.value) {
                          return _buildSearchResultsSection();
                        } else {
                          return Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Text(
                                    "Browse Categories",
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontSize: isSmallScreen ? 18 : 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _buildTopicChip("Romance", Icons.favorite),
                                    _buildTopicChip(
                                        "Travel", Icons.travel_explore),
                                    _buildTopicChip("Horror", Icons.hotel),
                                    _buildTopicChip("Document", Icons.book),
                                    _buildTopicChip(
                                        "Fiction", Icons.auto_stories),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                      }),
                    ],
                  ),
                ),
              ),
              Obx(() {
                return isSearching.value
                    ? SliverToBoxAdapter(child: SizedBox.shrink())
                    : SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            isSmallScreen ? 16 : 25,
                            isSmallScreen ? 20 : 25,
                            isSmallScreen ? 16 : 25,
                            15,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Trending Now",
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isSmallScreen ? 18 : 20,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      Get.to(() => TrendingBooksPage(
                                            bookController: bookController,
                                          ));
                                    },
                                    child: const Text("See All"),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              SizedBox(
                                height: isSmallScreen ? 190 : 220,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: bookController.bookData.length,
                                  itemBuilder: (context, index) {
                                    final book = bookController.bookData[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: Bookcard(
                                        coverUrl: book.imageUrl ?? '',
                                        title: book.title ?? '',
                                        onTap: () {
                                          FocusScope.of(context).unfocus();
                                          Get.to(() => Bookdetail(
                                                coverUrl: book.bookUrl ?? '',
                                                title: book.title ?? '',
                                                author: book.auther ?? '',
                                                description:
                                                    book.descriptions ?? '',
                                                aboutAuthor:
                                                    book.aboutAuthor ?? '',
                                                imageUrl: book.imageUrl ?? '',
                                              ));
                                        },
                                        bookUrl: '',
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
              }),
              Obx(() {
                return isSearching.value
                    ? SliverToBoxAdapter(child: SizedBox.shrink())
                    : SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            isSmallScreen ? 16 : 25,
                            0,
                            isSmallScreen ? 16 : 25,
                            isSmallScreen ? 20 : 25,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your Library",
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmallScreen ? 18 : 20,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Obx(() {
                                if (bookController.userBooks.isEmpty) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 40),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        "No books in your interests yet",
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: isSmallScreen ? 14 : 16,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: bookController.userBooks.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final book =
                                        bookController.userBooks[index];
                                    return Bookcard123(
                                      title: book.title ?? 'No Title',
                                      auther: book.auther ?? 'Unknown Author',
                                      coverUrl: book.imageUrl ?? '',
                                      price: (book.price ?? 0).toString(),
                                      rating: (book.ratings ?? 0).toString(),
                                      bookUrl: book.bookUrl ?? '',
                                      description: book.descriptions ??
                                          'No description available',
                                      aboutAuthor: book.aboutAuthor ??
                                          'No information about author',
                                      onTap: () {
                                        FocusScope.of(context).unfocus();
                                        Get.to(() => Bookdetail(
                                              coverUrl: book.bookUrl ?? '',
                                              title: book.title ?? '',
                                              author: book.auther ?? '',
                                              description:
                                                  book.descriptions ?? '',
                                              aboutAuthor:
                                                  book.aboutAuthor ?? '',
                                              imageUrl: book.imageUrl ?? '',
                                            ));
                                      },
                                    );
                                  },
                                );
                              }),
                            ],
                          ),
                        ),
                      );
              }),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            Get.to(() => ThoughtsPage());
          },
          child: Icon(Icons.feedback),
          backgroundColor: const Color(0xFF4E6EFF),
        ),
      ),
    );
  }

  Widget _buildTopicChip(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        avatar: Icon(icon, size: 16, color: const Color(0xFF4E6EFF)),
        label: Text(
          label,
          style: TextStyle(fontSize: 14),
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide.none,
      ),
    );
  }
}

class BookSearchDelegate extends SearchDelegate {
  final List<Bookmodel> books;

  BookSearchDelegate(this.books);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          FocusScope.of(context).unfocus();
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        FocusScope.of(context).unfocus();
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = books.where((book) {
      final titleMatch =
          book.title?.toLowerCase().contains(query.toLowerCase()) ?? false;
      final authorMatch =
          book.auther?.toLowerCase().contains(query.toLowerCase()) ?? false;
      return titleMatch || authorMatch;
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final book = results[index];
        return ListTile(
          leading: book.imageUrl != null
              ? Image.network(book.imageUrl!,
                  width: 50, height: 50, fit: BoxFit.cover)
              : Icon(Icons.book, size: 50),
          title: Text(book.title ?? 'No Title'),
          subtitle: Text(book.auther ?? 'Unknown Author'),
          onTap: () {
            FocusScope.of(context).unfocus();
            Get.to(() => Bookdetail(
                  coverUrl: book.bookUrl ?? '',
                  title: book.title ?? '',
                  author: book.auther ?? '',
                  description: book.descriptions ?? '',
                  aboutAuthor: book.aboutAuthor ?? '',
                  imageUrl: book.imageUrl ?? '',
                ));
            close(context, null);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = books.where((book) {
      final titleMatch =
          book.title?.toLowerCase().contains(query.toLowerCase()) ?? false;
      final authorMatch =
          book.auther?.toLowerCase().contains(query.toLowerCase()) ?? false;
      return titleMatch || authorMatch;
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final book = suggestions[index];
        return ListTile(
          leading: book.imageUrl != null
              ? Image.network(book.imageUrl!,
                  width: 50, height: 50, fit: BoxFit.cover)
              : Icon(Icons.book, size: 50),
          title: Text(book.title ?? 'No Title'),
          subtitle: Text(book.auther ?? 'Unknown Author'),
          onTap: () {
            FocusScope.of(context).unfocus();
            Get.to(() => Bookdetail(
                  coverUrl: book.bookUrl ?? '',
                  title: book.title ?? '',
                  author: book.auther ?? '',
                  description: book.descriptions ?? '',
                  aboutAuthor: book.aboutAuthor ?? '',
                  imageUrl: book.imageUrl ?? '',
                ));
            close(context, null);
          },
        );
      },
    );
  }
}
