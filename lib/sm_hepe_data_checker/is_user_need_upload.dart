import 'package:salesmanapp/db/db_helper.dart';
import 'package:salesmanapp/userdata.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IsUserNeedUpload{
  final db = DatabaseHelper();
  Future<bool> isUserNeedUpload()async{
    print("isUserNeedUpload function start");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('last_user_login') ?? ''.toString();
    List salesmanDataToUpload = [];
    // List hePeDataToUpload = await db.ofFetchForUploadHepe("");
    if(userId != ""){
      salesmanDataToUpload = await db.ofFetchForUploadSalesman(userId);
    }
print('ffff$salesmanDataToUpload');
    if(salesmanDataToUpload.isEmpty){
      print("sm is empty");
      DataToUploadChecker.isSalesmanNeedUpload = false;
    }else{
      DataToUploadChecker.isSalesmanNeedUpload = true;
    }

      DataToUploadChecker.isHePeNeedUpload = true;


    if(DataToUploadChecker.isSalesmanNeedUpload ){
      print("return true");
      return true;
    }else{
      print("return false");
      return false;
    }
  }
}