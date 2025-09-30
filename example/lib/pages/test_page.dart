import 'package:flutter/material.dart';

class OpenContainerDemo extends StatelessWidget {
  const OpenContainerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: const Text('OpenContainer FAB Morph'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.touch_app, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Tap the FAB to see the smooth morph transition',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
