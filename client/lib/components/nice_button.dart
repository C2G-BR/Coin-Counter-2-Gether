import 'package:flutter/material.dart';

class NiceButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final void Function() onPressed;

  const NiceButton({Key? key, required this.text, required this.icon, required this.onPressed}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
        ),
        icon: Icon(
          icon,
          size: 24.0,
        ),
        label: Text(
          text,
          style: const TextStyle(fontSize: 24),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
