import 'package:Readify/controller/pdfCotroller.dart';
import 'package:Readify/controller/theme_controller.dart';
// import 'package:e_book/controller/pdfCotroller.dart';
// import 'package:e_book/controller/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class Boopageread extends StatefulWidget {
  final String pdfUrl;
  Boopageread({super.key, required this.pdfUrl});
  final PdfController pdfController = Get.put(PdfController());

  @override
  State<Boopageread> createState() => _BoopagereadState();
}

class _BoopagereadState extends State<Boopageread> {
  final ThemeController _themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    //  final PdfViewerController pdfViewerController = PdfViewerController();
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
          'Book Title',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () => _themeController.toggleTheme(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.pdfController.pdfViewerKey.currentState?.openBookmarkView();
        },
        child: Icon(Icons.bookmark),
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.blue,
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
          // Dark mode settings
          initialScrollOffset:
              Offset(0, _themeController.isDarkMode.value ? 0 : 0),
        );
      }),
    );
  }
}
