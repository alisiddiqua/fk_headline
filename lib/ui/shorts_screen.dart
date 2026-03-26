import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../services/youtube_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ShortsScreen extends ConsumerStatefulWidget {
  const ShortsScreen({super.key});

  @override
  ConsumerState<ShortsScreen> createState() => _ShortsScreenState();
}

class _ShortsScreenState extends ConsumerState<ShortsScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final shortsAsyncValue = ref.watch(shortsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: shortsAsyncValue.when(
        data: (shorts) {
          if (shorts.isEmpty) return const Center(child: Text('No shorts found', style: TextStyle(color: Colors.white)));
          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: shorts.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final videoId = shorts[index]['id']['videoId'];
              final snippet = shorts[index]['snippet'];
              final thumbnailUrl = snippet['thumbnails']['high']['url'];
              final bool isActive = _currentIndex == index;

              return Stack(
                fit: StackFit.expand,
                children: [
                  // This is the golden secret to extreme smoothness: 
                  // We ONLY render the heavy Youtube webview player if the card is completely active. 
                  // Otherwise, we load a featherweight thumbnail image to guarantee flawless swiping at 60Hz.
                  if (isActive)
                    ShortVideoPlayer(videoId: videoId)
                  else
                    CachedNetworkImage(
                      imageUrl: thumbnailUrl,
                      fit: BoxFit.cover,
                    ),
                  
                  // Text Overlay Gradient Box
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

class ShortVideoPlayer extends StatefulWidget {
  final String videoId;
  const ShortVideoPlayer({super.key, required this.videoId});

  @override
  State<ShortVideoPlayer> createState() => _ShortVideoPlayerState();
}

class _ShortVideoPlayerState extends State<ShortVideoPlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        loop: true,
        hideControls: true, 
        disableDragSeek: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: false,
      ),
    );
  }
}
