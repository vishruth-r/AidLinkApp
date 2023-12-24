import 'package:flutter/material.dart';

class RequestPage extends StatefulWidget {
  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  List<String> items = ['Water', 'Bandages', 'Medicine', 'Blankets'];
  String selectedItem = 'Water';
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Resources'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DropdownButtonFormField<String>(
              value: selectedItem,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedItem = newValue!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Select Item',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                quantity = int.tryParse(value) ?? 1;
              },
              decoration: InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Perform action on submit (e.g., send request to backend)
                _submitRequest();
              },
              child: Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitRequest() {
    // Perform action with selected item and quantity
    print('Item: $selectedItem, Quantity: $quantity');
    // Add logic to send the request to the backend
    // For example, make an API call to submit the request
  }
}
