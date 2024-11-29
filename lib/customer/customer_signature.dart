import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:salesmanapp/userdata.dart';
import 'package:salesmanapp/variables/colors.dart';
import 'package:salesmanapp/widgets/dialogs.dart';
import 'package:signature/signature.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => print("Value changed"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          //SIGNATURE CANVAS
          Signature(
            controller: _controller,
            height: MediaQuery.of(context).size.height - 80,
            backgroundColor: Colors.white12,
          ),
          //OK AND CLEAR BUTTONS
          Container(
            decoration: const BoxDecoration(color: Colors.black),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                //SHOW EXPORTED IMAGE IN NEW ROUTE
                IconButton(
                  icon: const Icon(Icons.check),
                  color: ColorsTheme.mainColor,
                  onPressed: () async {
                    if (_controller.isNotEmpty) {
                      var data = await _controller.toPngBytes();
                      var signData = base64.encode(data!);
                      OrderData.signature = signData;
                      final action = await WarningDialogs.openDialog(
                        context,
                        'Information',
                        'Signature Saved Successfully',
                        false,
                        'OK',
                      );
                      if (action == DialogAction.yes) {
                        Navigator.pop(context);
                        OrderData.setSign = true;
                      }
                    }
                  },
                ),
                //CLEAR CANVAS
                IconButton(
                  icon: const Icon(Icons.clear),
                  color: ColorsTheme.mainColor,
                  onPressed: () {
                    setState(() => _controller.clear());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
