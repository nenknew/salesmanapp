import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:salesmanapp/db/db_helper.dart';
import 'package:salesmanapp/dialogs/mcp_sync_success.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../customer/customer.dart';
import '../customer/customer_cart.dart';
import '../customer/customer_profile.dart';
import '../userdata.dart';
import '../variables/colors.dart';
import '../widgets/elevated_button.dart';

class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({Key? key}) : super(key: key);

  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> with SingleTickerProviderStateMixin{
  final db = DatabaseHelper();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;

  bool viewSpinkit = false;
  bool incInfo = false;
  String text = "Today";
  bool btnSyncClick = false;
  late AnimationController animationController;
  DateTime now = DateTime.now();

  Map<String, List> mySelectedEvents = {};
  Map<String, List> mySelectedEventsData = {};

  final titleController = TextEditingController();
  final descpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = _focusedDay;

    loadMonthlyCoveragePlan();
    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 7),
    );
    animationController.repeat();
  }

  loadPreviousEvents(){
    setState(() {
      mySelectedEvents = mySelectedEventsData;
    });
  }

  loadMonthlyCoveragePlan() async{
    mySelectedEventsData.clear();
    var Data = await db.getSQFliteMonthlyCoveragePlan();
    for (var i = 0; i < Data.length; i++) {
      var event = Data[i];
      var date = event['date_sched'];
      if (!mySelectedEventsData.containsKey(date)) {
        mySelectedEventsData[date] = [];
      }
      mySelectedEventsData[date]?.add({
        "doc_no"                    : event['doc_no'],
        "customer_id"               : event['customer_id'],
        "location_name"             : event['location_name'],
        "address1"                  : event['address1'],
        "address2"                  : event['address2'],
        "address3"                  : event['address3'],
        "postal_address"            : event['postal_address'],
        "account_group_code"        : event['account_group_code'],
        "account_group_name"        : event['account_group_name'],
        "account_code"              : event['account_code'],
        "account_name"              : event['account_name'],
        "account_description"       : event['account_description'],
        "account_credit_limit"      : event['account_credit_limit'],
        "account_classification_id" : event['account_classification_id'],
        "payment_type"              : event['payment_type'],
        "salesman_code"             : event['salesman_code'],
        "status"                    : event['status'],
        "cus_mobile_number"         : event['cus_mobile_number'],
        "cus_password"              : event['cus_password'],
        "id"                        : event['id'],
        "sm_code"                   : event['sm_code'],
        "customer_code"             : event['customer_code'],
        "date_sched"                : event['date_sched'],
        "start_date"                : event['start_date'],
        "end_date"                  : event['end_date'],
        "visit_status"              : event['visit_status']
      });
    }
    await loadPreviousEvents();
  }

  List _listOfDayEvents(DateTime dateTime) {
    if (mySelectedEvents[DateFormat('yyyy-MM-dd').format(dateTime)] != null) {
      return mySelectedEvents[DateFormat('yyyy-MM-dd').format(dateTime)]!;
    } else {
      return [];
    }
  }


  checkCustInfo() {
    incInfo = false;
    if (CustomerData.accountCode == '') {
      incInfo = true;
    }
    if (CustomerData.accountName == '') {
      incInfo = true;
    }
    if (CustomerData.accountDescription == '') {
      incInfo = true;
    }
    if (CustomerData.province == '') {
      incInfo = true;
    }
    if (CustomerData.city == '') {
      incInfo = true;
    }
    if (CustomerData.district == '') {
      incInfo = true;
    }
    if (CustomerData.groupCode == '') {
      incInfo = true;
    }
    if (CustomerData.paymentType == '') {
      incInfo = true;
    }
    if (CustomerData.status == '') {
      incInfo = true;
    }
    if (CustomerData.colorCode == '') {
      incInfo = true;
    }

  }

  void _getColor() {
    var cCode = CustomerData.colorCode;
    CustomerData.placeOrder = true;
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
          CustomerData.placeOrder = false;
        }
        break;
    }
  }

  _showDialog(String cusName, String cusAdd, String account_code, String date_sched, String status_visit){
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context){
          return CupertinoAlertDialog(
            title: Text("Mark this as Vsited?", style: TextStyle(fontWeight: FontWeight.bold, color: ColorsTheme.mainColor),),
            content: Column(
              children: [
                SizedBox(height: 10,),
                Text("$cusName", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),),
                Text("$cusAdd", style: TextStyle(fontSize: 10),),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text("Yes"),
                onPressed: ()async{
                  if(status_visit != "1"){
                    print("tap yess");
                    await db.UpdateUserMCVOne(account_code, date_sched);
                    await loadMonthlyCoveragePlan();
                  }
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("No"),
                onPressed: ()async{
                  if(status_visit != "0"){
                    await db.UpdateUserMCVZero(account_code, date_sched);
                    await loadMonthlyCoveragePlan();
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
    );
  }

  _showDialogMCVSync(){
    instantMsgModal(
        context,
        Icon(
          CupertinoIcons.checkmark_alt_circle,
          color: Colors.green,
          size: 40,
        ),
        Text("Monthly Coverage Plan successfully synced."));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Monthly Coverage Plan'),
        actions: <Widget>[
          IconButton(
            icon: btnSyncClick
                ? AnimatedBuilder(
              animation: animationController,
              child: Icon(
                  CupertinoIcons.arrow_2_circlepath,
                  color: Colors.white),
              builder: (BuildContext context, Widget? _widget) {
                return new Transform.rotate(
                  angle:
                  animationController.value *
                      40,
                  child: _widget,
                );
              },
            ) : Icon(
              CupertinoIcons.arrow_2_circlepath,
              color: Colors.white,
            ),
            onPressed: () async{
              if(!btnSyncClick){
                setState(() {
                  btnSyncClick = true;
                });
                if(btnSyncClick){
                  var stat = await db.checkStatus(context);
                  if(stat == "Connected"){
                    var uploadRes;
                    List mcv = await db.getSQFliteMCV();
                    if(mcv.isNotEmpty){
                      uploadRes = await db.uploadCoveragePlan(context, mcv);
                      if(uploadRes){
                        List getMcv = await db.getMonthlyCoveragePlan(context);

                        print("getMC :: $getMcv");
                        print("getMC first :: ${getMcv.first}");

                        if(getMcv != null){
                          print("delete mcv");
                          await db.deleteSQFliteMonthlyCoveragePlan();

                          if(getMcv.isNotEmpty){
                            await db.insertMonthlyCoveragePlan(getMcv);
                          }
                        }
                        loadMonthlyCoveragePlan();
                        loadPreviousEvents();
                        _showDialogMCVSync();
                      }
                    }else{
                      List getMcv = await db.getMonthlyCoveragePlan(context);
                      if(getMcv.isNotEmpty){
                        await db.deleteSQFliteMonthlyCoveragePlan();
                        await db.insertMonthlyCoveragePlan(getMcv);
                      }
                      loadMonthlyCoveragePlan();
                      loadPreviousEvents();
                      _showDialogMCVSync();
                    }
                  }
                }
                setState(() {
                  btnSyncClick = false;
                });
              }


            },
          )
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(now.year, now.month - 3),
            lastDay: DateTime(now.year, now.month + 4, 0),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDate, selectedDay)) {
                // Call `setState()` when updating the selected day
                setState(() {
                  _selectedDate = selectedDay;

                  if(DateFormat("MMMM d, y").format(selectedDay) == DateFormat("MMMM d, y").format(DateTime.now())){
                    text = "Today";
                    print("Select Date :: $text");
                  }else{
                    text = DateFormat("MMMM d, y").format(selectedDay);
                  }

                  _focusedDay = focusedDay;
                  loadPreviousEvents();
                });
              }
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDate, day);
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                // Call `setState()` when updating calendar format
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              // No need to call `setState()` here
              _focusedDay = focusedDay;
            },
            eventLoader: _listOfDayEvents,
          ),
          Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
                  color: Colors.blueGrey
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      child: GestureDetector(
                        onTap: ()async{
                          print("TAP!!!!!");
                          /*var getC = await db.getMonthlyCoveragePlan(context);
                          print("MONTHLY COVERAGE PLAN :: $getC");
                          await db.deleteSQFliteMonthlyCoveragePlan();
                          await db.insertMonthlyCoveragePlan(getC);*/
                        },
                        child: Text("$text",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                      ),

                      ),

                    ),
                    /*Padding(padding: EdgeInsets.only(top: 50),

                    ),
                    Positioned(child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.0),
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    ),*/
                    Expanded(
                      child: ListView(
                        children: _listOfDayEvents(_selectedDate!)
                            .map((myEvents) {

                          CustomerData.colorCode =
                          myEvents['account_classification_id'];
                          _getColor();
                          return SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                GestureDetector(
                                  onLongPress: (){
                                    print(myEvents['visit_status']);
                                    String address = myEvents['address2'] + ', ' + myEvents['address3'] + ', ' + myEvents['address1'];
                                    _showDialog(myEvents['account_name'], address, myEvents['account_code'], myEvents['date_sched'], myEvents['visit_status']);
                                  },
                                  onTap: () {
                                    CustomerData.accountCode =
                                    myEvents['account_code'];
                                    CustomerData.accountName =
                                    myEvents['account_name'];
                                    CustomerData.accountDescription =
                                    myEvents['account_description'];
                                    CustomerData.province = myEvents['address1'];
                                    CustomerData.city = myEvents['address3'];
                                    CustomerData.district = myEvents['address2'];
                                    CustomerData.groupCode =
                                    myEvents['account_group_code'];
                                    CustomerData.paymentType =
                                    myEvents['payment_type'];
                                    CustomerData.status = myEvents['status'];
                                    CustomerData.colorCode =
                                    myEvents['account_classification_id'];
                                    CustomerData.contactNo =
                                    myEvents['cus_mobile_number'];
                                    CustomerData.creditLimit = '0.00';

                                    if (CustomerData.creditLimit == null ||
                                        CustomerData.creditLimit == 'NA') {
                                      CustomerData.creditLimit = "0.00";
                                    }
                                    if (CustomerData.groupCode == null ||
                                        CustomerData.groupCode == 'NA' ||
                                        CustomerData.groupCode == '') {
                                      CustomerData.groupCode = 'N/A';
                                    }

                                    checkCustInfo();

                                    if (!incInfo) {
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                              type: PageTransitionType.rightToLeft,
                                              child: CustomerProfile()));
                                    }
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 8),
                                    height: 80,
                                    width: MediaQuery.of(context).size.width,
                                    //color: Colors.white,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                        color: Colors.white
                                    ),
                                    child: Stack(children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            // margin: EdgeInsets.all(0),
                                            padding: EdgeInsets.only(left: 10),
                                            width: 5,
                                            height: 80,
                                            //color: CustomerData.custColor,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                                color: CustomerData.custColor,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Container(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  width:
                                                  MediaQuery.of(context).size.width - 200,
                                                  child: Text(
                                                    myEvents['account_name'],
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        fontSize: 17,
                                                        fontWeight: FontWeight.bold),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Text(
                                                  myEvents['address2'] +
                                                      ', ' +
                                                      myEvents['address3'] +
                                                      ', ' +
                                                      myEvents['address1'],
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.normal),
                                                ),
                                                SizedBox(height: 5,),
                                                myEvents['visit_status'] == '1' ?
                                                Text("Visited",
                                                  style: TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    color: Colors.green,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.normal),)
                                                :
                                                Text("Not yet Visited",
                                                  style: TextStyle(
                                                      fontStyle: FontStyle.italic,
                                                      color: Colors.red,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.normal),),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Column(
                                            children: <Widget>[
                                              Container(
                                                padding: EdgeInsets.only(right: 5),
                                                height: 30,
                                                width: 150,
                                                margin: EdgeInsets.only(top: 10),
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    primary: CustomerData.custColor,
                                                    minimumSize: Size(88, 36),
                                                    padding:
                                                    EdgeInsets.symmetric(horizontal: 16),
                                                    shape: const RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.all(
                                                          Radius.circular(5)),
                                                    ),
                                                  ),
                                                  onPressed: () => {},
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        myEvents
                                                        ['account_description'],
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.normal,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: CustomerData.placeOrder,
                                                child: Container(
                                                  padding: EdgeInsets.only(right: 5),
                                                  height: 30,
                                                  width: 150,
                                                  margin: EdgeInsets.only(top: 5),
                                                  child: ElevatedButton(
                                                    style: raisedButtonStyleWhite,
                                                    onPressed: () => {
                                                      CustomerData.accountCode =
                                                      myEvents['account_code'],
                                                      CustomerData.accountName =
                                                      myEvents['account_name'],
                                                      CustomerData.accountDescription =
                                                      myEvents
                                                      ['account_description'],
                                                      CustomerData.province =
                                                      myEvents['address1'],
                                                      CustomerData.city =
                                                      myEvents['address3'],
                                                      CustomerData.district =
                                                      myEvents['address2'],
                                                      CustomerData.groupCode =
                                                      myEvents
                                                      ['account_group_code'],
                                                      CustomerData.paymentType =
                                                      myEvents['payment_type'],
                                                      CustomerData.status =
                                                      myEvents['status'],
                                                      CustomerData.colorCode =
                                                      myEvents
                                                      ['account_classification_id'],
                                                      CustomerData.contactNo =
                                                      myEvents
                                                      ['cus_mobile_number'],
                                                      CustomerData.creditLimit = '0.00',
                                                      if (CustomerData.creditLimit == null ||
                                                          CustomerData.creditLimit == 'NA')
                                                        {
                                                          CustomerData.creditLimit = "0.00",
                                                        },
                                                      if (CustomerData.paymentType == '')
                                                        {
                                                          CustomerData.paymentType =
                                                          'Cash on Delivery',
                                                        },
                                                      // Navigator.push(context,
                                                      //     MaterialPageRoute(
                                                      //         builder: (context) {
                                                      //   return CustomerCart();
                                                      // })),
                                                      Navigator.push(
                                                          context,
                                                          PageTransition(
                                                              type: PageTransitionType
                                                                  .rightToLeft,
                                                              child: CustomerCart())),
                                                    },
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          'Place an Order',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: ColorsTheme.mainColor,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Container(
                                                          width: 20,
                                                          height: 20,
                                                          child: Icon(
                                                            Icons.add_circle_outline,
                                                            color: ColorsTheme.mainColor,
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ]
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
          ),

          //Expanded(child: buildCustCont()),


        ],
      ),
    );
  }
}
