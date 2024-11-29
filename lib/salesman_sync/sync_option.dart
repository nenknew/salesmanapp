import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salesmanapp/dialogs/confirm_sync.dart';
import 'package:salesmanapp/userdata.dart';
import 'package:salesmanapp/variables/colors.dart';
import 'package:salesmanapp/widgets/elevated_button.dart';
import 'package:salesmanapp/widgets/snackbar.dart';

class SyncOption extends StatefulWidget {
  const SyncOption({Key? key}) : super(key: key);

  @override
  State<SyncOption> createState() => _SyncOptionState();
}

class _SyncOptionState extends State<SyncOption> {
  bool viewDtpicker = false;

  DateTime startDate = DateTime.now().subtract(Duration(days: 15));
  DateTime endDate = DateTime.now();

  String stoday = DateFormat("MMM. dd, yyyy")
      .format(new DateTime.now().subtract(Duration(days: 15)));
  String etoday = DateFormat("MMM. dd, yyyy").format(new DateTime.now());

  void initState() {
    super.initState();
  }

  _pickStartDate() async {
    // GlobalVariables.syncStartDate = DateTime.now();
    DateTime? dt = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (dt != null)
      setState(() {
        startDate = dt;
        stoday = DateFormat("MMM. dd, yyyy").format(dt);
        GlobalVariables.syncStartDate = DateFormat("yyyy-MM-dd").format(dt);
      });
  }

  _pickEndDate() async {
    print('bed');
    // startDate = DateTime.now();
    DateTime? dt = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (dt != null)
      setState(() {
        endDate = dt;
        etoday = DateFormat("MMM. dd, yyyy").format(dt);
        // GlobalVariables.syncStartDate = DateFormat("yyyy-MM-dd").format(dt);
        GlobalVariables.syncEndDate = DateFormat("yyyy-MM-dd").format(dt);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            children: [
              // Text(
              //   'Select Sync Option',
              //   style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              // ),
              SizedBox(height: 10),
              // Container(
              //   width: MediaQuery.of(context).size.width / 2 + 40,
              //   height: 70,
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(5),
              //   ),
              //   child: Column(
              //     children: [
              //       ElevatedButton(
              //         style: syncButtonDialogStyle,
              //         onPressed: () {
              //           GlobalVariables.fullSync = true;
              //           Navigator.pop(context);
              //           if (!NetworkData.errorMsgShow) {
              //             showDialog(
              //                 context: context,
              //                 builder: (context) => ConfirmDialog(
              //                       title: 'Confirmation',
              //                       description:
              //                           'Are you sure you want to update transactions?',
              //                       buttonText: 'Confirm',
              //                     ));
              //           } else {
              //             showGlobalSnackbar(
              //                 'Connectivity',
              //                 'Please connect to internet.',
              //                 Colors.red.shade900,
              //                 Colors.white);
              //           }
              //         },
              //         child: Text(
              //           '  Full Sync  ',
              //           style: TextStyle(color: Colors.white, fontSize: 24),
              //         ),
              //       ),
              //       Text(
              //         'Note: Full Sync might take a while. Secure a strong connection.',
              //         style:
              //             TextStyle(fontSize: 8, fontWeight: FontWeight.w300),
              //       ),
              //     ],
              //   ),
              // ),
              // Divider(thickness: 1,),
              Visibility(
                  visible: viewDtpicker,
                  child: Container(
                    // height: 60,
                    width: MediaQuery.of(context).size.width / 2 + 40,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              // color: ColorsTheme.mainColor,
                              decoration: BoxDecoration(
                                  color: ColorsTheme.mainColor,
                                  border: Border.all(
                                      color: ColorsTheme.mainColor, width: 2),
                                  borderRadius: BorderRadius.circular(0)),
                              padding: EdgeInsets.all(5),
                              child: Text(
                                'Start Date :',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _pickStartDate();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: ColorsTheme.mainColor, width: 2),
                                    borderRadius: BorderRadius.circular(0)),
                                padding: EdgeInsets.all(5),
                                child: Row(
                                  children: [
                                    Text(
                                      stoday,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: ColorsTheme.mainColor,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Container(
                                      color: Colors.grey,
                                      child: Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              // color: ColorsTheme.mainColor,
                              decoration: BoxDecoration(
                                  color: ColorsTheme.mainColor,
                                  border: Border.all(
                                      color: ColorsTheme.mainColor, width: 2),
                                  borderRadius: BorderRadius.circular(0)),
                              padding: EdgeInsets.all(5),
                              child: Text(
                                'End Date :',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _pickEndDate();
                              },
                              child: Container(
                                // color: ColorsTheme.mainColor,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: ColorsTheme.mainColor, width: 2),
                                    borderRadius: BorderRadius.circular(0)),
                                padding: EdgeInsets.all(5),
                                child: Row(
                                  children: [
                                    Text(
                                      etoday,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: ColorsTheme.mainColor,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Container(
                                      color: Colors.grey,
                                      child: Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )),
              SizedBox(height: 10),
              Container(
                width: MediaQuery.of(context).size.width / 2 + 40,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  children: [
                    ElevatedButton(
                      style: syncButtonStyleWhite,
                      onPressed: () {
                        if (viewDtpicker == false) {
                          setState(() {
                            viewDtpicker = true;
                          });
                        } else {
                          GlobalVariables.fullSync = false;
                          Navigator.pop(context);
                          if (!NetworkData.errorMsgShow) {
                            showDialog(
                                context: context,
                                builder: (context) => ConfirmDialog(
                                      title: 'Confirmation',
                                      description:
                                          'Are you sure you want to update transactions?',
                                      buttonText: 'Confirm',
                                    ));
                          } else {
                            showGlobalSnackbar(
                                'Connectivity',
                                'Please connect to internet.',
                                Colors.red.shade900,
                                Colors.white);
                          }
                        }
                      },
                      child: Text(
                        'Selective Sync',
                        style: TextStyle(
                            color: ColorsTheme.mainColor, fontSize: 24),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
