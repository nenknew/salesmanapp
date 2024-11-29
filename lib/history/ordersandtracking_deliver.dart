import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:number_to_words/number_to_words.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:salesmanapp/db/db_helper.dart';
import 'package:salesmanapp/history/chequedata.dart';
import 'package:salesmanapp/history/signature.dart';
import 'package:salesmanapp/session/session_timer.dart';
import 'package:salesmanapp/userdata.dart';
import 'package:salesmanapp/variables/assets.dart';
import 'package:salesmanapp/variables/colors.dart';
import 'package:salesmanapp/widgets/elevated_button.dart';

class OrdersAndTrackingdlvr extends StatefulWidget {
  @override
  _OrdersAndTrackingdlvrState createState() => _OrdersAndTrackingdlvrState();
}

class _OrdersAndTrackingdlvrState extends State<OrdersAndTrackingdlvr> {
  int itemNo = 0;
  String itemserv = "";
  String itemunserv = "";
  String itemdeliver = "";
  String itemNo1 = "";
  String itemNo2 = "";
  int dlvrqty = 0;
  int undlvrqty = 0;
  String lineTotal = "0.00";
  String lineTotalunserv = "0.00";
  String orderTotal = "0.00";
  String orderTotal2 = "0.00";
  String itmCat = "";
  String itmCat2 = "";
  String itemQty = "";
  String unservitemQty = "";
  String discount = "";
  String lineAmt = "0.00";
  String imgPath = "";

  bool categ = false;
  bool categ2 = false;
  bool notYetDelivered = true;
  bool viewDisc = false;
  bool viewSpinkit = true;
  bool viewRemSpinkit = true;

  int i = 0;
  final formatCurrencyAmt =
      new NumberFormat.currency(locale: "en_US", symbol: "₱");
  final formatCurrencyTot =
      new NumberFormat.currency(locale: "en_US", symbol: "Php ");

  bool reqPressed = true;
  bool servedPressed = false;
  bool remPressed = false;
  bool delPressed = false;
  bool unServed = false;
  bool returned = false;
  bool noImage = false;
  bool loadspinkit = true;

  final db = DatabaseHelper();

  List _list = [];
  List _listserv = [];
  List _listunserv = [];
  List _listdelever = [];
  List _servedlist = [];
  // List _remlist = [];
  List _chequelist = [];
  List _templist = [];
  List _unservedList = [];
  List _returnedList = [];
  List _imgpath = [];
  // List _sampList = [];

  void initState() {
    super.initState();
    reqPressed = true;
    loadImagePath();
    loadOrdersdeliver();
    loadOrdersunserv();
    // loadImage();
    if (OrderData.status == 'Delivered' || OrderData.status == 'Returned') {
      GlobalVariables.showSign = true;
      notYetDelivered = false;
    } else {
      GlobalVariables.showSign = false;
      notYetDelivered = true;
    }

  }

  loadImagePath() async {
    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = documentDirectory.path + '/';
    imgPath = firstPath;
  }


  loadOrdersdeliver() async {
    int x = 1;
    OrderData.grandTotalserv = '0';

    // itemQty = '0';
    double total = 0;

    var getO = await db.getOrderedItemsdelever2(UserData.trans);

    _listdelever = json.decode(json.encode(getO));
    print(_listdelever);
    print(_listdelever.length);
    if (!mounted) return;
    if (_listdelever.isEmpty) {
      viewSpinkit = false;
    }
    _listdelever.forEach((element) {
      total +=double.parse(element['tot_amt']);
      dlvrqty += int.parse(element['del_qty']);
    });
    setState(() {
      OrderData.grandTotaldeliver = total.toStringAsFixed(2);

    });
    print('letsgo');
    setState(() {
      _listdelever.forEach((element) async {
        var getImg = await db.getItemImg(element['itm_code'], element['uom']);
        _imgpath = json.decode(json.encode(getImg));

        setState(() {
          itmCat = "";
          categ = false;
          if (_imgpath.isEmpty) {
            element['image'] = '';
          } else {
            element['image'] = _imgpath[0]['image'];
          }

        });
        print(x);
        if (x == _listdelever.length) {
          viewSpinkit = false;
        } else {
          x++;
        }
      });
    });
  }

  loadOrdersunserv() async {
    int x = 1;
    OrderData.grandTotalserv = '0';
    itemunserv = '0';
    // itemQty = '0';
    double total = 0;
    int qty = 0;
    var getO = await db.getreturndelever(UserData.trans);
    _listunserv = json.decode(json.encode(getO));
    print('unserv items$_listunserv');
    print(_listunserv.length);
    if (!mounted) return;
    if (_listunserv.isEmpty) {
      viewSpinkit = false;
    }
    _listunserv.forEach((element) {
      total +=double.parse(element['tot_amt']);
      undlvrqty += int.parse(element['qty']);
    });
    setState(() {
      OrderData.grandTotalunserv = total.toStringAsFixed(2);
      // itemunserv = qty.toString();
    });
    print('letsgo');
    setState(() {
      _listunserv.forEach((element) async {
        var getImg = await db.getItemImg(element['itm_code'], element['uom']);
        _imgpath = json.decode(json.encode(getImg));

        setState(() {
          itmCat = "";
          categ = false;
          if (_imgpath.isEmpty) {
            element['image'] = '';
          } else {
            element['image'] = _imgpath[0]['image'];
          }


        });
        print(x);
        if (x == _listunserv.length) {
          viewSpinkit = false;
        } else {
          x++;
        }
      });
    });

  }



  void handleUserInteraction([_]) {
    // _initializeTimer();

    SessionTimer sessionTimer = SessionTimer();
    sessionTimer.initializeTimer(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        handleUserInteraction();
      },
      onPanDown: (details) {
        handleUserInteraction();
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(

          body: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(

                pinned: true,
                floating: true,
                snap: true,
                toolbarHeight: ScreenData.scrHeight * .08,
                automaticallyImplyLeading: true,
                iconTheme: IconThemeData(
                  color: Colors.black, // Sets the back button color to black
                ),
                backgroundColor: Colors.white,
                elevation: 0,
                title: Column(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Orders And Trackings",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          color: ColorsTheme.mainColor,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                bottom: TabBar(
                  indicatorColor: ColorsTheme.mainColor,
                  labelColor: ColorsTheme.mainColor,
                  indicatorWeight: 5,
                  tabs: [

                    Tab(
                      icon: Icon(Icons.done_outline,
                          color: ColorsTheme.mainColor),
                      text: 'Delivered Items',
                    ),
                    Tab(
                      icon: Icon(Icons.recycling, color: ColorsTheme.mainColor),
                      text: 'Return Items',
                    ),

                  ],
                ),
              ),
            ],
            // body: Column(
            //   children: [
            //     buildtranCont(),
            //   ],
            // ),
            body: TabBarView(children: [
              Delivered(),
              Unserved(),
            ]),
          ),
        ),
      ),
    );
  }


  Container Delivered() {
    return Container(
      height: MediaQuery.of(context).size.height,
      child:Column(
        children: [
          Expanded(
            child: Container(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 1, bottom: 100),
                itemCount: _listdelever.length,
                itemBuilder: (context, index) {
                  // Your existing logic

                    itemQty = _listdelever[index]['del_qty'];

                  if (_listdelever[index]['itm_cat'] == null ||
                      _listdelever[index]['itm_cat'] == 'null' ||
                      _listdelever[index]['itm_cat'] == '') {
                    _listdelever[index]['itm_cat'] = '';
                  }
                  if (_listdelever[index]['image'] == '') {
                    noImage = true;
                  } else {
                    noImage = false;
                  }
                  if (delPressed) {
                    if (_listdelever[index]['flag'] == '1') {
                      viewDisc = true;
                      double a = double.parse(_listdelever[index]['discount']);
                      discount = a.toInt().toString();

                      // DISCOUNT COMPUTATION
                      lineAmt = (double.parse(_listdelever[index]['amt']) *
                          double.parse(itemQty))
                          .toString();
                      double discAmt = double.parse(lineAmt) * (a / 100);
                      lineTotal = (double.parse(lineAmt) - discAmt).toString();
                    } else {
                      viewDisc = false;
                      lineTotal = (double.parse(_listdelever[index]['amt']) *
                          double.parse(itemQty))
                          .toString();
                    }
                  } else {
                    lineTotal = (double.parse(_listdelever[index]['amt']) *
                        double.parse(itemQty))
                        .toString();
                  }

                  return Container(

                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(bottom: 5),
                            height: 70,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                    width: 1.0, color: Colors.blue), // Replace with ColorsTheme.mainColor
                              ),
                              color: Colors.white,
                            ),
                            child: Stack(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Container(
                                      width: 5,
                                      height: 80,
                                      color: ColorsTheme.mainColor,
                                    ),
                                    if (GlobalVariables.viewImg)
                                      Container(
                                        margin:
                                        EdgeInsets.only(left: 3, top: 3),
                                        width: 75,
                                        color: Colors.white,
                                        child: noImage
                                            ? Image(
                                            image:
                                            AssetsValues.noImageImg)
                                            : Image.file(File(imgPath +
                                            _unservedList[index]
                                            ['image'])),
                                      )
                                    else if (!GlobalVariables.viewImg)
                                      Container(
                                          margin: EdgeInsets.only(
                                              left: 3, top: 3),
                                          width: 75,
                                          color: Colors.white,
                                          child: Image(
                                              image: AssetsValues.noImageImg))
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.only(left: 85),
                                      margin: EdgeInsets.only(left: 3),
                                      width: MediaQuery.of(context).size.width / 2 + 50,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            _listdelever[index]['item_desc'] ?? '',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                            children: <Widget>[
                                              Container(
                                                width: 50,
                                                child: Text(
                                                  _listdelever[index]['uom'] ?? '',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w500),
                                                ),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context).size.width / 6 - 10,
                                                child: Text(
                                                  formatCurrencyTot.format(
                                                      double.parse(_listdelever[index]['amt'] ?? '0')),
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                      color: Colors.green,
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.normal),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[

                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              itemQty,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(right: 10),
                                              width: 100,
                                              child: Text(
                                                formatCurrencyTot.format(double.parse(lineTotal)),
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle: FontStyle.italic),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  );


                },
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: CustomerData.discounted ? 200 : 150,
            // color: Colors.grey,
            child: Stack(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 5,
                    ),
                    Container(
                      // width: 200,
                      height: CustomerData.discounted ? 200 : 150,
                      padding: EdgeInsets.only(left: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            'Order Summary',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Order No.',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.normal),
                          ),
                          SizedBox(
                            height: 5,
                          ),

                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            'Item(s)',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.normal),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            'Net Amount',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width / 2 + 150,
                      margin: EdgeInsets.only(
                        right: 10,
                        bottom: 5,
                      ),
                      padding: EdgeInsets.only(left: 100),
                      height: CustomerData.discounted ? 200 : 150,
                      // color: Colors.grey,
                      child: Stack(
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width / 2 + 60,
                            // color: Colors.grey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                SizedBox(height: 32),
                                Text(
                                  OrderData.trans!,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  height: 5,
                                ),

                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  '$dlvrqty',
                                  // '',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),

                                Text(
                                  formatCurrencyTot.format(double.parse(OrderData.grandTotaldeliver)),
                                  // '',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                width:
                                MediaQuery.of(context).size.width / 2 + 80,
                                // color: Colors.grey,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[

                                    SizedBox(
                                      width: 3,
                                    ),

                                    SizedBox(
                                      width: 3,
                                    ),
                                    Container(
                                      // width: 80,
                                      height: 30,
                                      child: ElevatedButton(
                                        style: raisedButtonStyleBlack,
                                        // padding: EdgeInsets.symmetric(
                                        //     horizontal: 0, vertical: 0),
                                        // elevation: 10,
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  OrderTracking());
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Tracking",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.white,
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
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Container Unserved() {
    return Container(
      height: MediaQuery.of(context).size.height,
      child:Column(
        children: [
          Expanded(
            child: Container(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 1, bottom: 100),
                itemCount: _listunserv.length,
                itemBuilder: (context, index) {
                  // Your existing logic
                  unservitemQty = _listunserv[index]['qty'];
                  if (_listunserv[index]['image'] == '') {
                    noImage = true;
                  } else {
                    noImage = false;
                  }

                  lineTotalunserv = (double.parse(_listunserv[index]['amt']) *
                        double.parse(unservitemQty))
                        .toString();

                  return Container(

                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(bottom: 5),
                            height: 70,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                    width: 1.0, color: Colors.blue), // Replace with ColorsTheme.mainColor
                              ),
                              color: Colors.white,
                            ),
                            child: Stack(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Container(
                                      width: 5,
                                      height: 80,
                                      color: ColorsTheme.mainColor,
                                    ),
                                    if (GlobalVariables.viewImg)
                                      Container(
                                        margin:
                                        EdgeInsets.only(left: 3, top: 3),
                                        width: 75,
                                        color: Colors.white,
                                        child: noImage
                                            ? Image(
                                            image:
                                            AssetsValues.noImageImg)
                                            : Image.file(File(imgPath +
                                            _unservedList[index]
                                            ['image'])),
                                      )
                                    else if (!GlobalVariables.viewImg)
                                      Container(
                                          margin: EdgeInsets.only(
                                              left: 3, top: 3),
                                          width: 75,
                                          color: Colors.white,
                                          child: Image(
                                              image: AssetsValues.noImageImg))
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.only(left: 85),
                                      margin: EdgeInsets.only(left: 3),
                                      width: MediaQuery.of(context).size.width / 2 + 50,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            _listunserv[index]['item_desc'] ?? '',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                            children: <Widget>[
                                              Container(
                                                width: 50,
                                                child: Text(
                                                  _listunserv[index]['uom'] ?? '',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w500),
                                                ),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context).size.width / 6 - 10,
                                                child: Text(
                                                  formatCurrencyTot.format(
                                                      double.parse(_listunserv[index]['amt'] ?? '0')),
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                      color: Colors.green,
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.normal),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              unservitemQty,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(right: 10),
                                              width: 100,
                                              child: Text(
                                                formatCurrencyTot.format(double.parse(lineTotalunserv)),
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle: FontStyle.italic),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  );


                },
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: CustomerData.discounted ? 200 : 150,
            // color: Colors.grey,
            child: Stack(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 5,
                    ),
                    Container(
                      // width: 200,
                      height: CustomerData.discounted ? 200 : 150,
                      padding: EdgeInsets.only(left: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            'Order Summary',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Order No.',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.normal),
                          ),
                          SizedBox(
                            height: 5,
                          ),

                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            'Item(s)',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.normal),
                          ),
                          SizedBox(
                            height: 5,
                          ),

                          Text(
                            'Net Amount',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width / 2 + 150,
                      margin: EdgeInsets.only(
                        right: 10,
                        bottom: 5,
                      ),
                      padding: EdgeInsets.only(left: 100),
                      height: CustomerData.discounted ? 200 : 150,
                      // color: Colors.grey,
                      child: Stack(
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width / 2 + 60,
                            // color: Colors.grey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                SizedBox(height: 32),
                                Text(
                                  OrderData.trans!,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  height: 5,
                                ),

                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  '$undlvrqty',
                                  // '',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),

                                Text(
                                  formatCurrencyTot.format(double.parse(OrderData.grandTotalunserv)),
                                  // '',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                width:
                                MediaQuery.of(context).size.width / 2 + 80,
                                // color: Colors.grey,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[

                                    SizedBox(
                                      width: 3,
                                    ),

                                    SizedBox(
                                      width: 3,
                                    ),
                                    Container(
                                      // width: 80,
                                      height: 30,
                                      child: ElevatedButton(
                                        style: raisedButtonStyleBlack,
                                        // padding: EdgeInsets.symmetric(
                                        //     horizontal: 0, vertical: 0),
                                        // elevation: 10,
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  OrderTracking());
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Tracking",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.white,
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
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderTracking extends StatefulWidget {
  @override
  _OrderTrackingState createState() => _OrderTrackingState();
}

class _OrderTrackingState extends State<OrderTracking> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      backgroundColor: Colors.grey[100],
      child: trackContent(context),
    );
  }

  trackContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            'Order # ' + OrderData.trans!,
            style: TextStyle(
              color: ColorsTheme.mainColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Date/Time',
                style: TextStyle(
                    color: Colors.grey[700], fontWeight: FontWeight.w500),
              ),
              SizedBox(
                width: 60,
              ),
              Text(
                'Status',
                style: TextStyle(
                    color: Colors.grey[700], fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 15,
        ),
        if (OrderData.status == 'Pending' || OrderData.status == 'On-Process')
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  OrderData.dateReq!,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  'Submitted',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        if (OrderData.status == 'Approved')
          Column(
            children: [
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      OrderData.dateReq!,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      'Submitted',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      OrderData.dateApp!,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      'Approved',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ],
          ),
        if (OrderData.status == 'Delivered' || OrderData.status == 'Returned')
          Column(
            children: [
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      OrderData.dateReq!,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      'Submitted',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      OrderData.dateApp!,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      'Approved',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      OrderData.dateDel!,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      OrderData.status!,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ],
          ),
        SizedBox(
          height: 20,
        )
      ],
    );
  }
}
