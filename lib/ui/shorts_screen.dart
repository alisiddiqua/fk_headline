import 'dart:async';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;
import 'package:wakelock_plus/wakelock_plus.dart';
import '../providers/api_provider.dart';
import '../services/youtube_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

const int _shortsTabIndex = 3; // FK Shorts is the 4th tab (0-indexed)

class ShortsScreen extends ConsumerStatefulWidget {
  const ShortsScreen({super.key});

  @override
  ConsumerState<ShortsScreen> createState() => _ShortsScreenState();
}

class _ShortsScreenState extends ConsumerState<ShortsScreen> {
  int _currentIndex = 0;
  late PageController _pageController;
  NativeShortPlayer? _activePlayer; // Reference to pause externally

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shortsAsyncValue = ref.watch(shortsProvider);
    final currentTab = ref.watch(currentTabProvider);
    final bool isShortsActive = currentTab == _shortsTabIndex;

    return Scaffold(
      backgroundColor: Colors.black,
      body: shortsAsyncValue.when(
        data: (shorts) {
          if (shorts.isEmpty) return const Center(child: Text('No videos found', style: TextStyle(color: Colors.white)));
          return PageView.builder(
            controller: _pageController,
            allowImplicitScrolling: true, // TRUE TIKTOK PRE-BUFFER ENGINE: Solves the decryption latency entirely!
            scrollDirection: Axis.vertical,
            itemCount: shorts.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              
              if (index >= shorts.length - 3) {
                ref.read(shortsProvider.notifier).loadMore();
              }
            },
            itemBuilder: (context, index) {
              final videoId = shorts[index]['id']['videoId'];
              final snippet = shorts[index]['snippet'];
              final thumbnailUrl = snippet['thumbnails']['high']['url'];
              final bool isActive = _currentIndex == index;

              return Stack(
                fit: StackFit.expand,
                children: [
                  NativeShortPlayer(
                    videoId: videoId,
                    isActive: isActive && isShortsActive, // ← pause when tab hidden
                    thumbnailUrl: thumbnailUrl,
                  ),
                  
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.only(left: 20, right: 80, bottom: 40, top: 120),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black87, Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.red,
                                radius: 14,
                                child: Icon(Icons.play_arrow, color: Colors.white, size: 16),
                              ),
                              SizedBox(width: 8),
                              Text('@FikrokhabarTV', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            snippet['title'].replaceAll(RegExp(r'&quot;'), '"').replaceAll(RegExp(r'&#39;'), "'"),
                            style: const TextStyle(color: Colors.white, fontSize: 15),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.red)),
        error: (e, st) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}

class NativeShortPlayer extends StatefulWidget {
  final String videoId;
  final bool isActive;
  final String thumbnailUrl;
  
  const NativeShortPlayer({super.key, required this.videoId, required this.isActive, required this.thumbnailUrl});

  @override
  State<NativeShortPlayer> createState() => _NativeShortPlayerState();
}

class _NativeShortPlayerState extends State<NativeShortPlayer> {
  VideoPlayerController? _controller;
  final _ytConfig = yt.YoutubeExplode();
  bool _isLoading = true;
  bool _showControls = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void didUpdateWidget(NativeShortPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // INSTANT PLAY PROTOCOL: The moment the user swipes to the pre-buffered widget, it instantly plays from memory!
    if (widget.isActive != oldWidget.isActive && _controller != null) {
      if (widget.isActive) {
        _controller!.play();
        WakelockPlus.enable();
      } else {
        _controller!.pause();
        _controller!.seekTo(Duration.zero);
        WakelockPlus.disable();
      }
    }
  }

  Future<void> _initPlayer() async {
    try {
      final manifest = await _ytConfig.videos.streamsClient.getManifest(widget.videoId);
      final streamInfo = manifest.muxed.first;
      
      _controller = VideoPlayerController.networkUrl(streamInfo.url);
      await _controller!.initialize();
      _controller!.setLooping(true);
      
      // Only play immediately if this exact widget is currently visible on load
      if (widget.isActive) {
        _controller!.play();
        WakelockPlus.enable();
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Fikrokhabar Stream Intercept Error: $e");
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    if (widget.isActive) WakelockPlus.disable();
    _controller?.dispose();
    _ytConfig.close();
    super.dispose();
  }

  void _toggleControls() {
    if (_showControls) {
      // Already visible — hide immediately
      _hideTimer?.cancel();
      setState(() => _showControls = false);
    } else {
      // Show and start 5-second auto-hide timer
      _hideTimer?.cancel();
      setState(() => _showControls = true);
      _hideTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) setState(() => _showControls = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _controller == null || !_controller!.value.isInitialized) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(imageUrl: widget.thumbnailUrl, fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.5)),
          const Center(child: CircularProgressIndicator(color: Colors.red, strokeWidth: 3)),
        ],
      );
    }
    
    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Raw Video Stream
          Center(
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
            ),
          ),

          // Controls Overlay — visible only when _showControls is true
          if (_showControls)
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Seek + Play row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.replay_10, color: Colors.white, size: 42),
                          onPressed: () {
                            if (_controller != null) {
                              _controller!.seekTo(_controller!.value.position - const Duration(seconds: 10));
                            }
                          },
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            if (_controller!.value.isPlaying) {
                              _controller!.pause();
                              WakelockPlus.disable();
                            } else {
                              _controller!.play();
                              WakelockPlus.enable();
                            }
                            setState(() {});
                          },
                          child: Icon(
                            _controller!.value.isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_fill,
                            color: Colors.white,
                            size: 64,
                          ),
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          icon: const Icon(Icons.forward_10, color: Colors.white, size: 42),
                          onPressed: () {
                            if (_controller != null) {
                              _controller!.seekTo(_controller!.value.position + const Duration(seconds: 10));
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Share button
                    GestureDetector(
                      onTap: () {
                        final url = 'https://www.youtube.com/watch?v=${widget.videoId}';
                        Share.share(url, subject: 'Watch this on FK Headline');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white54),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.share, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text('Share Video', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
