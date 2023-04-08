import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/controllers/navigation.dart';

class BottomNav extends StatelessWidget {
  final int activeButtonIndex;

  const BottomNav(this.activeButtonIndex, {Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    NavigationController navigation =
        Provider.of<NavigationController>(context, listen: false);


    return BottomNavigationBar(
      currentIndex: activeButtonIndex,
      onTap: (buttonIndex) {
        switch (buttonIndex) {
          case 1:
            navigation.changeScreen('/about');
            break;
          default:
            navigation.changeScreen('/');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'About',
        ),
      ],
    );
  }
}
