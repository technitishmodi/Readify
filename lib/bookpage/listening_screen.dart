import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:http/http.dart' as http;
import 'package:Readify/controller/tts_controller.dart';
import 'package:Readify/controller/theme_controller.dart';

class ListeningScreen extends StatefulWidget {
  final String pdfUrl;
  final String bookTitle;
  final String author;
  final String coverImageUrl;

  const ListeningScreen({
    super.key,
    required this.pdfUrl,
    required this.bookTitle,
    required this.author,
    required this.coverImageUrl,
  });

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen>
    with TickerProviderStateMixin {
  final TtsController ttsController = Get.put(TtsController());
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  String extractedText = '';
  bool isLoading = true;
  bool isExtracting = false;
  int currentPage = 0;
  int totalPages = 0;
  List<String> pageTexts = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _extractTextFromPdf();
  }

  @override
  void dispose() {
    _animationController.dispose();
    ttsController.stop();
    super.dispose();
  }

  Future<void> _extractTextFromPdf() async {
    setState(() {
      isLoading = true;
      isExtracting = true;
    });

    try {
      // Download PDF
      final response = await http.get(Uri.parse(widget.pdfUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download PDF');
      }

      // Load PDF document
      final PdfDocument document = PdfDocument(inputBytes: response.bodyBytes);
      totalPages = document.pages.count;
      pageTexts = [];

      // Extract text from all pages
      for (int i = 0; i < totalPages; i++) {
        final PdfTextExtractor extractor = PdfTextExtractor(document);
        final String pageText =
            extractor.extractText(startPageIndex: i, endPageIndex: i);
        pageTexts.add(pageText.trim());
      }

      // Combine all text
      extractedText = pageTexts.join('\n\n');

      // Clean up the text
      extractedText = _cleanText(extractedText);

      document.dispose();

      if (extractedText.isEmpty) {
        extractedText =
            "Sorry, no readable text could be extracted from this PDF. The PDF might contain only images or have text in a format that cannot be processed.";
      }
    } catch (e) {
      extractedText =
          "Error extracting text from PDF: ${e.toString()}. Please try again or check if the PDF is accessible.";
    } finally {
      setState(() {
        isLoading = false;
        isExtracting = false;
      });
    }
  }

  String _cleanText(String text) {
    // Remove excessive whitespace and clean up the text
    text = text.replaceAll(RegExp(r'\s+'), ' ');
    text = text.replaceAll(RegExp(r'\n\s*\n'), '\n\n');
    text = text.trim();
    return text;
  }

  void _playCurrentPage() async {
    if (currentPage < pageTexts.length) {
      String pageText = pageTexts[currentPage];
      if (pageText.isNotEmpty) {
        await ttsController.speak(pageText);
        ttsController.update(['playing_state', 'controls', 'text_overlay']);
      } else {
        Get.snackbar(
          'No Text',
          'This page has no readable text.',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );
      }
    }
  }

  void _playAllText() async {
    if (extractedText.isNotEmpty) {
      await ttsController.speak(extractedText);
      ttsController.update(['playing_state', 'controls', 'text_overlay']);
    } else {
      Get.snackbar(
        'No Text',
        'No text available to read aloud.',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    }
  }

  void _nextPage() {
    if (currentPage < totalPages - 1) {
      setState(() {
        currentPage++;
      });
      ttsController.stop();
    }
  }

  void _previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
      ttsController.stop();
    }
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            ttsController.stop();
            Get.back();
          },
        ),
        title: Text(
          'Listening Mode',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.light_mode_outlined, color: Colors.white),
            onPressed: () => Get.find<ThemeController>().toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showSettingsDialog(),
            tooltip: 'TTS Settings',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background with book cover
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (rect) => LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.9),
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.9),
                ],
              ).createShader(rect),
              blendMode: BlendMode.darken,
              child: Image.network(
                widget.coverImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: isLoading
                ? _buildLoadingView()
                : SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: screenSize.height -
                            kToolbarHeight -
                            MediaQuery.of(context).padding.top,
                      ),
                      child: Column(
                        children: [
                          // Book info section
                          Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                // Book cover with animation
                                RepaintBoundary(
                                  child: GetBuilder<TtsController>(
                                    id: 'playing_state',
                                    builder: (controller) => AnimatedBuilder(
                                      animation: _pulseAnimation,
                                      builder: (context, child) {
                                        return Transform.scale(
                                          scale: controller.isPlaying.value
                                              ? _pulseAnimation.value
                                              : 1.0,
                                          child: Container(
                                            height: screenSize.height * 0.2,
                                            width: screenSize.width * 0.35,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: colorScheme.primary
                                                      .withOpacity(0.3),
                                                  blurRadius: 20,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Image.network(
                                                widget.coverImageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Container(
                                                  color: colorScheme
                                                      .surfaceContainerHighest,
                                                  child: const Icon(Icons.book,
                                                      size: 40),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Book title and author
                                Text(
                                  widget.bookTitle,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'by ${widget.author}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Progress and controls section
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Progress indicator
                                      RepaintBoundary(
                                        child: GetBuilder<TtsController>(
                                          id: 'progress',
                                          builder: (controller) => Column(
                                            children: [
                                              LinearProgressIndicator(
                                                value: controller
                                                    .progressPercentage,
                                                backgroundColor: Colors.white24,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                            Color>(
                                                        colorScheme.primary),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    controller
                                                        .currentTimeFormatted,
                                                    style: TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 12),
                                                  ),
                                                  Text(
                                                    controller
                                                        .totalTimeFormatted,
                                                    style: TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      // Page navigation
                                      if (totalPages > 0) ...[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                              onPressed: currentPage > 0
                                                  ? _previousPage
                                                  : null,
                                              icon: Icon(
                                                Icons.skip_previous,
                                                color: currentPage > 0
                                                    ? Colors.white
                                                    : Colors.white38,
                                                size: 28,
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  Text(
                                                    'Page ${currentPage + 1} of $totalPages',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  ElevatedButton(
                                                    onPressed: _playCurrentPage,
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          colorScheme.secondary,
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 8),
                                                      minimumSize:
                                                          const Size(120, 36),
                                                    ),
                                                    child: Text('Play Page',
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed:
                                                  currentPage < totalPages - 1
                                                      ? _nextPage
                                                      : null,
                                              icon: Icon(
                                                Icons.skip_next,
                                                color:
                                                    currentPage < totalPages - 1
                                                        ? Colors.white
                                                        : Colors.white38,
                                                size: 28,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                      ],

                                      // Main playback controls
                                      Obx(() => Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              IconButton(
                                                onPressed: () =>
                                                    ttsController.stop(),
                                                icon: Icon(
                                                  Icons.stop,
                                                  color: Colors.white,
                                                  size: 28,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  if (ttsController
                                                      .isPlaying.value) {
                                                    ttsController.pause();
                                                  } else if (ttsController
                                                      .isPaused.value) {
                                                    ttsController.resume();
                                                  } else {
                                                    _playAllText();
                                                  }
                                                },
                                                child: Container(
                                                  width: 64,
                                                  height: 64,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        colorScheme.primary,
                                                        colorScheme.secondary
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: colorScheme
                                                            .primary
                                                            .withOpacity(0.4),
                                                        blurRadius: 16,
                                                        spreadRadius: 1,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    ttsController
                                                            .isPlaying.value
                                                        ? Icons.pause
                                                        : Icons.play_arrow,
                                                    color: Colors.white,
                                                    size: 32,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: _playAllText,
                                                icon: Icon(
                                                  Icons.replay,
                                                  color: Colors.white,
                                                  size: 28,
                                                ),
                                              ),
                                            ],
                                          )),

                                      const SizedBox(height: 20),

                                      // Speed control
                                      RepaintBoundary(
                                        child: GetBuilder<TtsController>(
                                          id: 'speed',
                                          builder: (controller) => Column(
                                            children: [
                                              Text(
                                                'Speed: ${controller.speechRate.value.toStringAsFixed(1)}x',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14),
                                              ),
                                              const SizedBox(height: 8),
                                              SliderTheme(
                                                data: SliderTheme.of(context)
                                                    .copyWith(
                                                  trackHeight: 3,
                                                  thumbShape:
                                                      RoundSliderThumbShape(
                                                          enabledThumbRadius:
                                                              8),
                                                ),
                                                child: Slider(
                                                  value: controller
                                                      .speechRate.value,
                                                  min: 0.1,
                                                  max: 2.0,
                                                  divisions: 19,
                                                  activeColor:
                                                      colorScheme.primary,
                                                  inactiveColor: Colors.white24,
                                                  onChanged: (value) =>
                                                      controller
                                                          .setSpeechRate(value),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Bottom padding
                          const SizedBox(height: 150),
                        ],
                      ),
                    ),
                  ),
          ),

          // Text display overlay at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: RepaintBoundary(
              child: Obx(() {
                if (!ttsController.isPlaying.value ||
                    ttsController.currentSpeakingText.value.isEmpty) {
                  return SizedBox.shrink();
                }

                return GetBuilder<TtsController>(
                  id: 'text_overlay',
                  builder: (controller) => Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.3,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.volume_up,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              controller.isPlayingChunks.value
                                  ? 'Speaking (${controller.currentChunkIndex.value + 1}/${controller.textChunks.length})'
                                  : 'Speaking',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              onPressed: () => controller.stop(),
                              icon: Icon(Icons.close,
                                  color: Colors.white70, size: 18),
                              constraints:
                                  BoxConstraints(minWidth: 32, minHeight: 32),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Flexible(
                          child: SingleChildScrollView(
                            child: Text(
                              controller.currentSpeakingText.value,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            isExtracting ? 'Extracting text from PDF...' : 'Preparing audio...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'This may take a few moments',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('TTS Settings'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Volume control
              Obx(() => Column(
                    children: [
                      Text(
                          'Volume: ${(ttsController.speechVolume.value * 100).round()}%'),
                      Slider(
                        value: ttsController.speechVolume.value,
                        min: 0.0,
                        max: 1.0,
                        onChanged: (value) => ttsController.setVolume(value),
                      ),
                    ],
                  )),

              // Pitch control
              Obx(() => Column(
                    children: [
                      Text(
                          'Pitch: ${ttsController.speechPitch.value.toStringAsFixed(1)}'),
                      Slider(
                        value: ttsController.speechPitch.value,
                        min: 0.5,
                        max: 2.0,
                        onChanged: (value) => ttsController.setPitch(value),
                      ),
                    ],
                  )),

              // Language selection
              Obx(() => ttsController.availableLanguages.isNotEmpty
                  ? DropdownButton<String>(
                      value: ttsController.currentLanguage.value,
                      items: ttsController.availableLanguages
                          .map((lang) => DropdownMenuItem(
                                value: lang,
                                child: Text(lang),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          ttsController.setLanguage(value);
                        }
                      },
                    )
                  : Text('Loading languages...')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
