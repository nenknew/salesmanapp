import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:salesmanapp/db/db_helper.dart';
import 'package:salesmanapp/dialogs/confirmupload.dart';
import 'package:salesmanapp/dialogs/syncsuccess.dart';
import 'package:salesmanapp/dialogs/uploadloading.dart';
import 'package:salesmanapp/providers/sync_cap.dart';
import 'package:salesmanapp/providers/upload_count.dart';
import 'package:salesmanapp/salesman_sync/sync_option.dart';
import 'package:salesmanapp/session/session_timer.dart';
import 'package:salesmanapp/sm_hepe_data_checker/is_user_need_upload.dart';
import 'package:salesmanapp/userdata.dart';
import 'package:salesmanapp/variables/colors.dart';
import 'package:salesmanapp/widgets/elevated_button.dart';
import 'package:salesmanapp/widgets/snackbar.dart';
import '../dialogs/confirm_sync.dart';
import '../forget_pass/change_password.dart';
import '../providers/caption_provider.dart';
import '../widgets/dialogs.dart';

class SyncSalesman extends StatefulWidget {
  @override
  _SyncSalesmanState createState() => _SyncSalesmanState();
}
class _SyncSalesmanState extends State<SyncSalesman> {
  bool viewSpinkit = true;
  bool uploadPressed = true;
  bool downloadPressed = false;
  bool errorMsgShow = true;
  bool uploading = false;
  bool loadSpinkit = true;
  final date = DateFormat("yyyy-MM-dd HH:mm:ss").format(new DateTime.now());
  bool upTrans = false;
  bool upItem = false;
  bool upCust = false;
  bool upSm = false;
  String transLastUp = '';
  String itemLastUp = '';
  String custLastUp = '';
  String smLastUp = '';
  String amount = "";
  String err1 = 'No Internet Connection';
  String err2 = 'No Connection to Server';
  String err3 = 'API Error';
  String errorMsg = '';
  final db = DatabaseHelper();
  IsUserNeedUpload nu = new IsUserNeedUpload();
  final String today = DateFormat("yyyy-MM-dd").format(new DateTime.now());
  Timer? timer;
  final formatCurrencyTot =
      new NumberFormat.currency(locale: "en_US", symbol: "Php ");
  List _toList = [];
  List _upList = [];
  List _updateLog = [];
  List _tempList = [];

  void initState() {
    GlobalVariables.updateBy = 'Salesman';
    GlobalVariables.updateSpinkit = false;
    NetworkData.uploaded = false;
    GlobalVariables.upload = false;
    super.initState();
    checkStatus();
    loadForUpload();
  }

  checkConnection() async{
    var stat = await db.checkStat();
    if (stat == 'Connected') {
      NetworkData.connected = true;
      NetworkData.errorMsgShow = false;
      NetworkData.errorMsg = '';
    }else {
      NetworkData.connected = false;
    }
  }
  checkUpdates() async {
    String dtime = '';
    var rsp = await db.ofFetchUpdatesTables();
    _upList = rsp;
    _upList.forEach((element) {

      DateTime a = DateTime.parse(element['date']);
      dtime = DateFormat("yyyy-MM-dd").format(a);

      if (element['tb_categ'] == 'TRANSACTIONS') {
        if (dtime == today) {
          upTrans = true;
        } else {
          upTrans = false;
        }
        DateTime x = DateTime.parse(element['date'].toString());
        transLastUp = DateFormat("MMM. d, y").format(x);
      }
      if (element['tb_categ'] == 'ITEM') {
        if (dtime == today) {
          upItem = true;
        } else {
          upItem = false;
        }
        DateTime x = DateTime.parse(element['date'].toString());
        itemLastUp = DateFormat("MMM. d, y").format(x);
      }
      if (element['tb_categ'] == 'CUSTOMER') {
        if (dtime == today) {
          upCust = true;
        } else {
          upCust = false;
        }
        DateTime x = DateTime.parse(element['date'].toString());
        custLastUp = DateFormat("MMM. d, y").format(x);
      }
      if (element['tb_categ'] == 'SALESMAN') {
        if (dtime == today) {
          upSm = true;
        } else {
          upSm = false;
        }
        DateTime x = DateTime.parse(element['date'].toString());
        smLastUp = DateFormat("MMM. d, y").format(x);
      }
    });
  }

  uploadButtonclicked() async {
    if (NetworkData.connected == true) {
      if (NetworkData.uploaded == false) {
       var res = await showDialog(
            context: context,
            builder: (context) => ConfirmUpload(
                  // iconn: 59137,
                  title: 'Confirmation!',
                  description1: 'Are you sure you want to upload transactions?',
                  description2: 'Please secure stable internet connection.',
                ));
        if(res==null || res=='cancel')
        {
          GlobalVariables.uploadBtn = false;
        }else{
          checkStatus();
        }
      }else{
        GlobalVariables.uploadBtn = false;
      }
    } else {
      GlobalVariables.uploadBtn = false;
      showGlobalSnackbar('Connectivity', 'Please connect to internet.',
          Colors.red.shade900, Colors.white);
    }
  }

  upload() async {
    int x = 0;
    Provider.of<UploadCount>(context, listen: false).setTotal(x);
    if (NetworkData.errorMsgShow == false &&
        uploading == false &&
        !GlobalVariables.uploaded) {
      for(var element in _toList) {
        NetworkData.uploaded = true;
        uploading = true;
        Provider.of<SyncCaption>(context, listen: false)
            .changeCap('Uploading ' + element['tran_no'] + '...');
        var tmp = await db.getTransactionLine(element['tran_no']);
        if (!mounted) return;
        var rsp = await db.saveTransactions(
            context,
            element['sm_code'],
            element['div_code'],
            element['date_req'],
            element['account_code'],
            element['store_name'],
            element['p_meth'] ?? "COD",
            element['itm_count'],
            element['tot_amt'],
            element['tran_stat'],
            element['signature'],
            'TRUE',
            element['hepe_upload'],
            tmp);
        setState((){
          x++;
          if (rsp.isNotEmpty || rsp != null) {
            db.updateTranUploadStatSM(element['tran_no'], rsp);
            db.updateLineUploadStat(element['tran_no'], rsp);
            Provider.of<UploadCount>(context, listen: false).setTotal(x);
            print(x);
            if (x == _toList.length) {
              GlobalVariables.uploaded = true;
              NetworkData.uploaded = false;
              GlobalVariables.upload = false;
              GlobalVariables.uploadBtn = false;
              Navigator.pop(context);
              loadForUpload();
            }
          }
        });
      }
    }else{
      GlobalVariables.uploadBtn = false;
    }
  }

  loadForUpload() async {
    var getP = await db.ofFetchForUploadSalesman(UserData.id);
    if (!mounted) return;
    setState(() {
      _toList = getP;
      if (_toList.isEmpty) {
        uploading = false;
      } else {
        GlobalVariables.uploaded = false;
        GlobalVariables.uploadLength = _toList.length.toString();
      }
    });
  }

  checkSpinkit() {
    if (GlobalVariables.updateSpinkit == true) {
      Navigator.pop(context);
      GlobalVariables.updateSpinkit = false;
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => UpdatedSuccessfully());
    }
  }

  loadUpdateLog() async {
    String updateType = 'Salesman';
    var rsp = await db.ofFetchUpdateLog(updateType);

      _updateLog = rsp;
    Provider.of<Caption>(context, listen: false).updateLogs(_updateLog);
  }

  checkStatus() async {
    loadForUpload();
    checkUpdates();
    checkSpinkit();
    loadUpdateLog();
    if (GlobalVariables.upload == true && GlobalVariables.uploadBtn == true) {
      GlobalVariables.upload = false;
      if (NetworkData.uploaded == false && uploading == false) {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => UploadingSpinkit());
        await upload();
      }else{
        GlobalVariables.uploadBtn = false;
      }
    }

  }



  /////////////////////////SELECTIVE UPDATE TRANSACTIONS
  updateTranLineSelective() async {
    //LINE UPDATE
    List linelist =[];

    var linersp = await db.getTranLineSelective(
        context,
        UserData.id.toString(),// gichange na ug smcode sa tranhead para magmatch ang syncing ug data
        GlobalVariables.syncStartDate.toString(),
        GlobalVariables.syncEndDate.toString());
        linelist = linersp;
        if(linelist.isNotEmpty){
          await db.deleteTable('tb_tran_line');
          await db.insertTableTbTranLine(linelist);

          await db.updateTable('tb_tran_line', date.toString());
          print('Transaction Line Created');
          updateSelectiveTransactions();
        }else{
          updateSelectiveTransactions();
        }
     }


  updateSelectiveTransactions() async {
    List linelist =[];
    var retlist = await db.getReturnedTranListSelective(
        context,
        GlobalVariables.syncStartDate.toString(),
        GlobalVariables.syncEndDate.toString());
    linelist =retlist;

            if(linelist.isNotEmpty){
              await db.deleteTable('tb_returned_tran');
              print("INSERTING DATA IN TB_RETURN_TRAN");
              await db.insertTableTbReturnedTran(linelist);
              await db.updateTable('tb_returned_tran', date.toString());
              print('RETURNED TRAN Updated');
              updateTranUnservedSelective();

            }else{
              updateTranUnservedSelective();
            }


  }

  updateTranUnservedSelective() async {
    //RETURNED/UNSERVED LIST
    List unsrvlist =[];

    var uslist = await db.getUnservedListSelective(
        context,
        GlobalVariables.syncStartDate.toString(),
        GlobalVariables.syncEndDate.toString());
    unsrvlist = uslist;
    if (unsrvlist.isNotEmpty) {
      print('tb_unserved_items Updated');
            await db.deleteTable('tb_unserved_items');
            await db.insertTableTbUnservedItems(unsrvlist);
            await db.updateTable('tb_unserved_items', date.toString());
      // updateTranCheque();
            updateTranHeadSelective();

      // updateTranLineSelective();
    } else {

      updateTranHeadSelective();
    }
  }

 updateTranHeadSelective() async {
    //TRAN UPDATE
    List tranHeadList =[];
      var thead = await db.getTranHeadSelective(
          context,
          UserData.id.toString(),
          GlobalVariables.syncStartDate.toString(),
          GlobalVariables.syncEndDate.toString());
      tranHeadList = thead;

    if (tranHeadList.isNotEmpty) {
      print('tb_tran_head Updated');
      await db.deleteTable('tb_tran_head');
      await db.insertTableTbTranHead(tranHeadList);
      await db.updateTable('tb_tran_head ', date.toString());
      await db.addUpdateTableLog(
          date.toString(),
          GlobalVariables.updateType,
          'Completed',
          GlobalVariables.updateBy);

     GlobalVariables.updateSpinkit = false;
      Navigator.pop(context);
     showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => UpdatedSuccessfully());


    }else{
      showGlobalSnackbar(
        '!',
        'No Data Found',
        Colors.red.shade900,
        Colors.white,
      );
      Navigator.pop(context);
      GlobalVariables.updateSpinkit = false;

    }
  }
  //for selective transaction


//for download data masterfile
  updateItemMasterfile() async {
    // List itemImgList = [];
    // Provider.of<SyncCaption>(context, listen: false)
    //     .changeCap('Updating Item Images...');
    // var rsp = await db.getItemImgList(context);
    // itemImgList = rsp;
    //   if(itemImgList.isNotEmpty){
    //     await db.insertItemImgList(itemImgList);
    //     await db.updateTable('tbl_item_image', date.toString());
        updateItemCateg();
      // }else
      //   {
      //     updateItemCateg();
      //   }
  }
  updateItemCateg() async {
    List categList = [];
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Categories...');
    // //CATEGORY
    var rsp1 = await db.getCategList(context);
    categList = rsp1;
        if(categList.isNotEmpty ){
          await db.deleteTable('tbl_category_masterfile');
          await db.updateCategList(categList);
          await db.updateTable('tbl_category_masterfile', date.toString());
          updateItemList();
        }else{
          updateItemList();
        }

  }


  updateItemList() async {
    List itemList = [];
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Item List...');
    var resp = await db.getItemList(context,UserData.username);
    itemList = resp;

    if(itemList.isNotEmpty ){
      await db.deleteTable('item_masterfiles');
      await db.insertItemList(itemList);
      await db.insertData();
      await db.updateTable('item_masterfiles', date.toString());
      await db.addUpdateTableLog(
          date.toString(),
          GlobalVariables.updateType,
          'Completed',
          GlobalVariables.updateBy);
      Navigator.pop(context);
      GlobalVariables.updateSpinkit = false;
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => UpdatedSuccessfully());

    }
    else{
      showGlobalSnackbar(
        '!',
        'No Data Found',
        Colors.red.shade900,
        Colors.white,
      );
      Navigator.pop(context);
      GlobalVariables.updateSpinkit = false;

    }
  }
//for download masterfile


////////////////////////////////////////////////////////////////////////////////////


  //for customer
  updateCustomer() async {
    List discountList = [];
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Discount List...');
    var rsp = await db.getDiscountList(context);
    discountList = rsp;
      if(discountList.isNotEmpty){
        await db.deleteTable('tbl_discounts');
        await db.insertDiscountList(discountList);
        await db.updateTable('tbl_discounts ', date.toString());
        print('Discount List Created');
        updateCustomerBank();
      }else{
        updateCustomerBank();
      }

  }

  updateCustomerBank() async {
    List bankList = [];
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Bank List...');
    var rsp1 = await db.getBankListonLine(context);
    bankList = rsp1;
        if(bankList.isNotEmpty){
          await db.deleteTable('tb_bank_list');
          await db.insertBankList(bankList);
          await db.updateTable('tb_bank_list', date.toString());
          updateCustomerList();
        }else{
          updateCustomerList();
        }

  }

  updateCustomerList() async {
    List customerList = [];
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Customer List...');

    var resp = await db.getCustomersList(context, UserData.username);
      customerList = resp;
    if(customerList.isNotEmpty ){
      await db.deleteTable('customer_master_files');
      await db.insertCustomersList(customerList);
      await db.updateTable('customer_master_files ', date.toString());
      await db.addUpdateTableLog(
          date.toString(),
          GlobalVariables.updateType,
          'Completed',
          GlobalVariables.updateBy);
      Navigator.pop(context);
      GlobalVariables.updateSpinkit = false;
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => UpdatedSuccessfully());

    }else{
      showGlobalSnackbar(
        '!',
        'No Data Found',
        Colors.red.shade900,
        Colors.white,
      );
      Navigator.pop(context);
      GlobalVariables.updateSpinkit = false;
    }

  }
  //for customer

  //////////////////////////////////////////////////////////////////////////
  //FOR SALESMAN
  updateSalesman() async {
    List salesmanList =[];
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Salesman List...');
    var resp = await db.getSalesmanList(context);
    salesmanList = resp;
      if(salesmanList.isNotEmpty){
        await db.deleteTable('salesman_lists');
        await db.insertSalesmanList(salesmanList);
        await db.updateTable('salesman_lists ', date.toString());
        updateOrderLimit();
      }else{
        updateOrderLimit();
      }

  }

  updateOrderLimit() async {
    List orderLimitList =[];
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Order Limit List...');
    var resp = await db.getOrderLimitonLine(context);
    orderLimitList = resp;
          if(orderLimitList.isNotEmpty){
            await db.deleteTable('tbl_order_limit');
            await db.insertOrderLimitList(orderLimitList);
            await db.updateTable('tbl_order_limit ', date.toString());
            updateSalesmanPrincipal();

          }else{
            updateSalesmanPrincipal();
          }

  }
  updateSalesmanPrincipal() async {
    List salesmanPrincipal =[];
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Salesman Principal...');
    var resp = await db.getSalesmanPrincipal(context,UserData.username);
    salesmanPrincipal = resp;
    if (salesmanPrincipal.isNotEmpty ) {
      await db.deleteTable('tbl_principals');
      await db.insertSalesmanPrincipal(salesmanPrincipal);
      await db.addUpdateTableLog(
          date.toString(),
          GlobalVariables.updateType,
          'Completed',
          GlobalVariables.updateBy);
      Navigator.pop(context);
      GlobalVariables.updateSpinkit = false;
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => UpdatedSuccessfully());


    }
    else{
      showGlobalSnackbar(
        '!',
        'No Data Founds',
        Colors.red.shade900,
        Colors.white,
      );
      Navigator.pop(context);
      GlobalVariables.updateSpinkit = false;
    }

  }
  //FOR SALESMAN
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
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 120,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sync",
                textAlign: TextAlign.right,
                style: TextStyle(
                    color: ColorsTheme.mainColor,
                    fontSize: 45,
                    fontWeight: FontWeight.bold),
              ),
              Visibility(
                  visible: NetworkData.errorMsgShow, child: buildStatusCont()),
              buildOrderOption(),
            ],
          ),
        ),
        body: uploadPressed ? buildUploadCont() : buildDownloadCont(),
        floatingActionButton: Visibility(
          visible: uploadPressed,
          child: Container(
            padding: EdgeInsets.only(left: 30),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FloatingActionButton(
                onPressed: () async{
                  print('${_toList}');
                  if(!GlobalVariables.uploadBtn){
                    GlobalVariables.uploadBtn = true;
                    if(UserData.id != "SM-DEMO"){
                      if (_toList.isNotEmpty) {
                        await checkConnection();
                        await uploadButtonclicked();
                      }else{
                        GlobalVariables.uploadBtn = false;
                      }
                    }else{
                      GlobalVariables.uploadBtn = false;
                      showGlobalSnackbar('DEMO ACCOUNT', 'Upload Failed',
                          Colors.grey, Colors.white);
                    }
                  }
                },
                tooltip: 'Upload',
                child: Icon(Icons.file_upload),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container buildDownloadCont() {
    final a =Provider.of<Caption>(context, listen: true);
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              // height: 250,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width - 40,
                          // color: Colors.grey,
                          child: Stack(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  InkWell(
                                    onTap: () async {
                                      await checkConnection();

                                      if (!NetworkData.errorMsgShow) {
                                        if (await nu.isUserNeedUpload()) {
                                          showGlobalSnackbar(
                                            'Download Error',
                                            'Please upload your orders before downloading.',
                                            Colors.grey.shade900,
                                            Colors.white,
                                          );
                                        } else {
                                          GlobalVariables.updateType = 'Transactions';

                                          // Show a range date picker dialog inline
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              DateTimeRange? selectedDateRange;

                                              return StatefulBuilder(
                                                builder: (context, setState) {
                                                  return AlertDialog(
                                                    title: Text('Select Date Range'),
                                                    content: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          selectedDateRange == null
                                                              ? 'No date range selected'
                                                              : 'Start: ${DateFormat("yyyy-MM-dd").format(selectedDateRange!.start)}\n'
                                                              'End: ${DateFormat("yyyy-MM-dd").format(selectedDateRange!.end)}',
                                                          textAlign: TextAlign.center,
                                                        ),
                                                        SizedBox(height: 16),
                                                        ElevatedButton(
                                                          onPressed: () async {
                                                            final DateTimeRange? picked = await showDateRangePicker(
                                                              context: context,
                                                              initialDateRange: selectedDateRange,
                                                              firstDate: DateTime(2000),
                                                              lastDate: DateTime(2100),
                                                            );

                                                            if (picked != null) {
                                                              setState(() {
                                                                selectedDateRange = picked;
                                                              });
                                                            }
                                                          },
                                                          child: Text('Pick Date Range'),
                                                        ),
                                                      ],
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: Text('Cancel'),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          if (selectedDateRange != null) {
                                                            // Close the date picker dialog
                                                            Navigator.pop(context);

                                                            // Show loading spinner
                                                            Spinkit.label = 'Updating Transactions...';
                                                            showDialog(
                                                              barrierDismissible: false,
                                                              context: context,
                                                              builder: (context) => LoadingSpinkit(),
                                                            );

                                                            // Assign selected dates as formatted Strings to GlobalVariables
                                                            GlobalVariables.syncStartDate =
                                                                DateFormat("yyyy-MM-dd").format(selectedDateRange!.start);
                                                            GlobalVariables.syncEndDate =
                                                                DateFormat("yyyy-MM-dd").format(selectedDateRange!.end);

                                                            await updateTranLineSelective();

                                                            // After the update process, you can dismiss the loading spinner

                                                          } else {
                                                            showGlobalSnackbar(
                                                              '!',
                                                              'No Date Selected.',
                                                              Colors.red.shade900,
                                                              Colors.white,
                                                            );
                                                          }
                                                        },
                                                        child: Text('Sync'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        }
                                      } else {
                                        showGlobalSnackbar(
                                          'Connectivity',
                                          'Please connect to internet.',
                                          Colors.red.shade900,
                                          Colors.white,
                                        );
                                      }
                                    },


                                    child: Container(
                                      margin: EdgeInsets.only(left: 5),
                                      height: 100,
                                      width: MediaQuery.of(context).size.width /
                                              2 -
                                          30,
                                      decoration: BoxDecoration(
                                          color: Colors.orange[300],
                                          border: Border.all(
                                              color: Colors.transparent),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Stack(
                                        children: <Widget>[
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5, top: 5),
                                                child: !upTrans
                                                    ? Container(
                                                        child: Text(
                                                          'Click to Update',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      )
                                                    : Container(
                                                        width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                2 -
                                                            30,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: <Widget>[
                                                            Icon(
                                                              Icons
                                                                  .check_circle,
                                                              size: 25,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                margin: EdgeInsets.only(
                                                    left: 5, right: 5),
                                                width: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2 -
                                                    30,
                                                // color: Colors.grey,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.shopping_cart,
                                                      size: 50,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Transaction',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5, top: 5),
                                                child: Row(
                                                  children: <Widget>[
                                                    Text(
                                                      'Last Updated: ',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                    Text(
                                                      transLastUp,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 12,
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
                                ],
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  InkWell(
                                    onTap: ()async {
                                      await checkConnection();
                                      if (!NetworkData.errorMsgShow) {
                                        final action = await Dialogs.openDialog(
                                            context,
                                            'Confirmation',
                                            'Are you sure you want to update Masterfile?',
                                            false,
                                            'cancel',
                                            'confirm');
                                        if (action == DialogAction.yes) {

                                          GlobalVariables.updateType =
                                          'Item Masterfile';
                                          Spinkit.label =
                                          'Updating Item Masterfiles...';
                                          showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (context) =>
                                                  LoadingSpinkit());
                                          updateItemMasterfile();
                                        }else{
                                          Navigator.pop(context);
                                        }
                                      }

                                      else {
                                        showGlobalSnackbar(
                                            'Connectivity',
                                            'Please connect to internet.',
                                            Colors.red.shade900,
                                            Colors.white);
                                      }
                                    },
                                    child: Container(
                                      height: 100,
                                      width: MediaQuery.of(context).size.width /
                                              2 -
                                          30,
                                      decoration: BoxDecoration(
                                          color: Colors.blue[300],
                                          border: Border.all(
                                              color: Colors.transparent),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Stack(
                                        children: <Widget>[
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5, top: 5),
                                                child: !upItem
                                                    ? Container(
                                                        child: Text(
                                                          'Click to Update',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      )
                                                    : Container(
                                                        width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                2 -
                                                            30,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: <Widget>[
                                                            Icon(
                                                              Icons
                                                                  .check_circle,
                                                              size: 25,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                width: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2 -
                                                    30,
                                                margin: EdgeInsets.only(
                                                    left: 5, right: 5),
                                                // color: Colors.grey,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.local_offer,
                                                      size: 50,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Item',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5, top: 5),
                                                child: Row(
                                                  children: <Widget>[
                                                    Text(
                                                      'Last Updated: ',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                    Text(
                                                      itemLastUp,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 12,
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
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width - 40,
                          // color: Colors.grey,
                          child: Stack(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  InkWell(
                                    onTap: ()async {
                                      await checkConnection();
                                      if (!NetworkData.errorMsgShow) {
                                        final action = await Dialogs.openDialog(
                                            context,
                                            'Confirmation',
                                            'Are you sure you want to update Customer',
                                            false,
                                            'cancel',
                                            'confirm');
                                        if (action == DialogAction.yes) {

                                          GlobalVariables.updateType =
                                          'Customer Masterfile';
                                          Spinkit.label =
                                          'Updating Customer...';
                                          showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (context) =>
                                                  LoadingSpinkit());
                                          updateCustomer();
                                        }
                                        else{
                                         Navigator.pop(context);
                                        }
                                      }
                                        else {
                                          showGlobalSnackbar(
                                              'Connectivity',
                                              'Please connect to internet.',
                                              Colors.red.shade900,
                                              Colors.white);
                                        }

                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(left: 5),
                                      height: 100,
                                      width: MediaQuery.of(context).size.width /
                                              2 -
                                          30,
                                      decoration: BoxDecoration(
                                          color: Colors.green[300],
                                          border: Border.all(
                                              color: Colors.transparent),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Stack(
                                        children: <Widget>[
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5, top: 5),
                                                child: !upCust
                                                    ? Container(
                                                        child: Text(
                                                          'Click to Update',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      )
                                                    : Container(
                                                        width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                2 -
                                                            30,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: <Widget>[
                                                            Icon(
                                                              Icons
                                                                  .check_circle,
                                                              size: 25,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                width: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2 -
                                                    30,
                                                margin: EdgeInsets.only(
                                                    left: 5, right: 5),
                                                // color: Colors.grey,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.account_circle,
                                                      size: 50,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Customer',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5, top: 5),
                                                child: Row(
                                                  children: <Widget>[
                                                    Text(
                                                      'Last Updated: ',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                    Text(
                                                      custLastUp,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 12,
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
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  InkWell(
                                    onTap: ()async {
                                      await checkConnection();
                                      if (!NetworkData.errorMsgShow) {
                                        final action = await Dialogs.openDialog(
                                            context,
                                            'Confirmation',
                                            'Are you sure you want to update Salesman?',
                                            false,
                                            'cancel',
                                            'confirm');
                                        if (action == DialogAction.yes) {
                                          GlobalVariables.updateType =
                                          'Salesman';
                                          Spinkit.label =
                                          'Updating Salesman...';
                                          showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (context) =>
                                                  LoadingSpinkit());
                                          updateSalesman();
                                        }else{
                                          Navigator.pop(context);
                                        }
                                      }

                                      else {
                                        showGlobalSnackbar(
                                            'Connectivity',
                                            'Please connect to internet.',
                                            Colors.red.shade900,
                                            Colors.white);
                                      }
                                    },
                                    child: Container(
                                      height: 100,
                                      width: MediaQuery.of(context).size.width /
                                              2 -
                                          30,
                                      decoration: BoxDecoration(
                                          color: Colors.purple[300],
                                          border: Border.all(
                                              color: Colors.transparent),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Stack(
                                        children: <Widget>[
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5, top: 5),
                                                child: !upSm
                                                    ? Container(
                                                        child: Text(
                                                          'Click to Update',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      )
                                                    : Container(
                                                        width: MediaQuery.of(context).size.width / 2 - 30,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: <Widget>[
                                                            Icon(
                                                              Icons
                                                                  .check_circle,
                                                              size: 25,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                width: MediaQuery.of(context).size.width / 2 - 30,
                                                margin: EdgeInsets.only(
                                                    left: 5, right: 5),
                                                // color: Colors.grey,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.local_shipping,
                                                      size: 50,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Salesman',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5, top: 5),
                                                child: Row(
                                                  children: <Widget>[
                                                    Text(
                                                      'Last Updated: ',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                    Text(
                                                      smLastUp,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 12,
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
            ),
          ),
          Container(
            // height: 220,
            // height: 380,
            padding: EdgeInsets.only(left: 15, right: 15),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            // margin: EdgeInsets.only(left: 10, right: 10),
                            width: MediaQuery.of(context).size.width - 35,
                            height: 20,
                            color: ColorsTheme.mainColor,
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  height: 50,
                                  margin: EdgeInsets.only(left: 10),
                                  // color: ColorsTheme.mainColor,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'Download Log',
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 10,
                                            color: Colors.white),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            // margin: EdgeInsets.only(left: 10, right: 10),
                            width: MediaQuery.of(context).size.width - 35,
                            height: 30,
                            color: Colors.transparent,
                            child: Stack(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      height: 50,
                                      margin: EdgeInsets.only(left: 10),
                                      // color: Colors.grey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            'Date',
                                            style: TextStyle(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      height: 50,
                                      margin: EdgeInsets.only(right: 10),
                                      // color: Colors.grey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            'Type',
                                            style: TextStyle(),
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
                                      height: 50,
                                      margin: EdgeInsets.only(right: 10),
                                      // color: Colors.grey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            'Status',
                                            style: TextStyle(),
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
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width - 35,
                            // height: 120,
                            height:
                                MediaQuery.of(context).size.height / 2 - 100,
                            color: Colors.transparent,
                            child: ListView.builder(
                                padding: const EdgeInsets.only(top: 1),
                                itemCount: a.updateLog.length,
                                itemBuilder: (context, index) {
                                  Color contColor = Colors.white;
                                  Color fontColor = Colors.white;
                                  String conDate = '';
                                  DateTime x = DateTime.parse(a.updateLog[index]['date'].toString());
                                  // conDate = DateFormat("MMM. d, y ").format(x);
                                  conDate = DateFormat.yMMMd().add_jm().format(x);
                                  if (a.updateLog[index]['tb_categ'] == 'Transactions') {
                                    // contColor = Colors.orange[300];
                                    fontColor = Colors.orange.shade300;
                                  }
                                  if (a.updateLog[index]['tb_categ'] == 'Item Masterfile') {
                                    // contColor = Colors.blue[300];
                                    fontColor = Colors.blue.shade300;
                                  }
                                  if (a.updateLog[index]['tb_categ'] ==
                                      'Customer Masterfile') {
                                    // contColor = Colors.green[300];
                                    fontColor = Colors.green.shade300;
                                  }
                                  if (a.updateLog[index]['tb_categ'] ==
                                      'Salesman Masterfile') {
                                    // contColor = Colors.purple[300];
                                    fontColor = Colors.purple.shade300;
                                  }
                                  return Container(
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(bottom: 5),
                                          padding: EdgeInsets.all(10),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              35,
                                          // height: 50,
                                          color: contColor,
                                          child: Stack(
                                            children: <Widget>[
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            150,
                                                    child: Text(
                                                      conDate,
                                                      style: TextStyle(
                                                        color: fontColor,
                                                        fontSize: 11,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                      // overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                3 +
                                                            20),
                                                    child: Text(
                                                      a.updateLog[index]
                                                          ['tb_categ'],
                                                      style: TextStyle(
                                                        color: fontColor,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: <Widget>[
                                                  Text(
                                                    a.updateLog[index]['status'],
                                                    style: TextStyle(
                                                      color: fontColor,
                                                      fontSize: 12,
                                                      fontStyle:
                                                          FontStyle.italic,
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
          ),
        ],
      ),
    );
  }

  Container buildUploadCont() {
    if (_toList.isEmpty) {
      return Container(
        padding: EdgeInsets.only(left: 15, right: 15),
        width: MediaQuery.of(context).size.width,
        // color: ColorsTheme.mainColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.file_upload,
              size: 100,
              color: Colors.grey[500],
            ),
            Text(
              'You have no transaction for upload.',
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
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: 15, right: 15),
      child: ListView.builder(
        padding: const EdgeInsets.all(0),
        itemCount: _toList.length,
        itemBuilder: (context, index) {
          bool uploaded = false;
          if (_toList[index]['uploaded'] == 'FALSE') {
            uploaded = false;
          } else {
            uploaded = true;
          }
          amount = _toList[index]['tot_amt'];
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 8),
                  height: 80,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: Stack(children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 5,
                          height: 80,
                          color: ColorsTheme.mainColor,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 3 + 30,
                          // color: Colors.grey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Order # ' + _toList[index]['tran_no'],
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _toList[index]['store_name'],
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _toList[index]['date_req'],
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 60),
                                width: MediaQuery.of(context).size.width / 4,
                                // color: Colors.blueGrey,
                                padding: EdgeInsets.only(left: 5, right: 5),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      'Total Amount',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      formatCurrencyTot
                                          .format(double.parse(amount)),
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          // color: ColorsTheme.mainColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    SizedBox(
                                      height: 5,
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
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 105,
                          // color: Colors.grey,
                          padding: EdgeInsets.only(left: 5, right: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: 5,
                              ),
                              !uploading
                                  ? Text(
                                      !uploaded
                                          ? 'Uploaded'
                                          : 'Ready to Upload',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          color: !uploaded
                                              ? Colors.greenAccent
                                              : ColorsTheme.mainColor,
                                          fontSize: !uploaded ? 16 : 14,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : Container(
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            'Uploading...',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SpinKitFadingCircle(
                                            color: Colors.green,
                                            size: 25,
                                          ),
                                        ],
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Container buildOrderOption() {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width - 40,
      margin: EdgeInsets.only(top: 0, bottom: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new SizedBox(
            width: (MediaQuery.of(context).size.width - 45) / 2,
            height: 35,
            child: new ElevatedButton(
              style: raisedButtonStyleWhite,
              onPressed: () {
                setState(() {
                  viewSpinkit = true;
                  // loadProcessed();
                  OrderData.visible = true;
                  uploadPressed = true;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    text: TextSpan(
                      text: "Upload Data",
                      // recognizer: _tapGestureRecognizer,
                      style: TextStyle(
                        // fontSize: 15,
                        fontSize: ScreenData.scrWidth * .038,
                        fontWeight:
                            uploadPressed ? FontWeight.bold : FontWeight.normal,
                        decoration: TextDecoration.underline,
                        color:
                            uploadPressed ? ColorsTheme.mainColor : Colors.grey,
                      ),
                    ),
                  ),
                  Container(
                    // padding: EdgeInsets.all(5),
                    child: Icon(
                      Icons.file_upload,
                      color: Colors.green,
                      size: ScreenData.scrWidth * .06,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 2,
          ),
          new SizedBox(
            width: (MediaQuery.of(context).size.width - 45) / 2,
            height: 35,
            child: new ElevatedButton(
              style: raisedButtonStyleWhite,
              onPressed: () {
                setState(() {
                  viewSpinkit = true;
                  // loadPending();
                  // loadConsolidated();
                  // dispose();
                  OrderData.visible = false;
                  uploadPressed = false;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                      text: TextSpan(
                    text: "Download Data",
                    // recognizer: _tapGestureRecognizer,
                    style: TextStyle(
                      // fontSize: 15,
                      fontSize: ScreenData.scrWidth * .038,
                      fontWeight:
                          uploadPressed ? FontWeight.normal : FontWeight.bold,
                      decoration: TextDecoration.underline,
                      color:
                          uploadPressed ? Colors.grey : ColorsTheme.mainColor,
                    ),
                  )),
                  Container(
                    // padding: EdgeInsets.all(5),
                    child: Icon(
                      Icons.file_download,
                      color: Colors.yellowAccent,
                      // size: 24,
                      size: ScreenData.scrWidth * .06,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container buildStatusCont() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 20,
      color: Colors.red,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                NetworkData.errorMsg!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 10,
              ),
              SpinKitFadingCircle(
                color: Colors.white,
                size: 15,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container buildHeader() {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(
        "Sync",
        textAlign: TextAlign.right,
        style: TextStyle(
            color: ColorsTheme.mainColor,
            fontSize: 45,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}

