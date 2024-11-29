import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:salesmanapp/db/db_helper.dart';
import 'package:salesmanapp/providers/cart_items.dart';
import 'package:salesmanapp/providers/cart_total.dart';
import 'package:salesmanapp/userdata.dart';
import 'package:salesmanapp/variables/assets.dart';
import 'package:salesmanapp/variables/colors.dart';
import 'dart:ui' as ui;
import 'package:salesmanapp/widgets/dialogs.dart';
import 'package:salesmanapp/widgets/elevated_button.dart';
import 'package:salesmanapp/widgets/snackbar.dart';

class AddDialog extends StatefulWidget {
  @override
  _AddDialogState createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  final formatCurrencyAmt =
      new NumberFormat.currency(locale: "en_US", symbol: "₱");
  TextEditingController qtyController = TextEditingController()..text = '1';

  // String _qtyController = "";
  String? imgPath;
  bool noImage = true;
  bool viewSpinkit = true;

  final db = DatabaseHelper();

  // bool outofStock = false;

  List _tolist = [];
  List _setlist = [];
  // List _rows = [];

  void initState() {
    super.initState();
    getUomList();
  }

  uomonChanged() async {
    var setU = await db.setUom(CartData.itmCode, CartData.itmUom);
    print('ITEM UOM: ${CartData.itmUom}');
    _setlist = await setU;
    print(_setlist);
    if (!mounted) return;
    setState(() {
      _setlist.forEach((element) async{
        CartData.itmAmt = await (element['list_price_wtax']);
        CartData.itmTotal = (double.parse(CartData.itmAmt!) * double.parse(CartData.itmQty))
                .toString();
        CartData.imgpath = await (element['image']);
        CartData.itmDesc = await (element['product_name']);
        CartData.isMust = await (element['isMust']);
        CartData.isPromo = await (element['isPromo']);
        if (element['status'] == '0') {
          GlobalVariables.outofStock = true;
          print('This item is out of stock');
        } else {
          GlobalVariables.outofStock = false;
          print('In Stock');
        }
      });
    });
  }

  getUomList() async {
    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = documentDirectory.path + '/';
    // var filePathAndName = documentDirectory.path + '/pic.jpg';
    imgPath = firstPath;

    var getU = await db.getUom(CartData.itmCode);
    print('UOMS : $getU');
    if (!mounted) return;
    setState(() {
      _tolist = getU;
      viewSpinkit = false;
    });
    // print(_tolist);
    // print(GlobalVariables.outofStock.toString());
  }

  totalchanged() {
    CartData.totalAmount =
        (double.parse(CartData.totalAmount) + double.parse(CartData.itmTotal))
            .toStringAsFixed(2);
    CartData.itmNo =
        (int.parse(CartData.itmNo) + int.parse(CartData.itmQty)).toString();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (viewSpinkit == true) {
      return Container(
        // height: 620,
        height: MediaQuery.of(context).size.height - 100,
        width: MediaQuery.of(context).size.width,
        color: Colors.white10,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 150,
                color: Colors.white,
                height: 150,
                child: Stack(
                  children: <Widget>[
                    Image(
                      color: ColorsTheme.mainColor,
                      image: AssetsValues.cartImage,
                    ),
                    CartData.isMust == '1' || CartData.isPromo == '1'?
                    Positioned(
                      top: 0,
                      left: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CartData.isMust == '1' ? Colors.red.shade800 : Colors.green.shade800,
                        ),
                        // width: 20,
                        // height: 20,
                        padding: EdgeInsets.all(7),
                        child: Text(
                          CartData.isMust == '1' ? 'must' : 'promo',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 7,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ):SizedBox(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              // color: Colors.grey,
              padding: EdgeInsets.only(top: 60, bottom: 16, right: 5, left: 5),
              margin: EdgeInsets.only(top: 100),
              decoration: BoxDecoration(
                  color: Colors.grey[50],
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0.0, 10.0),
                    ),
                  ]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width / 2 + 80,
                    height: 200,
                    // color: Colors.grey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          // color: Colors.grey,
                          margin: EdgeInsets.only(left: 10, right: 10),
                          width: MediaQuery.of(context).size.width - 100,
                          child: Text(
                            CartData.itmDesc!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: GlobalVariables.outofStock
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 20, right: 20),
                          width: MediaQuery.of(context).size.width / 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                formatCurrencyAmt
                                    .format(double.parse(CartData.itmAmt!)),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 20, right: 20),
                          width: MediaQuery.of(context).size.width / 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              DropdownButtonHideUnderline(
                                child: ButtonTheme(
                                  alignedDropdown: true,
                                  child: DropdownButton<String>(
                                    value: CartData.itmUom,
                                    items: _tolist.map((item) {
                                      return new DropdownMenuItem(
                                        child: new Text(
                                          item['uom'],
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                        value: item['uom'].toString().trim(),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        CartData.itmUom = newValue!;
                                        uomonChanged();
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 20, right: 20),
                          width: MediaQuery.of(context).size.width / 2,
                          child: Text(
                            'Quantity',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 20, right: 20),
                          width: MediaQuery.of(context).size.width / 2,
                          // color: Colors.grey,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if (int.parse(CartData.itmQty) > 0) {
                                      int i = 0;
                                      i = int.parse(CartData.itmQty) - 1;
                                      CartData.itmQty = i.toString();
                                      CartData.itmTotal =
                                          (double.parse(CartData.itmAmt!) *
                                                  double.parse(CartData.itmQty))
                                              .toString();
                                      // print(CartData.itmTotal);
                                      qtyController.text = CartData.itmQty;
                                    }
                                  });
                                },
                                child: Icon(
                                  Icons.indeterminate_check_box,
                                  color: ColorsTheme.mainColor,
                                  size: 36,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                width: 40,
                                child: TextField(
                                  textDirection: ui.TextDirection.rtl,
                                  controller: qtyController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    // WhitelistingTextInputFormatter.digitsOnly
                                  ],
                                  onChanged: (text) {
                                    setState(() {
                                      CartData.itmQty = qtyController.text;
                                      if (double.parse(CartData.itmQty) > 999) {
                                        qtyController.text = '999';
                                        CartData.itmQty = '999';
                                      }
                                      CartData.itmTotal =
                                          (double.parse(CartData.itmAmt!) *
                                                  double.parse(CartData.itmQty))
                                              .toStringAsFixed(2);
                                      // print(CartData.itmTotal);
                                    });
                                  },
                                  onTap: () => qtyController.selection =
                                      TextSelection(
                                          baseOffset: 0,
                                          extentOffset:
                                              qtyController.value.text.length),
                                ),
                                // child: Text(
                                //   CartData.itmQty,
                                //   style: TextStyle(
                                //     fontSize: 16,
                                //     fontWeight: FontWeight.w500,
                                //     color: Colors.black,
                                //   ),
                                //   textAlign: TextAlign.center,
                                // ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if (double.parse(CartData.itmQty) >= 999) {
                                      qtyController.text = '999';
                                      CartData.itmQty = '999';
                                    } else {
                                      int i = 0;
                                      i = int.parse(CartData.itmQty) + 1;
                                      CartData.itmQty = i.toString();
                                      CartData.itmTotal =
                                          (double.parse(CartData.itmAmt!) *
                                                  int.parse(CartData.itmQty))
                                              .toString();
                                      qtyController.text = CartData.itmQty;
                                    }
                                  });
                                },
                                child: Icon(
                                  Icons.add_box,
                                  color: ColorsTheme.mainColor,
                                  size: 36,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    // color: Colors.grey,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ElevatedButton(
                            style: raisedButtonDialogStyle,
                            onPressed: () async {
                              // print(CartData.itmQty);
                              if (GlobalVariables.outofStock == true) {
                                final action = await WarningDialogs.openDialog(
                                    context,
                                    'Information',
                                    'Out of stock. Please select other item.',
                                    false,
                                    'OK');
                                if (action == DialogAction.yes) {
                                  if (CartData.allProd == true) {
                                    CartData.setCateg = 'ALL PRODUCTS';
                                  }
                                } else {}
                              } else {
                                if (int.parse(CartData.itmQty) <= 0) {
                                  // print(CartData.itmQty);
                                  // showDialog(
                                  //     context: context,
                                  //     builder: (context) {
                                  //       return AlertDialog(
                                  //         title: Text('Error'),
                                  //         content: Text(
                                  //             'Unable to add empty quantity!'),
                                  //         actions: <Widget>[
                                  //           TextButton(
                                  //               onPressed: () {
                                  //                 Navigator.pop(context);
                                  //               },
                                  //               child: Text('OK'))
                                  //         ],
                                  //       );
                                  //     });
                                  showGlobalSnackbar(
                                      'Information',
                                      'Unable to add empty quantity!',
                                      Colors.blue,
                                      Colors.white);
                                } else {
                                  db.addItemtoCart(
                                      UserData.id,
                                      CustomerData.accountCode,
                                      CartData.itmCode,
                                      CartData.itmDesc,
                                      CartData.itmUom,
                                      CartData.itmAmt,
                                      CartData.itmQty,
                                      CartData.itmTotal,
                                      CartData.setCateg,
                                      CartData.isMust,
                                      CartData.isPromo,
                                      CartData.imgpath);
                                  Provider.of<CartItemCounter>(context,
                                          listen: false)
                                      .addTotal(int.parse(CartData.itmQty));
                                  Provider.of<CartTotalCounter>(context,
                                          listen: false)
                                      .addTotal(
                                          double.parse(CartData.itmTotal));
                                  setState(() {
                                    totalchanged();
                                  });

                                  final action =
                                      await WarningDialogs.openDialog(
                                          context,
                                          'Information',
                                          'Item added to cart.',
                                          false,
                                          'OK');
                                  if (action == DialogAction.yes) {
                                    if (CartData.allProd == true) {
                                      setState(() {
                                        CartData.setCateg = 'ALL PRODUCTS';
                                      });
                                    } else {
                                      setState(() {
                                        totalchanged();
                                      });
                                    }
                                    Navigator.pop(context);
                                  } else {}
                                }
                              }
                            },
                            child: Text(
                              'ADD TO CART',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (GlobalVariables.viewImg)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: ColorsTheme.mainColor, width: 2),
                ),
                width: 180,
                height: 150,
                child: Stack(
                  children: <Widget>[
                    Image.file(File(imgPath! + CartData.imgpath!)),
                    CartData.isMust == '1' || CartData.isPromo == '1'?
                    Positioned(
                      top: 0,
                      left: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CartData.isMust == '1' ? Colors.red.shade800 : Colors.green.shade800,
                        ),
                        // width: 20,
                        // height: 20,
                        padding: EdgeInsets.all(7),
                        child: Text(
                          CartData.isMust == '1' ? 'must' : 'promo',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 7,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ):SizedBox(),
                  ],
                ),
              )
            else if (!GlobalVariables.viewImg)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: ColorsTheme.mainColor, width: 2),
                ),
                width: 150,
                height: 150,
                child: Stack(
                  children: <Widget>[
                    Image(image: AssetsValues.noImageImg),
                    CartData.isMust == '1' || CartData.isPromo == '1'?
                    Positioned(
                      top: 0,
                      left: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CartData.isMust == '1' ? Colors.red.shade800 : Colors.green.shade800,
                        ),
                        // width: 20,
                        // height: 20,
                        padding: EdgeInsets.all(15),
                        child: Text(
                          CartData.isMust == '1' ? 'must' : 'promo',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ):SizedBox(),
                  ],
                ),

              )
          ],
        ),
      ],
    );
  }
}
