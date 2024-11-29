import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:salesmanapp/db/db_helper.dart';
import 'package:salesmanapp/forget_pass/forget_password.dart';
import 'package:salesmanapp/home/url/url.dart';
import 'package:salesmanapp/userdata.dart';
import 'package:salesmanapp/variables/assets.dart';
import 'package:salesmanapp/variables/colors.dart';
import 'package:salesmanapp/widgets/elevated_button.dart';
import 'package:salesmanapp/widgets/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesmanLoginPage extends StatefulWidget {
  @override
  _SalesmanLoginPageState createState() => _SalesmanLoginPageState();
}
class _SalesmanLoginPageState extends State<SalesmanLoginPage> {
  List _userdata = [];
  List device = [];
  List _userAttempt = [];

  String loginDialog = '';
  String err1 = 'No Internet Connection';
  String err2 = 'API Error';
  String err3 = 'No Connection to Server';
  final db = DatabaseHelper();
  final orangeColor = ColorsTheme.mainColor;
  final yellowColor = Colors.amber;
  final blueColor = Colors.blue;
  Timer? timer;
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool viewSpinkit = true;
  bool _obscureText = true;
  String message = '';
  String? imgPath;
  bool _autoLogin = false;
  bool _rememberPassword = false;
  void initState() {

    super.initState();
    _loadSavedCredentials();
    checkStatus();
    // if(UrlAddress.isLocal)
    //   {
    //     usernameController.text = 'TEST-01';
    //     passwordController.text = 'P@ssword2021';
    //   }else{
    //   usernameController.text = '';
    //   passwordController.text = '';
    // }
    // initPlatformState();
  }
  Future<void> _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberPassword = prefs.getBool('remember_password') ?? false;
      if (_rememberPassword) {
        usernameController.text = prefs.getString('username') ?? '';
        passwordController.text = prefs.getString('password') ?? '';
      }
      _autoLogin = prefs.getBool('auto_login') ?? false;
    });
  }
  Future<void> _saveCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_rememberPassword) {
      await prefs.setString('username', usernameController.text);
      await prefs.setString('password', passwordController.text);
    } else {
      await prefs.remove('username');
      await prefs.remove('password');
    }
    await prefs.setBool('auto_login', _autoLogin);
    await prefs.setBool('remember_password', _rememberPassword);
  }

  checkFailureAttempts(){
    bool lock = false;
    print("USER ATTEMP :: $_userAttempt");
    _userAttempt.forEach((element) {
      if (element['username'] == usernameController.text &&
          int.parse(element['attempt'].toString()) >= 3) {
        print('ACCOUNT WILL BE LOCKED OUT');
        lock = true;
        showGlobalSnackbar(
            'Information',
            'This account has been locked due to excessive login failures. Please contact your administrator.',
            Colors.blue,
            Colors.white);
        db.updateSalesmanStatus(usernameController.text);
        if (NetworkData.connected) {
          db.updateSalesmanStatusOnline(usernameController.text);
        }
      }
    });
    return lock;
  }

  checkStatus() async {
    var stat = await db.checkStat();

    if (stat == 'Connected') {
      NetworkData.connected = true;
      NetworkData.errorMsgShow = false;
      NetworkData.errorMsg = '';
    } else {
      if (stat == 'ERROR1') {
        NetworkData.connected = false;
        NetworkData.errorMsgShow = true;
        NetworkData.errorMsg = err1;
        NetworkData.errorNo = '1';
      }
      if (stat == 'ERROR2') {
        NetworkData.connected = false;
        NetworkData.errorMsgShow = true;
        NetworkData.errorMsg = err2;
        NetworkData.errorNo = '2';
      }
      if (stat == 'ERROR3') {
        NetworkData.connected = false;
        NetworkData.errorMsgShow = true;
        NetworkData.errorMsg = err3;
        NetworkData.errorNo = '3';
      }
      if (stat == 'Updating') {
        NetworkData.connected = false;
        NetworkData.errorMsgShow = true;
        NetworkData.errorMsg = 'Updating Server';
        NetworkData.errorNo = '4';
      }
    }
    // });
  }
  @override
  void dispose() {
    timer?.cancel();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: ()async{
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/option', (Route<dynamic> route) => false);
          db.updateCodeinSlsmnPrncpl(UserData.id);
          return true;
        },
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetsValues.wallImg,
                    fit: BoxFit.cover,
                  ),
                ),
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      // margin: EdgeInsets.only(top: 0),
                      // width: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30), // Rounded corners
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5), // Shadow color with transparency
                            spreadRadius: 3, // How much the shadow spreads
                            blurRadius: 5, // Softness of the shadow
                            offset: Offset(2, 2), // Shadow position (x, y)
                          ),
                        ],
                      ),
                      width: ScreenData.scrWidth * .55,
                      height: ScreenData.scrWidth * .4,
                      child: Center(
                        child: Image(
                          image: AssetsValues.loginLogo,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ScreenData.scrHeight * .030,
                    ),
                    Container(

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20), // Rounded corners
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5), // Shadow color with transparency
                            spreadRadius: 3, // How much the shadow spreads
                            blurRadius: 5, // Softness of the shadow
                            offset: Offset(2, 2), // Shadow position (x, y)
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(16), // Optional: Add padding inside the container
                      child: Text(
                        "Salesman Login",
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
                    SizedBox(
                      height: ScreenData.scrHeight * .030,
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: ScreenData.scrHeight * .27,
                      width: ScreenData.scrWidth * .84,
                      child: Column(
                        children: [
                          SingleChildScrollView(
                            child: buildSignInTextField(),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _rememberPassword,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberPassword = value ?? false;
                                    });
                                  },
                                ),
                                Text("Remember Password"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: ScreenData.scrHeight * .030,
                    ),
                    buildSignInButton(),
                    buildForgetPass(),
                    SizedBox(
                      height: ScreenData.scrHeight * .030,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        // height: 30,
                        // color: Colors.grey,
                        child: Row(

                          children: [
                            SizedBox(
                              width: ScreenData.scrWidth * .2,
                            ),
                            Text(
                              'E-COMMERCE(My NETgosyo App)' + ' COPYRIGHT 2020',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Container buildSignInButton() {
    return Container(
      margin: EdgeInsets.only(top: 0),
      child: Column(
        children: [
          ElevatedButton(
            style: raisedButtonLoginStyle,
            onPressed: () async {

              SharedPreferences prefs = await SharedPreferences.getInstance();
              print(UrlAddress.url);
              if (_formKey.currentState!.validate()) {
               if(!checkFailureAttempts()){
                 var username = usernameController.text;
                 var password = passwordController.text;
                 showDialog(
                     barrierDismissible: false,
                     context: context,
                     builder: (context) => LoggingInBox());
                 var rsp = await db.salesmanLogin(username, password);
                 if (rsp == '') {
                   loginDialog = 'Account not Found!';
                 } else {
                   if (rsp[0]['username'].toString() == username &&
                       rsp[0]['success'].toString() == '0') {
                     if (_userAttempt.isEmpty) {
                       _userAttempt = json.decode(json.encode(rsp));
                     } else {
                       int x = 0;
                       bool found = false;
                       _userAttempt.forEach((element) {
                         x++;
                         if (username.toString() ==
                             element['username'].toString()) {
                           element['attempt'] =
                               (int.parse(element['attempt'].toString()) + 1)
                                   .toString();
                           found = true;
                         } else {
                           if (_userAttempt.length == x && !found) {
                             _userAttempt.addAll(json.decode(json.encode(rsp)));
                           }
                         }
                       });
                     }
                     loginDialog = 'Account not Found!';
                   } else {
                     _userdata = rsp;
                     loginDialog = 'Found!';
                   }
                 }
                 if (loginDialog == 'Account not Found!') {
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(
                         backgroundColor: Colors.red,
                         content: Text("Invalid username or Password")),
                   );
                   Navigator.pop(context);
                 } else {
                   if (_userdata[0]['status'] == '0') {
                     showGlobalSnackbar(
                         'Information',
                         'This account has been locked due to excessive login failures. Please contact your administrator.',
                         Colors.blue,
                         Colors.white);
                   } else {
                     _saveCredentials();
                     showDialog(
                         barrierDismissible: false,
                         context: context,
                         builder: (context) => LoggingInBox());
                     UserData.id           = _userdata[0]['user_code'];
                     UserData.firstname    = _userdata[0]['first_name'];
                     UserData.lastname     = _userdata[0]['last_name'];
                     UserData.department   = _userdata[0]['department'];
                     UserData.division     = _userdata[0]['division'];
                     UserData.district     = _userdata[0]['district'];
                     UserData.position     = _userdata[0]['title'];
                     UserData.contact      = _userdata[0]['mobile'];
                     UserData.postal       = _userdata[0]['postal_code'];
                     UserData.email        = _userdata[0]['email'];
                     UserData.address      = _userdata[0]['address'];
                     UserData.routes       = _userdata[0]['area'];
                     UserData.passwordAge  = _userdata[0]['password_date'];
                     UserData.img          = _userdata[0]['img'];
                     UserData.imgPath      = imgPath.toString() + _userdata[0]['img'];
                     UserData.username     = username;
                     GlobalVariables.deviceData =
                         _deviceData['brand'].toString() +
                             '_' +
                             _deviceData['device'].toString() +
                             '-' +
                             _deviceData['androidId'].toString();
                     if (NetworkData.connected) {
                       var setDev = await db.setLoginDevice(
                           UserData.id!, GlobalVariables.deviceData!);
                     }
                     viewSpinkit = false;
                     if (viewSpinkit == false) {
                       DateTime a = DateTime.parse(UserData.passwordAge!);
                       final date1 = DateTime(a.year, a.month, a.day);
                       final date2 = DateTime.now();
                       final difference = date2.difference(date1).inDays;
                       if (difference >= 90) {
                         prefs.setString("last_user_login", UserData.id.toString().trim());
                         Navigator.of(context).pushNamedAndRemoveUntil(
                            '/smmenu', (Route<dynamic> route) => false);
                        db.updateCodeinSlsmnPrncpl(UserData.id);

                       } else {
                         GlobalVariables.passExp = false;

                         prefs.setString("last_user_login", UserData.id.toString().trim());
                         Navigator.of(context).pushNamedAndRemoveUntil(
                             '/smmenu', (Route<dynamic> route) => false);
                         db.updateCodeinSlsmnPrncpl(UserData.id);
                       }
                     }
                   }
                 }
               }

              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "LOGIN",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: ScreenData.scrHeight * .070,
          ),
        ],
      ),
    );
  }

  Column buildSignInTextField() {
    final node = FocusScope.of(context);
    return Column(children: [
      Form(
          key: _formKey,
          child: Column(children: <Widget>[
            TextFormField(
              textInputAction: TextInputAction.next,
              onEditingComplete: () => node.nextFocus(),
              controller: usernameController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black87),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                hintText: 'Username',
                hintStyle: TextStyle(color: Colors.red), // Red color for the hint text
                fillColor: Colors.white, // White background
                filled: true, // Enable the background color
              ),

                style: TextStyle(
                  color: Colors.red.shade900,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,

              ),

              validator: (value) {
                if (value!.isEmpty) {
                  return 'Username cannot be empty';
                }
                return null;
              },
            ),

            SizedBox(
              height: ScreenData.scrHeight * .020,
            ),
            TextFormField(
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => node.unfocus(),
              obscureText: _obscureText,
              controller: passwordController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                hintText: 'Password',
                fillColor: Colors.white, // White background
                filled: true, // Enable the background color
                hintStyle: TextStyle(color: Colors.red), // Red color for the hint text
                suffixIcon: GestureDetector(
                  child: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.red,
                      size: 30,
                    ),
                    onPressed: () {
                      _toggle();
                    },
                  ),
                ),
              ),
              style: TextStyle(
                color: Colors.red.shade900,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Password cannot be empty';
                }
                return null;
              },
            ),

          ]))
    ]);
  }

  Container buildForgetPass() {
    return Container(
      margin: EdgeInsets.only(top: 0),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              checkStatus();
              if (NetworkData.connected == true) {
                ForgetPassData.type = 'Salesman';
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ForgetPass();
                }));
                // print('Forget Password Form');
              } else {
                showGlobalSnackbar(
                    'Connectivity',
                    'Please connect to internet.',
                    Colors.red.shade900,
                    Colors.white);
              };
            },
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                color: Colors.red.shade900,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Text(message),
        ],
      ),
    );
  }
}

class LoggingInBox extends StatefulWidget {
  @override
  _LoggingInBoxState createState() => _LoggingInBoxState();
}

class _LoggingInBoxState extends State<LoggingInBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      // child: confirmContent(context),
      child: loadingContent(context),
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
                  'Logging in as Salesman...',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: Colors.white),
                ),
                SpinKitCircle(
                  color: ColorsTheme.mainColor,
                ),
              ],
            )),
      ],
    );
  }
}
