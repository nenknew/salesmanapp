import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class PreviewPayment extends StatefulWidget {
  final payments;
  const PreviewPayment({Key? key, this.payments}) : super(key: key);

  @override
  State<PreviewPayment> createState() => _PreviewPaymentState();
}

class _PreviewPaymentState extends State<PreviewPayment> {

  final formatCurrency = new NumberFormat.currency(locale: "en_US", symbol: "Php ");
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
Container fields(texts, text){
  return Container(
    width: MediaQuery.of(context).size.width * .70,
    height: MediaQuery.of(context).size.height * .06,
    child: Padding(
      padding: EdgeInsets.only(left: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Icon(Icons.payment, size: 30,),
          Text('$texts', style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),),
          VerticalDivider(),
          Text('$text', style: TextStyle(fontSize: 16),)
        ],
      ),
    ),
    decoration: BoxDecoration(
        color: Colors.orangeAccent,
        borderRadius: BorderRadius.circular(5)
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * .80,
        height: MediaQuery.of(context).size.height * .60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            fields('Payment Type:', widget.payments['cheque_no'] =='' ? 'CASH' : 'CHEQUE'),
            fields('TR No:', widget.payments['tran_no']=='' ? 'General Payment' : widget.payments['tran_no']),
            fields('SI No:', widget.payments['tran_no']=='' ? 'General Payment' : widget.payments['sales_invoice']),
            fields('Amount:',formatCurrency.format(double.parse(widget.payments['amount']))),
            fields('Tax:',formatCurrency.format(double.parse(widget.payments['tax']))),
            fields('Balance:',formatCurrency.format(double.parse(widget.payments['balance']))),
            fields('Date Paid:',formatter.format(DateTime.parse(widget.payments['payment_date']))),
            fields('Jefe-Code:',widget.payments['jefe_code']),
            fields('Account-Code:',widget.payments['account_code']),
          ],
        ),
      ),
    );
  }
}
