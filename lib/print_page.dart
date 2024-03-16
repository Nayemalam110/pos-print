import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class PrintPage extends StatefulWidget {
  final List<Map<String, dynamic>> items;

  const PrintPage({Key? key, required this.items}) : super(key: key);

  @override
  _PrintPageState createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool? isConnected;
  String _dataToPrint = 'This is the data to print'; // Initial data
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  BluetoothConnection? connection;
  File? _logoImage;

  @override
  void initState() {
    super.initState();
    // initPrinter();

    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    // Listen for Bluetooth state changes
    FlutterBluetoothSerial.instance.onStateChanged().listen((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    // Discover Bluetooth devices
    _listPairedDevices();
  }

  void _listPairedDevices() async {
    List<BluetoothDevice> devices =
        await FlutterBluetoothSerial.instance.getBondedDevices();
    setState(() {
      _devices = devices;
    });
  }
// image section  *********************************************** image section

  Future<void> _pickLogoFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _logoImage = File(pickedImage.path);
      });
    }
  }

  Future<String> imageToString(_logoImage) async {
    final File imageFile = _logoImage;
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64String = base64Encode(imageBytes);
    return base64String;
  }

  Future<void> _pickLogoFromCamera() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _logoImage = File(pickedImage.path);
      });
    }
  }

  // Future<void> _printReceipt() async {
  //   if (_selectedDevice != null) {
  //     try {
  //       BluetoothConnection connection =
  //           await BluetoothConnection.toAddress(_selectedDevice!.address);
  //       final total =
  //           widget.items.fold(0, (num sum, item) => sum + item['price']);
  //       String receipt = _logoImage != null
  //           ? '${imageToString(_logoImage)}\n\n'
  //           : 'Your Logo Here\n\n'; // Replace with your logo
  //       final ByteData data = await rootBundle.load('assets/logo.png');
  //       final Uint8List bytes = data.buffer.asUint8List();
  //       receipt += String.fromCharCodes(bytes);

  //       receipt += 'Bill Details:\n';
  //       for (final item in widget.items) {
  //         receipt +=
  //             '${item['name']} ${' ' * (40 - item['name'].toString().length)} ${' ' * 20}\$${item['price']}\n';
  //       }
  //       receipt += 'Total: ${' ' * 57}\$${total.toStringAsFixed(2)}\n\n';
  //       receipt += 'Thank you for your business!';
  //       connection.output.add(utf8.encode(receipt));

  //       await connection.output.allSent;
  //       await connection.finish();
  //       ScaffoldMessenger.of(context)
  //           .showSnackBar(SnackBar(content: Text('Printing completed')));
  //     } catch (e) {
  //       print('Error printing: $e');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Failed to connect or print')));
  //     }
  //   } else {
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text('Please select a printer')));
  //   }
  // }

  // void _printData(BluetoothDevice device) {
  //   //print('Printing data: ${widget.dataToPrint} to device: $device.name');
  //   // Implement your printing logic here, potentially using a package like 'printing'
  // }

  Future<void> connectToDevice(BluetoothDevice device) async {
    // Establish connection
    try {
      BluetoothConnection connection =
          await BluetoothConnection.toAddress(device.address);
      setState(() {
        this.connection = connection;
        showSnackBar('Connected to ${device.name}');
      });
    } catch (e) {
      showSnackBar('Failed to connect to ${device.name}');
      print("Error: $e");
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  String generateContent() {
    // Example of generating content
    final total = widget.items.fold(0, (num sum, item) => sum + item['price']);
    // String receipt = 'Your Logo Here\n\n'; // Replace with your logo

    String receipt = ' ';
    // _logoImage != null ? '${_logoImage!.path}\n\n' : 'Your Logo Here\n\n';

//

    receipt += 'Bill Details:\n'.toString().padLeft(20);
    receipt += 'Name:          ${'Price'.toString().padLeft(10)}\n';
    receipt += '-------------------------------\n';

    for (final item in widget.items) {
      receipt +=
          '${item['name'].toString().padRight(20)} ${item['price'].toString().padLeft(10)}\n';
    }
    receipt += '-------------------------------\n';
    receipt += 'Total:          ${total.toString().padLeft(10)}\n\n';
    receipt += 'Thank you for your business 123!\n\n\n\n';
    return receipt;
  }

  // Future<Uint8List> generatePDF() async {
  //   final pdf = pw.Document();
  //   pdf.addPage(
  //     pw.Page(
  //       build: (pw.Context context) {
  //         return pw.Center(
  //           child: pw.Text('Hello, World! This is a Testing.',
  //               style: pw.TextStyle(fontSize: 40)),
  //         );
  //       },
  //     ),
  //   );
  //   return pdf.save(); // Returns a Future<Uint8List>
  // }

  Future<void> printText() async {
    // Print text
    try {
      if (connection != null && connection!.isConnected) {
        String content = generateContent();
        //Uint8List pdfData = await generatePDF(); // Generate the PDF document
        //String pdfString = String.fromCharCodes(pdfData);
        //connection!.output.add(pdfData);
        //connection!.output.add(Uint8List.fromList(content.codeUnits));
        // if (_logoImage != null) {
        //   // Convert the image to a Uint8List
        //   Uint8List imageBytes = await _logoImage!.readAsBytes();
        //   // Send the image data to the printer
        //   connection!.output.add(imageBytes);
        //   await connection!.output.allSent; // Ensure all data is sent
        // } else {
        //   // If no logo is selected, print a placeholder
        //   connection!.output.add(utf8.encode('Your Logo Here\n\n'));
        //   await connection!.output.allSent; // Ensure all data is sent
        // }

        connection!.output.add(utf8.encode(content));
        await connection!.output.allSent;
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Printer not connected.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Print Page'),
      ),
      body: Container(
        constraints: BoxConstraints(maxWidth: 600),
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo
            Container(
              alignment: Alignment.center,
              child: _logoImage != null
                  ? Image.file(
                      _logoImage!,
                      height: 100,
                    )
                  : Image.asset(
                      'assets/logo.png', // Replace with your placeholder logo path
                      height: 100,
                    ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _pickLogoFromGallery,
                  child: Text('Upload Logo'),
                ),
                ElevatedButton(
                  onPressed: _pickLogoFromCamera,
                  child: Text('Take a Photo'),
                ),
              ],
            ),
            SizedBox(height: 20.0),

            Text(
              'Paired Devices:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            Expanded(
              child: ListView.builder(
                itemCount: _devices.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_devices[index].name ?? ' '),
                    onTap: () {
                      setState(() {
                        _selectedDevice = _devices[index];
                        connectToDevice(_selectedDevice!);
                      });
                    },
                    selected: _selectedDevice == _devices[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: printText,
        child: Icon(Icons.print),
      ),
    );
  }
}
