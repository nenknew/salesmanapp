import 'dart:async';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:salesmanapp/data_privacy_notice/privacy_notice.dart';
import 'package:salesmanapp/db/db_helper.dart';
import 'package:salesmanapp/providers/delivery_items.dart';
import 'package:salesmanapp/providers/upload_length.dart';
import 'package:salesmanapp/session/session_timer.dart';
import 'package:salesmanapp/home/url/url.dart';
import 'package:salesmanapp/userdata.dart';
import 'package:salesmanapp/variables/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:salesmanapp/history/history.dart';
import 'package:salesmanapp/profile/profile.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  SessionTimer sessionTimer = SessionTimer();
  ScrollController _scrollController = ScrollController();
  int _currentIndex = 0;
  final db = DatabaseHelper();
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );
  bool viewPol = true;
  bool testEnv = false;
  bool sendUserAppVersion = true;
  Timer? timer;
  final List<Widget> _children = [

    // Collection(),
    History(),
    // SyncUi(),
    Profile(),
  ];

  @override
  void initState() {

    super.initState();
    checkAppEnvironment();
    OrderData.visible = true;
    _currentIndex = GlobalVariables.menuKey;
    GlobalVariables.dataPrivacyNoticeScrollBottom = false;
    checkStatus();
    _initializeTimer();
    getAppVersion();
    checkAppEnvironment();
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
    _initPackageInfo();
    print(_packageInfo);
    AppData.appVersion = version;
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
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
      if (AppData.appVersion != null && UserData.id != null && sendUserAppVersion){
        sendUserAppVersion = false;
        var res = await db.hepeAppVersion(context, UserData.id!, AppData.appVersion!);
        setState(() {
          sendUserAppVersion = res;
        });
      }
    } else {
      NetworkData.connected = false;
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
    timer?.cancel();
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
              BottomNavigationBarItem(
                icon: (int.parse(Provider.of<DeliveryCounter>(context)
                            .itmNo
                            .toString()) ==
                        0)
                    ? Icon(Icons.home)
                    : Container(
                        width: 30,
                        child: Stack(
                          children: [
                            Icon(Icons.home),
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  // margin: EdgeInsets.only(top: 2),
                                  padding: EdgeInsets.only(top: 0),
                                  width: 20,
                                  height: 15,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue),
                                  child: Text(
                                    Provider.of<DeliveryCounter>(context)
                                        .itmNo
                                        .toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.leaderboard_rounded), label: 'Sales'),
              // BottomNavigationBarItem(
              //     icon: new Icon(Icons.equalizer), title: new Text('Sales')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.history), label: 'History'),
              BottomNavigationBarItem(
                  icon: (int.parse(Provider.of<UploadLength>(context)
                              .itmNo
                              .toString()) ==
                          0)
                      ? Icon(Icons.sync)
                      : Container(
                          width: 30,
                          child: Stack(
                            children: [
                              Icon(Icons.sync),
                              Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    // margin: EdgeInsets.only(top: 2),
                                    padding: EdgeInsets.only(top: 0),
                                    width: 20,
                                    height: 15,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.green),
                                    child: Text(
                                      Provider.of<UploadLength>(context)
                                          .itmNo
                                          .toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  label: 'Sync'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profile')
            ],
          ),
        ),
      ),
    );
  }
}
