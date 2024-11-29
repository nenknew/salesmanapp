class PaymentTerms{
  static const tblPaymentTerms = "payment_terms";
  static const colId           = "id";
  static const colDivision     = "division";
  static const colPaymentTerms = "payment_terms";

  late int? id;
  late String? division;
  late String? paymentTerms;

  PaymentTerms({this.id, this.division, this.paymentTerms});

  PaymentTerms.fromMap(Map<String, dynamic> map) {
    id            = map[colId];
    division      = map[colDivision];
    paymentTerms  = map[colPaymentTerms];
  }

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      colDivision     : division,
      colPaymentTerms : paymentTerms,
    };
    map[colId] = id;
    return map;
  }
}