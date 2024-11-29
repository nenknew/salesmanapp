import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:retry/retry.dart';
import 'package:salesmanapp/encrypt/enc.dart';
import 'package:salesmanapp/models/monthly_coverage_plan_Model.dart';
import 'package:salesmanapp/models/payment_terms.dart';
import 'package:salesmanapp/widgets/custom_modals.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:salesmanapp/home/url/url.dart';
import 'package:salesmanapp/userdata.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _database;
  //TEST VERSION
  // static final _dbName = 'TEST04.db';
  //LIVE VERSION
  static final _dbName = 'DISTRIBUTION3.db';
  static final _dbVersion = 3;

  String globaldate =
      DateFormat("yyyy-MM-dd HH:mm:ss").format(new DateTime.now());

  DatabaseHelper._();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get db async {
    if (_database != null) return _database!;

    _database = await init();
    return _database!;
  }

  Future<Database> init() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String dbPath = join(directory.path, _dbName);
    var database =
        openDatabase(dbPath, version: _dbVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);

    return database;
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async{
    print('ag mga version $oldVersion ug new $newVersion');
    if (oldVersion < newVersion) {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS ${MonthlyCoveragePlan.tblMonthlyCoveragePlan}(
        ${MonthlyCoveragePlan.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${MonthlyCoveragePlan.colSalesManCode} TEXT NOT NULL,
        ${MonthlyCoveragePlan.colCustomerCode} TEXT NOT NULL,
        ${MonthlyCoveragePlan.colDateSchedule} TEXT NOT NULL,
        ${MonthlyCoveragePlan.colStartedDate} TEXT NOT NULL,
        ${MonthlyCoveragePlan.colEndDate} TEXT NOT NULL,
        ${MonthlyCoveragePlan.colVisitStatus} TEXT NOT NULL
      )
    ''');

      await db.execute('''
      CREATE TABLE IF NOT EXISTS ${PaymentTerms.tblPaymentTerms}(
        ${PaymentTerms.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${PaymentTerms.colDivision} TEXT NOT NULL,
        ${PaymentTerms.colPaymentTerms} TEXT NOT NULL
      )
    ''');

      //vers 1.1.7
      await db.execute('ALTER TABLE payments ADD COLUMN tax TEXT DEFAULT "" ');
    }

  }

  void _onCreate(Database db, int version) {
    db.execute('''
      CREATE TABLE myTable( 
        id INTEGER PRIMARY KEY,
        name TEXT)
       ''');

    ///CUSTOMER_MASTER_FILES
    db.execute('''
      CREATE TABLE customer_master_files(
        doc_no INTEGER PRIMARY KEY,
        customer_id TEXT,
        location_name TEXT,
        address1 TEXT,
        address2 TEXT,
        address3 TEXT,
        postal_address TEXT,
        account_group_code TEXT,
        account_group_name TEXT,
        account_code TEXT,
        account_name TEXT,
        account_description TEXT,
        account_credit_limit TEXT,
        account_classification_id TEXT,
        payment_type TEXT,
        salesman_code TEXT,
        status TEXT,
       cheque_stat TEXT,
        cus_mobile_number TEXT,
        cus_password TEXT)''');
    db.execute('''CREATE INDEX cust_idx 
      ON customer_master_files 
      (customer_id, 
      customer_id,
      location_name, 
      account_group_code, 
      account_group_name, 
      account_code, 
      account_name, 
      account_description, 
      account_credit_limit,
      account_classification_id,
      payment_type,
      salesman_code,
      status)
    ''');
    ///ITEM MASTERFILE
    db.execute('''
      CREATE TABLE item_masterfiles(
        doc_no INTEGER PRIMARY KEY,
        item_masterfiles_id TEXT,
        product_name TEXT,
        company_code TEXT,
        itemcode TEXT,
        principal TEXT,
        product_family TEXT,
        uom TEXT,
        list_price_wtax TEXT,
        conversion_qty TEXT,
        isPromo TEXT,
        image TEXT,
        status TEXT,
        isMust TEXT)''');

    db.execute('''CREATE INDEX items_idx 
      ON item_masterfiles 
      (itemcode, product_name, company_code, principal, product_family, uom, isPromo, isMust)
    ''');

    //ITEM IMAGE MASTERFILE
    db.execute('''
      CREATE TABLE tbl_item_image(
        doc_no INTEGER PRIMARY KEY,
        id TEXT,
        item_code TEXT,
        item_uom TEXT,
        item_path TEXT,
        image TEXT,
        created_at TEXT,
        updated_at TEXT)''');
    //or CLOB

    //ITEM CATEGORY MASTERFILE
    db.execute('''
      CREATE TABLE tbl_category_masterfile(
        doc_no INTEGER PRIMARY KEY,
        id TEXT,
        category_name TEXT,
        category_image TEXT)''');

    ///SALESMAN_LISTS
    db.execute('''
      CREATE TABLE salesman_lists(
        doc_no INTEGER PRIMARY KEY,
        id TEXT,
        username TEXT,
        password TEXT,
        first_name TEXT,
        last_name TEXT,
        department TEXT,
        division TEXT,
        area TEXT,
        district TEXT,
        title TEXT,
        product_line TEXT,
        address TEXT,
        postal_code TEXT,
        email TEXT,
        telephone TEXT,
        mobile TEXT,
        user_code TEXT,
        status TEXT,
        password_date TEXT,
        img TEXT)''');

    ///HEJE DE VIAJE TABLE
    db.execute('''
      CREATE TABLE tbl_hepe_de_viaje(
        doc_no INTEGER PRIMARY KEY,
        id TEXT,
        username TEXT,
        password TEXT,
        first_name TEXT,
        last_name TEXT,
        department TEXT,
        division TEXT,
        area TEXT,
        district TEXT,
        title TEXT,
        product_line TEXT,
        address TEXT,
        postal_code TEXT,
        email TEXT,
        telephone TEXT,
        mobile TEXT,
        user_code TEXT,
        assigned_warehouse TEXT,
        status TEXT,
        password_date TEXT,
        img TEXT)''');

    ///SALESMAN-HEPE
    db.execute('''
      CREATE TABLE tbl_hepe_salesman(
        doc_no INTEGER PRIMARY KEY,
        id TEXT,
        salesman_code TEXT,
        hepe_code TEXT,
        status TEXT)''');

    ///RETURNED TABLE
    db.execute('''
      CREATE TABLE tb_returned_tran(
        doc_no INTEGER PRIMARY KEY,
        tran_no TEXT,
        date TEXT,
        account_code TEXT,
        store_name TEXT,
        itm_count TEXT,
        tot_amt TEXT,
        hepe_code TEXT,
        reason TEXT,
        flag TEXT,
        signature TEXT,
        image TEXT,
        uploaded TEXT)''');

    ///SALESMAN TEMPORARY CART
    db.execute('''
      CREATE TABLE tb_salesman_cart(
        doc_no INTEGER PRIMARY KEY,
        salesman_code TEXT,
        account_code TEXT,
        item_code TEXT,
        item_desc TEXT,
        item_uom TEXT,
        item_amt TEXT,
        item_qty TEXT,
        item_total TEXT,
        item_cat TEXT,
        isMust TEXT,
        isPromo TEXT,
        image TEXT)''');

    ///SALES TYPE
    db.execute('''
      CREATE TABLE tb_sales_type(
        doc_no INTEGER PRIMARY KEY,
        id TEXT,
        type TEXT,
        categ TEXT)''');

    ///TRANSACTION HEAD
    db.execute('''
      CREATE TABLE tb_tran_head(
        doc_no INTEGER PRIMARY KEY,
        id TEXT,
        tran_no TEXT,
        nav_invoice_no TEXT,
        date_req TEXT,
        date_app TEXT,
        date_transit TEXT,
        date_del TEXT,
        account_code TEXT,
        store_name TEXT,
        p_meth TEXT,
        itm_count TEXT,
        itm_del_count TEXT,
        tot_amt TEXT,
        tot_del_amt TEXT,
        pmeth_type TEXT,
        tran_stat TEXT,
        sm_code TEXT,
        hepe_code TEXT,
        div_code TEXT,
        order_by TEXT,
        flag TEXT,
        signature TEXT,
        auth_signature TEXT,
        isExported TEXT,
        export_date TEXT,
        rate_status TEXT,
        sm_upload TEXT,
        hepe_upload TEXT,
        balance TEXT)''');
    db.execute('''CREATE INDEX tb_thead_idx 
      ON tb_tran_head 
      (doc_no, 
      tran_no, store_name,div_code, tran_stat,sm_code, hepe_code, date_req,date_app, date_del, account_code,
      hepe_upload)
    ''');

    //TRANHEAD FOR MAS
    db.execute('''
      CREATE TABLE ar_tran_head(
        doc_no INTEGER PRIMARY KEY,
        id TEXT,
        tran_no TEXT,
        nav_invoice_no TEXT,
        date_req TEXT,
        date_app TEXT,
        date_transit TEXT,
        date_del TEXT,
        account_code TEXT,
        store_name TEXT,
        p_meth TEXT,
        itm_count TEXT,
        itm_del_count TEXT,
        tot_amt TEXT,
        tot_del_amt TEXT,
        pmeth_type TEXT,
        tran_stat TEXT,
        sm_code TEXT,
        hepe_code TEXT,
        div_code TEXT,
        order_by TEXT,
        flag TEXT,
        signature TEXT,
        auth_signature TEXT,
        isExported TEXT,
        export_date TEXT,
        rate_status TEXT,
        sm_upload TEXT,
        hepe_upload TEXT,
        balance TEXT)''');

    db.execute('''
      CREATE TABLE tb_uploaded_tranhead(
        doc_no INTEGER PRIMARY KEY,
        id TEXT,
        tran_no TEXT,
        nav_invoice_no TEXT,
        date_req TEXT,
        date_app TEXT,
        date_transit TEXT,
        date_del TEXT,
        account_code TEXT,
        store_name TEXT,
        p_meth TEXT,
        itm_count TEXT,
        itm_del_count TEXT,
        tot_amt TEXT,
        tot_del_amt TEXT,
        pmeth_type TEXT,
        tran_stat TEXT,
        sm_code TEXT,
        hepe_code TEXT,
        div_code TEXT,
        order_by TEXT,
        flag TEXT,
        signature TEXT,
        auth_signature TEXT,
        isExported TEXT,
        export_date TEXT,
        rate_status TEXT,
        sm_upload TEXT,
        hepe_upload TEXT)''');


    ///TRANSACTION LINE
    db.execute('''
      CREATE TABLE tb_tran_line(
        doc_no INTEGER PRIMARY KEY,
        tran_no TEXT,
        nav_invoice_no TEXT,
        itm_code TEXT,
        item_desc TEXT,
        req_qty TEXT,
        del_qty TEXT,
        uom TEXT,
        amt TEXT,
        discount TEXT,
        tot_amt TEXT,
        discounted_amount TEXT,
        itm_cat TEXT,
        itm_stat TEXT,
        flag TEXT,
        account_code TEXT,
        div_code TEXT,
        date_req TEXT,
        date_del TEXT,
        lrate TEXT,
        rated TEXT,
        manually_included TEXT,
        image TEXT,
        posting_date TEXT,
        balance TEXT,
        orig_qty TEXT)''');

// AR TRAN LINE
    db.execute('''
      CREATE TABLE ar_tran_line(
        doc_no INTEGER PRIMARY KEY,
        tran_no TEXT,
        nav_invoice_no TEXT,
        itm_code TEXT,
        item_desc TEXT,
        req_qty TEXT,
        del_qty TEXT,
        uom TEXT,
        amt TEXT,
        discount TEXT,
        tot_amt TEXT,
        discounted_amount TEXT,
        itm_cat TEXT,
        itm_stat TEXT,
        flag TEXT,
        account_code TEXT,
        div_code TEXT,
        date_req TEXT,
        date_del TEXT,
        lrate TEXT,
        rated TEXT,
        manually_included TEXT,
        image TEXT,
        posting_date TEXT,
        balance TEXT)''');

    ///UNSERVED ITEMS
    db.execute('''
      CREATE TABLE tb_unserved_items(
        doc_no INTEGER PRIMARY KEY,
        tran_no TEXT,
        date TEXT,
        itm_code TEXT,
        item_desc TEXT,
        qty TEXT,
        uom TEXT,
        amt TEXT,
        tot_amt TEXT,
        itm_cat TEXT,
        itm_stat TEXT,
        flag TEXT,
        remarks TEXT,
        image TEXT)''');

    ///UPDATE TABLES
    db.execute('''
      CREATE TABLE tb_tables_update(
        doc_no INTEGER PRIMARY KEY,
        tb_name TEXT,
        tb_categ TEXT,
        date TEXT,
        flag TEXT)''');

    ///UPDATE TABLES LOG
    db.execute('''
      CREATE TABLE tb_updates_log(
        doc_no INTEGER PRIMARY KEY,
        date TEXT,
        tb_categ TEXT,
        status TEXT,
        type TEXT)''');

    ///DISCOUNTS TABLE
    db.execute('''
      CREATE TABLE tbl_discounts(
        doc_no INTEGER PRIMARY KEY,
        id TEXT,
        cus_id TEXT,
        principal_id TEXT,
        discount TEXT,
        created_at TEXT,
        updated_at TEXT)''');

    ///BANK LIST FOR CHEQUE TABLE
    db.execute('''
      CREATE TABLE tb_bank_list (
        doc_no INTEGER PRIMARY KEY,
        bank_name TEXT)''');

    ///FAVORITES TABLE
    db.execute('''
      CREATE TABLE tb_favorites (
        doc_no INTEGER PRIMARY KEY,
        account_code TEXT,
        item_code TEXT,
        item_uom TEXT)''');

    ///CHEQUE DATA
    db.execute('''
      CREATE TABLE tb_cheque_data  (
        doc_no INTEGER PRIMARY KEY,
        tran_no TEXT,
        account_code TEXT,
        sm_code TEXT,
        hepe_code TEXT,
        datetime TEXT,
        payee_name TEXT,
        payor_name TEXT,
        bank_name TEXT,
        cheque_no TEXT,
        branch_code TEXT,
        account_no TEXT,
        cheque_date TEXT,
        amount TEXT,
        status TEXT,
        image TEXT,
        backimage TEXT,
        uploaded TEXT)''');

    ///BANNER IMAGES TABLE
    db.execute('''
      CREATE TABLE tbl_banner_image (
        doc_no INTEGER PRIMARY KEY,
        banner_details TEXT,
        banner_img TEXT,
        img_path TEXT)''');

    ///ORDER LIMIT
    db.execute('''
      CREATE TABLE tbl_order_limit (
        doc_no INTEGER PRIMARY KEY,
        id TEXT,
        code TEXT,
        min_order_amt TEXT)''');

    ///BANNER USER ACCESS
    db.execute('''
      CREATE TABLE user_access (
        doc_no INTEGER PRIMARY KEY,
        ua_userid TEXT,
        ua_code TEXT,
        ua_action TEXT,
        ua_cust TEXT,
        ua_add_date TEXT,
        ua_update_date TEXT)''');

    db.execute('''
      CREATE TABLE tbl_customer_salesman (
        doc_no INTEGER PRIMARY KEY,
        cus_customer_code TEXT,
        salesman_code TEXT,
        status TEXT)''');

    db.execute('''
      CREATE TABLE tbl_salesman_principal (
        doc_no INTEGER PRIMARY KEY,
        salesman_code TEXT,
        vendor_code TEXT)''');

    db.execute('''CREATE INDEX principal_idx 
      ON tbl_salesman_principal 
      (salesman_code, vendor_code)
    ''');

    db.execute('''
      CREATE TABLE tbl_principals (
        doc_no INTEGER PRIMARY KEY,
        vendor_code TEXT,
          principal_name TEXT,
            contract_under_via_doc TEXT,
              contract_under_via_receipt TEXT,
                distributor TEXT,
                  status TEXT,
                  created_at TEXT,
                 updated_at TEXT)''');

    db.execute('''
      CREATE TABLE consolidated_transactions (
        doc_no INTEGER PRIMARY KEY,
        itemcode TEXT,
        reference_no TEXT,
        description TEXT,
        uom TEXT)''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS ${MonthlyCoveragePlan.tblMonthlyCoveragePlan}(
        ${MonthlyCoveragePlan.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${MonthlyCoveragePlan.colSalesManCode} TEXT NOT NULL,
        ${MonthlyCoveragePlan.colCustomerCode} TEXT NOT NULL,
        ${MonthlyCoveragePlan.colDateSchedule} TEXT NOT NULL,
        ${MonthlyCoveragePlan.colStartedDate} TEXT NOT NULL,
        ${MonthlyCoveragePlan.colEndDate} TEXT NOT NULL,
        ${MonthlyCoveragePlan.colVisitStatus} TEXT NOT NULL
      )
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS ${PaymentTerms.tblPaymentTerms}(
        ${PaymentTerms.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${PaymentTerms.colDivision} TEXT NOT NULL,
        ${PaymentTerms.colPaymentTerms} TEXT NOT NULL
      )
    ''');

    //NEWLY ADDED TABLE FOR AR
    db.execute('''
      CREATE TABLE IF NOT EXISTS payments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tran_no TEXT,
        sales_invoice TEXT,
        posting_date TEXT ,
        payment_date TEXT NOT NULL,
        amount TEXT NOT NULL,
        balance TEXT NOT NULL,
        cheque_no TEXT,
        jefe_code TEXT NOT NULL,
        account_code TEXT NOT NULL,
        created_at TEXT NOT NULL,
        exported_at TEXT,
        uploaded TEXT,
        tax TEXT 
      )
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS chequeImgForUpload(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        img_path TEXT NOT NULL,
        filename TEXT NOT NULL,
        uploaded TEXT
      )
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS proofReturnImgForUpload(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        img_path TEXT NOT NULL,
        filename TEXT NOT NULL,
        uploaded TEXT
      )
    ''');

    db.execute(''' INSERT INTO item_masterfiles VALUES(null,'0000','ALL PRODUCTS','0000',
    '0000','ALL PRODUCTS','ALL PRODUCTS','PC','0','0','0','no_image_item.jpg','1','0')''');

    db.execute('''INSERT INTO tbl_salesman_principal VALUES(null, '0000','0000')''');
    print("Database was created!");
  }

  Future insertSalesmanList(salesman) async {
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < salesman.length; i++) {
      var row = {
        'id'              : salesman[i]['id'],
        'username'        : salesman[i]['username'],
        'password'        : salesman[i]['password'],
        'first_name'      : salesman[i]['first_name'],
        'last_name'       : salesman[i]['last_name'],
        'department'      : salesman[i]['department'],
        'division'        : salesman[i]['division'],
        'area'            : salesman[i]['area'],
        'district'        : salesman[i]['district'],
        'title'           : salesman[i]['title'],
        'product_line'    : salesman[i]['product_line'],
        'address'         : salesman[i]['address'],
        'postal_code'     : salesman[i]['postal_code'],
        'email'           : salesman[i]['email'],
        'telephone'       : salesman[i]['telephone'],
        'mobile'          : salesman[i]['mobile'],
        'user_code'       : salesman[i]['user_code'],
        'status'          : salesman[i]['status'],
        'password_date'   : salesman[i]['password_date'],
        'img'             : salesman[i]['img']
      };
      batch.insert('salesman_lists', row);
    }
    await batch.commit(noResult: true);
  }

  Future insertHepeList(hepe) async {
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < hepe.length; i++) {
      var row = {
        'id'                    : hepe[i]['id'],
        'username'              : hepe[i]['username'],
        'password'              : hepe[i]['password'],
        'first_name'            : hepe[i]['first_name'],
        'last_name'             : hepe[i]['last_name'],
        'department'            : hepe[i]['department'],
        'division'              : hepe[i]['division'],
        'area'                  : hepe[i]['area'],
        'district'              : hepe[i]['district'],
        'title'                 : hepe[i]['title'],
        'product_line'          : hepe[i]['product_line'],
        'address'               : hepe[i]['address'],
        'postal_code'           : hepe[i]['postal_code'],
        'email'                 : hepe[i]['email'],
        'telephone'             : hepe[i]['telephone'],
        'mobile'                : hepe[i]['mobile'],
        'user_code'             : hepe[i]['user_code'],
        'assigned_warehouse'    : hepe[i]['assigned_warehouse'],
        'status'                : hepe[i]['status'],
        'password_date'         : hepe[i]['password_date'],
        'img'                   : hepe[i]['img']
      };
      batch.insert('tbl_hepe_de_viaje', row);
    }
    await batch.commit(noResult: true);
  }

  Future insertintoSalesmanPrncpl()async{
    print("huyi");
    var client = await db;
    await client.execute('''INSERT INTO tbl_salesman_principal VALUES(null, '0000','0000')''');
   }
  Future insertCustomersList(customer) async {
    print("INSERT CUSTOMERLIST :: $customer");
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < customer.length; i++) {
      batch.insert('customer_master_files', customer[i]);
    }
    await batch.commit(noResult: true);
  }

  Future insertDiscountList(discount) async {
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < discount.length; i++) {
      var row = {
        'id'              : discount[i]['id'],
        'cus_id'          : discount[i]['cus_id'],
        'principal_id'    : discount[i]['principal_id'],
        'discount'        : discount[i]['discount'],
        'created_at'      : discount[i]['created_at'],
        'updated_at'      : discount[i]['updated_at']
      };
      batch.insert('tbl_discounts', row);
    }
    await batch.commit(noResult: true);
  }

  Future insertBankList(bank) async {
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < bank.length; i++) {
      var row = {
        'bank_name'  : bank[i]['bank_name']
      };
      batch.insert('tb_bank_list', row);
    }
    await batch.commit(noResult: true);
  }

  Future insertCustomerSalesman(customer_salesman) async {
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < customer_salesman.length; i++) {
      var row = {
        'cus_customer_code'  : customer_salesman[i]['cus_customer_code'],
        'salesman_code'  : customer_salesman[i]['salesman_code'],
        'status'  : customer_salesman[i]['status']
      };
      batch.insert('tbl_customer_salesman', row);
    }
    await batch.commit(noResult: true);
  }

  Future insertOrderLimitList(orderLimit) async {
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < orderLimit.length; i++) {
      var row = {
        'id'              : orderLimit[i]['id'],
        'code'            : orderLimit[i]['code'],
        'min_order_amt'   : orderLimit[i]['min_order_amt']
      };
      batch.insert('tbl_order_limit', row);
    }
    await batch.commit(noResult: true);
  }

  Future insertAccessList(access) async {
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < access.length; i++) {
      var row = {
        'ua_userid'       : access[i]['ua_userid'],
        'ua_code'         : access[i]['ua_code'],
        'ua_action'       : access[i]['ua_action'],
        'ua_cust'         : access[i]['ua_cust'],
        'ua_add_date'     : access[i]['ua_add_date'],
        'ua_update_date'  : access[i]['ua_update_date']
      };
      batch.insert('user_access', row);
    }
    await batch.commit(noResult: true);
  }

  Future insertSalesTypeList(type) async {
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < type.length; i++) {
      var row = {
        'id'          : type[i]['id'],
        'type'        : type[i]['type'],
        'categ'       : type[i]['categ']
      };
      batch.insert('tb_sales_type', row);
    }
    await batch.commit(noResult: true);
  }

  Future insertItemList(items) async {
    print("InsertItemList :: $items");
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < items.length; i++) {
      batch.insert('item_masterfiles', items[i]);
    }

    await batch.commit(noResult: true);
  }
  Future<void> insertData() async {
    try {
      // Get the database instance
      final client = await db;

      // Execute the SQL query to insert data
      await client.rawInsert('''
      INSERT INTO item_masterfiles VALUES(
        null, 
        '0000', 
        'ALL PRODUCTS', 
        '0000',
        '0000', 
        'ALL PRODUCTS', 
        'ALL PRODUCTS', 
        'PC', 
        '0', 
        '0', 
        '0', 
        'no_image_item.jpg', 
        '1', 
        '0'
      )
    ''');

      print('Data inserted successfully!');
    } catch (e) {
      print('Error inserting data: $e');
    }
  }


  Future insertPrincipals(principals) async {
    print("InsertItemList :: $principals");
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < principals.length; i++) {

      var row = {
        'vendor_code'                       : principals[i]['vendor_code'],
        'principal_name'                    : principals[i]['principal_name'],
        'contract_under_via_doc'            : principals[i]['contract_under_via_doc'],
        'contract_under_via_receipt'        : principals[i]['contract_under_via_receipt'],
        'distributor'                       : principals[i]['distributor'],
        'status'                            : principals[i]['status'],
        'created_at'                        : principals[i]['created_at'],
        'updated_at'                        : principals[i]['updated_at']
      };

      batch.insert('tbl_principals', row);
    }
    await batch.commit(noResult: true);
  }

  Future insertAllProduct() async {
    var client = await db;
    client.execute(''' INSERT INTO item_masterfiles VALUES(null,'0000','ALL PRODUCTS','0000',
    '0000','ALL PRODUCTS','ALL PRODUCTS','PC','0','0','0','no_image_item.jpg','1','0')''');
  }
  // INSERTSalesmanPrincipal
  Future insertSalesmanPrincipal(items) async {

    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < items.length; i++) {
      batch.insert('tbl_principals', items[i]);
    }
    await batch.commit(noResult: true);

  }

  Future insertConsolidatedTrans(items) async {
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < items.length; i++) {
      var row = {
        'itemcode'      : items[i]['itemcode'],
        'reference_no'  : items[i]['reference_no'],
        'description'   : items[i]['description'],
        'uom'           : items[i]['uom']
      };
      batch.insert('consolidated_transactions', row);
    }
    await batch.commit(noResult: true);
  }

  Future insertTableTbTranHead(tranHeadList) async {
      var client = await db;
      Batch batch = client.batch();
      for (var i = 0; i < tranHeadList.length; i++) {
        var row = {
          'id'                : tranHeadList[i]['id'],
          'tran_no'           : tranHeadList[i]['tran_no'],
          'nav_invoice_no'    : tranHeadList[i]['nav_invoice_no'],
          'date_req'          : tranHeadList[i]['date_req'],
          'date_app'          : tranHeadList[i]['date_app'],
          'date_transit'      : tranHeadList[i]['date_transit'],
          'date_del'          : tranHeadList[i]['date_del'],
          'account_code'      : tranHeadList[i]['account_code'],
          'store_name'        : tranHeadList[i]['store_name'],
          'p_meth'            : tranHeadList[i]['p_meth'],
          'itm_count'         : tranHeadList[i]['itm_count'],
          'itm_del_count'     : tranHeadList[i]['itm_del_count'],
          'tot_amt'           : tranHeadList[i]['tot_amt'],
          'tot_del_amt'       : tranHeadList[i]['tot_del_amt'],
          'pmeth_type'        : tranHeadList[i]['pmeth_type'],
          'tran_stat'         : tranHeadList[i]['tran_stat'],
          'sm_code'           : tranHeadList[i]['sm_code'],
          'hepe_code'         : tranHeadList[i]['hepe_code'],
          'div_code'          : tranHeadList[i]['div_code'],
          'order_by'          : tranHeadList[i]['order_by'],
          'flag'              : tranHeadList[i]['flag'],
          'signature'         : tranHeadList[i]['signature'],
          'auth_signature'    : tranHeadList[i]['auth_signature'],
          'isExported'        : tranHeadList[i]['isExported'],
          'export_date'       : tranHeadList[i]['export_date'],
          'rate_status'       : tranHeadList[i]['rate_status'],
          'sm_upload'         : tranHeadList[i]['sm_upload'],
          'hepe_upload'       : tranHeadList[i]['hepe_upload'],
          'balance'           : tranHeadList[i]['tot_del_amt']
        };
        batch.insert('tb_tran_head', row);
      }
      await batch.commit(noResult: true);
    }


  Future insertTableTbTranLine(linelist) async {
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < linelist.length; i++) {
      var row = {
        'tran_no'             : linelist[i]['tran_no'],
        'nav_invoice_no'      : linelist[i]['nav_invoice_no'],
        'itm_code'            : linelist[i]['itm_code'],
        'item_desc'           : linelist[i]['item_desc'],
        'req_qty'             : linelist[i]['req_qty'],
        'del_qty'             : linelist[i]['del_qty'],
        'uom'                 : linelist[i]['uom'],
        'amt'                 : linelist[i]['amt'],
        'discount'            : linelist[i]['discount'],
        'tot_amt'             : linelist[i]['tot_amt'],
        'discounted_amount'   : linelist[i]['discounted_amount'],
        'itm_cat'             : linelist[i]['itm_cat'],
        'itm_stat'            : linelist[i]['itm_stat'],
        'flag'                : linelist[i]['flag'],
        'account_code'        : linelist[i]['account_code'],
        'div_code'            : linelist[i]['div_code'],
        'date_req'            : linelist[i]['date_req'],
        'date_del'            : linelist[i]['date_del'],
        'lrate'               : linelist[i]['lrate'],
        'rated'               : linelist[i]['rated'],
        'manually_included'   : linelist[i]['manually_included'],
        'image'               : linelist[i]['image'],
        'posting_date'        : linelist[i]['posting_date'],
        'balance'             : linelist[i]['tot_amt'],
        'orig_qty'             : linelist[i]['del_qty']
      };
      batch.insert('tb_tran_line', row);
    }
    await batch.commit(noResult: true);
  }
  //mas balance tran head
  Future updateArTranHead(tran_no) async {
    var client = await db;
    int i = 0;
    List? result = await client.rawQuery(
        'SELECT head.date_del, head.itm_del_count, head.tot_del_amt,head.tran_stat,head.hepe_upload, '
            'head.balance, arhead.balance as existingbal, arhead.tot_del_amt as existinAmt '
            'from tb_tran_head as head INNER JOIN ar_tran_head as arhead '
            'ON arhead.tran_no = head.tran_no WHERE head.tran_no = ? ',[tran_no]
    );

    return client.update('ar_tran_head', {
      'date_del'          : result[i]['date_del'],
      'itm_del_count'     : result[i]['itm_del_count'],
      'tot_del_amt'       : result[i]['tot_del_amt'],
      'tran_stat'         : result[i]['tran_stat'],
      'hepe_upload'       : result[i]['hepe_upload'],
      // 'balance'           : (double.parse(result[i]['existingbal']) + (double.parse(result[i]['balance']) - double.parse(result[i]['existinAmt'])).abs()).toStringAsFixed(2)
    },where: 'tran_no = ?',
    whereArgs: [tran_no]);
  }
  Future insertArTranHead(tranHeadList) async {
    var client = await db;

    Batch batch = client.batch();
    for (var i = 0; i < tranHeadList.length; i++) {
      var row = {
        'id'                : tranHeadList[i]['id'],
        'tran_no'           : tranHeadList[i]['tran_no'],
        'nav_invoice_no'    : tranHeadList[i]['nav_invoice_no'],
        'date_req'          : tranHeadList[i]['date_req'],
        'date_app'          : tranHeadList[i]['date_app'],
        'date_transit'      : tranHeadList[i]['date_transit'],
        'date_del'          : tranHeadList[i]['date_del'],
        'account_code'      : tranHeadList[i]['account_code'],
        'store_name'        : tranHeadList[i]['store_name'],
        'p_meth'            : tranHeadList[i]['p_meth'],
        'itm_count'         : tranHeadList[i]['itm_count'],
        'itm_del_count'     : tranHeadList[i]['itm_del_count'],
        'tot_amt'           : tranHeadList[i]['tot_amt'],
        'tot_del_amt'       : tranHeadList[i]['tot_del_amt'],
        'pmeth_type'        : tranHeadList[i]['pmeth_type'],
        'tran_stat'         : tranHeadList[i]['tran_stat'],
        'sm_code'           : tranHeadList[i]['sm_code'],
        'hepe_code'         : tranHeadList[i]['hepe_code'],
        'div_code'          : tranHeadList[i]['div_code'],
        'order_by'          : tranHeadList[i]['order_by'],
        'flag'              : tranHeadList[i]['flag'],
        'signature'         : tranHeadList[i]['signature'],
        'auth_signature'    : tranHeadList[i]['auth_signature'],
        'isExported'        : tranHeadList[i]['isExported'],
        'export_date'       : tranHeadList[i]['export_date'],
        'rate_status'       : tranHeadList[i]['rate_status'],
        'sm_upload'         : tranHeadList[i]['sm_upload'],
        'hepe_upload'       : tranHeadList[i]['hepe_upload'],
        // 'balance'           : tranHeadList[i]['balance'] == '' ? tranHeadList[i]['tot_del_amt'] : tranHeadList[i]['balance']
        'balance'           : 0
      };
      batch.insert('ar_tran_head', row);
    }
    await batch.commit(noResult: true);
  }

  Future updateArTranLine(tran_no) async {
    var client = await db;
    int i=0;
    List? result = await client.rawQuery(
        'SELECT itm_code,uom,del_qty, itm_stat, date_del from tb_tran_line '
            'WHERE tran_no= ? ',[tran_no]
    );

      return client.update('ar_tran_line', {
        'del_qty'             : result[i]['del_qty'],
        'itm_stat'            : result[i]['itm_stat'],
        'date_del'            : result[i]['date_del'],
      },where: 'tran_no',
          whereArgs: [tran_no]);


  }
  Future insertArTranLine(linelist) async {
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < linelist.length; i++) {
      var row = {
        'tran_no'             : linelist[i]['tran_no'],
        'nav_invoice_no'      : linelist[i]['nav_invoice_no'],
        'itm_code'            : linelist[i]['itm_code'],
        'item_desc'           : linelist[i]['item_desc'],
        'req_qty'             : linelist[i]['req_qty'],
        'del_qty'             : linelist[i]['del_qty'],
        'uom'                 : linelist[i]['uom'],
        'amt'                 : linelist[i]['amt'],
        'discount'            : linelist[i]['discount'],
        'tot_amt'             : linelist[i]['tot_amt'],
        'discounted_amount'   : linelist[i]['discounted_amount'],
        'itm_cat'             : linelist[i]['itm_cat'],
        'itm_stat'            : linelist[i]['itm_stat'],
        'flag'                : linelist[i]['flag'],
        'account_code'        : linelist[i]['account_code'],
        'div_code'            : linelist[i]['div_code'],
        'date_req'            : linelist[i]['date_req'],
        'date_del'            : linelist[i]['date_del'],
        'lrate'               : linelist[i]['lrate'],
        'rated'               : linelist[i]['rated'],
        'manually_included'   : linelist[i]['manually_included'],
        'image'               : linelist[i]['image'],
        'posting_date'        : linelist[i]['posting_date'],
        'balance'             : linelist[i]['tot_amt']
      };
      batch.insert('ar_tran_line', row);
    }
    await batch.commit(noResult: true);
  }
  //mas balance tran head
  Future insertTableTbUnservedItems(unsrvlist) async {
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < unsrvlist.length; i++) {
      var row = {
        'tran_no'     : unsrvlist[i]['tran_no'],
        'date'        : unsrvlist[i]['date'],
        'itm_code'    : unsrvlist[i]['itm_code'],
        'item_desc'   : unsrvlist[i]['item_desc'],
        'qty'         : unsrvlist[i]['qty'],
        'uom'         : unsrvlist[i]['uom'],
        'amt'         : unsrvlist[i]['amt'],
        'tot_amt'     : unsrvlist[i]['tot_amt'],
        'itm_cat'     : unsrvlist[i]['itm_cat'],
        'itm_stat'    : unsrvlist[i]['itm_stat'],
        'flag'        : unsrvlist[i]['flag'],
        'image'       : unsrvlist[i]['image']
      };
      batch.insert('tb_unserved_items', row);
    }
    await batch.commit(noResult: true);
  }

  Future insertTableTbReturnedTran(returnList) async {
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < returnList.length; i++) {
      var row = {
        'tran_no'       : returnList[i]['tran_no'],
        'date'          : returnList[i]['date'],
        'account_code'  : returnList[i]['account_code'],
        'store_name'    : returnList[i]['store_name'],
        'itm_count'     : returnList[i]['itm_count'],
        'tot_amt'       : returnList[i]['tot_amt'],
        'hepe_code'     : returnList[i]['hepe_code'],
        'reason'        : returnList[i]['reason'],
        'flag'          : returnList[i]['flag'],
        'signature'     : returnList[i]['signature'],
        'uploaded'      : returnList[i]['uploaded']
      };
      batch.insert('tb_returned_tran', row);
    }
    await batch.commit(noResult: true);
  }

  // Future insertItemList(items, img) async {
  //   var client = await db;
  //   Batch batch = client.batch();
  //   for (var i = 0; i < items.length; i++) {
  //     batch.insert('item_masterfiles', items[i]);
  //     batch.update('item_masterfiles', {'image': img['image_path']},
  //         where: 'itemcode = ? AND uom = ?', whereArgs: []);
  //   }
  //   await batch.commit(noResult: true);
  // }

  Future insertItemImgList(img) async {
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < img.length; i++) {
      var row = {
        'id'             : img[i]['id'],
        'item_code'      : img[i]['item_code'],
        'item_uom'       : img[i]['item_uom'],
        'item_path'      : img[i]['item_path'],
        'image'          : img[i]['image'],
        'created_at'     : img[i]['created_at'],
        'updated_at'     : img[i]['updated_at']
      };
      batch.insert('tbl_item_image', row);
    }
    await batch.commit(noResult: true);
  }


  Future updateItemImg(img) async {
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < img.length; i++) {
      batch.update(
          'item_masterfiles',
          {
            'image': img[i]['item_path']
          },
          where     : 'itemcode = ? AND uom = ?',
          whereArgs : [img[i]['item_code'], img[i]['item_uom']]);
    }
    await batch.commit(noResult: true);
  }

  Future insertCategList(categ) async {
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < categ.length; i++) {
      var row = {
        'id'             : categ[i]['id'],
        'category_name'  : categ[i]['category_name'],
        'category_image' : categ[i]['category_image']
      };
      batch.insert('tbl_category_masterfile', row);
    }
    await batch.commit(noResult: true);
  }

  Future updateCategList(categ) async {
    var client = await db;
    Batch batch = client.batch();

    for (var i = 0; i < categ.length; i++) {
      var row = {
        'id'             : categ[i]['id'],
        'category_name'  : categ[i]['category_name'],
        'category_image' : categ[i]['category_image']
      };
      batch.insert('tbl_category_masterfile', row);
      // batch.update('tbl_category_masterfile', categ[i],
      //     where: 'doc_no = ?', whereArgs: [categ[i]['doc_no']]);
    }
    await batch.commit(noResult: true);
  }
  Future deleteArHead() async {
    var client = await db;
    return client.rawQuery(
        'DELETE FROM ar_tran_head',
        null);
  }
  Future deleteArLine() async {
    var client = await db;
    return client.rawQuery(
        'DELETE FROM ar_tran_line',
        null);
  }
  Future deleteCheque() async {
    var client = await db;
    return client.rawQuery(
        'DELETE FROM tb_cheque_data',
        null);
  }
  Future deleteChequeImg() async {
    var client = await db;
    return client.rawQuery(
        'DELETE FROM chequeImgForUpload',
        null);
  }
  Future deletePayment() async {
    var client = await db;
    return client.rawQuery(
        'DELETE FROM payments',
        null);
  }
  Future deleteCateg() async {
    var client = await db;
    return client.rawQuery(
        'DELETE FROM tbl_category_masterfile WHERE category_name != " "', null);
  }

  Future deleteCustomer() async {
    var client = await db;
    return client.rawQuery(
        'DELETE FROM customer_master_files WHERE customer_id != " "', null);
  }

  Future deleteTable(tbNname) async {
    var client = await db;
    return client.rawQuery('DELETE FROM $tbNname WHERE doc_no !=" "', null);
  }

  Future addItemtoCart(salesmanCode, accountCode, itemCode, itemDesc, itemUom,
      itemAmt, qty, total, itemCat, isMust, isPromo, itemImage) async {
    int fqty = 0;
    double ftotal = 0.00;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT item_qty, item_total FROM tb_salesman_cart WHERE account_code ="$accountCode" AND  item_code = "$itemCode" AND item_uom = "$itemUom"',
        null);
    // final result = count;
    // return res;
    if (res.isEmpty) {
      return client.insert('tb_salesman_cart', {
        'salesman_code' : salesmanCode,
        'account_code'  : accountCode,
        'item_code'     : itemCode,
        'item_desc'     : itemDesc,
        'item_uom'      : itemUom,
        'item_amt'      : itemAmt,
        'item_qty'      : qty,
        'item_total'    : total,
        'item_cat'      : itemCat,
        'isMust'        : isMust,
        'isPromo'       : isPromo,
        'image'         : itemImage,
      });
    } else {
      res.forEach((element) {
        fqty = int.parse(element['item_qty']);
        ftotal = double.parse(element['item_total']);
      });
      return client.update(
          'tb_salesman_cart',
          {
            'item_qty'    : (fqty + int.parse(qty)).toString(),
            'item_total'  : (ftotal + double.parse(total)).toString()
          },
          where: 'account_code = ? AND item_code = ? AND item_uom = ?',
          whereArgs: [accountCode, itemCode, itemUom]);
    }
  }


  Future addTempTranHead(tranNo, dateReq, accountCode, storeName, pMeth,
      itmCount, totAmt, tranStat, smCode, divCode, signature) async {
    String orderby = 'Salesman';
    String upStat = 'FALSE';
    double totalAmt = 0.00;
    int iCount = 0;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT * FROM tb_tran_head WHERE tran_no ="$tranNo"', null);
    if (res.isEmpty) {
      return client.insert('tb_tran_head', {
        'tran_no'       : tranNo,
        'date_req'      : dateReq,
        'account_code'  : accountCode,
        'store_name'    : storeName,
        'p_meth'        : pMeth,
        'itm_count'     : itmCount,
        'tot_amt'       : totAmt,
        'tran_stat'     : tranStat,
        'sm_code'       : smCode,
        'div_code'      : divCode,
        'order_by'      : orderby,
        'signature'     : signature,
        'sm_upload'     : upStat,
        'hepe_upload'   : upStat,
        'balance'       : totAmt
      });
    } else {
      res.forEach((element) {
        totalAmt = double.parse(element['tot_amt']);
        iCount = int.parse(element['itm_count']);
      });
      return client.update(
          'tb_tran_head',
          {
            'itm_count' : (iCount + int.parse(itmCount)).toString(),
            'tot_amt'   : (totalAmt + double.parse(totAmt)).toString(),
          },
          where: 'tran_no = ?',
          whereArgs: [tranNo]);
    }
  }

  //tb_uploaded_tranhead
  Future add_uploaded_tranhead(tranNo, dateReq, accountCode, storeName, pMeth,
      itmCount, totAmt, tranStat, smCode, divCode, signature) async {
    String orderby = 'Salesman';
    String upStat = 'FALSE';
    double totalAmt = 0.00;
    int iCount = 0;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT * FROM tb_uploaded_tranhead WHERE tran_no ="$tranNo"', null);
    if (res.isEmpty) {
      // return client.insert('tb_tran_head', {
      return client.insert('tb_uploaded_tranhead', {
        'tran_no'       : tranNo,
        'date_req'      : dateReq,
        'account_code'  : accountCode,
        'store_name'    : storeName,
        'p_meth'        : pMeth,
        'itm_count'     : itmCount,
        'tot_amt'       : totAmt,
        'tran_stat'     : tranStat,
        'sm_code'       : smCode,
        'div_code'      : divCode,
        'order_by'      : orderby,
        'signature'     : signature,
        'sm_upload'     : upStat,
        'hepe_upload'   : upStat,
      });
    } else {
      res.forEach((element) {
        totalAmt = double.parse(element['tot_amt']);
        iCount = int.parse(element['itm_count']);
      });
      return client.update(
          'tb_tran_head',
          {
            'itm_count' : (iCount + int.parse(itmCount)).toString(),
            'tot_amt'   : (totalAmt + double.parse(totAmt)).toString(),
          },
          where: 'tran_no = ?',
          whereArgs: [tranNo]);
    }
  }


  Future addTempTranLine(tranNo, itemCode, itemDesc, itemQty, itemUom, itemAmt,
      totAmt, itemCat, accountCode, divCode, date, image) async {
    int fqty = 0;
    double ftotal = 0.00;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT req_qty, tot_amt FROM tb_tran_line WHERE tran_no ="$tranNo" AND account_code ="$accountCode" AND  itm_code = "$itemCode" AND uom = "$itemUom"',
        null);
    // final result = count;
    // return res;
    if (res.isEmpty) {
      return client.insert('tb_tran_line', {
        'tran_no'           : tranNo,
        'itm_code'          : itemCode,
        'item_desc'         : itemDesc,
        'req_qty'           : itemQty,
        'del_qty'           : '0',
        'uom'               : itemUom,
        'amt'               : itemAmt,
        'discount'          : '0',
        'tot_amt'           : totAmt,
        'discounted_amount' : '0.00',
        'itm_cat'           : itemCat,
        'itm_stat'          : 'Pending',
        'flag'              : '0',
        'account_code'      : accountCode,
        'div_code'          : divCode,
        'date_req'          : date,
        'image'             : image,
        'balance'           : totAmt //partial amount nya ug onprocess pa
      });
    } else {
      res.forEach((element) {
        fqty = int.parse(element['req_qty']);
        ftotal = double.parse(element['tot_amt']);
      });
      return client.update(
          'tb_tran_line',
          {
            'req_qty': (fqty + int.parse(itemQty)).toString(),
            'tot_amt': (ftotal + double.parse(totAmt)).toString()
          },
          where     : 'tran_no = ? AND account_code = ? AND itm_code = ? AND uom = ?',
          whereArgs : [tranNo, accountCode, itemCode, itemUom]);
    }
  }

  Future addUpdateTable(tbName, tbCateg, date) async {
    var client = await db;
    return client.insert('tb_tables_update', {
      'tb_name'   : tbName,
      'tb_categ'  : tbCateg,
      'date'      : date,
    });
  }

  Future updateCodeinSlsmnPrncpl(salesmanCode)async{
    var client = await db;
    //a
    return client.update('tbl_salesman_principal', {'salesman_code': salesmanCode},
        where: 'vendor_code = ?', whereArgs: ['0000']);
  }

  Future updateTable(tbName, date) async {
    var client = await db;
    return client.update('tb_tables_update', {'tb_name': tbName, 'date': date},
        where: 'tb_name = ?', whereArgs: [tbName]);
  }

  Future updateSalesmanPassword(code, pass) async {
    var client = await db;
    String date = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()).toString();
    print('DATE and TIME ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
    return client.update('salesman_lists', {'password': pass, 'status' : '1', 'password_date' : date },
        where: 'user_code = ?', whereArgs: [code]);
  }

  Future updateHepePassword(code, pass) async {
    var client = await db;
    String date = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()).toString();
    return client.update('tbl_hepe_de_viaje', {'password': pass, 'status': '1', 'password_date': date},
        where: 'user_code = ?', whereArgs: [code]);
  }

  Future addUpdateTableLog(date, tbCateg, stat, type) async {
    var client = await db;
    return client.insert('tb_updates_log', {
      'date'      : date,
      'tb_categ'  : tbCateg,
      'status'    : stat,
      'type'      : type,
    });
  }

  Future updateCart(accountCode, itemCode, itemUom, itemQty, itemTotal) async {
    var client = await db;
    return client.update(
        'tb_salesman_cart',
        {
          'item_qty'    : itemQty,
          'item_total'  : itemTotal
        },
        where     : 'account_code = ? AND item_code = ? AND item_uom = ?',
        whereArgs : [accountCode, itemCode, itemUom]);

    // return 'UPDATED';
  }

  Future ofUpdateItemImg(image, itemcode, uom) async {
    var client = await db;
    return client.update(
        'item_masterfiles',
        {
          'image': image
        },
        where     : 'itemcode = ? AND uom = ?',
        whereArgs : [itemcode, uom]);
  }

  Future updateTranUploadStatSM(tmpTranNo, tranNo) async {
    String stat = 'TRUE';
    var client = await db;
    return client.update(
        'tb_tran_head',
        {
          'tran_no'   : tranNo,
          'sm_upload' : stat
        },
        where     : 'tran_no = ?',
        whereArgs : [tmpTranNo]);
  }

  Future updateTranUploadStatHEPE(tranNo) async {
    String stat = 'TRUE';
    var client = await db;
    return client.update(
        'tb_tran_head',
        {
          'hepe_upload': stat
        },
        where     : 'tran_no = ?',
        whereArgs : [tranNo]);
  }

  Future resetHepeUploadToFalse(tranNo) async {
    String stat = 'FALSE';
    var client = await db;
    return client.update(
        'tb_tran_head',
        {
          'hepe_upload': stat
        },
        where     : 'tran_no = ?',
        whereArgs : [tranNo]);
  }

  Future updateLineUploadStat(tmpTranNo, tranNo) async {
    var client = await db;
    return client.update(
        'tb_tran_line',
        {
          'tran_no': tranNo
        },
        where: 'tran_no = ?',
        whereArgs: [tmpTranNo]);
  }

  // Future sampleUpdateItemImg(image, itemcode, uom) async {
  //   var client = await db;
  //   return client.update('tbl_item_image', {'item_path': image},
  //       where: 'item_code = ? AND item_uom = ?', whereArgs: [itemcode, uom]);
  // }

  //FETCHIN API PAYMENTS AND UPDATE
  Future getPayment(tran_no) async {
    var url = Uri.parse(UrlAddress.url + 'getPaymentEntry');
    final response = await retry(() => http.post(url, headers: {
      "Accept": "Application/json"
    }, body: {
      'trans': encrypt(tran_no),
    }));
    var convertedDatatoJson = jsonDecode(response.body);
    return convertedDatatoJson;
  }




  //PAYMENTS UPLOADING
  Future fetchPayment() async {
    var client = await db;
     return client.rawQuery('SELECT * FROM payments WHERE uploaded="false"' , null);
  }

  Future fetchPayment1(tran) async {
    var client = await db;
    return client.rawQuery('SELECT * FROM payments WHERE tran_no="$tran"' , null);
  }
  Future uploadPayment(payments) async {
    var url = Uri.parse(UrlAddress.url + 'uploadPayments');
      final response = await retry(() => http.post(url, headers: {
        "Accept": "Application/json"
      }, body: {
        'payments': encrypt(jsonEncode(payments)),
      }));
      return response.body.toString();
  }
  Future uploadCheque(cheques) async {
    var url = Uri.parse(UrlAddress.url + 'uploadCheques');
    final response = await retry(() => http.post(url, headers: {
      "Accept": "Application/json"
    }, body: {
      'cheques': encrypt(jsonEncode(cheques)),
    }));
    return response.body.toString();
  }
  Future updatePaymentsStatus(tranNo, invoice) async{
    var client = await db;
    return client.update(
        'payments',
        {
          'uploaded'   : 'true'
        },
        where     : 'tran_no = ? AND sales_invoice = ?',
        whereArgs : [tranNo, invoice]);
  }
  Future updateChequeStatus(tranNo, chequeNo) async{
    var client = await db;
    return client.update(
        'tb_cheque_data',
        {
          'uploaded'   : 'true'
        },
        where     : 'tran_no = ? AND cheque_no = ?',
        whereArgs : [tranNo, chequeNo]);
  }
  Future fetchCheques() async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_cheque_data WHERE uploaded="false"' , null);
  }
  Future fetchChequesImg() async {
    var client = await db;
    return client.rawQuery(
        'SELECT img_path, filename FROM chequeImgForUpload WHERE uploaded="false"' , null);
  }
  Future fetchReturnImg() async {
    var client = await db;
    return client.rawQuery(
        'SELECT img_path, filename FROM proofReturnImgForUpload WHERE uploaded="false"' , null);
  }
  Future deletecheque() async {
    var client = await db;
    return client.rawQuery('DELETE * FROM chequeImgForUpload');
  }

Future uploadChequesImg(cheques) async{
  var url = Uri.parse('http://172.16.43.195:8082/api/palawan/palawan_image');
  // var url = Uri.parse(UrlAddress.kaloyurl2 + 'api/test/saveChequePhoto');
  // print('uwu $imageTxt');
  var res =  await http.post(url, headers: {
    "Accept": "Application/json"
  }, body: {
    'data' : jsonEncode(cheques)
    // 'filename': ChequeData.ccheqNum.text,
    // 'image_data': ChequeData.base64img
  });
  var convertedDatatoJson = jsonDecode(res.body);
  return convertedDatatoJson;
  // return res.body;
}
  Future uploadProofReturnImgs(proof) async{
    var url = Uri.parse(UrlAddress.kaloyurl2 + 'api/test/saveChequePhoto');
    // print('uwu $imageTxt');
    var res =  await http.post(url, headers: {
      "Accept": "Application/json"
    }, body: {
      'data' : jsonEncode(proof)
      // 'filename': ChequeData.ccheqNum.text,
      // 'image_data': ChequeData.base64img
    });
    var convertedDatatoJson = jsonDecode(res.body);
    return convertedDatatoJson;
    // return res.body;
  }

  Future updateChequeImgStatus(filename) async{
    var client = await db;
    return client.update(
        'chequeImgForUpload',
        {
          'uploaded'   : 'true'
        },
        where     : 'filename= ?',
        whereArgs : [filename]);
  }

  Future updateReturnImgStatus(filename) async{
    var client = await db;
    return client.update(
        'proofReturnImgForUpload',
        {
          'uploaded'   : 'true'
        },
        where     : 'filename= ?',
        whereArgs : [filename]);
  }
  Future ofFetchUpdatesTables() async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_tables_update ORDER BY date ASC', null);
  }

  Future ofFetchAll() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM tb_bank_list ', null);
  }

  Future ofFetchSalesmanList() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM salesman_lists', null);
  }

  Future ofFetchHepeList() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM tbl_hepe_de_viaje', null);
  }

  Future ofFetchCustomerList() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM customer_master_files', null);
  }

  Future ofFetchDiscountList() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM tbl_discounts', null);
  }

  Future ofFetchBankList() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM tb_bank_list', null);
  }

  Future ofFetchOrderLimit() async {
    print("ofFetchOrderLimit");
    var client = await db;
    return client.rawQuery('SELECT * FROM tbl_order_limit', null);
  }

  Future ofFetchUserAccess() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM user_access', null);
  }

  Future ofSalesTypeList() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM tb_sales_type', null);
  }

  Future ofFetchItemList() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM item_masterfiles', null);
  }
  Future ofFetchPrincipals() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM tbl_principals', null);
  }
  Future ofFetchItemImgList() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM tbl_item_image', null);
  }

  Future ofFetchCategList() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM tbl_category_masterfile', null);
  }

  Future categSearch(text) async {
    var client = await db;
    return client.rawQuery(
        "SELECT * FROM item_masterfiles "
            "WHERE principal LIKE '%$text%' OR company_code LIKE '%$text%' "
            "GROUP BY company_code ",
        null);
  }

  Future ofFetchPrincipalList(String salesmanCode) async {
    var client = await db;

    // Query to fetch and sort, ensuring 'ALL PRODUCTS' appears first
    return client.rawQuery('''
    SELECT * 
    FROM item_masterfiles 
    GROUP BY company_code 
    ORDER BY 
      CASE WHEN principal = 'ALL PRODUCTS' THEN 0 ELSE 1 END, 
      principal
  ''');
  }

  Future getReturnedList() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM tb_returned_tran', null);
  }

  Future getReturnedStatus() async {
    // String stat = 'Returned';
    var client = await db;
    return client.rawQuery(
        'SELECT store_name, hepe_code,tran_stat FROM tb_tran_head', null);
  }



  Future ofFetchCart(custcode) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_salesman_cart WHERE account_code ="$custcode" ORDER BY doc_no ASC',
        null);
  }

  Future searchCart(custcode, itmcode, uom) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_salesman_cart WHERE account_code ="$custcode" AND item_code ="$itmcode" AND item_uom ="$uom"',
        null);
  }



  Future ofFetchSalesmanOngoingHistory(code) async {

    // String status = 'Delivered';
    var client = await db;
    return client.rawQuery(
        "SELECT *,''as newdate FROM tb_tran_head WHERE sm_code ='$code' AND tran_stat ='Pending' "
            "ORDER BY date_app DESC",
        null);
  }


  Future ofFetchSalesmanCompletedHistory(code) async {

    // String status = 'Delivered';
    var client = await db;
    return client.rawQuery(
        "SELECT *,''as newdate FROM tb_tran_head WHERE sm_code ='$code' AND tran_stat ='Approved' "
            "ORDER BY date_app DESC",
        null);
  }

  Future ofFetchSalesmandeliverHistory(code) async {

    var client = await db;
    return client.rawQuery(
        "SELECT *,''as newdate FROM tb_tran_head WHERE sm_code ='$code' AND tran_stat ='Delivered' "
            "ORDER BY date_app DESC",
        null);
  }





  Future ofFetchCustomerHistory(code) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_tran_head WHERE account_code ="$code" ORDER BY date_req ASC',
        null);
  }


  Future ofFetchForUploadSalesman(code) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_tran_head WHERE sm_code ="$code" AND tran_stat ="Pending" AND sm_upload !="TRUE" ORDER BY date_req ASC',
        null);
  }

  //check if some transaction need to upload
  Future ofFetchForUploadSalesman2() async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_tran_head WHERE tran_stat ="Pending" AND sm_upload !="TRUE" ORDER BY date_req ASC',
        null);
  }

  Future ofFetchForUploadHepe(code) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_tran_head WHERE (tran_stat ="Delivered" OR tran_stat ="Returned" OR tran_stat="Partial") '
            'AND hepe_upload !="TRUE" AND tot_del_amt IS NOT NULL ORDER BY date_del ASC',
        null);
  }


  Future ofFetchForUploadCustomer(code) async {
    var client = await db;
    return client.rawQuery(
        'SELECT tran_no FROM tb_tran_head WHERE account_code ="$code" AND tran_stat ="Pending" AND sm_upload !="TRUE" ORDER BY date_req ASC',
        null);
  }

  Future ofFetchUpdateLog(type) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_updates_log WHERE type ="$type" ORDER BY doc_no DESC',
        null);
  }



  Future  getAllPromoProducts(companyCode)async{
    print("getAllProductst USER ID :: ${UserData.id}");
    var client = await db;
    return client.rawQuery(
      "SELECT * "
          "FROM item_masterfiles "
          "WHERE isPromo = '1'  "
          "GROUP BY itemcode, product_name "
          "ORDER BY isMust DESC, isPromo DESC",

    );

  }

  Future getAllProducts()async{

    print("getAllProductst USER ID :: ${UserData.id}");
    var client = await db;

    return client.rawQuery("SELECT * "
        "FROM item_masterfiles  "
        "WHERE status = '1' "
        "GROUP BY itemcode,product_name "
        "ORDER BY isMust DESC, isPromo DESC");
  }

  Future getPromoProducts(companyCode) async {
    var client = await db;

    return client.rawQuery(
        "SELECT COUNT(consolidated_transactions.itemcode) as trans, item.product_name, item.uom, item.company_code,"
            "item.itemcode, item.list_price_wtax, item.image, item.product_family "
            "FROM item_masterfiles AS item "
            "LEFT JOIN consolidated_transactions "
            "ON item.itemcode = consolidated_transactions.itemcode "
            "WHERE item.company_code = '$companyCode' "
            "GROUP BY item.itemcode,item.product_name "
            "ORDER BY trans DESC",null);

  }

  Future getProducts(companyCode) async {
    var client = await db;

    return client.rawQuery(
              "SELECT COUNT(consolidated_transactions.itemcode) as trans, item.product_name, item.uom, item.company_code,"
                  "item.itemcode, item.list_price_wtax, item.image, item.product_family, item.isMust, item.isPromo "
              "FROM item_masterfiles AS item "
              "LEFT JOIN consolidated_transactions "
              "ON item.itemcode = consolidated_transactions.itemcode "
              "WHERE item.company_code = '$companyCode' "
              "GROUP BY item.itemcode,item.product_name "
              "ORDER BY item.isMust DESC, item.isPromo DESC",null);
  }



  Future getUom(itemcode) async {
    var client = await db;
    return client.rawQuery(
        "SELECT * FROM item_masterfiles AS items INNER JOIN tbl_salesman_principal AS tsp ON "
            "items.company_code = tsp.vendor_code WHERE items.itemcode = '$itemcode' "
            " AND tsp.salesman_code = '${UserData.id}' AND items.itemcode != '0000'"
            " GROUP BY items.uom",
        null);
  }

  Future getOrderedItems(tranNo) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_tran_line WHERE tran_no ="$tranNo"  ORDER BY item_desc ASC',
        null);
  }
  Future getOrderedItemsserv(tranNo) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_tran_line WHERE tran_no ="$tranNo" AND (itm_stat = "Served" OR  itm_stat = "Delivered") ORDER BY item_desc ASC',
        null);
  }
  Future getOrderedItemsunserv(tranNo) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_unserved_items WHERE tran_no ="$tranNo" AND itm_stat = "Unserved" ORDER BY item_desc ASC',
        null);
  }
  Future getOrderedItemsdelever(tranNo) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_tran_line WHERE tran_no ="$tranNo" AND itm_stat = "Delivered"  ORDER BY item_desc ASC',
        null);
  }
  Future getOrderedItemsdelever2(tranNo) async {
    var client = await db;
    return client.rawQuery(
      '''
    SELECT * 
    FROM tb_tran_line 
    WHERE tran_no = ? 
      AND itm_stat = "Delivered" 
      AND CAST(del_qty AS INTEGER) != 0 
    ORDER BY item_desc ASC
    ''',
      [tranNo],
    );
  }
  Future getreturndelever(tranNo) async {
    var client = await db;
    return client.rawQuery(
      '''
    SELECT * 
    FROM tb_unserved_items
    WHERE tran_no = ? 
      AND itm_stat = "Returned" 
    ORDER BY item_desc ASC
    ''',
      [tranNo],
    );
  }
  Future getServedItems(tranNo) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_tran_line WHERE tran_no ="$tranNo" and nav_invoice_no!="" ORDER BY item_desc ASC',
        null);
  }

     Future getTranLinefromSqlite(tranNo) async  {
        var client = await db;
        return client.rawQuery(
            'SELECT tot_amt FROM tb_tran_line WHERE tran_no ="$tranNo" AND itm_stat = "Served" ORDER BY item_desc ASC',
            null);
      }

  Future fetchUpdateTranLine(tranNo) async  {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_tran_line WHERE tran_no ="$tranNo" AND nav_invoice_no!="" ORDER BY cast(tot_amt as double) ASC',
        null);
  }

  Future getTranlines()async{
  var client = await db;
  return client.rawQuery(
      'SELECT * FROM tb_tran_line GROUP BY tran_no ORDER BY item_desc ASC ',
      null);
  }

  Future getAllLine() async {
    var client = await db;
    return client.rawQuery(
        'SELECT doc_no,tran_no FROM tb_tran_line ORDER BY doc_no DESC', null);
  }

  Future getTransactionLine(tranNo) async {
    var client = await db;
    // return client.rawQuery(
    //     'SELECT * FROM tb_tran_line WHERE tran_no ="$tranNo" ORDER BY item_desc ASC',
    //     null);
    return client.rawQuery(
        'SELECT * FROM tb_tran_line WHERE tran_no ="$tranNo" ORDER BY item_desc ASC',
        null);
  }

  Future getReturnedTran(tranNo) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_returned_tran WHERE tran_no ="$tranNo"', null);
  }



  Future getItemImg(itmcode, uom) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM item_masterfiles WHERE itemcode ="$itmcode" AND uom="$uom"',
        null);
  }

  Future getItemImginTable(itmcode, uom) async {
    var client = await db;
    return client.rawQuery(
        'SELECT item_path FROM tbl_item_image WHERE item_code ="$itmcode" AND item_uom="$uom"',
        null);
  }


  Future setUom(itmcode, uom) async {
    var client = await db;
    return client.rawQuery(
        "SELECT * FROM item_masterfiles AS items INNER JOIN tbl_salesman_principal AS tsp ON "
        "items.company_code = tsp.vendor_code WHERE items.itemcode = '$itmcode' AND items.uom ='$uom' "
            " AND tsp.salesman_code = '${UserData.id}' AND items.itemcode != '0000'",
        null);
    // return client.rawQuery(
    //     'SELECT * FROM item_masterfiles WHERE itemcode ="$itmcode" AND uom ="$uom"',
    //     null);
    /*
     ""
     */
  }

  Future deleteItem(code, itmcode, uom) async {
    var client = await db;
    return client.rawQuery(
        'DELETE FROM tb_salesman_cart WHERE account_code ="$code" AND item_code ="$itmcode" AND item_uom ="$uom"',
        null);
  }


  Future deleteCart(code) async {
    var client = await db;
    return client.rawQuery(
        'DELETE FROM tb_salesman_cart WHERE account_code ="$code"', null);
  }

  Future searchAllItems(text) async {
    var client = await db;
    return await client.rawQuery(
        "SELECT * FROM item_masterfiles "
        "WHERE "
            // "items.itemcode = '$text' "
            "itemcode LIKE '%$text%' "
            "OR product_name LIKE '%$text%' "
            "AND itemcode != '0000' "
            "AND status = '1' "
        "GROUP BY "
            "itemcode, "
            "product_name "
        "ORDER BY "
            "isMust DESC, "
            "isPromo DESC", null);
  }

  Future searchAllPromoItems(text) async {
    var client = await db;
    return await client.rawQuery(
            "SELECT * FROM item_masterfiles  "
            "WHERE "
                "itemcode = '$text'"
                " OR product_name LIKE '%$text%'"
                " AND isPromo = '1'"
                " AND status = '1'"
                " AND itemcode != '0000' "
            "GROUP BY "
                "itemcode, "
                "product_name "
            "ORDER BY "
                "isMust DESC, "
                "isPromo DESC", null);
  }
  // Future searchItems(categ, text) async {
  //   var client = await db;
  //   return client.rawQuery(
  //       "SELECT * FROM item_masterfiles WHERE product_family ='$categ' AND product_name LIKE '%$text%' AND conversion_qty ='1'",
  //       null);
  // }
  Future searchItems(companyCode, text) async {
    print("serchITems");
    var client = await db;
    return await client.rawQuery(
           "SELECT * FROM item_masterfiles AS items "
           "WHERE "
               "items.itemcode = '$text' OR "
               "items.product_name LIKE '%$text%' AND "
               "items.company_code = '$companyCode' AND "
               "items.itemcode != '0000' "
               "items.status = '1' "
           "GROUP BY "
               "items.itemcode, "
               "items.product_name "
           "ORDER BY "
               "items.isMust DESC, "
               "items.isPromo DESC", null);

  }

  Future customerSearch(text, code) async {
    var client = await db;
    return client.rawQuery(
        "SELECT * FROM customer_master_files WHERE location_name LIKE '%$text%' OR account_code LIKE '%$text%' AND status ='1'",
        null);

  }

  Future salesmanHistorySearch(text) async {
    var client = await db;
    return client.rawQuery(
        "SELECT * FROM tb_tran_head WHERE store_name LIKE '%$text%'", null);
  }



  Future salesmanLogin(username, password) async {
    var client = await db;
    var emp = '';
    var passwordF = md5.convert(utf8.encode(password));
    List<Map> res = await client.rawQuery(
        'SELECT username, (1) as attempt,(0) as success FROM salesman_lists WHERE username = "$username"',
        null);
    if (res.isEmpty) {
      return emp;
    } else {
      var rsp = await client.rawQuery(
          'SELECT *,(1) as success FROM salesman_lists WHERE username = "$username" AND password = "$passwordF" ',
          null);
      if (rsp.isEmpty) {
        return emp;
        //return res; // to lock user if login fail 3 times.
      } else {
        return rsp;
      }
    }
  }
  Future getItemDailySales() async {
    String date = DateFormat("yyyy-MM-dd").format(new DateTime.now());
    String stat = 'Delivered';
    var client = await db;
    return client.rawQuery(
        'SELECT *,item_masterfiles.image,SUM(tb_tran_line.del_qty) as total FROM tb_tran_line INNER JOIN item_masterfiles on item_masterfiles.itemcode = tb_tran_line.itm_code AND item_masterfiles.uom =  tb_tran_line.uom WHERE tb_tran_line.itm_stat="$stat" AND strftime("%Y-%m-%d", tb_tran_line.date_del)="$date" GROUP BY tb_tran_line.itm_code',
        null);
  }

  Future getCustomerDailySales(id) async {
    String date = DateFormat("yyyy-MM-dd").format(new DateTime.now());
    String stat = 'Delivered';
    var client = await db;

      return client.rawQuery(
          'SELECT tb_tran_head.store_name,SUM(tb_tran_head.tot_del_amt) as total FROM tb_tran_head WHERE sm_code ="$id" AND tran_stat="$stat" GROUP BY account_code',
          null);

  }


  Future getAllTran() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM tb_tran_head ORDER BY id ASC', null);
  }

  Future getTodayBooked(id) async {
    String orderby = "Salesman";
    String date = DateFormat("yyyy-MM-dd").format(new DateTime.now());
    var client = await db;
    return client.rawQuery(
        'SELECT tran_no,tot_amt FROM tb_tran_head WHERE sm_code ="$id" AND order_by="$orderby" AND (strftime("%Y-%m-%d", date_req)="$date") AND sm_upload ="TRUE" ORDER BY tran_no ASC',
        null);
  }
  Future getcustomerBooked(id) async {
    String orderby = "Salesman";
    String date = DateFormat("yyyy-MM-dd").format(new DateTime.now());
    var client = await db;
    return client.rawQuery(
        'SELECT tran_no,tot_amt FROM tb_tran_head WHERE sm_code ="$id" AND order_by="$orderby" AND (strftime("%Y-%m-%d", date_req)="$date") AND sm_upload ="TRUE" ORDER BY tran_no ASC',
        null);
  }
  Future getWeeklyBooked(id, d1, d2) async {
    String weekstart = DateFormat("yyyy-MM-dd").format(d1);
    String weekend = DateFormat("yyyy-MM-dd").format(d2);
    String orderby = 'Salesman';
    var client = await db;
    return client.rawQuery(
        'SELECT tran_no,tot_amt FROM tb_tran_head WHERE sm_code ="$id" AND order_by="$orderby" AND (strftime("%Y-%m-%d", date_req)>="$weekstart") AND (strftime("%Y-%m-%d", date_req)<="$weekend") AND sm_upload ="TRUE"',
        null);
  }

  Future getMonthlyBooked(id) async {
    String date = DateFormat("yyyy-MM").format(new DateTime.now());
    String orderby = 'Salesman';
    var client = await db;
    return client.rawQuery(
        'SELECT tran_no,tot_amt FROM tb_tran_head WHERE sm_code ="$id" AND order_by="$orderby"  AND (strftime("%Y-%m", date_req)="$date") AND sm_upload ="TRUE"',
        null);
  }

  Future getYearlyBooked(id) async {
    String date = DateFormat("yyyy").format(new DateTime.now());
    String orderby = 'Salesman';
    var client = await db;
    return client.rawQuery(
        'SELECT tran_no,tot_amt FROM tb_tran_head WHERE sm_code ="$id" AND order_by="$orderby"  AND (strftime("%Y", date_req)="$date") AND sm_upload ="TRUE"',
        null);
  }

  ///
  ///
  ///
  ///
  ///
  /// MYSQL CODE
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  Future checkSMusername(String username) async {
    var url = Uri.parse(UrlAddress.url + 'checksm');

    final response = await http.post(url,
        headers: {"Accept": "Application/json"},
        body: {'username': encrypt(username)});
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }


  Future viewAllCustomers(code) async {
    var client = await db;
    return client.rawQuery(
        "SELECT * FROM customer_master_files WHERE status ='1' ORDER BY doc_no ASC ",
        null);
    // return client.rawQuery(

  }

  Future viewMultiCustomersList(String code) async {
    var client = await db;
    return client.rawQuery(
        "SELECT * FROM customer_master_files WHERE account_code = '$code' AND status='1' ORDER BY doc_no ASC LIMIT 100",
        null);
  }

  //GET SALESMAN TAGGING CUSTOMER
  Future getCustomerSalesman(BuildContext context)async{
    try {
      var url = Uri.parse(UrlAddress.url + 'getCustomerSalesman');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(response.body);
        return convertedDatatoJson;
      } else if (response.statusCode >= 400 || response.statusCode <= 499) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text(
                "Error: ${response.statusCode}. Your client has issued a malformed or illegal request.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
                () {});
      } else if (response.statusCode >= 500 || response.statusCode <= 599) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text("Error: ${response.statusCode}. Internal server error.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
                () {});
      }
    } on TimeoutException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
              () {});
    } on SocketException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
              () {});
    } on HttpException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("An HTTP error eccured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
              () {});
    } on FormatException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("Format exception error occured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
              () {});
    }
  }

  Future getSalesmanList(BuildContext context) async {
    print("getSalesmanList");
    // String url = UrlAddress.url + 'getsalesmanlist';
    try {
      var url = Uri.parse(UrlAddress.url + 'getsalesmanlist');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      print("getSalesmanList Response :: ${response.body}");
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(response.body);
        print("getSalesmanList :: StatusCode = 200");
        return convertedDatatoJson;
      } else if (response.statusCode >= 400 || response.statusCode <= 499) {
        print("getSalesmanList :: StatusCode = 400 - 499");
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text(
                "Error: ${response.statusCode}. Your client has issued a malformed or illegal request.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      } else if (response.statusCode >= 500 || response.statusCode <= 599) {
        print("getSalesmanList :: StatusCode = 500 - 599");
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text("Error: ${response.statusCode}. Internal server error.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      }
    } on TimeoutException {
      print("getSalesmanList :: TimeoutException");
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on SocketException {
      print("getSalesmanList :: SocketException");
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on HttpException {
      print("getSalesmanList :: HttpException");
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("An HTTP error eccured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on FormatException {
      print("getSalesmanList :: FormatException");
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("Format exception error occured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    }
  }
 getConsolidatedTrans(BuildContext context) async {
    // String url = UrlAddress.url + 'getsalesmanlist';
    try {
      var url = Uri.parse(UrlAddress.url + 'getConsolidatedTrans');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(response.body);
        return convertedDatatoJson;
      } else if (response.statusCode >= 400 || response.statusCode <= 499) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text(
                "Error: ${response.statusCode}. Your client has issued a malformed or illegal request.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
                () {});
      } else if (response.statusCode >= 500 || response.statusCode <= 599) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text("Error: ${response.statusCode}. Internal server error.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
                () {});
      }
    } on TimeoutException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
              () {});
    } on SocketException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
              () {});
    } on HttpException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("An HTTP error eccured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
              () {});
    } on FormatException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("Format exception error occured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
              () {});
    }
  }

  Future getCustomersList(BuildContext context,username) async {

      try {
        var url = Uri.parse('${UrlAddress.url}/getcustomerslist');
        final response = await retry(() => http.post(url,
            headers: {"Accept": "Application/json"},
            body: {'username': encrypt(username)}));
        var convertedDatatoJson = jsonDecode(decrypt(response.body));
        return convertedDatatoJson;
      } on TimeoutException {
      } on SocketException {
      } on HttpException {
      } on FormatException {}
    }

  Future getSalesmanPrincipal(BuildContext context,username) async {

    try {
      print(username);
      var url = Uri.parse('${UrlAddress.url}/getSalesmanPrincipal');
      final response = await retry(() => http.post(url,
          headers: {"Accept": "Application/json"},
          body: {'username': encrypt(username)}));
      var convertedDatatoJson = jsonDecode(decrypt(response.body));
      return convertedDatatoJson;
    } on TimeoutException {
    } on SocketException {
    } on HttpException {
    } on FormatException {}
  }



  Future getDiscountList(BuildContext context) async {
    print("getDiscountList !!!!");
    try {
      var url = Uri.parse(UrlAddress.url + 'getdiscountlist');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      print(response);
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(response.body);
        return convertedDatatoJson;

      } else if (response.statusCode >= 400 || response.statusCode <= 499) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text(
                "Error: ${response.statusCode}. Your client has issued a malformed or illegal request.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      } else if (response.statusCode >= 500 || response.statusCode <= 599) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text("Error: ${response.statusCode}. Internal server error.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      }
    } on TimeoutException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on SocketException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on HttpException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("An HTTP error eccured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on FormatException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("Format exception error occured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    }
  }

  Future getBankListonLine(BuildContext context) async {
    try {
      var url = Uri.parse(UrlAddress.url + 'getbanklist');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(response.body);
        return convertedDatatoJson;
      } else if (response.statusCode >= 400 || response.statusCode <= 499) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text(
                "Error: ${response.statusCode}. Your client has issued a malformed or illegal request.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      } else if (response.statusCode >= 500 || response.statusCode <= 599) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text("Error: ${response.statusCode}. Internal server error.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      }
    } on TimeoutException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on SocketException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on HttpException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("An HTTP error eccured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on FormatException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("Format exception error occured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    }
  }

  Future getOrderLimitonLine(BuildContext context) async {
    try {
      var url = Uri.parse(UrlAddress.url + 'getsmorderlimit');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(response.body);
        print("getOrderLimitonLine Response :: $convertedDatatoJson");
        return convertedDatatoJson;
      } else if (response.statusCode >= 400 || response.statusCode <= 499) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text(
                "Error: ${response.statusCode}. Your client has issued a malformed or illegal request.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      } else if (response.statusCode >= 500 || response.statusCode <= 599) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text("Error: ${response.statusCode}. Internal server error.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      }
    } on TimeoutException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on SocketException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on HttpException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("An HTTP error eccured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on FormatException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("Format exception error occured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    }
  }

  Future getUserAccessonLine(BuildContext context) async {
    try {
      var url = Uri.parse(UrlAddress.url + 'getuseraccesslist');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(response.body);
        return convertedDatatoJson;
      } else if (response.statusCode >= 400 || response.statusCode <= 499) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text(
                "Error: ${response.statusCode}. Your client has issued a malformed or illegal request.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      } else if (response.statusCode >= 500 || response.statusCode <= 599) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text("Error: ${response.statusCode}. Internal server error.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      }
    } on TimeoutException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on SocketException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on HttpException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("An HTTP error eccured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on FormatException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("Format exception error occured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    }
  }


  Future getItemList(BuildContext context,username) async {

    try {
      print(username);
      var url = Uri.parse('${UrlAddress.url}/getitemlist');
      final response = await retry(() => http.post(url,
          headers: {"Accept": "Application/json"},
          body: {'username': encrypt(username)}));
      var convertedDatatoJson = jsonDecode(decrypt(response.body));
      return convertedDatatoJson;
    } on TimeoutException {
    } on SocketException {
    } on HttpException {
    } on FormatException {}
  }


  Future getItemImgList(BuildContext context) async {
    try {
      var url = Uri.parse(UrlAddress.url + 'getitemimglist');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(response.body);
        return convertedDatatoJson;
      } else if (response.statusCode >= 400 || response.statusCode <= 499) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text(
                "Error: ${response.statusCode}. Your client has issued a malformed or illegal request.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      } else if (response.statusCode >= 500 || response.statusCode <= 599) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text("Error: ${response.statusCode}. Internal server error.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      }
    } on TimeoutException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on SocketException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on HttpException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("An HTTP error eccured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on FormatException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("Format exception error occured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    }
  }

  Future getCategList(BuildContext context) async {
    try {
      var url = Uri.parse(UrlAddress.url + 'getcateglist');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(response.body);
        return convertedDatatoJson;
      } else if (response.statusCode >= 400 || response.statusCode <= 499) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text(
                "Error: ${response.statusCode}. Your client has issued a malformed or illegal request.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      } else if (response.statusCode >= 500 || response.statusCode <= 599) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text("Error: ${response.statusCode}. Internal server error.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      }
    } on TimeoutException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on SocketException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on HttpException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("An HTTP error eccured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on FormatException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("Format exception error occured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    }
  }

  Future getTranHead(BuildContext context, String code) async {
    try {
      var url = Uri.parse(UrlAddress.url + 'getalltranhead');
      final response = await retry(() => http.post(url,
          headers: {"Accept": "Application/json"},
          body: {'sm_code': encrypt(code)}));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(decrypt(response.body));
        return convertedDatatoJson;
      } else if (response.statusCode >= 400 || response.statusCode <= 499) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text(
                "Error: ${response.statusCode}. Your client has issued a malformed or illegal request.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      } else if (response.statusCode >= 500 || response.statusCode <= 599) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text("Error: ${response.statusCode}. Internal server error.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      }
    } on TimeoutException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on SocketException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on HttpException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("An HTTP error eccured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on FormatException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("Format exception error occured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    }
  }

  Future getTranLine(BuildContext context) async {
    try {
      var url = Uri.parse(UrlAddress.url + 'getalltranline');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(decrypt(response.body));
        return convertedDatatoJson;
      } else if (response.statusCode >= 400 || response.statusCode <= 499) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text(
                "Error: ${response.statusCode}. Your client has issued a malformed or illegal request.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      } else if (response.statusCode >= 500 || response.statusCode <= 599) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text("Error: ${response.statusCode}. Internal server error.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      }
    } on TimeoutException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on SocketException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on HttpException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("An HTTP error eccured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on FormatException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("Format exception error occured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    }
  }

  Future getUnservedList(BuildContext context) async {
    try {
      var url = Uri.parse(UrlAddress.url + 'getunservedlist');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(decrypt(response.body));
        return convertedDatatoJson;
      } else if (response.statusCode >= 400 || response.statusCode <= 499) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text(
                "Error: ${response.statusCode}. Your client has issued a malformed or illegal request.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      } else if (response.statusCode >= 500 || response.statusCode <= 599) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text("Error: ${response.statusCode}. Internal server error.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      }
    } on TimeoutException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on SocketException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on HttpException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("An HTTP error eccured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on FormatException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("Format exception error occured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    }
  }

  Future getReturnedTranList(BuildContext context) async {
    try {
      var url = Uri.parse(UrlAddress.url + 'getreturnedlist');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(decrypt(response.body));
        return convertedDatatoJson;
      } else if (response.statusCode >= 400 || response.statusCode <= 499) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text(
                "Error: ${response.statusCode}. Your client has issued a malformed or illegal request.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      } else if (response.statusCode >= 500 || response.statusCode <= 599) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text("Error: ${response.statusCode}. Internal server error.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      }
    } on TimeoutException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on SocketException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on HttpException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("An HTTP error eccured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on FormatException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("Format exception error occured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    }
  }

  Future saveTransactions(
      BuildContext context,
      String userId,
      String divCode,
      String date,
      String custId,
      String storeName,
      String payment,
      String itmcount,
      String totamt,
      String stat,
      String signature,
      String smStat,
      String hepeStat,
      List line) async {
    try {
      var url = Uri.parse(UrlAddress.url + 'addtransactions');
      // final response = await retry(() => http.post(url, headers: {
      final response = await http.post(url, headers: {
            "Accept": "Application/json"
          }, body: {
            'sm_code': encrypt(userId),
            'div_code': encrypt(divCode),
            'date_req': encrypt(date),
            'account_code': encrypt(custId),
            'store_name': encrypt(storeName),
            'p_meth': encrypt("CASH"),
            'itm_count': encrypt(itmcount),
            'tot_amt': encrypt(totamt),
            'tran_stat': encrypt(stat),
            'auth_signature': encrypt(signature),
            'sm_upload': encrypt(smStat),
            'hepe_upload': encrypt(hepeStat),
            'line': jsonEncode(line),
          });
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(response.body);
        return convertedDatatoJson;
      } else if (response.statusCode >= 400 || response.statusCode <= 499) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text(
                "Error: ${response.statusCode}. Your client has issued a malformed or illegal request.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      } else if (response.statusCode >= 500 || response.statusCode <= 599) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text("Error: ${response.statusCode}. Internal server error.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      }
    } on TimeoutException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on SocketException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on HttpException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle, size: 50, color: Colors.red),
          Text("An HTTP error eccured. Please try again later.", textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on FormatException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("Format exception error occured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    }
  }

  Future checkStat() async {
    try {
      // String url = UrlAddress.url + 'checkstat';
      var url = Uri.parse(UrlAddress.url + 'checkstat');
      final response = await http.post(url, headers: {"Accept": "Application/json"}, body: {});
      var convertedDatatoJson = jsonDecode(response.body);
      return convertedDatatoJson;
    } on TimeoutException {
      return 'ERROR1';
    } on SocketException {
      return 'ERROR1';
    } on HttpException {
      return 'ERROR2';
    } on FormatException {
      return 'ERROR3';
    }
  }

  Future checkStatus(context) async {
    try {
      // String url = UrlAddress.url + 'checkstat';
      var url = Uri.parse(UrlAddress.url + 'checkstat');
      final response = await http.post(url, headers: {"Accept": "Application/json"}, body: {});
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(response.body);
        return convertedDatatoJson;
      } else if (response.statusCode >= 400 && response.statusCode <= 499) {
        customModal(context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text("Error: ${response.statusCode}. Your client has issued a malformed or illegal request.", textAlign: TextAlign.center),
            true, Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      } else if (response.statusCode >= 500 && response.statusCode <= 599) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text("Error: ${response.statusCode}. Internal server error.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      }
    } on TimeoutException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on SocketException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on HttpException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("An HTTP error eccured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on FormatException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("Format exception error occured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    }
  }


  Future checkDiscounted(id) async {
    var client = await db;
    List<Map> res = await client.rawQuery(
        'SELECT * FROM tbl_discounts WHERE cus_id ="$id"', null);
    if (res.isNotEmpty){
      return "TRUE";
    } else {
      return "FALSE";
    }
  }



  Future getChequeData(tranNo) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_cheque_data WHERE tran_no ="$tranNo"', null);
  }

  Future getUnservedOrders(tranNo) async {
    String stat = 'Unserved';
    var client = await db;
    return client.rawQuery(
        'SELECT tb_unserved_items.*,tb_tran_head.tran_stat FROM tb_unserved_items INNER JOIN tb_tran_head on tb_tran_head.tran_no = tb_unserved_items.tran_no WHERE tb_unserved_items.tran_no ="$tranNo" AND tb_unserved_items.itm_stat = "$stat"  ORDER BY doc_no ASC',
        null);
  }

  Future getReturnedOrders(tranNo) async {
    String stat = 'Returned';
    var client = await db;
    return client.rawQuery(
        'SELECT *,tb_unserved_items.tot_amt,tb_tran_head.tran_stat FROM tb_unserved_items INNER JOIN tb_tran_head on tb_tran_head.tran_no = tb_unserved_items.tran_no WHERE tb_unserved_items.tran_no ="$tranNo" AND tb_unserved_items.itm_stat = "$stat"  ORDER BY doc_no ASC',
        null);
  }

  Future getDeliveredOrders(tranNo) async {
    String stat = 'Delivered';
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_tran_line  WHERE tran_no ="$tranNo" AND nav_invoice_no!="" AND del_qty!=0 AND itm_stat = "$stat" ORDER BY doc_no ASC',
        null);
  }






  Future addfav(cusCode, itmCode, uom) async {
    var client = await db;
    return client.insert('tb_favorites', {
      'account_code'  : cusCode,
      'item_code'     : itmCode,
      'item_uom'      : uom,
    });
  }

  Future deleteFav(cusCode, itmCode, uom) async {
    var client = await db;
    return client.rawQuery(
        'DELETE FROM tb_favorites WHERE account_code = "$cusCode" AND item_code= "$itmCode" AND item_uom= "$uom"',
        null);
  }

  Future getFav(code) async {
    var client = await db;
    return client.rawQuery(
        'SELECT *,item_masterfiles.product_name,item_masterfiles.product_family,'
            'item_masterfiles.uom,item_masterfiles.list_price_wtax, '
            'item_masterfiles.image FROM tb_favorites INNER JOIN item_masterfiles '
            'on tb_favorites.item_code = item_masterfiles.itemcode '
            'WHERE tb_favorites.account_code ="$code" '
            'AND item_masterfiles.conversion_qty="1"',
        null);
  }


  //////////////////////////////////////////////

  Future loginUser(String username, String password) async {
    // String url = UrlAddress.url + 'signin';
    var url = Uri.parse(UrlAddress.url + 'signin');
    final response = await retry(() => http.post(url,
        headers: {"Accept": "Application/json"},
        body: {'username': encrypt(username), 'password': encrypt(password)}));
    var convertedDatatoJson = jsonDecode(response.body);
    return convertedDatatoJson;
  }


  Future changeSalesmanPassword(String code, String pass) async {
    // String url = UrlAddress.url + 'changesmpassword';
    var url = Uri.parse(UrlAddress.url + 'changesmpassword');
    final response = await retry(() => http.post(url,
        headers: {"Accept": "Application/json"},
        body: {'user_code': encrypt(code), 'password': encrypt(pass)}));
    var convertedDatatoJson = jsonDecode(response.body);
    return convertedDatatoJson;
  }



  Future addSmsCode(String username, String code, String mobile) async {
    // String url = UrlAddress.url + 'addsmscode';
    var url = Uri.parse(UrlAddress.url + 'addsmscode');
    final response = await retry(() => http.post(url, headers: {
          "Accept": "Application/json"
        }, body: {
          'username': encrypt(username),
          'smscode': encrypt(code),
          'mobile': encrypt(mobile)
        }));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future checkSmsCode(String username, String code) async {
    // String url = UrlAddress.url + 'checksmscode';
    var url = Uri.parse(UrlAddress.url + 'checksmscode');
    final response = await retry(() => http.post(url, headers: {
          "Accept": "Application/json"
        }, body: {
          'username': encrypt(username),
          'smscode': encrypt(code),
        }));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }



  Future updateSalesmanStatus(username) async {
    var client = await db;
    String stat = '0';
    return client.update(
        'salesman_lists',
        {
          'status': stat
        },
        where     : 'username = ?',
        whereArgs : [username]);
  }



  Future updateSalesmanStatusOnline(String username) async {
    String stat = '0';
    // String url = UrlAddress.url + 'updatesmstatus';
    var url = Uri.parse(UrlAddress.url + 'updatesmstatus');
    final response = await retry(() => http.post(url, headers: {
          "Accept": "Application/json"
        }, body: {
          'username'  : encrypt(username),
          'status'    : encrypt(stat),
        }));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future getSMPasswordHistory(String userId, String password) async {
    // String url = UrlAddress.url + 'checksmpasshistory';
    var url = Uri.parse(UrlAddress.url + 'checksmpasshistory');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url, headers: {
          "Accept": "Application/json"
        }, body: {
          'account_code': encrypt(userId),
          'password': encrypt(password),
        }));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }


  Future setLoginDevice(String code, String device) async {
    // String url = UrlAddress.url + 'setlogindevice';
    var url = Uri.parse(UrlAddress.url + 'setlogindevice');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url,
        headers: {"Accept": "Application/json"},
        body: {'account_code': encrypt(code), 'device': encrypt(device)}));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future checkLoginDevice(String code, String device) async {
    // String url = UrlAddress.url + 'checklogindevice';
    var url = Uri.parse(UrlAddress.url + 'checklogindevice');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url,
        headers: {"Accept": "Application/json"},
        body: {'account_code': code, 'device': device}));
    var convertedDatatoJson = jsonDecode(response.body);
    return convertedDatatoJson;
  }

  Future checkCustomerMessages(code) async {
    // String url = UrlAddress.url + 'checkcustomermessage';
    var url = Uri.parse(UrlAddress.url + 'checkcustomermessage');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url,
        headers: {"Accept": "Application/json"}, body: {'account_code': code}));
    var convertedDatatoJson = jsonDecode(response.body);
    return convertedDatatoJson;
  }

  Future getMessageHead(code) async {
    // String url = UrlAddress.url + 'getallmessagehead';
    var url = Uri.parse(UrlAddress.url + 'getallmessagehead');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url,
        headers: {"Accept": "Application/json"},
        body: {'account_code': encrypt(code)}));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future getMessage(ref) async {
    // String url = UrlAddress.url + 'getmessage';
    var url = Uri.parse(UrlAddress.url + 'getmessage');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url,
        headers: {"Accept": "Application/json"},
        body: {'ref_no': encrypt(ref)}));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future sendMsg(code, ref, msg) async {
    // String url = UrlAddress.url + 'addreply';
    var url = Uri.parse(UrlAddress.url + 'addreply');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url, headers: {
          "Accept": "Application/json"
        }, body: {
          'account_code': encrypt(code),
          'ref_no': encrypt(ref),
          'msg_body': encrypt(msg)
        }));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future changeMsgStat(ref) async {
    // String url = UrlAddress.url + 'changemsgstat';
    var url = Uri.parse(UrlAddress.url + 'changemsgstat');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url,
        headers: {"Accept": "Application/json"},
        body: {'ref_no': encrypt(ref)}));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future checkAppversion(tvar) async {
    var url = Uri.parse(UrlAddress.url + 'checkappversion');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url,
        headers: {"Accept": "Application/json"},
        body: {'tvar': encrypt(tvar)}));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future getAllMessageLog() async {
    // String url = UrlAddress.url + 'getallmessagehead';
    var url = Uri.parse(UrlAddress.url + 'getallmessageheadlog');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() =>
        http.post(url, headers: {"Accept": "Application/json"}, body: {}));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future updateSalesmanImg(String code, String img) async {
    // String url = UrlAddress.url + 'updatehepestatus';
    var url = Uri.parse(UrlAddress.url + 'updatesmimage');
    final response = await retry(() => http.post(url, headers: {
          "Accept": "Application/json"
        }, body: {
          'user_code' : encrypt(code),
          'img'       : encrypt(img),
        }));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future updateHepeImg(String code, String img) async {
    // String url = UrlAddress.url + 'updatehepestatus';
    var url = Uri.parse(UrlAddress.url + 'updatehepeimage');
    final response = await retry(() => http.post(url, headers: {
          "Accept": "Application/json"
        }, body: {
          'user_code' : encrypt(code),
          'img'       : encrypt(img),
        }));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  ///////////////////////SELECTIVE SYNC TRANSACTIONS
  Future getReturnedTranListSelective(
      BuildContext context, String d1, String d2) async {

    try {
      var url = Uri.parse(UrlAddress.url + 'getreturnedlistselective');
      final response = await retry(() => http.post(url, headers: {
            "Accept": "Application/json"
          }, body: {
            'date1': encrypt(d1),
            'date2': encrypt(d2),
          }));

      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(decrypt(response.body));
        return convertedDatatoJson;
      } else if (response.statusCode >= 400 || response.statusCode <= 499) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text(
                "Error: ${response.statusCode}. Your client has issued a malformed or illegal request.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      } else if (response.statusCode >= 500 || response.statusCode <= 599) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text("Error: ${response.statusCode}. Internal server error.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      }
    } on TimeoutException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on SocketException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on HttpException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("An HTTP error eccured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on FormatException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("Format exception error occured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    }
  }

  Future getUnservedListSelective(
      BuildContext context, String d1, String d2) async {
    try {
      var url = Uri.parse(UrlAddress.url + 'getunservedlistselective');
      final response = await retry(() => http.post(url, headers: {
            "Accept": "Application/json"
          }, body: {
            'date1': encrypt(d1),
            'date2': encrypt(d2),
          }));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(decrypt(response.body));
        return convertedDatatoJson;
      } else if (response.statusCode >= 400 || response.statusCode <= 499) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text(
                "Error: ${response.statusCode}. Your client has issued a malformed or illegal request.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      } else if (response.statusCode >= 500 || response.statusCode <= 599) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text("Error: ${response.statusCode}. Internal server error.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      }
    } on TimeoutException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on SocketException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on HttpException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("An HTTP error eccured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on FormatException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("Format exception error occured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    }
  }
      getArTransactions() async{
        var url = Uri.parse(UrlAddress.url + 'getArThead');
        final response = await retry(() => http.post(url, headers: {
          "Accept": "Application/json"
        }, body: {}));

        var res = jsonDecode(response.body);
        print('ang res kay $res');
        return res;
      }
  Future getTranLineSelective(
      BuildContext context, String division, String d1, String d2) async {
    try {
      var url = Uri.parse(UrlAddress.url + 'getalltranlineselective');
      final response = await http.post(url, headers: {
            "Accept": "Application/json"
          }, body: {
            'sm_code': encrypt(division),
            'date1': encrypt(d1),
            'date2': encrypt(d2),
          });
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(decrypt(response.body));
        return convertedDatatoJson;
      } else if (response.statusCode >= 400 || response.statusCode <= 499) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text(
                "Error: ${response.statusCode}. Your client has issued a malformed or illegal request.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      } else if (response.statusCode >= 500 || response.statusCode <= 599) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text("Error: ${response.statusCode}. Internal server error.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      }
    } on TimeoutException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on SocketException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on HttpException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("An HTTP error eccured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on FormatException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("Format exception error occured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    }
  }



  Future getTranHeadSelective(
      BuildContext context, String code, String d1, String d2) async {
    try {
      var url = Uri.parse(UrlAddress.url + 'getalltranheadselective');
      final response = await retry(() => http.post(url, headers: {
            "Accept": "Application/json"
          }, body: {
            'sm_code': encrypt(code),
            'date1': encrypt(d1),
            'date2': encrypt(d2)
          }));

      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(decrypt(response.body));
        return convertedDatatoJson;
      } else if (response.statusCode >= 400 || response.statusCode <= 499) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text(
                "Error: ${response.statusCode}. Your client has issued a malformed or illegal request.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      } else if (response.statusCode >= 500 || response.statusCode <= 599) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text("Error: ${response.statusCode}. Internal server error.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
            () {});
      }
    } on TimeoutException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on SocketException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on HttpException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("An HTTP error eccured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    } on FormatException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("Format exception error occured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
          () {});
    }
  }

  Future tryCatch(BuildContext context, Function() function) async {

    try {
      final response = await retry(function).timeout(Duration(seconds: 20));

      if (response.statusCode == 200) {
        // print("STATUS :: ${response.statusCode}");
        var convertedDatatoJson = jsonDecode(response.body);
        return convertedDatatoJson;
      } else if (response.statusCode >= 400 && response.statusCode <= 499) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text(
                "Error: ${response.statusCode}. Your client has issued a malformed or illegal request.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
                () {});
      } else if (response.statusCode >= 500 && response.statusCode <= 599) {
        customModal(
            context,
            Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            Text("Error: ${response.statusCode}. Internal server error.",
                textAlign: TextAlign.center),
            true,
            Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            '',
                () {});
      }
    } on TimeoutException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
              () {});
    } on SocketException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text(
              "Connection timed out. Please check internet connection or proxy server configurations.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
              () {});
    } on HttpException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("An HTTP error eccured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
              () {});
    } on FormatException {
      customModal(
          context,
          Icon(CupertinoIcons.exclamationmark_circle,
              size: 50, color: Colors.red),
          Text("Format exception error occured. Please try again later.",
              textAlign: TextAlign.center),
          true,
          Icon(
            CupertinoIcons.checkmark_alt,
            size: 25,
            color: Colors.greenAccent,
          ),
          'Okay',
              () {});
    }
  }

  Future uploadCoveragePlan(BuildContext context, List mcv) async {
    print("upload CoveragePlan");
    var url = Uri.parse(UrlAddress.url + "UploadCoveragePlan");
    final response = await tryCatch(context, () => http.post(url, headers: {
      "Accept": "Application/json"
    }, body: {
      "mcv" : json.encode(mcv),
    }));

    return response;

  }

  Future getMonthlyCoveragePlan(BuildContext context) async {
    print("getMont");
    var url = Uri.parse(UrlAddress.url + "getMonthlyCoveragePlan");
    final response = await tryCatch(context, () => http.post(url, headers: {
      "Accept": "Application/json"
    }, body: {
      "userCode" : UserData.id,
    }));

    return response;

  }

  Future insertMonthlyCoveragePlan(mcv) async {
    print("INSERTING");
    print("Receive Data :: $mcv");
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < mcv.length; i++) {
      var row = {
        'sm_code'         : mcv[i]['sm_code'],
        'customer_code'   : mcv[i]['customer_code'],
        'date_sched'      : mcv[i]['date_sched'],
        'start_date'      : mcv[i]['start_date'],
        'end_date'        : mcv[i]['end_date'],
        'visit_status'    : mcv[i]['visit_status']
      };
      batch.insert('${MonthlyCoveragePlan.tblMonthlyCoveragePlan}', row);
    }
    await batch.commit(noResult: true);
  }





  Future userAppVersion(BuildContext context, String userName, String appVersion) async{
    var url = Uri.parse(UrlAddress.url + "userAppVersion");
    final response = await tryCatch(context, () => http.post(url, headers: {
      "Accept": "Application/json"
    }, body: {
      'userName'       : encrypt(userName),
      'version'       : encrypt(appVersion),
    }));
    return response;
  }
  Future hepeAppVersion(BuildContext context, String userName, String appVersion) async{
    var url = Uri.parse(UrlAddress.url + "hepeAppVersion");
    final response = await tryCatch(context, () => http.post(url, headers: {
      "Accept": "Application/json"
    }, body: {
      'userName'       : encrypt(userName),
      'version'       : encrypt(appVersion),
    }));
    return response;
  }


  Future getSQFliteMonthlyCoveragePlan() async {
    var client = await db;
    return client.rawQuery(
        "SELECT * FROM customer_master_files "
            "INNER JOIN monthly_coverage_plan "
            "ON monthly_coverage_plan.customer_code = customer_master_files.account_code "
            "WHERE monthly_coverage_plan.sm_code = '${UserData.id}'");
  }

  Future getSQFliteMCV() async {
    var client = await db;
    return client.rawQuery(
        "SELECT * FROM monthly_coverage_plan "
            "WHERE sm_code = '${UserData.id}'");
  }

  Future deleteSQFliteMonthlyCoveragePlan() async {
    var client = await db;
    return client.rawQuery(
        'DELETE FROM monthly_coverage_plan '
            'WHERE sm_code = "${UserData.id}"');
  }

  Future UpdateUserMCVOne(String customerCode, String dateSched) async {
    print("UPDATE");
    var client = await db;
    return client.rawQuery(
        'Update monthly_coverage_plan Set visit_status = "1" '
            'WHERE sm_code = "${UserData.id}" And customer_code = "$customerCode" And date_sched = "$dateSched"');
  }

  Future UpdateUserMCVZero(String customerCode, String dateSched) async {
    print("UPDATE");
    var client = await db;
    return client.rawQuery(
        'Update monthly_coverage_plan Set visit_status = "0" '
            'WHERE sm_code = "${UserData.id}" And customer_code = "$customerCode" And date_sched = "$dateSched"');
  }

  Future checkConnection(BuildContext context) async {
    var url = Uri.parse(UrlAddress.url + 'checkstat');
    /*final response = await http.post(url, headers: {"Accept": "Application/json"}, body: {});
    var convertedDatatoJson = jsonDecode(response.body);
    return convertedDatatoJson;*/

    final response = await tryCatch(context, () => http.post(url, headers: {
      "Accept": "Application/json"
    }, body: {}));
    print("CONNECTION RESPONSE :: $response");
    return response;
  }
}
