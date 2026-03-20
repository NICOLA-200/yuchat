import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo image
            SizedBox(
              width: 100,
              height: 100,
              child: Image(
                image: AssetImage('lib/assets/images/logo.png'),
                fit: BoxFit.contain,
              ),
            )
          ],
        ),
      ),
    );
  }
}
  