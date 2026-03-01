import 'package:flutter/material.dart';

/// Placeholder page for the "+" tab. Tap "+" in the nav bar shows this screen.
/// Can be replaced later with modal or create flow.
class PlusPlaceholderPage extends StatelessWidget {
  const PlusPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 64),
            SizedBox(height: 16),
            Text('+', style: TextStyle(fontSize: 32)),
          ],
        ),
      ),
    );
  }
}
