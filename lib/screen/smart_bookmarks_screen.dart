import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Readify/controller/smart_bookmark_controller.dart';

class SmartBookmarksScreen extends StatelessWidget {
  const SmartBookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookmarkController = Get.put(SmartBookmarkController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Ensure bookmarks are loaded when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('DEBUG: SmartBookmarksScreen opened, triggering bookmark load');
      bookmarkController.loadUserBookmarks();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Bookmarks'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context, bookmarkController),
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => _showStatsDialog(context, bookmarkController),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryTabs(bookmarkController, colorScheme),
          Expanded(
            child:
                Obx(() => _buildBookmarksList(bookmarkController, colorScheme)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(
      SmartBookmarkController controller, ColorScheme colorScheme) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Obx(() => ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              final isSelected =
                  controller.selectedCategory.value == category.id;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: isSelected,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category.icon,
                        size: 16,
                        color:
                            isSelected ? colorScheme.onPrimary : category.color,
                      ),
                      const SizedBox(width: 4),
                      Text(category.name),
                    ],
                  ),
                  onSelected: (_) =>
                      controller.selectedCategory.value = category.id,
                  backgroundColor: colorScheme.surface,
                  selectedColor: category.color,
                  checkmarkColor: colorScheme.onPrimary,
                ),
              );
            },
          )),
    );
  }

  Widget _buildBookmarksList(
      SmartBookmarkController controller, ColorScheme colorScheme) {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    final bookmarks =
        controller.getBookmarksByCategory(controller.selectedCategory.value);

    print('DEBUG: Building bookmarks list');
    print('DEBUG: Selected category: ${controller.selectedCategory.value}');
    print('DEBUG: Total bookmarks found: ${bookmarks.length}');
    print(
        'DEBUG: All bookmark keys: ${controller.bookBookmarks.keys.toList()}');

    if (bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No bookmarks yet',
              style: TextStyle(
                fontSize: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start reading and create smart bookmarks!',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                print('DEBUG: Manual refresh triggered');
                await controller.loadUserBookmarks();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.loadUserBookmarks,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookmarks.length,
        itemBuilder: (context, index) {
          final bookmark = bookmarks[index];
          print(
              'DEBUG: Displaying bookmark ${index + 1}: ${bookmark.selectedText.substring(0, bookmark.selectedText.length > 50 ? 50 : bookmark.selectedText.length)}...');
          return _BookmarkCard(
            bookmark: bookmark,
            onTap: () => _showBookmarkDetails(context, bookmark, controller),
            onEdit: () => _showEditDialog(context, bookmark, controller),
            onDelete: () => _showDeleteDialog(context, bookmark, controller),
          );
        },
      ),
    );
  }

  void _showSearchDialog(
      BuildContext context, SmartBookmarkController controller) {
    showDialog(
      context: context,
      builder: (context) => _SearchBookmarksDialog(controller: controller),
    );
  }

  void _showStatsDialog(
      BuildContext context, SmartBookmarkController controller) {
    final stats = controller.getBookmarkStats();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bookmark Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatRow('Total Bookmarks', '${stats['totalBookmarks']}'),
            _StatRow('Books with Bookmarks', '${stats['booksWithBookmarks']}'),
            _StatRow('Average Importance',
                '${(stats['averageImportance'] * 100).toStringAsFixed(0)}%'),
            const SizedBox(height: 16),
            const Text('By Category:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...((stats['categoryStats'] as Map<String, int>).entries.map(
                  (entry) => _StatRow(entry.key, '${entry.value}'),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBookmarkDetails(BuildContext context, SmartBookmark bookmark,
      SmartBookmarkController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Page ${bookmark.pageNumber}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                bookmark.bookTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Selected Text:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(bookmark.selectedText),
              ),
              if (bookmark.userNote.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Your Note:',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(bookmark.userNote),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: bookmark.tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          backgroundColor: Colors.blue[100],
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditDialog(context, bookmark, controller);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, SmartBookmark bookmark,
      SmartBookmarkController controller) {
    controller.noteController.text = bookmark.userNote;
    String selectedCategory = bookmark.category;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Bookmark'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Note:'),
              const SizedBox(height: 8),
              TextField(
                controller: controller.noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Add your note...',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Category:'),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setState) => DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                  items: controller.categories
                      .map((category) => DropdownMenuItem(
                            value: category.id,
                            child: Row(
                              children: [
                                Icon(category.icon,
                                    size: 16, color: category.color),
                                const SizedBox(width: 8),
                                Text(category.name),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedCategory = value!),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final updatedBookmark = bookmark.copyWith(
                userNote: controller.noteController.text,
                category: selectedCategory,
              );
              await controller.updateBookmark(updatedBookmark);
              controller.noteController.clear();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, SmartBookmark bookmark,
      SmartBookmarkController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bookmark'),
        content: const Text('Are you sure you want to delete this bookmark?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await controller.deleteBookmark(bookmark.id, bookmark.bookId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  final SmartBookmark bookmark;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BookmarkCard({
    required this.bookmark,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final category = _getCategoryInfo(bookmark.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(category['icon'], color: category['color'], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bookmark.bookTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text('Page ${bookmark.pageNumber}'),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: onEdit,
                        child: const Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: onDelete,
                        child: const Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                bookmark.selectedText,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              if (bookmark.userNote.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    bookmark.userNote,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  if (bookmark.tags.isNotEmpty) ...[
                    Expanded(
                      child: Wrap(
                        spacing: 4,
                        children: bookmark.tags
                            .take(3)
                            .map((tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    tag,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < (bookmark.importance * 5).round()
                            ? Icons.star
                            : Icons.star_border,
                        size: 12,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getCategoryInfo(String categoryId) {
    switch (categoryId) {
      case 'important':
        return {'icon': Icons.star, 'color': Colors.amber};
      case 'quotes':
        return {'icon': Icons.format_quote, 'color': Colors.purple};
      case 'research':
        return {'icon': Icons.science, 'color': Colors.green};
      case 'review':
        return {'icon': Icons.schedule, 'color': Colors.orange};
      case 'reference':
        return {'icon': Icons.library_books, 'color': Colors.teal};
      default:
        return {'icon': Icons.bookmark, 'color': Colors.blue};
    }
  }
}

class _SearchBookmarksDialog extends StatefulWidget {
  final SmartBookmarkController controller;

  const _SearchBookmarksDialog({required this.controller});

  @override
  State<_SearchBookmarksDialog> createState() => _SearchBookmarksDialogState();
}

class _SearchBookmarksDialogState extends State<_SearchBookmarksDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<SmartBookmark> _searchResults = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Search Bookmarks'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search bookmarks...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                setState(() {
                  _searchResults = widget.controller.searchBookmarks(query);
                });
              },
            ),
            const SizedBox(height: 16),
            if (_searchResults.isNotEmpty)
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final bookmark = _searchResults[index];
                    return ListTile(
                      title: Text(bookmark.bookTitle),
                      subtitle: Text(
                        bookmark.selectedText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text('Page ${bookmark.pageNumber}'),
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to bookmark details or book page
                      },
                    );
                  },
                ),
              )
            else if (_searchController.text.isNotEmpty)
              const Text('No bookmarks found'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
