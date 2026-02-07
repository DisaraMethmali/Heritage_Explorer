import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/navigation_state.dart';
import '../providers/user_provider.dart';

import 'home_screen.dart';
import 'location_screen.dart';
import 'recommendation_screen.dart';
import 'about_screen.dart';
import 'chat_screen.dart';
import 'king_conversation_screen.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    // Get userId from UserProvider
    final userId = Provider.of<UserProvider>(context, listen: false).userId;

    // Screens that require userId must be initialized here
    final List<Widget> screens = [
      const HomeScreen(),
      const LocationScreen(),
      const RecommendationScreen(),
      ChatScreen(userId: userId), // pass userId here
      const KingConversationScreen(),
    ];

    return ValueListenableBuilder<int>(
      valueListenable: NavigationState.selectedIndex,
      builder: (context, currentIndex, _) {
        return Scaffold(
          body: screens[currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF004C7A),
            unselectedItemColor: Colors.grey,
            onTap: (index) {
              NavigationState.selectedIndex.value = index;
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.location_on),
                label: "Location",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.recommend),
                label: "Recommend",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: "Chat",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book), // icon for king conversation
                label: "Story",
              ),
            ],
          ),
        );
      },
    );
  }
}
