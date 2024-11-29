import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
// import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:salesmanapp/customer/checkout.dart';
import 'package:salesmanapp/customer/customer_profile.dart';
// import 'package:salesman/customer/product_page.dart';
import 'package:salesmanapp/db/db_helper.dart';
import 'package:salesmanapp/models/payment_terms.dart';
import 'package:salesmanapp/providers/cart_items.dart';
import 'package:salesmanapp/providers/cart_total.dart';
import 'package:salesmanapp/session/session_timer.dart';
import 'package:salesmanapp/userdata.dart';
import 'package:salesmanapp/variables/assets.dart';
import 'package:salesmanapp/variables/colors.dart';
import 'package:salesmanapp/widgets/dialogs.dart';
import 'package:salesmanapp/widgets/elevated_button.dart';
import 'package:salesmanapp/widgets/snackbar.dart';

class CustomerCart extends StatefulWidget {
  @override
  _CustomerCartState createState() => _CustomerCartState();
}

class _CustomerCartState extends State<CustomerCart> {
  // double total_amount = 0;
  String itmCat = "";
  String imgPath = "";
  bool categ = false;
  bool emptyCart = true;
  bool viewSpinkit = true;
  bool noImage = true;
  // List _temp = [];
  List templist = [];
  // List _limit = [];
  List tmp = [];
  List rows = [];


  double botmHeight = 150.00;

  final db = DatabaseHelper();

  final formatCurrencyAmt =
      new NumberFormat.currency(locale: "en_US", symbol: "₱");
  final formatCurrencyTot =
      new NumberFormat.currency(locale: "en_US", symbol: "Php ");

  void initState() {
    super.initState();
    loadTemp();
    checkOrders();
  }

  // viewSampleTable() async {
  //   var res = await db.ofFetchAll();
  //   setState(() {
  //     templist = res;
  //     print(templist);
  //   });
  // }

  checkOrders() async {
    CustomerData.minOrderLock = true;
    var rsp = await db.ofFetchForUploadCustomer(CustomerData.accountCode);
    tmp = rsp;
    print(rsp);
    if (tmp.isEmpty) {
      CustomerData.minOrderLock = true;
    } else {
      CustomerData.minOrderLock = false;
    }
    print(CustomerData.minOrderLock);
  }

  loadTemp() async {
    // viewSampleTable();
    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = documentDirectory.path + '/';
    imgPath = firstPath;
    emptyCart = true;
    CartData.itmNo = '0';
    CartData.totalAmount = "0.00";
    var rsp = await db.ofFetchCart(CustomerData.accountCode);
    // var rsp = await getTemp(UserData.id, CustomerData.accountCode);
    templist = json.decode(json.encode(rsp));
    // templist = rsp;
    // print(templist);

    setState(() {
      if (templist.isNotEmpty) {
        emptyCart = false;
      }
      computeTotal();
      _getColor();
      // loadMinOrder();
    });
    OrderData.setSign = false;
    OrderData.signature = '';
    viewSpinkit = false;
  }

  computeTotal() {
    setState(() {
      itmCat = "";
      categ = false;
      CartData.itmNo = '0';
      double sum = 0;
      if (templist.isNotEmpty) {
        templist.forEach((element) {
          setState(() {
            sum = sum + double.parse(element['item_total']);
            // print(element['item_total']);
            CartData.totalAmount = sum.toStringAsFixed(2);
            // print(CartData.totalAmount);
            // CartData.itmNo = templist.length.toString();
            CartData.itmNo =
                (int.parse(CartData.itmNo) + int.parse(element['item_qty']))
                    .toString();
          });
        });
      } else {
        setState(() {
          CartData.totalAmount = '0.00';
          CartData.itmNo = '0';
        });
      }

      print('TOTAL AMOUNT:' + CartData.totalAmount);
      // print(CartData.itmNo);
      CartData.itmLineNo = templist.length.toString();
    });
    Provider.of<CartItemCounter>(context, listen: false)
        .setTotal(int.parse(CartData.itmNo));
    Provider.of<CartTotalCounter>(context, listen: false)
        .setTotal(double.parse(CartData.totalAmount));
  }

  // loadMinOrder() async {
  //   var gOrderLimit = await db.getOrderLimit();
  //   _limit = gOrderLimit;
  //   if (!mounted) return;
  //   _limit.forEach((element) {
  //     setState(() {
  //       GlobalVariables.minOrder = element['min_order_amt'];
  //       print('MINIMUM ORDER');
  //       print(GlobalVariables.minOrder);
  //     });
  //   });
  //   // GlobalVariables.minOrder = '1500.00';
  //   viewSpinkit = false;
  // }

  showSnackBar(context, itmCode, itmDesc, itmUom, itmAmt, itmQty, itmTotal,
      setCateg, isMust, isPromo, itmImg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
            '1 Item Deleted',
          ),
          action: SnackBarAction(
              label: "UNDO",
              onPressed: () {
                setState(() {
                  unDoDelete(itmCode, itmDesc, itmUom, itmAmt, itmQty, itmTotal,
                      setCateg, isMust, isPromo, itmImg);
                });
              })),
    );
  }

  unDoDelete(
      itmCode, itmDesc, itmUom, itmAmt, itmQty, itmTotal, setCateg, isMust, isPromo, itmImg) {
    setState(() {
      db.addItemtoCart(UserData.id, CustomerData.accountCode, itmCode, itmDesc,
          itmUom, itmAmt, itmQty, itmTotal, setCateg, isMust, isPromo, itmImg);
      refreshList();
    });
  }

  Future<Null> refreshList() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      loadTemp();
    });

    // return null;
  }

  void handleUserInteraction([_]) {
    // _initializeTimer();

    SessionTimer sessionTimer = SessionTimer();
    sessionTimer.initializeTimer(context);
  }

  void _getColor() {
    var cCode = CustomerData.colorCode;
    switch (cCode) {
      case "488":
        {
          CustomerData.custColor = Colors.black;
        }
        break;
      case "489":
        {
          CustomerData.custColor = Colors.purpleAccent;
        }
        break;
      case "490":
        {
          CustomerData.custColor = Colors.pinkAccent;
        }
        break;
      case "491":
        {
          CustomerData.custColor = Colors.green;
        }
        break;
      case "492":
        {
          CustomerData.custColor = Colors.redAccent;
        }
        break;
      case "493":
        {
          CustomerData.custColor = Colors.blue.shade300;
        }
        break;
      case "495":
        {
          CustomerData.custColor = Colors.deepOrange;
        }
        break;
      default:
        {
          CustomerData.custColor = Colors.grey.shade200;
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (viewSpinkit == true) {
    //   return Container(
    //     height: MediaQuery.of(context).size.height,
    //     width: MediaQuery.of(context).size.width,
    //     color: Colors.white,
    //     child: Center(
    //       child: SpinKitFadingCircle(
    //         color: Colors.deepOrange,
    //         size: 50,
    //       ),
    //     ),
    //   );
    // }
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        handleUserInteraction();
      },
      onPanDown: (details) {
        handleUserInteraction();
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: AppBar(
            automaticallyImplyLeading: true,
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.deepOrange),
            elevation: 0,
            title: Text(
              CustomerData.accountName! + "'s Cart",
              // "EMAMASD ASDADASD's CART",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: GestureDetector(
              child: Icon(CupertinoIcons.arrow_left),
              onTap: () {
                GlobalVariables.menuKey = 0;
                GlobalVariables.viewPolicy = false;
                print('POP');
                Navigator.pop(context);
                // Navigator.push(
                //     context,
                //     PageTransition(
                //         type: PageTransitionType.leftToRight,
                //         child: CustomerProfile()));
              },
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 5),
          child: Column(
            children: [
              Expanded(child: buildListViewCont()),
            ],
          ),
        ),
        floatingActionButton: Container(
          padding: EdgeInsets.only(left: 50),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton(
              onPressed: () {
                // Navigator.push(context, MaterialPageRoute(builder: (context) {
                //   return ProductPage();
                // }));
                // Navigator.popAndPushNamed(context, '/cart'),
                // Navigator.push(
                //     context,
                //     PageTransition(
                //         type: PageTransitionType.rightToLeft,
                //         child: CheckOut()));
                Navigator.popAndPushNamed(context, '/prodpage');
              },
              child: Icon(Icons.add),
              backgroundColor: ColorsTheme.mainColor,
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: botmHeight,
            // color: Colors.grey,
            child: Stack(
              children: <Widget>[
                SizedBox(
                  width: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      // width: 100,
                      height: 150,
                      // color: Colors.grey,
                      margin: EdgeInsets.only(left: 10),
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
                          Text(
                            'Payment Terms',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.normal),
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
                            'Grand Total',
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 5),
                      width: 310,
                      height: 150,
                      // color: Colors.grey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          SizedBox(
                            height: 32,
                          ),
                          Text(
                            '0',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            UserData.selectedPaymentMethod,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            CartData.itmNo,
                            // '',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            formatCurrencyTot
                                .format(double.parse(CartData.totalAmount)),
                            // formatCurrencyTot.format(double.parse(totalAmount)),
                            // '',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          Container(
                            height: 30,
                            child: Row(
                              children: <Widget>[
                                ElevatedButton(
                                  style: raisedButtonStyleWhite,
                                  onPressed: () async {
                                    print('Test');

                                    if (templist.isEmpty) {
                                      GlobalVariables.menuKey = 0;
                                      GlobalVariables.viewPolicy = false;
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil('/smmenu',
                                              (Route<dynamic> route) => false);
                                    } else {
                                      final action = await Dialogs.openDialog(
                                          context,
                                          'Confirmation',
                                          'Are you sure you want to cancel this order?',
                                          true,
                                          'No',
                                          'Yes');
                                      if (action == DialogAction.yes) {
                                        db.deleteCart(CustomerData.accountCode);
                                        final action =
                                            await WarningDialogs.openDialog(
                                                context,
                                                'Information',
                                                'Successfully deleted cart.',
                                                false,
                                                'OK');
                                        if (action == DialogAction.yes) {
                                          GlobalVariables.menuKey = 0;
                                          GlobalVariables.viewPolicy = false;
                                          Navigator.of(context)
                                              .pushNamedAndRemoveUntil(
                                                  '/smmenu',
                                                  (Route<dynamic> route) =>
                                                      false);
                                        }
                                      } else {}
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Cancel Order",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: ColorsTheme.mainColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                ElevatedButton(
                                  style: raisedButtonStyleGreen,
                                  onPressed: () async {
                                    if (templist.isEmpty) {
                                      showGlobalSnackbar(
                                          'Information',
                                          'Unable to checkout empty cart.',
                                          Colors.blue,
                                          Colors.white);
                                    } else {
                                      if (UserAccess.noMinOrder == true) {
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType
                                                    .rightToLeft,
                                                child: CheckOut()));
                                      } else {
                                        //KUNG NAA PAY EXISTING NGA ORDER NGA WALA PA NA SYNC MAKA ORDER SYA BSAN DI KAABOT SA MIN ORDER
                                        if (CustomerData.minOrderLock == true) {
                                          if (double.parse(
                                                  CartData.totalAmount) <
                                              double.parse(
                                                  GlobalVariables.minOrder)) {
                                            String msg =
                                                'Order amount did not reached the minimum amount of ' +
                                                    formatCurrencyAmt.format(
                                                        double.parse(
                                                            GlobalVariables
                                                                .minOrder)) +
                                                    '.' +
                                                    ' Add more items?';
                                            final action =
                                                await Dialogs.openDialog(
                                                    context,
                                                    "Information",
                                                    msg,
                                                    false,
                                                    'No',
                                                    'Yes');
                                            if (action == DialogAction.yes) {
                                              Navigator.popAndPushNamed(
                                                  context, '/prodpage');
                                            } else {}
                                          } else {
                                            Navigator.push(
                                                context,
                                                PageTransition(
                                                    type: PageTransitionType
                                                        .rightToLeft,
                                                    child: CheckOut()));
                                          }
                                        } else {
                                          Navigator.push(
                                              context,
                                              PageTransition(
                                                  type: PageTransitionType
                                                      .rightToLeft,
                                                  child: CheckOut()));
                                        }
                                      }
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Checkout Order",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }

  Container buildHeaderCont() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 80,
      // color: Colors.white,
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              // GlobalVariables.menuKey = 1;
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return CustomerProfile();
              }));
            },
            child: Container(
              width: 50,
              height: 80,
              child: Icon(
                Icons.arrow_back,
                color: ColorsTheme.mainColor,
                size: 36,
              ),
            ),
          ),
          SizedBox(
            width: 15,
          ),
          Container(
            width: MediaQuery.of(context).size.width - 100,
            height: 80,
            alignment: Alignment.center,
            // color: Colors.lightGreen,
            child: Text(
              CustomerData.accountName! + "'s Cart",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container buildListViewCont() {
    if (viewSpinkit == true) {
      return Container(
        // height: 620,
        // height: MediaQuery.of(context).size.height - 100,
        width: MediaQuery.of(context).size.width,
        color: Colors.white10,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 150,
              color: Colors.white,
              height: 150,
              child: Image(
                color: ColorsTheme.mainColor,
                image: AssetsValues.cartImage,
              ),
            ),
          ],
        ),
      );
    }
    if (emptyCart == true) {
      return Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.remove_shopping_cart,
              size: 100,
              color: Colors.orange[500],
            ),
            Text(
              'You have not added any product in your cart.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
            )
          ],
        ),
      );
    }
    return Container(
      // margin: EdgeInsets.only(top: 110),
      // color: Colors.amber,
      // height: 510,
      // height: MediaQuery.of(context).size.height - botmHeight * 2,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 1),
        itemCount: templist.length,
        itemBuilder: (context, index) {
          // String x = '';
          if (itmCat != templist[index]['item_cat']) {
            categ = false;
            itmCat = templist[index]['item_cat'];
          } else {
            categ = true;
          }
          if (templist[index]['image'] == '') {
            noImage = true;
          } else {
            noImage = false;
          }
          templist[index]['item_total'] =
              (double.parse(templist[index]['item_amt']) *
                      double.parse(templist[index]['item_qty']))
                  .toStringAsFixed(2);
          final item = templist[index].toString();
          return SingleChildScrollView(
            child: Dismissible(
              background: Container(
                alignment: AlignmentDirectional.centerEnd,
                color: ColorsTheme.mainColor,
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              direction: DismissDirection.endToStart,
              key: Key(item),
              // key: UniqueKey(),
              onDismissed: (direction) {
                if (!mounted) return;
                setState(() {
                  print('COMPUTE TOTAL');
                  var itmcode = templist[index]['item_code'].toString();
                  var itmdesc = templist[index]['item_desc'].toString();
                  var itmuom = templist[index]['item_uom'].toString();
                  var itmamt = templist[index]['item_amt'].toString();
                  var itmqty = templist[index]['item_qty'].toString();
                  var itmtot = templist[index]['item_total'].toString();
                  var itmcat = templist[index]['item_cat'].toString();
                  var itmImg = templist[index]['image'].toString();
                  var isMust = templist[index]['isMust'].toString();
                  var isPromo = templist[index]['isPromo'].toString();

                  db.deleteItem(
                      CustomerData.accountCode,
                      templist[index]['item_code'].toString(),
                      templist[index]['item_uom'].toString());
                  templist.removeAt(index);
                  computeTotal();
                  // refreshList();

                  showSnackBar(context, itmcode, itmdesc, itmuom, itmamt,
                      itmqty, itmtot, itmcat, isMust, isPromo, itmImg);

                  // print(templist);
                });
              },
              child: Column(
                children: <Widget>[
                  // if (!categ)
                  //   Container(
                  //     width: MediaQuery.of(context).size.width,
                  //     // height: 15,
                  //     color: Colors.deepOrange,
                  //     child: Stack(
                  //       children: <Widget>[
                  //         Row(
                  //           mainAxisAlignment: MainAxisAlignment.start,
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: <Widget>[
                  //             // Container(
                  //             //   padding: EdgeInsets.all(3),
                  //             //   margin: EdgeInsets.only(left: 5),
                  //             //   child: Text(
                  //             //     templist[index]['item_cat'],
                  //             //     textAlign: TextAlign.left,
                  //             //     style: TextStyle(
                  //             //         fontSize: 10,
                  //             //         fontWeight: FontWeight.w400,
                  //             //         color: Colors.white),
                  //             //   ),
                  //             // ),
                  //           ],
                  //         ),
                  //         Row(
                  //           mainAxisAlignment: MainAxisAlignment.end,
                  //           children: <Widget>[
                  //             Container(
                  //               padding: EdgeInsets.all(3),
                  //               margin: EdgeInsets.only(right: 10),
                  //               child: Text(
                  //                 'Sub Total',
                  //                 textAlign: TextAlign.right,
                  //                 style: TextStyle(
                  //                     fontSize: 10,
                  //                     fontWeight: FontWeight.w400,
                  //                     color: Colors.white),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //         Row(
                  //           mainAxisAlignment: MainAxisAlignment.end,
                  //           children: <Widget>[
                  //             Container(
                  //               padding: EdgeInsets.all(3),
                  //               margin: EdgeInsets.only(right: 110),
                  //               child: Text(
                  //                 'Qty',
                  //                 textAlign: TextAlign.left,
                  //                 style: TextStyle(
                  //                     fontSize: 10,
                  //                     fontWeight: FontWeight.w400,
                  //                     color: Colors.white),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  Container(
                    margin: EdgeInsets.only(bottom: 5),
                    height: 70,
                    width: MediaQuery.of(context).size.width,
                    // color: Colors.white,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                            width: 1.0, color: ColorsTheme.mainColor),
                      ),
                      color: Colors.white,
                    ),
                    child: Stack(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 5,
                              height: 80,
                              color: ColorsTheme.mainColor,
                            ),
                            if (GlobalVariables.viewImg)
                              Container(
                                margin: EdgeInsets.only(left: 3, top: 3),
                                width: 75,
                                color: Colors.white,
                                child: noImage ?
                                Stack(
                                  children: <Widget>[
                                    Image(image: AssetsValues.noImageImg),
                                    templist[index]['isMust'] == '1' || templist[index]['isPromo'] == '1'?
                                    Positioned(
                                      top: 0,
                                      left: 5,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: templist[index]['isMust'] == '1' ? Colors.red.shade800 : Colors.green.shade800,
                                        ),
                                        // width: 20,
                                        // height: 20,
                                        padding: EdgeInsets.all(7),
                                        child: Text(
                                          templist[index]['isMust'] == '1' ? 'must' : 'promo',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 7,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ),
                                    ):SizedBox(),
                                  ],
                                ):
                                Stack(
                                  children: <Widget>[
                                    Image.file(File(imgPath + templist[index]['image'])),
                                    templist[index]['isMust'] == '1' || templist[index]['isPromo'] == '1'?
                                    Positioned(
                                      top: 0,
                                      left: 5,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: templist[index]['isMust'] == '1' ? Colors.red.shade800 : Colors.green.shade800,
                                        ),
                                        // width: 20,
                                        // height: 20,
                                        padding: EdgeInsets.all(7),
                                        child: Text(
                                          templist[index]['isMust'] == '1' ? 'must' : 'promo',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 7,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ),
                                    ):SizedBox(),
                                  ],
                                )
                                //Image.file(File(imgPath + templist[index]['image'])),
                              )
                            else if (!GlobalVariables.viewImg)
                              Container(
                                margin: EdgeInsets.only(left: 3, top: 3),
                                width: 75,
                                color: Colors.white,
                                child: Stack(
                                  children: <Widget>[
                                    Image(image: AssetsValues.noImageImg),
                                    templist[index]['isMust'] == '1' || templist[index]['isPromo'] == '1'?
                                    Positioned(
                                      top: 0,
                                      left: 5,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: templist[index]['isMust'] == '1' ? Colors.red.shade800 : Colors.green.shade800,
                                        ),
                                        // width: 20,
                                        // height: 20,
                                        padding: EdgeInsets.all(7),
                                        child: Text(
                                          templist[index]['isMust'] == '1' ? 'must' : 'promo',
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
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(left: 85),
                              margin: EdgeInsets.only(left: 3),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width - 230,
                                    child: Text(
                                      templist[index]['item_desc'],
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          width: 45,
                                          child: Text(
                                            templist[index]['item_uom'],
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 2,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  6 -
                                              15,
                                          child: Text(
                                            formatCurrencyAmt.format(
                                                double.parse(templist[index]
                                                    ['item_amt'])),
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(right: 5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    height: 40,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (int.parse(templist[index]
                                                    ['item_qty']) ==
                                                1) {
                                              itmCat = "";
                                              categ = false;
                                              showGlobalSnackbar(
                                                  'Information',
                                                  'Swipe to remove item.',
                                                  Colors.blue,
                                                  Colors.white);
                                            } else {
                                              if (int.parse(templist[index]
                                                      ['item_qty']) >
                                                  1) {
                                                setState(() {
                                                  var i = int.parse(
                                                          templist[index]
                                                              ['item_qty']) -
                                                      1;
                                                  templist[index]['item_qty'] =
                                                      i.toString();

                                                  templist[index]
                                                      ['item_total'] = (double
                                                              .parse(templist[
                                                                      index][
                                                                  'item_amt']) *
                                                          double.parse(
                                                              templist[index]
                                                                  ['item_qty']))
                                                      .toStringAsFixed(2);

                                                  db.updateCart(
                                                      CustomerData.accountCode,
                                                      templist[index]
                                                          ['item_code'],
                                                      templist[index]
                                                          ['item_uom'],
                                                      templist[index]
                                                          ['item_qty'],
                                                      templist[index]
                                                          ['item_total']);
                                                  computeTotal();
                                                });
                                              } else {
                                                setState(() {
                                                  db.deleteItem(
                                                      CustomerData.accountCode,
                                                      templist[index]
                                                              ['item_code']
                                                          .toString(),
                                                      templist[index]
                                                              ['item_uom']
                                                          .toString());

                                                  templist.removeAt(index);
                                                  computeTotal();
                                                });
                                              }
                                            }
                                          });
                                        },
                                        child: Container(
                                          child: Icon(
                                            Icons.indeterminate_check_box,
                                            color: ColorsTheme.mainColor,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 25,
                                        child: Text(
                                          templist[index]['item_qty']
                                              .toString(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            var i = int.parse(templist[index]
                                                    ['item_qty']) +
                                                1;
                                            print(i);
                                            templist[index]['item_qty'] =
                                                i.toString();

                                            templist[index]['item_total'] =
                                                (double.parse(templist[index]
                                                            ['item_amt']) *
                                                        double.parse(
                                                            templist[index]
                                                                ['item_qty']))
                                                    .toStringAsFixed(2);
                                            computeTotal();
                                            db.updateCart(
                                                CustomerData.accountCode,
                                                templist[index]['item_code'],
                                                templist[index]['item_uom'],
                                                templist[index]['item_qty'],
                                                templist[index]['item_total']);
                                          });
                                        },
                                        child: Container(
                                          child: Icon(
                                            Icons.add_box,
                                            color: ColorsTheme.mainColor,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 70,
                                        padding: EdgeInsets.only(right: 5),
                                        child: Text(
                                          formatCurrencyAmt.format(double.parse(
                                              templist[index]['item_total'])),
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FontStyle.italic),
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
            ),
          );
        },
      ),
    );
  }
}
