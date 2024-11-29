import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:salesmanapp/customer/customer.dart';
import 'package:salesmanapp/customer/customer_cart.dart';
import 'package:salesmanapp/customer/customer_profile.dart';
import 'package:salesmanapp/customer/product_page.dart';
import 'package:salesmanapp/customer/product_per_categ.dart';
import 'package:salesmanapp/menu.dart';
import 'package:salesmanapp/option.dart';
import 'package:salesmanapp/providers/caption_provider.dart';
import 'package:salesmanapp/providers/cart_items.dart';
import 'package:salesmanapp/providers/cart_total.dart';
import 'package:salesmanapp/providers/delivery_items.dart';
import 'package:salesmanapp/providers/img_download.dart';
import 'package:salesmanapp/providers/sync_cap.dart';
import 'package:salesmanapp/providers/upload_count.dart';
import 'package:salesmanapp/providers/upload_length.dart';
import 'package:salesmanapp/salesman_home/login.dart';
import 'package:salesmanapp/salesman_home/menu.dart';
import 'package:salesmanapp/variables/assets.dart';
import 'package:salesmanapp/variables/colors.dart';
import 'package:salesmanapp/widgets/size_config.dart';

void main() {

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => Caption()),
    ChangeNotifierProvider(create: (_) => SyncCaption()),
    ChangeNotifierProvider(create: (_) => DownloadStat()),
    ChangeNotifierProvider(create: (_) => CartItemCounter()),
    ChangeNotifierProvider(create: (_) => CartTotalCounter()),
    ChangeNotifierProvider(create: (_) => UploadLength()),
    ChangeNotifierProvider(create: (_) => UploadCount()),
    ChangeNotifierProvider(create: (_) => DeliveryCounter()),
    // ChangeNotifierProvider(create: (_) => PaymentsBalances())
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return LayoutBuilder(
      builder: (context, constraints) {
        SizeConfig().init(constraints);
        return GetMaterialApp(
          title: 'Salesman',
          debugShowCheckedModeBanner: false,
          // showPerformanceOverlay: true,
          theme: ThemeData(
            primaryColor: ColorsTheme.mainColor,
            primarySwatch: Colors.deepOrange,
            // primarySwatch: ColorsTheme.mainColor,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          initialRoute: "/splash",
          routes: {
            "/splash": (context) => Splash(),
            "/option": (context) => MyOptionPage(),
            "/smmenu": (context) => SalesmanMenu(),
            "/smcustomer": (context) => Customer(),
            "/custprofile": (context) => CustomerProfile(),
            "/cart": (context) => CustomerCart(),
            "/prodpage": (context) => ProductPage(),
            "/categpage": (context) => ProductperCategory(),
            "/hepemenu": (context) => Menu(),
            "/smLogin": (context) => SalesmanLoginPage(),
          },
        );
      },
    );
  }
}

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isRootedDevice = false;
  @override
  void initState() {
    super.initState();
    new Timer(new Duration(seconds: 2), () {
      checkFirstSeen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            Container(
              color: ColorsTheme.mainColor,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Center(
                        child: Container(
                          // padding: EdgeInsets.only(top: 50),
                          width: MediaQuery.of(context).size.width / 2,
                          height: MediaQuery.of(context).size.height / 3,
                          child: Column(
                            children: [
                              Image(
                                image: AssetsValues.mainlogo,
                              ),
                              // SpinKitThreeBounce(
                              //   color: Colors.white,
                              //   size: 60,
                              // )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.of(context).size.width,
                // height: 30,
                // color: Colors.grey,
                child: Text('E-COMMERCE COPYRIGHT 2020',
                    style: TextStyle(
                        color: ColorsTheme.mainColorLight,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future checkFirstSeen() async {
    // if (isRootedDevice == false) {
    print('WELCOME');
    //dispose();
    Navigator.push(
        context,
        PageRouteBuilder(
            transitionDuration: Duration(seconds: 1),
            transitionsBuilder: (context, animation, animationTimne, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            pageBuilder: (context, animation, animationTime) {
              return MyOptionPage();
            }));
  }
}
