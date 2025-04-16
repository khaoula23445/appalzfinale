import 'package:alzheimer_app/alzhimer_home/bottom_navigation_view/tabIcon_data.dart';
import 'package:alzheimer_app/alzhimer_home/bottom_navigation_view/tabIcon_data.dart';
import 'package:alzheimer_app/alzhimer_home/my_diary/LiveLocationMap.dart';
import 'package:alzheimer_app/games/GameSelectionScreen.dart';
import 'package:alzheimer_app/games/MemoryQuizGame.dart';
import 'package:alzheimer_app/games/training_screen.dart';
import 'package:flutter/material.dart';
import 'bottom_navigation_view/bottom_bar_view.dart';
import 'fitness_app_theme.dart';
import 'my_diary/my_diary_screen.dart';

class FitnessAppHomeScreen extends StatefulWidget {
  @override
  _FitnessAppHomeScreenState createState() => _FitnessAppHomeScreenState();
}

class _FitnessAppHomeScreenState extends State<FitnessAppHomeScreen>
    with TickerProviderStateMixin {
  AnimationController? animationController;

  List<TabIconData> tabIconsList = TabIconData.tabIconsList;

  Widget tabBody = Container(color: FitnessAppTheme.background);

  @override
  void initState() {
    tabIconsList.forEach((TabIconData tab) {
      tab.isSelected = false;
    });
    tabIconsList[0].isSelected = true;

    animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    tabBody = MyDiaryScreen(animationController: animationController);
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<bool>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            } else {
              return Stack(children: <Widget>[tabBody, bottomBar()]);
            }
          },
        ),
      ),
    );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  Widget bottomBar() {
    return Column(
      children: <Widget>[
        const Expanded(child: SizedBox()),
        BottomBarView(
          tabIconsList: tabIconsList,
          addClick: () {
            // Action pour le bouton central
          },
          changeIndex: (int index) {
            if (!mounted) return;

            animationController?.reverse().then<dynamic>((data) {
              if (!mounted) return;

              setState(() {
                switch (index) {
                  case 0:
                    tabBody = FitnessAppHomeScreen();
                    break;
                  case 1:
                    tabBody = GameSelectionScreen();
                    break;
                  case 2:
                    tabBody =
                        FitnessAppHomeScreen(); // Remplacez par votre écran
                    break;
                  case 3:
                    tabBody =
                        FitnessAppHomeScreen(); // Remplacez par votre écran
                    break;
                  default:
                    tabBody = FitnessAppHomeScreen();
                }
              });
            });
          },
        ),
      ],
    );
  }
}
