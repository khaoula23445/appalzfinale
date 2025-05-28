import 'package:flutter/material.dart';

class TabIconData {
  TabIconData({
    required this.icon,
    required this.selectedIcon,
    this.index = 0,
    this.isSelected = false,
    this.animationController,
  });

  IconData icon; // Default icon
  IconData selectedIcon; // Active/selected icon
  bool isSelected;
  int index;
  AnimationController? animationController;

  static List<TabIconData> tabIconsList = <TabIconData>[
    TabIconData(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      index: 0,
      isSelected: true,
    ),
    TabIconData(
      icon: Icons.games_outlined,
      selectedIcon: Icons.games,
      index: 1,
      isSelected: false,
    ),
    TabIconData(
      icon: Icons.map_outlined,
      selectedIcon: Icons.map,
      index: 2,
      isSelected: false,
    ),
    TabIconData(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      index: 3,
      isSelected: false,
    ),
    TabIconData(
      icon: Icons.games_outlined,
      selectedIcon: Icons.games_outlined,
      index: 4,
      isSelected: false,
    ),
    TabIconData(
      icon: Icons.games_outlined,
      selectedIcon: Icons.games_outlined,
      index: 5,
      isSelected: false,
    ),
  ];
}
