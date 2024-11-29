import 'dart:async';
import 'dart:io';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:salesmanapp/home/url/url.dart';

class AppData {
  static String appName = 'E-COMMERCE(My NETgosyo App) ${UrlAddress.server}';
  static String? appVersion;
  static String appYear = ' COPYRIGHT 2021';
  static bool appUptodate = true;
  static String updesc = 'SMAPP';
}

class ScreenData {
  static double scrWidth = 0.00;
  static double scrHeight = 0.00;
}

class DataToUploadChecker{
  static bool isSalesmanNeedUpload = true;
  static bool isHePeNeedUpload = true;
}

class UserData {
  static String? id;
  static String? firstname;
  static String? lastname;
  static String? position;
  static String? department;
  static String? division;
  static String? district;
  static String? contact;
  static String? postal;
  static String? email;
  static String? address;
  static String? routes;
  static String? trans;
  static String? sname;
  static String? username;
  static String? newPassword;
  static String? passwordAge;
  static String? img;
  static String? imgPath;
  static String? getImgfrom;
  static List tranList=[];
  static String selectedPaymentMethod = "";
  static List<String> paymentMethod = [""];
}

class UserAccess {
  static bool noMinOrder = false;
  static bool multiSalesman = false;
  // static bool multiSalesman = true;
  static List customerList = [];
}

class OrderData {
  static bool statReset = false;
  static String? trans;
  static String? pmeth;
  static String? name;
  static String? dateReq;
  static String? dateApp;
  static String? dateDel;
  static String? itmno;
  static String? address;
  static String? contact;
  static String? qty;
  static String? smcode;
  static String totamt = '0';
  static String retAmt = '0';
  static String totalDisc = '0';
  static String grandTotal = '0';
  static String grandTotalserv = '0';
  static String grandTotalunserv = '0';
  static String grandTotaldeliver = '0';
  static bool visible = true;
  static String? status;
  static String? changeStat;
  static String? signature;
  static String? pmtype;
  static bool setPmType = false;
  static bool setSign = false;
  static bool setChequeImg = false;
  static List tranLine = [];
  static bool returnOrder = false;
  static String returnReason = "";
  static String specialInstruction = "";
  static bool note = false;

  //newly Added
  static String? divcode;
  static String remaining  = '0';
  static String? receiptAmtMas;
  static String? masBalance;
  static String? receiptStoreName;
  static bool isPartial = false; //ilhanan ni para ma.identify ug batching ba nya
  static String itemNos  = '0';
  static double taxAmount  = 0.00;
  static String? invoice  = '';
  static List? returnList  = []; //mao nig gireturn
  static List? restoreList  = []; // mao nig girestore

  static TextFormField amount(String fieldname){
    final CurrencyTextInputFormatter _formatter = CurrencyTextInputFormatter(
        symbol: 'PHP '
    );
    return TextFormField(
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.done,
      cursorColor: Colors.deepOrange.withOpacity(0.8),

      inputFormatters:<TextInputFormatter>[
        _formatter
      ],
      onChanged: (text){
        if(text.isNotEmpty){
          String newtext = text.replaceAll("PHP ", "").replaceAll(",", "");
          OrderData.taxAmount = double.parse(newtext);
        }else{
          OrderData.taxAmount = 0.00;
        }
      },
      keyboardType: TextInputType.numberWithOptions(
          decimal: true,
          signed: false
      ),
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.deepOrange.withOpacity(0.7),
            width: 2.0,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        hintText: 'Enter Tax Amount',
        // hintStyle: const TextStyle(fontStyle: FontStyle.normal, fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class CustomerData {
  static String? id;
  static String? accountCode;
  static String? groupCode;
  static String? province;
  static String? city;
  static String? district;
  static String? accountName;
  static String? accountDescription;
  static String? contactNo;
  static String? paymentType;
  static String? status;
  static String? colorCode;
  static Color? custColor;
  static String? creditLimit;
  static String? creditBal;
  static bool discounted = false;
  static bool placeOrder = true;
  static List tranNoList = [];
  static bool minOrderLock = true;
}

class CartData {
  static String itmNo = '0';
  static String? itmLineNo;
  static String totalAmount = '0';
  static String setCateg = '';
  static String? itmCode;
  static String? itmDesc;
  static String? itmUom;
  static String? itmAmt;
  static String itmQty = '';
  static String itmTotal = "";
  static String? cartTotal;
  static String? imgpath;
  static String? company_code;
  static bool allProd = false;
  static String isMust = "";
  static String isPromo = "";
}

class GlobalVariables {
  static String? totalAmount;
  static List totalList=[];
  static String? itemCount;
  static bool viewImg = false;
  static String? tran_no;
  static String? itmQty;
  static int menuKey = 0;
  static String? tranNo;
  static bool isDone = false;
  static bool showSign = false;
  static bool showCheque = false;
  static List itemlist = [];
  static List favlist = [];
  static List returnList = [];
  static bool emptyFav = true;
  static bool processedPressed = false;
  static String minOrder = '0';
  static bool outofStock = false;
  static bool consolidatedOrder = false;
  static String appVersion = '01';
  static String updateType = '';
  static String updateBy = '';
  // static String dlPercentage = '';
  static String progressString = '';
  static bool updateSpinkit = true;
  static bool uploaded = false;
  static String tableProcessing = '';
  static List processList = [];
  // static List<String> processList = List<String>();
  // processList['process'] = '';
  static bool viewPolicy = true;
  static bool dataPrivacyNoticeScrollBottom = false;
  static String? fpassUsername;
  static String? fpassmobile;
  static String? fpassusercode;
  static String statusCaption = '';
  static String? uploadLength;
  static bool upload = false;
  static bool uploadBtn = false;
  static bool? uploadSpinkit;
  static double? spinProgress;
  static bool passExp = false;
  static String? deviceData;
  static bool fullSync = false;
  // static String? syncStartDate;
  // static String? syncEndDate;
  static String syncStartDate = DateFormat("yyyy-MM-dd")
      .format(DateTime.now().subtract(Duration(days: 15)));
  static String syncEndDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
}

class GlobalTimer {
  static Timer? timerSessionInactivity;
}

class ChequeData {
  static String? payeeName;
  static String? payorName;
  static String? bankName;
  static String? chequeNum;
  static String? branchCode;
  static String? bankAccNo;
  static String? chequeDate;
  static String? status;
  static String? chequeAmt;
  static String? numToWords;
  static String? imgName;
  static File? image;
  static File? imageback;
  static bool changeImg = false;

  //NEWLY ADDED
  static String base64img = '';
  static String defaultchoice = '';
  static String selectedDate = '';
  static bool isCOD = false; // cod na cheque payment auto assign ang amount
  static TextEditingController cheqAmt = TextEditingController();
  static TextEditingController cpayeeName = TextEditingController();
  static TextEditingController cpayorName = TextEditingController();
  static TextEditingController ccheqNum = TextEditingController();
  static TextEditingController cbranchCode = TextEditingController();
  static TextEditingController cbankAccnt = TextEditingController();
}

class SalesData {
  static String? salesToday;
  static String? salesWeekly;
  static String? salesMonthly;
  static String? salesYearly;
  static String? salesmanSalesType;
  static String? customerSalesType;
  static String? overallSalesType;
  static String? smTotalCaption;
  static String? custTotalCaption;
  static String? itmTotalCaption;
  static String? itemSalesType;
}

class NetworkData {
  static Timer? timer;
  static bool connected = false;
  static bool errorMsgShow = true;
  static String? errorMsg;
  static bool uploaded = false;
  static String? errorNo;
}

class ForgetPassData {
  static String? type;
  static String? smsCode;
  static String? number;
}

class ChatData {
  static String? senderName;
  static String? accountCode;
  static String? accountName;
  static String? accountNum;
  static String? refNo;
  static String? status;
  static bool newNotif = false;
}

MyGlobals myGlobals = MyGlobals();

class MyGlobals {
  GlobalKey? _scaffoldKey;
  MyGlobals() {
    _scaffoldKey = GlobalKey();
  }
  GlobalKey get scaffoldKey => _scaffoldKey!;
}

class Spinkit {
  static String? label;
}

class PrinterData{
  static bool connected = false;
  static String mac = '';
}