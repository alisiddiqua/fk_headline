import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/api_provider.dart';
import 'home_screen.dart';
import 'category_screen.dart';
import 'search_screen.dart';
import 'islamiafkaar_screen.dart';
import 'shorts_screen.dart';
import 'widgets/audio_mini_player.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentTabProvider);

    const screens = [
      HomeScreen(),
      CategoryScreen(),
      SearchScreen(),
      ShortsScreen(),
      IslamiafkaarScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: currentIndex,
            children: screens,
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AudioMiniPlayer(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) {
          ref.read(currentTabProvider.notifier).state = index;
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_fill, color: Colors.red),
            label: 'FK Shorts',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'Islamiafkaar'),
        ],
      ),
    );
  }
}
