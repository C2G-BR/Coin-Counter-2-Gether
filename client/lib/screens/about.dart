import 'package:flutter/material.dart';
import '../components/bottom_nav.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'Creators of Coin2Gether Counter©',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 48,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: const [
                      Icon(
                        Icons.account_circle,
                        size: 98,
                      ),
                      Text(
                        'Bastian Berle',
                        style: TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                  Column(
                    children: const [
                      Icon(
                        Icons.account_circle,
                        size: 98,
                      ),
                      Text(
                        'Ron Holzapfel',
                        style: TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 48,
              ),
              const Text(
                'Coin2Gether Counter is an application to count coins by taking a photo of them. To test it, you need to take a photo of your coins. Once you do that, we will calculate the value of the coins in the picture and show it to you. You can also take a picture from your gallery.',
                style: TextStyle(fontSize: 24, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              const Text(
                '...',
                style: TextStyle(fontSize: 24, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 48,
              ),
              const Text(
                'Try to place the coins so that the tail is visible as much as possible. Each field has two numbers. The first number indicates the detected value in euro cents. The second number indicates the certainty with which the model can recognize the correct value.',
                style: TextStyle(fontSize: 24, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(1),
    );
  }
}
