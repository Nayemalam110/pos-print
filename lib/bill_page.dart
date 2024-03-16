import 'package:flutter/material.dart';
import 'package:simple_bill/print_page.dart';

class BillPage extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const BillPage({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double totalPrice = items.fold<double>(
      0,
      (prev, item) => prev + item['price'],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Bill'),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        constraints: BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Items Added:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Item')),
                  DataColumn(label: Text('Price')),
                ],
                rows: items.map((item) {
                  return DataRow(cells: [
                    DataCell(Text(item['name'])),
                    DataCell(Text('\$${item['price']}')),
                  ]);
                }).toList(),
              ),
            ),
            SizedBox(height: 10.0),
            Divider(),
            SizedBox(height: 10.0),
            Text(
              'Total Price: \$${totalPrice.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PrintPage(items: items)),
                );
              },
              child: Text('Print Bill'),
            ),
          ],
        ),
      ),
    );
  }
}
