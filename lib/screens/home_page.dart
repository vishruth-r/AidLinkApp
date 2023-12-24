import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swipe Boxes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Color _redBoxColor = Colors.grey;
  Color _orangeBoxColor = Colors.grey;
  Color _blueBoxColor = Colors.grey;
  Color _greenBoxColor = Colors.grey;

  bool _snackBarShown = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Swipe Boxes'),
      ),
      body: ListView(
        padding: EdgeInsets.all(20.0),
        children: [
          _buildSwipeBox(Colors.red, _redBoxColor, "Red Alert"),
          SizedBox(height: 20),
          _buildSwipeBox(Colors.orange, _orangeBoxColor, "Orange Alert"),
          SizedBox(height: 20),
          _buildSwipeBox(Colors.blue, _blueBoxColor, "Blue Alert"),
          SizedBox(height: 20),
          _buildSwipeBox(Colors.green, _greenBoxColor, "Green Alert"),
        ],
      ),
    );
  }

  Widget _buildSwipeBox(Color color, Color boxColor, String alertText) {
    return SizedBox(
      height: 60,
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          if (!_snackBarShown && details.delta.dx > 0) {
            setState(() {
              boxColor = color;
              _showSnackBar(alertText);
              _snackBarShown = true;
            });
          }
          if (details.delta.dx < 0) {
            setState(() {
              boxColor = Colors.grey;
              _snackBarShown = false;
            });
          }
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: boxColor,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Center(
            child: Text(
              alertText,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String text) {
    print("alert shown");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: Duration(seconds: 2),
      ),
    ).closed.then((reason) {
      setState(() {
        _snackBarShown = false; // Reset the flag after the SnackBar is closed
      });
    });
  }
}
