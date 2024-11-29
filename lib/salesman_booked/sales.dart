import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:salesmanapp/db/db_helper.dart';
// import 'package:salesman/url/url.dart';
import 'package:salesmanapp/userdata.dart';
import 'package:salesmanapp/variables/assets.dart';
import 'package:salesmanapp/variables/colors.dart';

class HepeSalesPage extends StatefulWidget {
  const HepeSalesPage({Key? key}) : super(key: key);

  @override
  State<HepeSalesPage> createState() => _HepeSalesPageState();
}

class _HepeSalesPageState extends State<HepeSalesPage> {
  var colorCode = '';
  String startdate = "";
  String enddate = "";
  String weekstart = "";
  String weekend = "";
  String imgPath = "";
  double categHeight = 0.00;

  final db = DatabaseHelper();

  bool noImage = false;
  bool viewSpinkit = false;
  bool _expandedCustomer = false;
  bool _expandedItems = false;
  bool _expandedUnsItems = false;
  bool _expandedRetItems = false;
  List _sList = [];
  List _salesList = [];
  List _wsalesList = [];
  List _msalesList = [];
  List _ysalesList = [];
  // List _imgpath = [];
  // List _smList = [];
  List _smsalelist = [];
  List _totlist = [];
  List _smtypelist = [];
  List _custtypelist = [];
  List _itmtypelist = [];
  List _custsalelist = [];
  List _itemsalelist = [];
  List _custDsalesList = [];
  List _custWsalesList = [];
  List _custMsalesList = [];
  List _custYsalesList = [];
  List _itmDsalesList = [];
  List _itmWsalesList = [];
  List _itmMsalesList = [];
  List _itmYsalesList = [];

  String tSno = '';
  String wSno = '';
  String mSno = '';
  String ySno = '';

  List _temp = [];

  final formatCurrencyAmt =
  new NumberFormat.currency(locale: "en_US", symbol: "P");
  final formatCurrencyTot =
  new NumberFormat.currency(locale: "en_US", symbol: "Php ");

  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

  final String today =
  DateFormat("EEEE, MMM-dd-yyyy").format(new DateTime.now());
  final date =
  DateTime.parse(DateFormat("yyyy-mm-dd").format(new DateTime.now()));

  final String month = DateFormat("MMMM yyyy").format(new DateTime.now());
  final String year = DateFormat("yyyy").format(new DateTime.now());

  DateTime sDate = DateTime.now();
  DateTime eDate = DateTime.now();

  String startDate = "";
  String endDate = "";

  void initState() {
    super.initState();
    getDataRange();
    loadImagePath();
    loadSales();
  }

  loadImagePath() async {
    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = documentDirectory.path + '/';
    imgPath = firstPath;
  }

  getDataRange() async {
    var rsp = await db.getAllTran();
    _temp = rsp;
    // print(_temp);
    // print(_temp.last);
    sDate = DateTime.parse(_temp[0]['date_req'].toString());
    eDate = DateTime.parse(_temp.last['date_req'].toString());
    setState(() {
      startDate = DateFormat("MMM. dd, yyyy").format(sDate);
      endDate = DateFormat("MMM. dd, yyyy").format(eDate);
    });
    print(startDate);
    print(endDate);
  }

  loadSales() async {

    //CUSTOMER
    loadCustomerDailySales();

    //ITEMS
    loadItemDailySales();

  }


  loadItemDailySales() async {
    _itmDsalesList.clear();
    _sList.clear();
    var getDsales = await db.getItemDailySales();
    _sList = json.decode(json.encode(getDsales));
    // print(_sList);
    _sList.forEach((element) async {
      if (!mounted) return;
      setState(() {
        _itmDsalesList.add(element);
      });
    });
    itemSalesTypeChanged();
    viewSpinkit = false;
  }


  loadCustomerDailySales() async {
    _custDsalesList.clear();
    _sList.clear();
    var getDsales = await db.getCustomerDailySales(
        UserData.id,);
    // _sList = getDsales;
    _sList = json.decode(json.encode(getDsales));
    print('ang slist $_sList');
    _sList.forEach((element) {
      // if (!mounted) return;
      setState(() {
        _custDsalesList.add(element);
        print('ang customer gdf $_custDsalesList');
      });
    });
    customerSalesTypeChanged();
    // viewSpinkit = false;
  }

  itemSalesTypeChanged() {

      _itemsalelist.clear();
      List nums = [];
      _itmDsalesList.forEach((element) {
        setState(() {
          nums.add(element);
        });
      });

      nums.sort((b, a) => int.parse(a['total'].toString())
          .compareTo(int.parse(b['total'].toString())));
      nums.forEach((element) {
        setState(() {
          String desc = element['item_desc'];
          _itmDsalesList.forEach((element) {
            setState(() {
              if (desc == (element['item_desc'])) {
                _itemsalelist.add(element);
              }
            });
          });
        });
      });


  }

  customerSalesTypeChanged() {

      _custsalelist.clear();
      List<double> nums = [];
      _custDsalesList.forEach((element) {
        setState(() {
          nums.add(double.parse(element['total'].toString()));
        });
      });

      nums.sort((b, a) => a.compareTo(b));
      nums.forEach((element) {
        setState(() {
          double amt = element;
          _custDsalesList.forEach((element) {
            setState(() {
              if (amt == double.parse(element['total'].toString())) {
                _custsalelist.add(element);
                print('ang customer dd $_custsalelist');
              }
            });
          });
        });
      });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: ScreenData.scrHeight * .085,
        automaticallyImplyLeading: true,
        backgroundColor: Colors.red,
        elevation: 0,
        title: Column(
          children: [
            Text(
              "Sales",
              textAlign: TextAlign.right,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 45,
                  fontWeight: FontWeight.bold),
            ),
            // SizedBox(height: 50),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ExpansionPanelList(
                    expandedHeaderPadding: EdgeInsets.all(1),
                    animationDuration: Duration(milliseconds: 300),
                    expansionCallback: (int i, bool isExpanded) {
                      _expandedCustomer = !_expandedCustomer;
                      setState(() {});
                    },
                    children: [
                      ExpansionPanel(
                        canTapOnHeader: true,
                        backgroundColor: Colors.deepOrange[100],
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return ListTile(
                            title: Row(
                              children: [
                                Icon(Icons.groups),
                                SizedBox(width: 10),
                                Text(
                                  'Customer',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        body: Column(
                          children: [
                            buildCustomerCont(),
                          ],
                        ),
                        isExpanded: _expandedCustomer,
                      ),
                    ],
                  ),
                  ExpansionPanelList(
                    expandedHeaderPadding: EdgeInsets.all(1),
                    animationDuration: Duration(milliseconds: 300),
                    expansionCallback: (int i, bool isExpanded) {
                      _expandedItems = !_expandedItems;
                      setState(() {});
                    },
                    children: [
                      ExpansionPanel(
                        canTapOnHeader: true,
                        backgroundColor: Colors.blue[100],
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return ListTile(
                            title: Row(
                              children: [
                                Icon(Icons.shopping_basket),
                                SizedBox(width: 10),
                                Text(
                                  'Items',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          );
                        },
                        body: Column(
                          children: [
                            buildItemCont(),
                          ],
                        ),
                        isExpanded: _expandedItems,
                      ),
                    ],
                  ),
                  ExpansionPanelList(
                    expandedHeaderPadding: EdgeInsets.all(1),
                    animationDuration: Duration(milliseconds: 300),
                    expansionCallback: (int i, bool isExpanded) {
                      _expandedUnsItems = !_expandedUnsItems;
                      setState(() {});
                    },
                    children: [
                      ExpansionPanel(
                        canTapOnHeader: true,
                        backgroundColor: Colors.yellowAccent[100],
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return ListTile(
                            title: Row(
                              children: [
                                Icon(Icons.shopping_basket),
                                SizedBox(width: 10),
                                Text(
                                  'Unserved Items',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          );
                        },
                        body: Column(
                          children: [
                            // buildItemCont(),
                          ],
                        ),
                        isExpanded: _expandedUnsItems,
                      ),
                    ],
                  ),
                  ExpansionPanelList(
                    expandedHeaderPadding: EdgeInsets.all(1),
                    animationDuration: Duration(milliseconds: 300),
                    expansionCallback: (int i, bool isExpanded) {
                      _expandedRetItems = !_expandedRetItems;
                      setState(() {});
                    },
                    children: [
                      ExpansionPanel(
                        canTapOnHeader: true,
                        backgroundColor: Colors.black12,
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return ListTile(
                            title: Row(
                              children: [
                                Icon(Icons.shopping_basket),
                                SizedBox(width: 10),
                                Text(
                                  'Returned Items',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          );
                        },
                        body: Column(
                          children: [
                            // buildItemCont(),
                          ],
                        ),
                        isExpanded: _expandedRetItems,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Note:',
                          style: TextStyle(
                              fontStyle: FontStyle.italic, fontSize: 12),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Data shown above is base on the date stated in header.',
                              style: TextStyle(
                                  fontStyle: FontStyle.italic, fontSize: 12),
                            ),
                            Text(
                              'If you want to load the accurate data. Kindly perform a full sync.',
                              style: TextStyle(
                                  fontStyle: FontStyle.italic, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Container buildItemCont() {
    if (viewSpinkit == true) {
      return Container(
        height: MediaQuery.of(context).size.height / 2,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: SpinKitFadingCircle(
            color: ColorsTheme.mainColor,
            size: 50,
          ),
        ),
      );
    }
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Colors.blue[50],
          border: Border.all(color: Colors.blue.shade50),
          borderRadius: BorderRadius.circular(0)),
      child: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width - 2,
                      // color: Colors.grey,
                      child: Stack(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding:
                                const EdgeInsets.only(left: 10, top: 15),
                                child: Container(
                                  child: Text(
                                    'Top Items',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 20, right: 0),
                                // width: MediaQuery.of(context).size.width / 2,
                                // color: Colors.grey,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    DropdownButtonHideUnderline(
                                      child: ButtonTheme(
                                        alignedDropdown: true,
                                        child: DropdownButton<String>(
                                          items: _itmtypelist.map((item) {
                                            return new DropdownMenuItem(
                                              child: new Text(
                                                item['type'],
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              value: item['type'].toString(),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              SalesData.itemSalesType =
                                                  newValue;
                                              itemSalesTypeChanged();
                                            });
                                          },
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
                Row(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      width: MediaQuery.of(context).size.width - 2,
                      height: 30,
                      color: Colors.blue[200],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Item Description',
                              style: TextStyle(),
                            ),
                          ),
                          Text(
                           'Total Qty',
                            style: TextStyle(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width - 2,
                      height: MediaQuery.of(context).size.height / 2 - 80,
                      padding: EdgeInsets.only(bottom: 5),
                      // color: Colors.transparent,
                      color: Colors.blue[50],
                      child: ListView.builder(
                          padding: const EdgeInsets.only(top: 1),
                          itemCount: _itemsalelist.length,
                          itemBuilder: (context, index) {
                            if (_itemsalelist[index]['image'] == '' ||
                                _itemsalelist[index]['image'] == null) {
                              noImage = true;
                            } else {
                              noImage = false;
                            }
                            return Container(
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    width:
                                    MediaQuery.of(context).size.width - 35,
                                    height: 80,
                                    color: Colors.transparent,
                                    child: Stack(
                                      children: <Widget>[
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              width: 5,
                                              height: 80,
                                              color: ColorsTheme.mainColor,
                                            ),
                                            if (GlobalVariables.viewImg)
                                              Container(
                                                height: 80,
                                                margin: EdgeInsets.only(
                                                    left: 3, top: 0),
                                                width: 75,
                                                color: Colors.white,
                                                child: noImage
                                                    ? Image(
                                                    image: AssetsValues
                                                        .noImageImg)
                                                    : Image.file(File(imgPath +
                                                    _itemsalelist[index]
                                                    ['image'])),
                                              ),
                                            if (!GlobalVariables.viewImg)
                                              Container(
                                                  margin: EdgeInsets.only(
                                                      left: 3, top: 3),
                                                  width: 75,
                                                  color: Colors.white,
                                                  child: Image(
                                                      image: AssetsValues
                                                          .noImageImg)),
                                            Container(
                                              color: Colors.white,
                                              height: 80,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                                  150,
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    _itemsalelist[index]
                                                    ['item_desc'],
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                      fontWeight:
                                                      FontWeight.w500,
                                                    ),
                                                    // overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                          MainAxisAlignment.end,
                                          children: <Widget>[
                                            Container(
                                              height: 80,
                                              width: 40,
                                              color: Colors.white,
                                              child: Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    _itemsalelist[index]
                                                    ['total']
                                                        .toString(),
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                      fontWeight:
                                                      FontWeight.w500,
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
                            );
                          }),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container buildCustomerCont() {
    return Container(
      height: MediaQuery.of(context).size.height / 3,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Colors.deepOrange[50],
          border: Border.all(color: Colors.deepOrange.shade50),
          borderRadius: BorderRadius.circular(0)),
      child: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width - 2,
                      // color: Colors.grey,
                      child: Stack(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding:
                                const EdgeInsets.only(left: 10, top: 15),
                                child: Container(
                                  child: Text(
                                    'Top Customer',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 20, right: 0),
                                // width: MediaQuery.of(context).size.width / 2,
                                // color: Colors.grey,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    DropdownButtonHideUnderline(
                                      child: ButtonTheme(
                                        alignedDropdown: true,
                                        child: DropdownButton<String>(
                                          // value: SalesData.customerSalesType,
                                          items: _custtypelist.map((item) {
                                            return new DropdownMenuItem(
                                              child: new Text(
                                                item['type'],
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              value: item['type'].toString(),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              SalesData.customerSalesType =
                                                  newValue;
                                              customerSalesTypeChanged();
                                            });
                                          },
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
                Row(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      width: MediaQuery.of(context).size.width - 2,
                      height: 30,
                      color: Colors.deepOrange[200],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Name',
                              style: TextStyle(),
                            ),
                          ),
                          Container(
                            // width: 110,
                            child: Text(
                              'Total Amount',
                              style: TextStyle(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width - 2,
                      height: MediaQuery.of(context).size.height / 3 - 80,
                      color: Colors.transparent,
                      child: ListView.builder(
                          padding: const EdgeInsets.only(top: 1),
                          itemCount: _custsalelist.length,
                          itemBuilder: (context, index) {
                            return Container(
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    width:
                                    MediaQuery.of(context).size.width - 35,
                                    height: 50,
                                    color: Colors.transparent,
                                    child: Stack(
                                      children: <Widget>[
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              // color: Colors.grey,
                                              // height: ,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                                  150,
                                              child: Text(
                                                _custsalelist[index]
                                                ['store_name'],
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                // overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.end,
                                          children: <Widget>[
                                            Text(
                                              formatCurrencyAmt.format(
                                                  double.parse(
                                                      _custsalelist[index]
                                                      ['total']
                                                          .toString())),
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


}
