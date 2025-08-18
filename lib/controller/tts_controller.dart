import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

class TtsController extends GetxController {
  FlutterTts? flutterTts;
  
  // Observable variables
  var isPlaying = false.obs;
  var isPaused = false.obs;
  var currentPosition = 0.obs;
  var totalLength = 0.obs;
  var currentText = ''.obs;
  var speechRate = 0.5.obs;
  var speechVolume = 0.8.obs;
  var speechPitch = 1.0.obs;
  var availableLanguages = <String>[].obs;
  var currentLanguage = 'en-US'.obs;
  var availableVoices = <Map>[].obs;
  var currentVoice = <String, String>{}.obs;
  var isInitialized = false.obs;
  var currentChunkIndex = 0.obs;
  var textChunks = <String>[].obs;
  var isPlayingChunks = false.obs;
  var currentSpeakingText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      flutterTts = FlutterTts();
      
      // Check if TTS is available on the device
      bool isAvailable = await _checkTtsAvailability();
      if (!isAvailable) {
        print("TTS not available on this device");
        isInitialized.value = false;
        return;
      }
      
      // Set basic handlers
      flutterTts!.setStartHandler(() {
        isPlaying.value = true;
        isPaused.value = false;
      });

      flutterTts!.setCompletionHandler(() {
        // Handle chunk completion
        if (isPlayingChunks.value) {
          currentChunkIndex.value++;
          if (currentChunkIndex.value < textChunks.length) {
            // Continue with next chunk
            _speakNextChunk();
          } else {
            // All chunks completed
            isPlayingChunks.value = false;
            isPlaying.value = false;
            isPaused.value = false;
            print("TTS: All chunks completed");
          }
        } else {
          // Normal single text completion
          isPlaying.value = false;
          isPaused.value = false;
        }
      });

      flutterTts!.setErrorHandler((msg) {
        print("TTS Error: $msg");
        isPlaying.value = false;
        isPaused.value = false;
        isPlayingChunks.value = false;
        
        // Show user-friendly message for common errors
        if (msg.contains("-8") || msg.contains("speak")) {
          Get.snackbar(
            "TTS Unavailable",
            "Text-to-speech is not available. Please check your device's TTS settings.",
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 5),
          );
        }
      });

      // Set minimal settings with delays
      await Future.delayed(Duration(milliseconds: 300));
      await flutterTts!.setSpeechRate(0.5);
      await Future.delayed(Duration(milliseconds: 100));
      await flutterTts!.setVolume(0.8);
      await Future.delayed(Duration(milliseconds: 100));
      await flutterTts!.setPitch(1.0);

      isInitialized.value = true;
      print("TTS initialized successfully");
    } catch (e) {
      print("TTS initialization error: $e");
      isInitialized.value = false;
      
      Get.snackbar(
        "TTS Error",
        "Text-to-speech initialization failed. Feature unavailable.",
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    }
  }

  Future<bool> _checkTtsAvailability() async {
    try {
      // Try to get available languages as a test
      var languages = await flutterTts!.getLanguages;
      return languages != null && languages.isNotEmpty;
    } catch (e) {
      print("TTS availability check failed: $e");
      return false;
    }
  }

  Future<void> speak(String text) async {
    print("=== TTS DEBUG: speak() called ===");
    print("Text length: ${text.length}");
    print("Text preview: ${text.substring(0, text.length > 200 ? 200 : text.length)}");
    print("Text is empty: ${text.trim().isEmpty}");
    
    if (text.trim().isEmpty) {
      print("TTS: Skipping empty text");
      return;
    }
    
    if (flutterTts == null || !isInitialized.value) {
      print("TTS: Initializing TTS...");
      await _initTts();
      if (!isInitialized.value) {
        print("TTS: Initialization failed");
        Get.snackbar(
          "TTS Unavailable",
          "Text-to-speech is not supported on this device",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      await Future.delayed(Duration(milliseconds: 500));
    }

    try {
      print("TTS: Stopping current speech...");
      await flutterTts!.stop();
      await Future.delayed(Duration(milliseconds: 200));
      
      currentText.value = text;
      
      // Check if text is too long for single TTS call
      if (text.length > 4000) {
        print("TTS: Text too long (${text.length} chars), splitting into chunks");
        currentSpeakingText.value = text;
        print("TTS: Set currentSpeakingText to ${text.length} characters");
        await _speakInChunks(text);
      } else {
        print("TTS: Starting to speak text...");
        currentSpeakingText.value = text;
        print("TTS: Set currentSpeakingText to ${text.length} characters");
        await flutterTts!.speak(text);
        print("TTS: Speak command sent successfully");
      }
    } catch (e) {
      print("TTS: Speak error: $e");
      isPlaying.value = false;
      isPaused.value = false;
      
      Get.snackbar(
        "TTS Error",
        "Unable to speak this text. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    }
  }

  Future<void> _speakInChunks(String text) async {
    // Split text into manageable chunks
    textChunks.value = _splitTextIntoChunks(text, 3000);
    currentChunkIndex.value = 0;
    isPlayingChunks.value = true;
    
    print("TTS: Split into ${textChunks.length} chunks");
    
    // Start speaking the first chunk
    await _speakNextChunk();
  }

  Future<void> _speakNextChunk() async {
    if (currentChunkIndex.value < textChunks.length && isPlayingChunks.value) {
      String chunk = textChunks[currentChunkIndex.value];
      print("TTS: Speaking chunk ${currentChunkIndex.value + 1}/${textChunks.length} (${chunk.length} chars)");
      currentSpeakingText.value = chunk;
      print("TTS: Updated currentSpeakingText with chunk ${currentChunkIndex.value + 1} (${chunk.length} chars)");
      
      try {
        await flutterTts!.speak(chunk);
      } catch (e) {
        print("TTS: Chunk speak error: $e");
        isPlayingChunks.value = false;
        isPlaying.value = false;
        currentSpeakingText.value = '';
      }
    }
  }

  List<String> _splitTextIntoChunks(String text, int maxChunkSize) {
    List<String> chunks = [];
    List<String> sentences = text.split(RegExp(r'[.!?]+\s+'));
    
    String currentChunk = '';
    
    for (String sentence in sentences) {
      if (currentChunk.length + sentence.length + 1 <= maxChunkSize) {
        currentChunk += (currentChunk.isEmpty ? '' : '. ') + sentence;
      } else {
        if (currentChunk.isNotEmpty) {
          chunks.add(currentChunk.trim());
          currentChunk = sentence;
        } else {
          // Single sentence is too long, split by words
          List<String> words = sentence.split(' ');
          String wordChunk = '';
          for (String word in words) {
            if (wordChunk.length + word.length + 1 <= maxChunkSize) {
              wordChunk += (wordChunk.isEmpty ? '' : ' ') + word;
            } else {
              if (wordChunk.isNotEmpty) {
                chunks.add(wordChunk.trim());
                wordChunk = word;
              }
            }
          }
          if (wordChunk.isNotEmpty) {
            currentChunk = wordChunk;
          }
        }
      }
    }
    
    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk.trim());
    }
    
    return chunks;
  }

  Future<void> pause() async {
    try {
      if (flutterTts != null) {
        await flutterTts!.pause();
      }
    } catch (e) {
      print('Pause error: $e');
    }
  }

  Future<void> resume() async {
    try {
      if (flutterTts != null && isPaused.value) {
        await flutterTts!.speak(currentText.value);
      }
    } catch (e) {
      print('Resume error: $e');
    }
  }

  Future<void> stop() async {
    try {
      if (flutterTts != null) {
        await flutterTts!.stop();
      }
      isPlaying.value = false;
      isPaused.value = false;
      isPlayingChunks.value = false;
      currentSpeakingText.value = '';
      print("TTS: Stopped and cleared speaking text");
    } catch (e) {
      print('Stop error: $e');
    }
  }

  Future<void> setSpeechRate(double rate) async {
    speechRate.value = rate;
    try {
      if (flutterTts != null) {
        await flutterTts!.setSpeechRate(rate);
      }
    } catch (e) {
      print('Set speech rate error: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    speechVolume.value = volume;
    try {
      if (flutterTts != null) {
        await flutterTts!.setVolume(volume);
      }
    } catch (e) {
      print('Set volume error: $e');
    }
  }

  Future<void> setPitch(double pitch) async {
    speechPitch.value = pitch;
    try {
      if (flutterTts != null) {
        await flutterTts!.setPitch(pitch);
      }
    } catch (e) {
      print('Set pitch error: $e');
    }
  }

  Future<void> setLanguage(String language) async {
    currentLanguage.value = language;
    try {
      if (flutterTts != null) {
        await flutterTts!.setLanguage(language);
      }
    } catch (e) {
      print('Set language error: $e');
    }
  }

  // Computed properties for UI
  double get progressPercentage => 0.0;
  String get currentTimeFormatted => "0:00";
  String get totalTimeFormatted => "0:00";

  @override
  void onClose() {
    stop();
    super.onClose();
  }
}
