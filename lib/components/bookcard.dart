import 'package:flutter/material.dart';
import 'package:Readify/models/bookmodel.dart';
import 'package:Readify/controller/Bookcontroller.dart';
import 'package:get/get.dart';

class Bookcard extends StatelessWidget {
  final String coverUrl;
  final String title;
  final VoidCallback onTap;
  final Bookmodel? book; // Add book model for ownership check
  final bool showActions; // Flag to show/hide action buttons

  const Bookcard({
    super.key,
    required this.coverUrl,
    required this.title,
    required this.onTap,
    required String bookUrl,
    this.book,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final bookController = Get.find<BookController>();
    final canEdit = book != null && bookController.isUserBookOwner(book!);

    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Stack(
        children: [
          InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 120,
              height: 220, 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 175,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(4, 1),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: coverUrl.isNotEmpty
                          ? Image.network(
                              coverUrl,
                              width: 120,
                              height: 180,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image, size: 50),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Wrap the title in Flexible
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.9),
                              height: 1.3,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Action buttons for user-owned books
          if (showActions && canEdit)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                      onPressed: () => _showEditDialog(context),
                      tooltip: 'Edit Book',
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 16),
                      onPressed: () => _showDeleteDialog(context),
                      tooltip: 'Delete Book',
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
              ),
            ),
        ],
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
        content: Text('Are you sure you want to delete "${book!.title}"? This action cannot be undone.'),
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
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
