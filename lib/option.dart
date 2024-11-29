import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:salesmanapp/db/db_helper.dart';
import 'package:salesmanapp/providers/caption_provider.dart';
import 'package:salesmanapp/salesman_home/login.dart';
import 'package:salesmanapp/home/url/url.dart';
import 'package:http/http.dart' as http;
import 'package:salesmanapp/sm_hepe_data_checker/is_user_need_upload.dart';
import 'package:salesmanapp/userdata.dart';
import 'package:salesmanapp/variables/assets.dart';
import 'package:salesmanapp/variables/colors.dart';
import 'package:salesmanapp/widgets/size_config.dart';
import 'package:salesmanapp/widgets/snackbar.dart';
import 'package:url_launcher/url_launcher.dart';
class MyOptionPage extends StatefulWidget {
  @override
  _MyOptionPageState createState() => _MyOptionPageState();
}

class _MyOptionPageState extends State<MyOptionPage> {
  List rows = [];
  List salesmanList = [];
  List salesmanPrincipalList = [];
  List transactions = [];
  List customerList = [];
  List discountList = [];
  List hepeList = [];
  List itemList = [];
  List itemImgList = [];
  List itemAllImgList = [];
  List itemwImgList = [];
  List categList = [];
  List salestypeList = [];
  List bankList = [];
  List orderLimitList = [];
  List accessList = [];

  String? imageData;

  bool dataLoaded = false;
  bool processing = false;
  final db = DatabaseHelper();

  bool loadSpinkit = true;
  bool imgLoad = true;


  String? _dir;

  bool downloading = false;
  List ver = [];
  bool proceed = false;
  IsUserNeedUpload nu = new IsUserNeedUpload();

  String date = DateFormat("yyyy-MM-dd HH:mm:ss").format(new DateTime.now());


  Future createDatabase() async {
    await db.init();
    checkStatus();
    load();
    print(date);
    print('mucreate ni sila');

  }
  String appver = '';
appversion() async{
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;
  setState(() {
    appver = version;
  });
  // AppData.appVersion =
}
  checkVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    AppData.appVersion = version;
    var res = await db.checkAppversion(AppData.updesc);
    setState(() {
      ver = res;
      // print(ver);
    });
    if (ver.isNotEmpty) {
      setState(() {

        if (ver[0]['tdesc'] == AppData.appVersion) {
          AppData.appUptodate = true;
        } else {
          if(ver[0]['tdesc'] != null && NetworkData.connected == true){
            AppData.appUptodate = false;
          }else{
            AppData.appUptodate = true;
          }

        }
      });
    }

  }

  @override
  void initState() {
    super.initState();
    appversion();
    proceed = false;
    createDatabase();
    _initDir();
    if(UrlAddress.url=='https://distApp2.alturush.com/')
      {
        UrlAddress.isLocal = false;
      }else{
      UrlAddress.isLocal = true;
    }
  }

  _initDir() async {
    if (null == _dir) {
      _dir = (await getApplicationDocumentsDirectory()).path;
      print(_dir);
    }

  }

  load() {
    Provider.of<Caption>(context, listen: false)
        .changeCap('Creating/Updating Database...');
    GlobalVariables.spinProgress = 0;
    if (loadSpinkit == true) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => LoadingSpinkit());
    }
  }

  unloadSpinkit() async {
    loadSpinkit = false;
    setState(() {
      GlobalVariables.tableProcessing = 'Unloading Spinkit . . .';
    });
    Navigator.pop(context);
  }

  Future<void> _launchURL(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }
  //(2)
  checkStatus() async {
    Provider.of<Caption>(context, listen: false)
        .changeCap('Checking Connection...');
    var stat = await db.checkStat();
    if (!mounted) return;
    print(stat);
    if (stat == 'Connected') {
      setState(() {
        NetworkData.connected = true;
        NetworkData.errorMsgShow = false;
        NetworkData.errorMsg = '';
      });
      await checkVersion();
    } else {
      setState(() {
        NetworkData.connected = false;
      });
    }
    if (stat == '' || stat == null) {
      setState(() {
        unloadSpinkit();
      });
    } else {
      // itemImage(); // OLD PROCESS
      if(await nu.isUserNeedUpload()){
        await modalIsUserNeedUpload();
      }else{
        if(!AppData.appUptodate && NetworkData.connected == true){
          setState(() {
            modalUpdate();
          });
        }else{
          setState(() {
            checkEmpty();
          });
        }
      }
    }
  }
  Future modalIsUserNeedUpload() async{
    return showModalBottomSheet(
      isDismissible: false,
      enableDrag: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return WillPopScope(
            onWillPop: () => Future.value(false),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.gpp_good, color: ColorsTheme.mainColor,),
                    ),
                    Center(
                      child: Padding(
                        padding:
                        const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                        child: Column(
                          children: <Widget>[
                            Text("Reminders!", style: TextStyle(color: ColorsTheme.mainColor, fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("${DataToUploadChecker.isSalesmanNeedUpload ? "Salesman":""}"
                                "${DataToUploadChecker.isSalesmanNeedUpload ? DataToUploadChecker.isHePeNeedUpload ? " And ":"":""}"
                                "${DataToUploadChecker.isHePeNeedUpload ? "Hepe":""} "
                                "Transactions Need to Upload!", style: TextStyle(color: Colors.black)),
                            SizedBox(),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SizedBox(width: 15,),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async{
                              setState(() {
                                Navigator.of(context).pop();
                                unloadSpinkit();
                              });
                            },
                            child: Text("Okay"),
                          ),
                        ),
                        SizedBox(width: 10,),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        );
      },
    );
  }

  Future modalUpdate() async{
    return showModalBottomSheet(
      isDismissible: false,
      enableDrag: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return WillPopScope(
            onWillPop: () => Future.value(false),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.update, color: ColorsTheme.mainColor,),
                    ),
                    Center(
                      child: Padding(
                        padding:
                        const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                        child: Column(
                          children: <Widget>[
                            Text("New update Available!", style: TextStyle(color: ColorsTheme.mainColor)),
                            Text("Version ${AppData.appVersion}", style: TextStyle(color: ColorsTheme.mainColor)),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SizedBox(width: 10,),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: (){
                              setState(() {
                                proceed = false;
                                _launchURL(Uri.parse(UrlAddress.appLink));
                              });
                            },
                            child: Text("Update", style: TextStyle(color: Colors.black)),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.white70),
                            ),
                          ),
                        ),
                        SizedBox(width: 15,),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async{
                              setState(() {
                                Navigator.of(context).pop();
                                checkEmpty();
                              });
                            },
                            child: Text("Later"),
                          ),
                        ),
                        SizedBox(width: 10,),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        );
      },
    );
  }



  //(3)
  checkEmpty() async {
    //SALESMAN
    var sm = await db.ofFetchSalesmanList();
    salesmanList = sm;
    if (salesmanList.isEmpty) {
      Provider.of<Caption>(context, listen: false)
          .changeCap('Creating Salesman List...');
      var rsp = await db.getSalesmanList(context);
      salesmanList = rsp;
      print(salesmanList);
      await db.insertSalesmanList(salesmanList);
      await db.addUpdateTable('salesman_lists ', 'SALESMAN', date.toString());
      Provider.of<Caption>(context, listen: false)
          .changeCap('Updated Successfuly!');
      unloadSpinkit();
    } else {
      if (NetworkData.connected == true) {
        Provider.of<Caption>(context, listen: false)
            .changeCap('Creating Salesman List...');
        var rsp = await db.getSalesmanList(context);
        salesmanList = rsp;
        print(salesmanList);
        await db.insertSalesmanList(salesmanList);
        await db.addUpdateTable('salesman_lists ', 'SALESMAN', date.toString());
        //I can call a function for Payment terms here
        Provider.of<Caption>(context, listen: false)
            .changeCap('Updated Successfuly!');
        unloadSpinkit();
      }
      else{
        Provider.of<Caption>(context, listen: false)
            .changeCap('Updated UnSuccessful!');
        unloadSpinkit();
        showGlobalSnackbar(
          'Connectivity',
          'Please connect to the internet.',
          Colors.red.shade900,
          Colors.white,
        );

      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    ScreenData.scrWidth = screenWidth;
    ScreenData.scrHeight = screenHeight;
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
          body: Stack(
            children: <Widget>[
              Container(
                width: screenWidth,
                height: screenHeight,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetsValues.wallImg,
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 0.8 * screenWidth,
                      child: Card(
                        color: Colors.white.withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Center(
                            child: Text(
                              'Salesman App',
                              style: TextStyle(
                                color: Colors.red.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 34,
                                shadows: [
                                  Shadow(
                                    blurRadius: 4.0,
                                    color: Colors.grey.shade600,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height:MediaQuery.of(context).size.height /7),
                    GestureDetector(
                      onTap: () async {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return SalesmanLoginPage();
                            }));
                      },
                      child: Container(
                        width: screenWidth * 0.5,
                        height: screenHeight * 0.2,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(width: 3, color: Colors.green.shade700),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade500,
                              blurRadius: 6.0,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                width: ScreenData.scrWidth /1,
                                height: ScreenData.scrHeight * .09,
                                child: Image(image: AssetsValues.smImg,color: Colors.red)),
                            SizedBox(height: 10),
                            Text(
                              'Start Here',
                              style: TextStyle(
                                color: Colors.red.shade900,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      color: Colors.white.withOpacity(0.7),
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'App Version $appver',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height:MediaQuery.of(context).size.height /5),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red, // Set the background color to blue
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Adjust padding if needed
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // Add rounded corners
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            "/option", (Route<dynamic> route) => false);
                      },
                      child: Text(
                        'Refresh',
                        style: TextStyle(
                          color: Colors.white, // White text color for contrast
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: screenWidth * 0.6,
                        child: Text(
                          '${AppData.appName} ${AppData.appYear}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }

}

class LoadingSpinkit extends StatefulWidget {
  @override
  _LoadingSpinkitState createState() => _LoadingSpinkitState();
}

class _LoadingSpinkitState extends State<LoadingSpinkit> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: loadingContent(context),
      ),
    );
  }

  loadingContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
            padding: EdgeInsets.only(top: 50, bottom: 16, right: 5, left: 5),
            margin: EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.transparent,
                  ),
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  // Provider.of<Caption>(context).cap,
                  context.watch<Caption>().cap,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: Colors.white),
                ),
                SpinKitCircle(
                  color: ColorsTheme.mainColor,
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            )),
      ],
    );
  }
}
