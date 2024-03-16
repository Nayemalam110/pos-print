import 'package:flutter/material.dart';
import 'package:simple_bill/bill_page.dart';

class FirstPage extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  List<Map<String, dynamic>> _items = [];

  void _addItem() {
    String name = _nameController.text.trim();
    String price = _priceController.text.trim();
    if (name.isNotEmpty && price.isNotEmpty) {
      setState(() {
        _items.add({
          'name': name,
          'price': double.parse(price),
        });
        _nameController.clear();
        _priceController.clear();
      });
    }
  }

  void _navigateToBillPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BillPage(items: _items)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Items'),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(maxWidth: 600),
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Item Name'),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _addItem,
                child: Text('Add Item'),
              ),
              SizedBox(height: 20.0),
              Text(
                'Items Added:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(_items[index]['name']),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text('\$${_items[index]['price']}'),
                      ),
                    ],
                  );
                },
              ),
              Divider(),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Total Price : ',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '\$${_items.fold<double>(0, (prev, item) => prev + item['price'])}',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () => _navigateToBillPage(context),
                child: Text('View Bill'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
