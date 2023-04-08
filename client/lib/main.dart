import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:frontend/screens/all.dart';
import 'package:frontend/controllers/navigation.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ListenableProvider<NavigationController>(
          create: (_) => NavigationController()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NavigationController navigation =
        Provider.of<NavigationController>(context);

    return MaterialApp(
      home: Navigator(
        pages: [
          if (navigation.screenName == '/about')
            const MaterialPage(child: AboutScreen())
          else
            MaterialPage(child: HomeScreen()),
        ],
        onPopPage: (route, result) {
          bool popStatus = route.didPop(result);
          if (popStatus == true) {
            Provider.of<NavigationController>(context, listen: false)
                .changeScreen('/');
          }
          return popStatus;
        },
      ),
    );
  }
}
