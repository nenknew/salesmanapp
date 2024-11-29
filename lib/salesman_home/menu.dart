import 'dart:async';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:salesmanapp/data_privacy_notice/privacy_notice.dart';
import 'package:salesmanapp/db/db_helper.dart';
import 'package:salesmanapp/models/payment_terms.dart';
import 'package:salesmanapp/salesman_booked/booked.dart';
import 'package:salesmanapp/salesman_sync/sync.dart';
import 'package:salesmanapp/session/session_timer.dart';
import 'package:salesmanapp/home/url/url.dart';
import 'package:salesmanapp/userdata.dart';
import 'package:salesmanapp/customer/customer.dart';
import 'package:salesmanapp/history/history.dart';
import 'package:salesmanapp/profile/profile.dart';
import 'package:salesmanapp/variables/colors.dart';
import 'package:salesmanapp/widgets/elevated_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesmanMenu extends StatefulWidget {
  @override
  _SalesmanMenuState createState() => _SalesmanMenuState();
}

class _SalesmanMenuState extends State<SalesmanMenu> {
  SessionTimer sessionTimer = SessionTimer();

  Map<String, dynamic> _deviceData = <String, dynamic>{};
  ScrollController _scrollController = ScrollController();
  String err1 = 'No Internet Connection';
  String err2 = 'No Connection to Server';
  String err3 = 'API Error';
  bool viewPol = true;
  bool stopTimer = false;
  bool testEnv = false;
  final orangeColor = ColorsTheme.mainColor;
  final yellowColor = Colors.amber;
  final blueColor = Colors.blue;
  bool sendUserAppVersion = true;
  final db = DatabaseHelper();
  Timer? timer2;
  int _currentIndex = 0;
  final List<Widget> _children = [
    // Home(),
    Customer(),
    SalesmanBooked(),
    History(),
    SyncSalesman(),
    Profile(),
  ];

  @override
  void initState() {

    super.initState();

    checkAppEnvironment();
    _currentIndex = GlobalVariables.menuKey;
    GlobalVariables.dataPrivacyNoticeScrollBottom = false;
    checkStatus();

    _initializeTimer();
    // initPlatformState();
    getAppVersion();
  }



  checkAppEnvironment() {
    if (UrlAddress.url == 'https://distapp1.alturush.com/') {
      setState(() {
        testEnv = true;
      });
    } else {
      setState(() {
        testEnv = false;
      });
    }
  }

  getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    print(version);
    AppData.appVersion = version;
  }

  void onTappedBar(int index) {
    _currentIndex = index;
    setState(() {
    });
  }

  void _initializeTimer() {
    sessionTimer.initializeTimer(context);
  }

  checkStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var stat = await db.checkStat();
    if (stat == 'Connected') {
      NetworkData.connected = true;
      NetworkData.errorMsgShow = false;
      NetworkData.errorMsg = '';
      GlobalVariables.deviceData = _deviceData['brand'].toString() +
          '_' +
          _deviceData['device'].toString() +
          '-' +
          _deviceData['androidId'].toString();
      var resp =
          await db.checkLoginDevice(UserData.id!, GlobalVariables.deviceData!);
      if (AppData.appVersion != null && UserData.id != null && sendUserAppVersion){
        sendUserAppVersion = false;
        var res = await db.userAppVersion(context, UserData.id!, AppData.appVersion!);
        if(!mounted)return;
        setState(() {
          sendUserAppVersion = res;
        });
      }
      // print(GlobalVariables.deviceData);
      if (resp.isEmpty && !stopTimer) {
        stopTimer = true;
      }
    } else {
      if (stat == 'ERROR1') {
        NetworkData.connected = false;
        NetworkData.errorMsgShow = true;
        NetworkData.errorMsg = err1;
        NetworkData.errorNo = '1';
        // print('Network Error...');
      }
      if (stat == 'ERROR2') {
        NetworkData.connected = false;
        NetworkData.errorMsgShow = true;
        NetworkData.errorMsg = err2;
        NetworkData.errorNo = '2';
        // print('Connection to API Error...');
      }
      if (stat == 'ERROR3') {
        NetworkData.connected = false;
        NetworkData.errorMsgShow = true;
        NetworkData.errorMsg = err3;
        NetworkData.errorNo = '3';
        // print('API Error...');
      }
      if (stat == 'Updating') {
        NetworkData.connected = false;
        NetworkData.errorMsgShow = true;
        NetworkData.errorMsg = 'Updating Server';
        // print('Updating Server...');
      }
    }

    if(UserData.username != prefs.get('user'))
      {
        if (viewPol == true) {
          if (GlobalVariables.viewPolicy == true) {
            viewPol = false;
            viewPolicy();
          }
        }
      }
  }

  viewPolicy() async{ //added async
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user', UserData.username.toString());
    if (GlobalVariables.viewPolicy == true) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => WillPopScope(
          onWillPop: () async => false,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              _scrollController.addListener(() {
                if (_scrollController.position.pixels ==
                    _scrollController.position.maxScrollExtent) {
                  if (GlobalVariables.dataPrivacyNoticeScrollBottom == false) {
                    setState(() {
                      GlobalVariables.dataPrivacyNoticeScrollBottom = true;
                    });
                  }
                }
              });

              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height / 1.5,
                      width: MediaQuery.of(context).size.width,
                      child: ListView(
                        controller: _scrollController,
                        children: <Widget>[
                          DataPrivacyNotice(),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      "Close",
                      style: TextStyle(
                          color:
                              GlobalVariables.dataPrivacyNoticeScrollBottom ==
                                      true
                                  ? ColorsTheme.mainColor
                                  : Colors.grey),
                    ),
                    onPressed: () {
                      if (GlobalVariables.dataPrivacyNoticeScrollBottom ==
                          true) {
                        Navigator.pop(context);
                        GlobalVariables.viewPolicy = false;
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ),
      );
    }
  }


  void handleUserInteraction([_]) {
    SessionTimer sessionTimer = SessionTimer();
    sessionTimer.initializeTimer(context);
  }

  @override
  void dispose() {
    timer2?.cancel();
    GlobalTimer.timerSessionInactivity?.cancel();
    super.dispose();
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
      child: WillPopScope(
        onWillPop: () => Future.value(false),
        child: Scaffold(
          body: _children[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            fixedColor: testEnv ? Colors.blue : ColorsTheme.mainColor,
            onTap: onTappedBar,
            type: BottomNavigationBarType.fixed,
            currentIndex:
                _currentIndex, // this will be set when a new tab is tapped
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              // BottomNavigationBarItem(
              //     icon: Icon(Icons.group), label: 'Customer'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.local_grocery_store_rounded),
                  label: 'Booked'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.history), label: 'History'),
              BottomNavigationBarItem(icon: Icon(Icons.sync), label: 'Sync'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}

class ViewPolicy extends StatefulWidget {
  @override
  _ViewPolicyState createState() => _ViewPolicyState();
}

class _ViewPolicyState extends State<ViewPolicy> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: dialogContent(context),
      ),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          // color: Colors.grey,
          padding: EdgeInsets.only(top: 20, bottom: 10, right: 5, left: 5),
          // margin: EdgeInsets.only(top: 16),
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
                // height: 280,
                margin: EdgeInsets.only(bottom: 5),
                width: MediaQuery.of(context).size.width,
                // color: Colors.white,
                // decoration: BoxDecoration(),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            // color: Colors.grey,
                            width: MediaQuery.of(context).size.width / 2,
                            margin: EdgeInsets.only(left: 10),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.green,
                                    size: 72,
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    'Privacy Policy',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    'Your password has been reset successfully.',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
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
              ),
              Container(
                // color: Colors.grey,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        style: raisedButtonStyleWhite,
                        onPressed: () {
                          setState(() {
                            GlobalVariables.viewPolicy = false;
                            Navigator.pop(context);
                          });
                        },
                        child: Text(
                          'Accept',
                          style: TextStyle(color: ColorsTheme.mainColor),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
