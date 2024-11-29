import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:salesmanapp/providers/sync_cap.dart';
import 'package:salesmanapp/providers/upload_count.dart';
// import 'package:salesman/providers/upload_length.dart';
import 'package:salesmanapp/userdata.dart';

class UploadingSpinkit extends StatefulWidget {
  @override
  _UploadingSpinkitState createState() => _UploadingSpinkitState();
}

class _UploadingSpinkitState extends State<UploadingSpinkit> {
  @override
  Widget build(BuildContext context) {
    // onWillPop: () => Future.value(false),
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        // child: confirmContent(context),
        child: loadingContent(context),
      ),
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
                  // 'Uploading ' +
                  //     GlobalVariables.uploadLength! +
                  //     ' transactions' +
                  //     '. . .',
                  context.watch<SyncCaption>().cap,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
                Text(
                  // 'Uploading ' +
                  //     GlobalVariables.uploadLength! +
                  //     ' transactions' +
                  //     '. . .',
                  '(' +
                      context.watch<UploadCount>().itmNo.toString() +
                      '/' +
                      GlobalVariables.uploadLength.toString() +
                      ')',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
                SpinKitCircle(
                  color: Colors.green,
                ),
              ],
            )),
      ],
    );
  }
}
