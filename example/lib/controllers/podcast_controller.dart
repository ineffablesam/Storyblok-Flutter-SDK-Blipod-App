import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/article_generation.dart';

class PodcastController extends GetxController {
  final supabase = Supabase.instance.client;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Observable variables
  var isPlaying = false.obs;
  var currentPosition = 0.0.obs;
  var totalDuration = 0.0.obs;
  var playbackSpeed = 1.0.obs;
  var isExpanded = false.obs;
  var percentage = 0.0.obs;

  // Article generations list
  var articleGenerations = <ArticleGeneration>[].obs;
  var isLoading = true.obs;

  // Current playing podcast
  var currentPodcast = Rxn<ArticleGeneration>();

  // Mini player state
  var isPlayerVisible = false.obs;

  // Loading state for audio
  var isAudioLoading = false.obs;

  RealtimeChannel? _realtimeChannel;

  @override
  void onInit() {
    super.onInit();
    _loadArticleGenerations();
    _setupRealtimeSubscription();
    _setupAudioListeners();
  }

  @override
  void onClose() {
    _realtimeChannel?.unsubscribe();
    _audioPlayer.dispose();
    super.onClose();
  }

  void _setupAudioListeners() {
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;

      // Handle completion
      if (state.processingState == ProcessingState.completed) {
        isPlaying.value = false;
        currentPosition.value = 0.0;
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
      }
    });

    // Listen to position changes
    _audioPlayer.positionStream.listen((position) {
      currentPosition.value = position.inSeconds.toDouble();
    });

    // Listen to duration changes
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        totalDuration.value = duration.inSeconds.toDouble();
      }
    });

    // Listen to playback speed changes
    _audioPlayer.speedStream.listen((speed) {
      playbackSpeed.value = speed;
    });
  }

  Future<void> _loadArticleGenerations() async {
    try {
      isLoading.value = true;

      final userId = getUserId();
      if (userId == null) {
        if (kDebugMode) {
          print('User not authenticated');
        }
        return;
      }

      debugPrint('Loading article generations for user: $userId');

      final session = supabase.auth.currentSession;
      debugPrint('Current session: ${session != null ? "exists" : "null"}');
      debugPrint(
        'Access token: ${session?.accessToken != null ? "exists" : "null"}',
      );

      final response = await supabase
          .from('article_generations')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      debugPrint('Response received: ${response.length} articles');

      articleGenerations.value = (response as List)
          .map((json) => ArticleGeneration.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error loading article generations: $e');
      debugPrint('Error type: ${e.runtimeType}');
    } finally {
      isLoading.value = false;
    }
  }

  void _setupRealtimeSubscription() {
    final userId = getUserId();
    if (userId == null) {
      print('User not authenticated');
      return;
    }

    debugPrint('Setting up realtime subscription for user: $userId');
    _realtimeChannel = supabase
        .channel('article_generations_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'article_generations',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) => _handleRealtimeUpdate(payload),
        )
        .subscribe();
  }

  String? getUserId() {
    if (kIsWeb) {
      return "ce275d54-579e-463f-95a7-5cec946cc791";
    }
    return supabase.auth.currentUser?.id;
  }

  void _handleRealtimeUpdate(PostgresChangePayload payload) {
    if (payload.eventType == PostgresChangeEvent.insert) {
      final newArticle = ArticleGeneration.fromJson(payload.newRecord);
      articleGenerations.insert(0, newArticle);
    } else if (payload.eventType == PostgresChangeEvent.update) {
      final updatedArticle = ArticleGeneration.fromJson(payload.newRecord);
      final index = articleGenerations.indexWhere(
        (a) => a.id == updatedArticle.id,
      );
      if (index != -1) {
        articleGenerations[index] = updatedArticle;

        // Update current podcast if it's the one being updated
        if (currentPodcast.value?.id == updatedArticle.id) {
          currentPodcast.value = updatedArticle;
        }
      }
    } else if (payload.eventType == PostgresChangeEvent.delete) {
      final deletedId = payload.oldRecord['id'];
      articleGenerations.removeWhere((a) => a.id == deletedId);

      // Close player if deleted podcast is currently playing
      if (currentPodcast.value?.id == deletedId) {
        closePlayer();
      }
    }
  }

  Future<void> togglePlayPause() async {
    try {
      if (isPlaying.value) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      debugPrint('Error toggling play/pause: $e');
      Get.snackbar(
        'Playback Error',
        'Failed to play/pause audio',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> seekTo(double position) async {
    try {
      await _audioPlayer.seek(Duration(seconds: position.toInt()));
    } catch (e) {
      debugPrint('Error seeking: $e');
    }
  }

  Future<void> skipForward() async {
    final newPosition = currentPosition.value + 15;
    final maxPosition = totalDuration.value;
    await seekTo(newPosition > maxPosition ? maxPosition : newPosition);
  }

  Future<void> skipBackward() async {
    final newPosition = currentPosition.value - 15;
    await seekTo(newPosition < 0 ? 0 : newPosition);
  }

  Future<void> changeSpeed() async {
    double newSpeed;
    if (playbackSpeed.value == 1.0) {
      newSpeed = 1.25;
    } else if (playbackSpeed.value == 1.25) {
      newSpeed = 1.5;
    } else if (playbackSpeed.value == 1.5) {
      newSpeed = 2.0;
    } else {
      newSpeed = 1.0;
    }

    try {
      await _audioPlayer.setSpeed(newSpeed);
      debugPrint('Playback speed changed to: ${newSpeed}x');
    } catch (e) {
      debugPrint('Error changing speed: $e');
    }
  }

  Future<void> startPlaying(ArticleGeneration article) async {
    try {
      // Check if audio URL is available
      if (article.audioFileUrl == null || article.audioFileUrl!.isEmpty) {
        Get.snackbar(
          'No Audio Available',
          'This article does not have an audio file yet',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      isAudioLoading.value = true;
      currentPodcast.value = article;
      isPlayerVisible.value = true;

      // Stop current playback if any
      await _audioPlayer.stop();

      // Set audio source
      debugPrint('Loading audio from: ${article.audioFileUrl}');
      await _audioPlayer.setUrl(article.audioFileUrl!);

      // Start playing
      await _audioPlayer.play();

      isAudioLoading.value = false;
    } catch (e) {
      debugPrint('Error starting playback: $e');
      isAudioLoading.value = false;

      Get.snackbar(
        'Playback Error',
        'Failed to load audio file: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );

      // Reset state
      currentPodcast.value = null;
      isPlayerVisible.value = false;
    }
  }

  Future<void> closePlayer() async {
    await _audioPlayer.stop();
    isPlayerVisible.value = false;
    isPlaying.value = false;
    currentPosition.value = 0.0;
    totalDuration.value = 0.0;
    currentPodcast.value = null;
  }

  void minimizePlayer() {
    isPlayerVisible.value = true;
  }

  String formatDuration(double seconds) {
    int minutes = (seconds / 60).floor();
    int remainingSeconds = (seconds % 60).floor();
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  double get progress => totalDuration.value > 0
      ? currentPosition.value / totalDuration.value
      : 0.0;

  Future<void> refreshArticles() async {
    await _loadArticleGenerations();
  }

  Future<void> processArticle(String articleUrl) async {
    try {
      final userId = getUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('Processing article: $articleUrl');
      debugPrint('User ID: $userId');

      final response = await http.post(
        Uri.parse(
          'https://sethozoyxgoarhziwzqv.supabase.co/functions/v1/process-article',
        ),
        headers: {
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNldGhvem95eGdvYXJoeml3enF2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg2OTM1NTMsImV4cCI6MjA3NDI2OTU1M30.pMyBNAATHfqInWlZ2eaMStMgeIf_JxTMKgN9HOs-lMg',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'articleUrl': articleUrl, 'userId': userId}),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Article processing initiated successfully');
      } else {
        throw Exception(
          'Failed to process article: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error in processArticle: $e');
      rethrow;
    }
  }
}
