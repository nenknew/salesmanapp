class MonthlyCoveragePlan{
  static const tblMonthlyCoveragePlan = 'monthly_coverage_plan';
  static const colId                  = 'id';
  static const colSalesManCode        = 'sm_code';
  static const colCustomerCode        = 'customer_code';
  static const colDateSchedule        = 'date_sched';
  static const colStartedDate         = 'start_date';
  static const colEndDate             = 'end_date';
  static const colVisitStatus         = 'visit_status';

  late final int? id;
  late String? salesManCode;
  late String? customerCode;
  late String? dateSchedule;
  late String? startedDate;
  late String? endDate;
  late String? visitStatus;

  MonthlyCoveragePlan(
      {this.id,
        this.salesManCode,
        this.customerCode,
        this.dateSchedule,
        this.startedDate,
        this.endDate,
        this.visitStatus});

  MonthlyCoveragePlan.fromMap(Map<String, dynamic> map) {
    id              = map[colId];
    salesManCode    = map[colSalesManCode];
    customerCode    = map[colCustomerCode];
    dateSchedule    = map[colDateSchedule];
    startedDate     = map[colStartedDate];
    endDate         = map[colEndDate];
    visitStatus     = map[colVisitStatus];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colSalesManCode : salesManCode,
      colCustomerCode : customerCode,
      colDateSchedule : dateSchedule,
      colStartedDate  : startedDate,
      colEndDate      : endDate,
      colVisitStatus  : visitStatus,
    };
    map[colId] = id;
    return map;
  }
}
