import 'package:flutter/material.dart';

import '../maps_page.dart';

class CustomBottomAppBar extends StatelessWidget {
  final List<Function()> onPressed;
  final int currentIndex;

  const CustomBottomAppBar({
    Key? key,
    required this.onPressed,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Container(
        height: 60, // Adjust the height as needed
        padding: EdgeInsets.symmetric(horizontal: 16.0), // Adjust padding as needed
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                onPressed[0](); // Handle Home button tap
              },
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                onPressed[1](); // Handle Search button tap
              },
            ),
            IconButton(
              icon: Icon(Icons.favorite),
              onPressed: () {
                onPressed[2](); // Handle Favorite button tap
              },
            ),
            IconButton(
              icon: Icon(Icons.location_pin),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapsPage(),
                  ),
                );
                onPressed[3](); // Handle Profile button tap
              },
            ),
          ],
        ),
      ),
    );
  }
}
