import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Readify/bookdetails/bookdetail.dart';
import 'package:Readify/models/bookmodel.dart';
import 'package:Readify/controller/Bookcontroller.dart';

class Bookcard123 extends StatelessWidget {
  final String title;
  final String coverUrl;
  final String auther;
  final String price;
  final String rating;
  final String bookUrl;
  final String description;
  final String aboutAuthor;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final Bookmodel? book;
  final bool showActions;

  const Bookcard123({
    super.key,
    required this.title,
    required this.coverUrl,
    required this.auther,
    required this.price,
    required this.rating,
    required this.bookUrl,
    required this.onTap,
    this.onDelete,
    required this.description,
    required this.aboutAuthor,
    this.book,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final bookController = Get.find<BookController>();
    final canEdit = book != null && bookController.isUserBookOwner(book!);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Bookdetail(
              title: title,
              coverUrl: bookUrl,
              imageUrl: coverUrl,
              author: auther,
              description: description,
              aboutAuthor: aboutAuthor,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Glassmorphism Background
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: Colors.white.withOpacity(0.15),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
              ),

              Row(
                children: [
                  // Book Cover
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(22),
                      bottomLeft: Radius.circular(22),
                    ),
                    child: Stack(
                      children: [
                        Image.network(
                          coverUrl,
                          width: 120,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 120,
                            height: 180,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.broken_image, size: 40),
                          ),
                        ),
                        Container(
                          width: 120,
                          height: 180,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.6),
                                Colors.transparent,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Book Details
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),

                          // Author
                          Text(
                            "by $auther",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white70,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),

                          // Price
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.secondary,
                                  Theme.of(context).colorScheme.primary,
                                ],
                              ),
                            ),
                            child: Text(
                              "₹ $price",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),

                          // Rating
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                rating,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.white),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "($rating)",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Floating Action Buttons
              if (showActions && canEdit)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Row(
                    children: [
                      _buildCircleButton(
                        context,
                        icon: Icons.edit,
                        color: Colors.blueAccent,
                        onTap: () => _showEditDialog(context),
                      ),
                      const SizedBox(width: 8),
                      _buildCircleButton(
                        context,
                        icon: Icons.delete,
                        color: Colors.redAccent,
                        onTap: () => _showDeleteDialog(context),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton(BuildContext context,
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.85),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.6),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    if (book == null) return;

    final bookController = Get.find<BookController>();
    bookController.populateEditForm(book!);

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
                book!.id!,
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

  void _showDeleteDialog(BuildContext context) {
    if (book == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: Text(
            'Are you sure you want to delete "${book!.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final bookController = Get.find<BookController>();
              await bookController.deleteUserBook(book!.id!);
              Navigator.pop(context);
            },
            child:
                const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
