import 'package:Readify/controller/pdfCotroller.dart';
import 'package:Readify/controller/theme_controller.dart';
import 'package:Readify/controller/reading_progress_controller.dart';
import 'package:Readify/controller/smart_bookmark_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class Boopageread extends StatefulWidget {
  final String pdfUrl;
  final String bookId;
  final String bookTitle;
  final bool enableTts;
  
  Boopageread({
    super.key, 
    required this.pdfUrl,
    required this.bookId,
    required this.bookTitle,
    this.enableTts = false
  });
  
  final PdfController pdfController = Get.put(PdfController());

  @override
  State<Boopageread> createState() => _BoopagereadState();
}

class _BoopagereadState extends State<Boopageread> {
  final ThemeController _themeController = Get.find<ThemeController>();
  final ReadingProgressController _progressController = Get.put(ReadingProgressController());
  final SmartBookmarkController _bookmarkController = Get.put(SmartBookmarkController());
  
  bool isPlaying = false;
  int currentPage = 1;
  int totalPages = 0;
  String selectedText = '';
  DateTime? sessionStartTime;

  @override
  void initState() {
    super.initState();
    _startReadingSession();
  }

  @override
  void dispose() {
    _endReadingSession();
    super.dispose();
  }

  void _startReadingSession() {
    sessionStartTime = DateTime.now();
    _progressController.startReadingSession(widget.bookId, widget.bookTitle);
  }

  void _endReadingSession() {
    if (sessionStartTime != null && totalPages > 0) {
      _progressController.endReadingSession(
        currentPage: currentPage,
        totalPages: totalPages,
        wordsRead: _estimateWordsRead(),
      );
    }
  }

  int _estimateWordsRead() {
    // Simple estimation: assume 250 words per page
    return currentPage * 250;
  }

  void _toggleTts() {
    setState(() {
      isPlaying = !isPlaying;
    });
    // implement TTS toggle logic here
  }

  void _showBookmarkDialog() {
    if (selectedText.isEmpty) {
      Get.snackbar('No Text Selected', 'Please select some text to bookmark');
      return;
    }

    final noteController = TextEditingController();
    final tagController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Smart Bookmark'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Page $currentPage'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  selectedText,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Add your note (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tagController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                  border: OutlineInputBorder(),
                  hintText: 'important, quote, research',
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
          ElevatedButton(
            onPressed: () async {
              final tags = tagController.text
                  .split(',')
                  .map((tag) => tag.trim())
                  .where((tag) => tag.isNotEmpty)
                  .toList();

              await _bookmarkController.createBookmark(
                bookId: widget.bookId,
                bookTitle: widget.bookTitle,
                pageNumber: currentPage,
                selectedText: selectedText,
                userNote: noteController.text,
                userTags: tags,
              );

              Navigator.pop(context);
            },
            child: const Text('Save Bookmark'),
          ),
        ],
      ),
    );
  }

  void _showProgressDialog() {
    final progress = _progressController.getBookProgress(widget.bookId);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reading Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              value: totalPages > 0 ? currentPage / totalPages : 0,
              strokeWidth: 8,
            ),
            const SizedBox(height: 16),
            Text(
              '${totalPages > 0 ? ((currentPage / totalPages) * 100).toStringAsFixed(1) : 0}% Complete',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Page $currentPage of $totalPages'),
            if (progress != null) ...[
              const SizedBox(height: 16),
              Text('Last read: ${_formatDate(progress.lastReadDate)}'),
              Text('Time spent: ${progress.timeSpent.inMinutes} minutes'),
            ],
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    return '${difference} days ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.blue,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.bookTitle,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.analytics,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: _showProgressDialog,
            tooltip: 'Reading Progress',
          ),
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () => _themeController.toggleTheme(),
          ),
          if (widget.enableTts)
            IconButton(
              icon: Icon(
                isPlaying ? Icons.stop : Icons.play_arrow,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              onPressed: widget.enableTts ? _toggleTts : null,
              tooltip: isPlaying ? 'Stop Reading' : 'Start Reading',
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "bookmark",
            onPressed: _showBookmarkDialog,
            backgroundColor: Colors.amber,
            child: const Icon(Icons.bookmark_add),
            tooltip: 'Add Smart Bookmark',
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "bookmarks",
            onPressed: () {
              widget.pdfController.pdfViewerKey.currentState?.openBookmarkView();
            },
            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.blue,
            child: const Icon(Icons.bookmark),
            tooltip: 'View Bookmarks',
          ),
        ],
      ),
      body: Obx(() {
        return SfPdfViewer.network(
          widget.pdfUrl,
          key: widget.pdfController.pdfViewerKey,
          canShowScrollHead: true,
          canShowScrollStatus: true,
          pageLayoutMode: PdfPageLayoutMode.continuous,
          scrollDirection: PdfScrollDirection.vertical,
          interactionMode: PdfInteractionMode.pan,
          enableTextSelection: true,
          enableDoubleTapZooming: true,
          controller: widget.pdfController.pdfViewerController,
          pageSpacing: 0,
          onDocumentLoaded: (PdfDocumentLoadedDetails details) {
            setState(() {
              totalPages = details.document.pages.count;
            });
          },
          onPageChanged: (PdfPageChangedDetails details) {
            setState(() {
              currentPage = details.newPageNumber;
            });
            
            // Update reading progress
            if (totalPages > 0) {
              _progressController.updateBookProgress(
                widget.bookId,
                currentPage,
                totalPages,
              );
            }
          },
          onTextSelectionChanged: (PdfTextSelectionChangedDetails details) {
            setState(() {
              selectedText = details.selectedText ?? '';
            });
          },
          initialScrollOffset:
              Offset(0, _themeController.isDarkMode.value ? 0 : 0),
        );
      }),
      bottomNavigationBar: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Page $currentPage${totalPages > 0 ? ' of $totalPages' : ''}',
              style: theme.textTheme.bodyMedium,
            ),
            if (totalPages > 0)
              Container(
                width: 100,
                child: LinearProgressIndicator(
                  value: currentPage / totalPages,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ),
            if (selectedText.isNotEmpty)
              ElevatedButton.icon(
                onPressed: _showBookmarkDialog,
                icon: const Icon(Icons.bookmark_add, size: 16),
                label: const Text('Bookmark'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
