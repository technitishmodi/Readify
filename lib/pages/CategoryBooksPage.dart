import 'package:Readify/bookdetails/bookdetail.dart';
import 'package:Readify/controller/Bookcontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryBooksPage extends StatelessWidget {
  final String categoryName;
  final IconData categoryIcon;
  final BookController bookController;

  const CategoryBooksPage({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.bookController,
  });

  // Get category-specific theme colors
  Map<String, dynamic> getCategoryTheme(String category) {
    switch (category.toLowerCase()) {
      case 'horror':
        return {
          'primary': const Color(0xFF8B0000), // Dark red
          'secondary': const Color(0xFF2F1B14), // Dark brown
          'accent': const Color(0xFFFF4500), // Orange red
          'background': [Colors.black, const Color(0xFF1A0A0A), const Color(0xFF2F1B14)],
          'cardGradient': [const Color(0xFF8B0000).withOpacity(0.2), const Color(0xFF2F1B14).withOpacity(0.2)],
          'shadowColor': const Color(0xFF8B0000),
          'textGradient': [const Color(0xFF8B0000), const Color(0xFFFF4500), const Color(0xFFDC143C)],
        };
      case 'romance':
        return {
          'primary': const Color(0xFFFF69B4), // Hot pink
          'secondary': const Color(0xFF8B008B), // Dark magenta
          'accent': const Color(0xFFFFB6C1), // Light pink
          'background': [Colors.black, const Color(0xFF2D1B2E), const Color(0xFF4A2C4A)],
          'cardGradient': [const Color(0xFFFF69B4).withOpacity(0.2), const Color(0xFF8B008B).withOpacity(0.2)],
          'shadowColor': const Color(0xFFFF69B4),
          'textGradient': [const Color(0xFFFF69B4), const Color(0xFFFFB6C1), const Color(0xFF8B008B)],
        };
      case 'travel':
        return {
          'primary': const Color(0xFF00CED1), // Dark turquoise
          'secondary': const Color(0xFF4682B4), // Steel blue
          'accent': const Color(0xFF87CEEB), // Sky blue
          'background': [Colors.black, const Color(0xFF1B2A3D), const Color(0xFF2E4A5B)],
          'cardGradient': [const Color(0xFF00CED1).withOpacity(0.2), const Color(0xFF4682B4).withOpacity(0.2)],
          'shadowColor': const Color(0xFF00CED1),
          'textGradient': [const Color(0xFF00CED1), const Color(0xFF87CEEB), const Color(0xFF4682B4)],
        };
      case 'document':
        return {
          'primary': const Color(0xFF708090), // Slate gray
          'secondary': const Color(0xFF2F4F4F), // Dark slate gray
          'accent': const Color(0xFFC0C0C0), // Silver
          'background': [Colors.black, const Color(0xFF1C1C1C), const Color(0xFF2F2F2F)],
          'cardGradient': [const Color(0xFF708090).withOpacity(0.2), const Color(0xFF2F4F4F).withOpacity(0.2)],
          'shadowColor': const Color(0xFF708090),
          'textGradient': [const Color(0xFF708090), const Color(0xFFC0C0C0), const Color(0xFF2F4F4F)],
        };
      case 'fiction':
        return {
          'primary': const Color(0xFF9370DB), // Medium purple
          'secondary': const Color(0xFF4B0082), // Indigo
          'accent': const Color(0xFFBA55D3), // Medium orchid
          'background': [Colors.black, const Color(0xFF2E1A47), const Color(0xFF4B2A6B)],
          'cardGradient': [const Color(0xFF9370DB).withOpacity(0.2), const Color(0xFF4B0082).withOpacity(0.2)],
          'shadowColor': const Color(0xFF9370DB),
          'textGradient': [const Color(0xFF9370DB), const Color(0xFFBA55D3), const Color(0xFF4B0082)],
        };
      default:
        // Default cyber neon theme
        return {
          'primary': Colors.purple,
          'secondary': Colors.cyan,
          'accent': Colors.pink,
          'background': [Colors.black, const Color(0xFF1A1A2E), const Color(0xFF16213E)],
          'cardGradient': [Colors.purple.withOpacity(0.2), Colors.cyan.withOpacity(0.2)],
          'shadowColor': Colors.purple,
          'textGradient': [Colors.purple, Colors.cyan, Colors.pink],
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter books by category
    final categoryBooks = bookController.bookData.where((book) => 
      book.category?.toLowerCase() == categoryName.toLowerCase()).toList();

    final theme = getCategoryTheme(categoryName);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme['background'],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              backgroundColor: Colors.transparent,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme['primary'].withOpacity(0.3),
                      theme['secondary'].withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: theme['background'],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [theme['primary'], theme['secondary']],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: theme['shadowColor'].withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: Icon(
                            categoryIcon,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: theme['textGradient'],
                          ).createShader(bounds),
                          child: Text(
                            categoryName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${categoryBooks.length} books available',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: categoryBooks.isEmpty
                  ? SliverToBoxAdapter(
                      child: Container(
                        height: 300,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: theme['cardGradient'],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme['primary'].withOpacity(0.3),
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                categoryIcon,
                                size: 80,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'No $categoryName books yet',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Be the first to add a book in this category!',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final book = categoryBooks[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Get.to(() => Bookdetail(
                                      coverUrl: book.bookUrl ?? '',
                                      title: book.title ?? '',
                                      author: book.auther ?? '',
                                      description: book.descriptions ?? '',
                                      aboutAuthor: book.aboutAuthor ?? '',
                                      imageUrl: book.imageUrl ?? '',
                                    ));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: theme['cardGradient'],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: theme['primary'].withOpacity(0.3),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme['shadowColor'].withOpacity(0.1),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Book Cover
                                      Container(
                                        width: 90,
                                        height: 130,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          gradient: LinearGradient(
                                            colors: [
                                              theme['primary'].withOpacity(0.3),
                                              theme['secondary'].withOpacity(0.3),
                                            ],
                                          ),
                                          border: Border.all(
                                            color: theme['accent'].withOpacity(0.5),
                                            width: 1,
                                          ),
                                          image: book.imageUrl != null && book.imageUrl!.isNotEmpty
                                              ? DecorationImage(
                                                  image: NetworkImage(book.imageUrl!),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: book.imageUrl == null || book.imageUrl!.isEmpty
                                            ? Center(
                                                child: Icon(Icons.book, 
                                                  size: 40, 
                                                  color: theme['accent']),
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
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                                height: 1.3,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "By ${book.auther ?? 'Unknown Author'}",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white.withOpacity(0.7),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            if (book.descriptions != null && book.descriptions!.isNotEmpty)
                                              Text(
                                                book.descriptions!,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white.withOpacity(0.6),
                                                  height: 1.4,
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [theme['accent'], theme['primary']],
                                                    ),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(Icons.star,
                                                        color: Colors.white,
                                                        size: 14),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        (double.tryParse(book.ratings ?? '0')?.toStringAsFixed(1)) ?? '0.0',
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 12,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Spacer(),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 12, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [theme['primary'], theme['secondary']],
                                                    ),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    "\$${book.price?.toStringAsFixed(2) ?? '0.00'}",
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                    ),
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
                            ),
                          );
                        },
                        childCount: categoryBooks.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
