

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:salesmanapp/db/db_helper.dart';

import 'package:salesmanapp/providers/sync_cap.dart';
// import 'package:salesman/url/url.dart';
import 'package:salesmanapp/userdata.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../providers/caption_provider.dart';
import '../widgets/snackbar.dart';

class SyncLoadingSpinkit extends StatefulWidget {
  @override
  _SyncLoadingSpinkitState createState() => _SyncLoadingSpinkitState();
}

class _SyncLoadingSpinkitState extends State<SyncLoadingSpinkit>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;

  final db = DatabaseHelper();

  bool loadSpinkit = false;
  List itemList = [];
  List categList = [];
  List itemImgList = [];
  List customerList = [];
  List discountList = [];
  List bankList = [];
  List accessList = [];
  List salesmanList = [];
  List orderLimitList = [];
  List tranHeadList = [];
  List returnList = [];
  List unsrvlist = [];
  List chequeList = [];
  List linelist = [];
  List hepeList = [];
  List salesmanPrincipal = [];
  List transactions = [];

  final date = DateFormat("yyyy-MM-dd HH:mm:ss").format(new DateTime.now());

  @override
  void dispose() {
    // TODO: implement dispose
    animationController!.dispose();
    super.dispose();

  }
  void initState() {
    super.initState();
    animationController = new AnimationController(
        vsync: this, duration: const Duration(seconds: 1));
    if (GlobalVariables.updateType == 'Transactions') {
      if (GlobalVariables.fullSync == true) {
        print('NISUD SA FULL SYNC');
        updateTransactions();
      } else {
        print('NISUD SA SELECTIVE albeth');
        updateSelectiveTransactions();
      }
    }
    if (GlobalVariables.updateType == 'Item Masterfile') {
      updateItemMasterfile();
    }
    if (GlobalVariables.updateType == 'Customer Masterfile') {
      updateCustomer();
    }
    if (GlobalVariables.updateType == 'Salesman Masterfile') {
      updateSalesman();
    }
  }

  updateTransactions() async {
    //RETURNED TRAN LIST
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Returned List...');
    List retlist = await db.getReturnedTranList(context);
    returnList = retlist;
    if (returnList.isNotEmpty) {
      int v = 0;
      returnList.forEach((element) async {
        if (v < returnList.length) {
          v++;
          if (v == returnList.length) {
            await db.deleteTable('tb_returned_tran');
            await db.insertTableTbReturnedTran(returnList);
            await db.updateTable('tb_returned_tran', date.toString());
            print('RETURNED TRAN Updated');
            updateTranUnserved();
            // updateTranLine();
          }
        }
      });
    } else {
      print('EMPTY RETURN LIST');
      await db.deleteTable('tb_returned_tran');
      updateTranUnserved();
      // updateTranLine();
    }
  }

  updateTranUnserved() async {
    //RETURNED/UNSERVED LIST
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Unserved List...');
    var uslist = await db.getUnservedList(context);
    unsrvlist = uslist;
    if (unsrvlist.isNotEmpty) {
      int w = 0;
      unsrvlist.forEach((element) async {
        if (w < unsrvlist.length) {
          w++;
          if (w == unsrvlist.length) {
            await db.deleteTable('tb_unserved_items');
            await db.insertTableTbUnservedItems(unsrvlist);
            await db.updateTable('tb_unserved_items', date.toString());
            print('Unserved/Returned List Updated');
            // updateTranCheque();
            updateTranLine();
          }
        }
      });
    } else {
      print('EMPTY UNSERVED LIST');
      await db.deleteTable('tb_unserved_items');
      updateTranLine();
    }
  }

  // updateTranCheque() async {
  //   //CHEQUE DATA UPDATE
  //   var chqdata = await db.getChequeList();
  //   chequeList = chqdata;
  //   if (chequeList.isNotEmpty) {
  //     int x = 1;
  //     chequeList.forEach((element) async {
  //       if (x < chequeList.length) {
  //         x++;
  //         if (x == chequeList.length) {
  //           await db.deleteTable('tb_cheque_data');
  //           await db.insertTable(chequeList, 'tb_cheque_data');
  //           await db.updateTable('tb_cheque_data', date.toString());
  //           print('Cheque Data List Created');
  //         }
  //       }
  //     });
  //   } else {
  //     print('EMPTY CHEQUE LIST');
  //     await db.deleteTable('tb_cheque_data');
  //   }

  // }

  updateTranLine() async {
    //LINE UPDATE
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Transaction Items...');
    var linersp = await db.getTranLine(context);
    linelist = linersp;
    if (linelist.isNotEmpty) {
      int y = 1;
      linelist.forEach((element) async {
        if (y < linelist.length) {
          y++;
          if (y == linelist.length) {
            await db.deleteTable('tb_tran_line');
            await db.insertTableTbTranLine(linelist);
            await db.updateTable('tb_tran_line', date.toString());
            print('Transaction Line Created');
            updateTranHead();
          }
        }
      });
    } else {
      print('EMPTY TRANSACTION LINE');
      await db.deleteTable('tb_tran_line');
      updateTranHead();
    }
  }

  updateTranHead() async {
    //TRAN UPDATE
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Transactions Head...');
    print(UserData.position);
      var thead = await db.getTranHead(context, UserData.id.toString());
      tranHeadList = thead;


    if (tranHeadList.isNotEmpty) {
      int z = 0;
      tranHeadList.forEach((element) async {
        if (z < tranHeadList.length) {
          z++;
          // print(tranHeadList.length);
          if (z == tranHeadList.length) {
            await db.deleteTable('tb_tran_head');
            await db.insertTableTbTranHead(tranHeadList);
            await db.updateTable('tb_tran_head ', date.toString());
            await db.addUpdateTableLog(date.toString(), GlobalVariables.updateType, 'Completed', GlobalVariables.updateBy);
            print('Transaction Head Created 202');
            GlobalVariables.updateSpinkit = true;
          }
        }
      });
    } else {
      print('EMPTY TRANSACTION HEAD 208');
      await db.deleteTable('tb_tran_head');
      GlobalVariables.updateSpinkit = true;
    }
  }

  /////////////////////////SELECTIVE UPDATE TRANSACTIONS
  ///
  updateSelectiveTransactions() async {
    //RETURNED TRAN LIST

    print('Updating Selective Transactions');
    print(GlobalVariables.syncStartDate);
    print(GlobalVariables.syncEndDate);
    Provider.of<SyncCaption>(context, listen: false).changeCap('Updating Returned List...');
    var retlist = await db.getReturnedTranListSelective(
        context,
        GlobalVariables.syncStartDate.toString(),
        GlobalVariables.syncEndDate.toString());
    print("retlist RESPONSE :: ${retlist}");

    if (returnList.isNotEmpty) {
      // setState(() {
        returnList = retlist;
      // });
      int v = 0;
      returnList.forEach((element) async {
        if (v < returnList.length) {
          v++;
          if (v == returnList.length) {
            await db.deleteTable('tb_returned_tran');
            print("INSERTING DATA IN TB_RETURN_TRAN");
            await db.insertTableTbReturnedTran(returnList);
            await db.updateTable('tb_returned_tran', date.toString());
            print('RETURNED TRAN Updated');
            updateTranUnservedSelective();
          }
        }
      });
    } else {
      print('EMPTY RETURN LIST');
      await db.deleteTable('tb_returned_tran');
      updateTranUnservedSelective();
    }
    // await db.deleteTable('tb_returned_tran');
    // updateTranUnservedSelective();
  }

  updateTranUnservedSelective() async {
    //RETURNED/UNSERVED LIST
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Unserved List...');
    var uslist = await db.getUnservedListSelective(
        context,
        GlobalVariables.syncStartDate.toString(),
        GlobalVariables.syncEndDate.toString());
    unsrvlist = uslist;
    if (unsrvlist.isNotEmpty) {
      int w = 0;
      unsrvlist.forEach((element) async {
        if (w < unsrvlist.length) {
          w++;
          if (w == unsrvlist.length) {
            await db.deleteTable('tb_unserved_items');
            await db.insertTableTbUnservedItems(unsrvlist);
            await db.updateTable('tb_unserved_items', date.toString());
            print('Unserved/Returned List Updated');
            // updateTranCheque();
            updateTranLineSelective();
          }
        }
      });
      // updateTranLineSelective();
    } else {
      print('EMPTY UNSERVED LIST');
      await db.deleteTable('tb_unserved_items');
      updateTranLineSelective();
    }
  }

  updateTranLineSelective() async {
    //LINE UPDATE
    print("hey updateTranLineSelective");
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Transaction...');
    var linersp = await db.getTranLineSelective(
        context,
        // UserData.division.toString(),
        UserData.id.toString(),// gichange na ug smcode sa tranhead para magmatch ang syncing ug data
        GlobalVariables.syncStartDate.toString(),
        GlobalVariables.syncEndDate.toString());
    print("TEST :: $linersp");
    linelist = linersp;
    print("USERDATA Division :: ${UserData.division}");
    print(linelist);
    if (linelist.isNotEmpty) {

      await db.deleteTable('tb_tran_line');
      await db.insertTableTbTranLine(linelist);

      await db.updateTable('tb_tran_line', date.toString());
      print('Transaction Line Created');
      updateTranHeadSelective();
    } else {
      print('EMPTY TRANSACTION LINE');
      await db.deleteTable('tb_tran_line');
      updateTranHeadSelective();
    }
  }

  updateTranHeadSelective() async {
    //TRAN UPDATE
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Transactions...');
    print("USER POSITION ${UserData.position}");
    if (UserData.position == 'Salesman') {
      var thead = await db.getTranHeadSelective(
          context,
          UserData.id.toString(),
          GlobalVariables.syncStartDate.toString(),
          GlobalVariables.syncEndDate.toString());
      print("asa ani $thead");
      tranHeadList = thead;
    }

    if (tranHeadList.isNotEmpty) {
      // int z = 0;
      // tranHeadList.forEach((element) async {
      //   if (z < tranHeadList.length) {
      //     z++;
      //     // print(tranHeadList.length);
      //     if (z == tranHeadList.length) {
      //       print("Z :: $z");
      //       print("tranHeadList Length :: ${tranHeadList.length}");
      //       print("tranHeadList :: $tranHeadList");
      //       await db.deleteTable('tb_tran_head');
      //       await db.insertTableTbTranHead(tranHeadList);
      //       await db.updateTable('tb_tran_head ', date.toString());
      //       await db.addUpdateTableLog(
      //           date.toString(),
      //           GlobalVariables.updateType,
      //           'Completed',
      //           GlobalVariables.updateBy);
      //       print('Transaction Head Created 357');
      //       // insertUpdatePayments(tranHeadList);
      //       updateArTransactions();
      //     }
      //   }
      // });
      await db.deleteTable('tb_tran_head');
      await db.insertTableTbTranHead(tranHeadList);
      await db.updateTable('tb_tran_head ', date.toString());
      await db.addUpdateTableLog(
          date.toString(),
          GlobalVariables.updateType,
          'Completed',
          GlobalVariables.updateBy);
      print('Transaction Head Created 357');
      // insertUpdatePayments(tranHeadList);
      updateArTransactions();
    } else {
      print('EMPTY TRANSACTION HEAD 366');
      await db.deleteTable('tb_tran_head');
      updateArTransactions();
      // GlobalVariables.updateSpinkit = true;
      // Future.delayed(Duration(seconds: 2),(){
      //   Navigator.pop(context);
      // });
    }
  }

  updateArTransactions()
  async{
    await db.deleteArHead();
    await db.deleteArLine();
    // await db.deleteTbunserved(); // Partial para empty and table sa unserved
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Fetching Transactions...');
    Map res = await db.getArTransactions();
    int ctr = 0;
    if(res['tranhead'].isNotEmpty)
      {
        await db.insertArTranHead(res['tranhead']);
        // for(var element in res['tranhead']){
          await db.insertArTranLine(res['tranline']);
        //   ctr++;
        // }
      }
    successModal();
    // String updateType = 'Jefe';

  }

  successModal() // tawgon ni sya kadahuman sync
  async{
    List rsp = await db.ofFetchUpdateLog(GlobalVariables.updateBy);
    print('ag rsp kay $rsp');
    if(rsp.isNotEmpty)
    {
      print('nisud ani');
      Provider.of<Caption>(context, listen: false).updateLogs(rsp);
    }
    CoolAlert.show(
        context: context,
        type: CoolAlertType.success,
        text: "Successfuly Sync",
        cancelBtnText: 'Cancel',
        cancelBtnTextStyle: TextStyle(color: Colors.green),
        showCancelBtn: false,
        autoCloseDuration: Duration(seconds: 2),
        onConfirmBtnTap: () {
          Navigator.canPop(context);
        }
    );
    GlobalVariables.updateSpinkit = true;
    Future.delayed(Duration(seconds: 2),(){
      Navigator.pop(context);
      // SyncHepe().createState().loadUpdateLog();
    });

  }

//////////////////////////////////////////
/////////////////////
  updateItemMasterfile() async {
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Item Images...');
    var rsp = await db.getItemImgList(context);
    itemImgList = rsp;
    int x = 0;
    itemImgList.forEach((element) async {
      if (x < itemImgList.length) {
        x++;
        if (x == itemImgList.length) {
          await db.insertItemImgList(itemImgList);
          await db.updateTable('tbl_item_image', date.toString());
          print('Item Image List Updated');
          updateItemCateg();
        }
      }
    });
  }

  updateItemCateg() async {
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Categories...');
    // //CATEGORY
    var rsp1 = await db.getCategList(context);
    categList = rsp1;
    int y = 0;
    categList.forEach((element) async {
      if (y < categList.length) {
        // print(element);
        // final imgBase64Str = await networkImageToBase64(
        //     UrlAddress.categImg + element['category_image']);
        // setState(() {
        // element['category_image'] = imgBase64Str;
        // });
        y++;
        if (y == categList.length) {
          await db.deleteTable('tbl_category_masterfile');
          await db.updateCategList(categList);
          await db.updateTable('tbl_category_masterfile', date.toString());
          print('Categ List Updated');
          updateItemList();
        }
      }
    });
  }

  updateItemList() async {
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Item List...');
    var resp = await db.getItemList(context,UserData.username);
    itemList = resp;
    print('ang item list$itemList');
        if(itemList.isNotEmpty || itemList != Null){
          await db.deleteTable('item_masterfiles');
          await db.insertItemList(itemList);
          await db.updateTable('item_masterfiles', date.toString());
          await db.addUpdateTableLog(
              date.toString(),
              GlobalVariables.updateType,
              'Completed',
              GlobalVariables.updateBy);
          print('Item Masterfile Updated');
          successModal();
          // GlobalVariables.updateSpinkit = true;
        }
      else{
          showGlobalSnackbar(
            '!',
            'No Data Found',
            Colors.red.shade900,
            Colors.white,
          );
        }

  }

  updateCustomer() async {
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Discount List...');
    var rsp = await db.getDiscountList(context);
    discountList = rsp;
    int x = 1;
    discountList.forEach((element) async {
      if (x < discountList.length) {
        x++;
        if (x == discountList.length) {
          await db.deleteTable('tbl_discounts');
          await db.insertDiscountList(discountList);
          await db.updateTable('tbl_discounts ', date.toString());
          print('Discount List Created');
          updateCustomerBank();
        }
      }
    });
  }

  updateCustomerBank() async {
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Bank List...');
    var rsp1 = await db.getBankListonLine(context);
    bankList = rsp1;
    int y = 1;
    bankList.forEach((element) async {
      if (y < bankList.length) {
        y++;
        if (y == bankList.length) {
          await db.deleteTable('tb_bank_list');
          await db.insertBankList(bankList);
          await db.updateTable('tb_bank_list', date.toString());
          print('Bank List Created');
          // updateUserAccess();
          updateCustomerList();
        }
      }
    });
  }

  updateUserAccess() async {
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating User Access...');
    var rsp1 = await db.getUserAccessonLine(context);
    accessList = rsp1;
    int y = 1;
    accessList.forEach((element) async {
      if (y < accessList.length) {
        y++;
        if (y == accessList.length) {
          await db.deleteTable('user_access');
          await db.insertAccessList(accessList);
          await db.updateTable('tb_bank_list', date.toString());
          print('User Access Created');
          updateCustomerList();
        }
      }
    });
  }

  updateCustomerList() async {
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Customer List...');
    print(UserData.id);

    var resp = await db.getCustomersList(context, UserData.username);
    if (resp != null && resp is List) {
      customerList = resp;
    } else {
      customerList = []; // Assign an empty list if response is null or not a list
    }
print('ang customer$customerList');
     if(customerList.isNotEmpty || customerList != Null){
       await db.deleteTable('customer_master_files');
       await db.insertCustomersList(customerList);
       await db.updateTable('customer_master_files ', date.toString());
       await db.addUpdateTableLog(
           date.toString(),
           GlobalVariables.updateType,
           'Completed',
           GlobalVariables.updateBy);
       print('Customer List Created');
       successModal();
       // GlobalVariables.updateSpinkit = true;
       // Navigator.pop(context);

     }else{
     showGlobalSnackbar(
     '!',
     'No Data Found',
     Colors.red.shade900,
     Colors.white,
     );
     }

  }

  updateSalesman() async {
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Salesman List...');
    var resp = await db.getSalesmanList(context);
    salesmanList = resp;
    int y = 1;
    salesmanList.forEach((element) async {
      if (y < salesmanList.length) {
        y++;
        if (y == salesmanList.length) {
          await db.deleteTable('salesman_lists');
          await db.insertSalesmanList(salesmanList);
          await db.updateTable('salesman_lists ', date.toString());
          // await db.addUpdateTableLog(
          //     date.toString(),
          //     GlobalVariables.updateType,
          //     'Completed',
          //     GlobalVariables.updateBy);
          print('Salesman List Created');
          updateOrderLimit();
        }
      }
    });
  }

  updateOrderLimit() async {
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Order Limit List...');
    var resp = await db.getOrderLimitonLine(context);
    orderLimitList = resp;
    int y = 1;
    orderLimitList.forEach((element) async {
      if (y < orderLimitList.length) {
        y++;
        if (y == orderLimitList.length) {
          await db.deleteTable('tbl_order_limit');
          await db.insertOrderLimitList(orderLimitList);
          await db.updateTable('tbl_order_limit ', date.toString());
          // await db.addUpdateTableLog(
          //     date.toString(),
          //     GlobalVariables.updateType,
          //     'Completed',
          //     GlobalVariables.updateBy);
          print('Order Limit Created');
          updateSalesmanPrincipal();
        }
      }
    });
  }

  updateSalesmanPrincipal() async {
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Salesman Principal...');
    var resp = await db.getSalesmanPrincipal(context,UserData.username);
    salesmanPrincipal = resp;
    print('ang principal$salesmanPrincipal');

        if (salesmanPrincipal.isNotEmpty || salesmanPrincipal != Null) {
          await db.deleteTable('tbl_principals');
          print("InsertIntoSalesman");
          await db.insertSalesmanPrincipal(salesmanPrincipal);
          await db.addUpdateTableLog(
              date.toString(),
              GlobalVariables.updateType,
              'Completed',
              GlobalVariables.updateBy);
          print('SALESMAN PRINCIPAL UPDATED');
          GlobalVariables.updateSpinkit = true;
          successModal();
          // updateConsolidatedTransactions();
        }
        else{
          showGlobalSnackbar(
            '!',
            'No Data Founds',
            Colors.red.shade900,
            Colors.white,
          );
        }

  }

  updateConsolidatedTransactions()async{
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Consolidated Transactions...');
    var resp = await db.getConsolidatedTrans(context);
    transactions = resp;
    int y = 1;
    transactions.forEach((element) async {
      if (y < transactions.length) {
        y++;
        if (y == transactions.length) {
          await db.deleteTable('consolidated_transactions');
          await db.insertConsolidatedTrans(transactions);
          await db.addUpdateTableLog(
              date.toString(),
              GlobalVariables.updateType,
              'Completed',
              GlobalVariables.updateBy);
          print('CONSOLIDATED TRANSACTIONS UPDATED');
          GlobalVariables.updateSpinkit = true;
          //updateJefe();
        }
      }
    });
  }



  Future<String> networkImageToBase64(String imageUrl) async {
    var imgUri = Uri.parse(imageUrl);
    http.Response response = await http.get(imgUri);
    final bytes = response.bodyBytes;
    // return (bytes != null ? base64Encode(bytes) : null);
    return (base64Encode(bytes));
  }

  @override
  Widget build(BuildContext context) {
    // onWillPop: () => Future.value(false),
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
            // width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: 50, bottom: 16, right: 5, left: 5),
            margin: EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.transparent,
                    // blurRadius: 10.0,
                    // offset: Offset(0.0, 10.0),
                  ),
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  // 'Updating ' + GlobalVariables.updateType + ' . . .',
                  // Provider.of<SyncCaption>(context).cap,
                  context.watch<SyncCaption>().cap,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
                SpinKitCircle(
                  controller: animationController,
                  color: Colors.yellowAccent,
                ),
              ],
            )),
      ],
    );
  }
}
