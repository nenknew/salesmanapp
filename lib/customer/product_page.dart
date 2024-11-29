import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
// import 'package:salesman/customer/customer_cart.dart';
import 'package:salesmanapp/customer/favorites.dart';
// import 'package:salesman/customer/product_per_categ.dart';
import 'package:salesmanapp/db/db_helper.dart';
import 'package:salesmanapp/providers/cart_items.dart';
import 'package:salesmanapp/session/session_timer.dart';
import 'package:salesmanapp/userdata.dart';
import 'package:salesmanapp/variables/assets.dart';
import 'package:salesmanapp/variables/colors.dart';

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final searchController = TextEditingController();
  List _categlist = [];
  String _searchController = "";
  String categPath = '';
  String principalPath = '';
  // List _flist = [];
  bool viewSpinkit = true;

  final db = DatabaseHelper();

  void initState() {
    loadCateg();
    super.initState();

  }

  loadCateg() async {
    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = documentDirectory.path + '/category/';
    // print(firstPath);
    // var filePathAndName = documentDirectory.path + '/images/pic.jpg';
    categPath = firstPath;
    principalPath = (await getApplicationDocumentsDirectory()).path+'/principal/';
    // var ctg = await db.ofFetchCategList();
    var ctg = await db.ofFetchPrincipalList(UserData.id.toString());
    print("USER ID :: ${UserData.id}");
    print("Category :: $ctg");
    print("User Suplier size :: ${ctg.length}");
    if (!mounted) return;
    setState(() {
      _categlist = ctg;
      // print(_categlist);
      viewSpinkit = false;
    });
    loadFavorites();
  }

  searchCateg() async {
    var getC = await db.categSearch(_searchController.toString().trim());
    // var getC = await await db.ofFetchPrincipalList();
    if (!mounted) return;
    setState(() {
      _categlist = getC;
    });
  }

  loadFavorites() async {
    GlobalVariables.emptyFav = true;
    var getF = await db.getFav(CustomerData.accountCode);
    setState(() {
      GlobalVariables.favlist = getF;

      if (GlobalVariables.favlist.isNotEmpty) {
        GlobalVariables.emptyFav = false;
      }
    });
  }

  void handleUserInteraction([_]) {
    // _initializeTimer();

    SessionTimer sessionTimer = SessionTimer();
    sessionTimer.initializeTimer(context);
  }

  @override
  Widget build(BuildContext context) {
    print('Building Product Page...');

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        handleUserInteraction();
      },
      onPanDown: (details) {
        handleUserInteraction();
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 180, bottom: 5),
                child: Column(
                  children: [
                    buildCategCont(),
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 178,
              color: Colors.white,
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 30, bottom: 5),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 15,
                    ),
                    buildHeader(),
                    SizedBox(
                      height: 10,
                    ),
                    buildSearchField(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildSearchField() {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(top: 0, bottom: 0),
      child: Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  // width: MediaQuery.of(context).size.width - 130,
                  width: MediaQuery.of(context).size.width - 50,
                  height: 40,
                  child: TextFormField(
                    // controller: searchController,
                    onChanged: (String str) {
                      if(str.isEmpty){
                        loadCateg();
                        setState(() {
                        });
                      }else{
                        setState(() {
                          _searchController = str;
                          searchCateg();
                        });
                      }
                    },
                    decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black87),
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        hintText: 'Search Principal'),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                // Container(
                //   width: 80,
                //   height: 35,
                //   // color: ColorsTheme.mainColor,
                //   child: RaisedButton(
                //     shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(5)),
                //     color: ColorsTheme.mainColor,
                //     // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                //     onPressed: () {},
                //     child: Text(
                //       'Search',
                //       style: TextStyle(color: Colors.white, fontSize: 12),
                //     ),
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container buildCategCont() {

    if (viewSpinkit == true) {
      return Container(
        height: 620,
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
        margin: EdgeInsets.only(top: 0),
        // color: Colors.amber,
        // height: 510,
        height: MediaQuery.of(context).size.height - 100,
        width: MediaQuery.of(context).size.width,
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.only(top: 1),
            itemCount: _categlist.length,
            itemBuilder: (BuildContext context, index) {
              // print(categPath + _categlist[index]['catego
              // ory_image']);
              return GestureDetector(
                onTap: () => {
                  // CartData.setCateg = _categlist[index]['category_name'],
                  CartData.setCateg = _categlist[index]['principal'],
                  CartData.company_code = _categlist[index]['company_code'],
                  print("Principal :: ${CartData.setCateg} Company Code :: ${CartData.company_code}"),
                  // Navigator.push(context, MaterialPageRoute(builder: (context) {
                  //   return ProductperCategory();
                  // })),
                  Navigator.popAndPushNamed(context, '/categpage'),
                },
                child: Container(
                  width: MediaQuery.of(context).size.width ,
                  height: MediaQuery.of(context).size.height ,
                  // height: 80,
                  color: Colors.transparent,
                  child: Stack(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          // if (!GlobalVariables.viewImg)

                  Image.asset(
                  '${AssetsValues.principalImagePath}${_categlist[index]['company_code']}.png',
                    fit: BoxFit.cover, // Adjust as needed
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback image if the vendor-specific image is missing
                      return Image.asset(AssetsValues.noImageImg.assetName);
                    },
                  ),

                  // else if (!GlobalVariables.viewImg)
                          //   Container(
                          //       width:
                          //           MediaQuery.of(context).size.width - 20 / 2,
                          //       child: Image(image: AssetsValues.noImageImg))
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width - 20 / 2,
                            child: Card(
                                // elevation: 10,
                                color: Colors.black54,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child:
                                      // Text(_categlist[index]['category_name'],
                                      Text(_categlist[index]['principal']!,
                                          style: TextStyle(
                                            color: Colors.white,
                                          )),
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  Container buildHeader() {
    return Container(
      alignment: Alignment.centerLeft,
      child: Stack(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Text(
                  "Products",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: ColorsTheme.mainColor,
                      fontSize: 45,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              GestureDetector(
                child: Container(
                  // color: Colors.grey,
                  width: 50,
                  height: 50,
                  child: Stack(
                    children: <Widget>[
                      Icon(
                        Icons.wallet_giftcard_rounded,
                        size: 50,
                        color: ColorsTheme.mainColor,
                      ),
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(
                            top: 13,
                          ),
                          child: Text(
                            'PROMO',
                            // textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              backgroundColor: ColorsTheme.mainColor.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () => {
                  CartData.setCateg = "PROMO ITEMS",
                  CartData.company_code = "0000",
                  print("Principal :: ${CartData.setCateg} Company Code :: ${CartData.company_code}"),
                  // Navigator.push(context, MaterialPageRoute(builder: (context) {
                  //   return ProductperCategory();
                  // })),
                  Navigator.popAndPushNamed(context, '/categpage'),
                },
              ),
              SizedBox(
                width: 5,
              ),
              GestureDetector(
                child: Container(
                  // color: Colors.grey,
                  width: 50,
                  height: 50,
                  child: Stack(
                    children: <Widget>[
                      Icon(
                        Icons.favorite,
                        size: 50,
                        color: ColorsTheme.mainColor,
                      ),
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(
                            bottom: 12,
                          ),
                          child: Text(
                            'Favorites',
                            // textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () => {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return FavoritesPage();
                  })),
                },
              ),
              SizedBox(
                width: 5,
              ),
              GestureDetector(
                child: Container(
                  // color: Colors.grey,
                  width: 50,
                  height: 50,
                  child: Stack(
                    children: <Widget>[
                      Icon(
                        Icons.shopping_cart,
                        size: 50,
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          // margin: EdgeInsets.only(top: 2),
                          padding: EdgeInsets.only(top: 3),
                          width: 25,
                          height: 20,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ColorsTheme.mainColor),
                          child: Text(
                            // CartData.itmNo,
                            Provider.of<CartItemCounter>(context)
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
                    ],
                  ),
                ),
                onTap: () => {
                  Navigator.popAndPushNamed(context, '/cart'),
                  // Navigator.push(context, MaterialPageRoute(builder: (context) {
                  //   return CustomerCart();
                  // })),
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
