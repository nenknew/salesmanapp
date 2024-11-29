//FOR LIVE
// class UrlAddress {
//   static String url = 'https://distApp2.alturush.com/';
//   // static String itemImg = 'https://distribution.alturush.com/assets/photos/';
//   static String userImg = url + 'img/user/';
//   static String itemImg = url + 'img/';
//   static String chequeImg =
//       'https://distribution.alturush.com/assets/photos/cheque/';
//   static String sliderImg =
//       'https://distribution.alturush.com/assets/photos/slider_img/';
//   static String categImg =
//       'https://distribution.alturush.com/assets/photos/category/';
//   static String appLink =
//       'https://distribution.alturush.com/downloads/salesmanApp.apk';
// }


// LIVE URL static String url = 'https://distApp2.alturush.com/';

class UrlAddress {
  static String server = "LIVE";
  static String live_url = 'https://distApp2.alturush.com/';
  // static String url = 'https://distApp2.alturush.com/'; //LIVE
  static String url = 'http://172.16.43.150:83/'; //LOCAL
  //  static String url = 'http://172.16.43.125/distapp2/';

  static String kaloyurl = 'https://distribution.alturush.com/'; //live
  static String kaloyurl2 = 'http://172.16.43.195:82/'; //local

  // static String kaloyurl = 'http://172.16.43.195:8081/';
  static bool isLocal = true;
  // static String url = 'http://172.16.161.100/distribution/';
  // static String url = 'https://distApp2.alturush.com/';
  static String userImg = live_url + 'img/user/';
  static String itemImg = live_url + 'img/';
  static String chequeImg = live_url + 'img/cheque/';
  static String categImg = live_url + 'img/category/';
  static String principalImg = 'https://distribution.alturush.com/principal-images/';
  //static String principalImg = 'http://172.16.43.155:8001/principal-images/';
  static String appLink = 'https://distribution.alturush.com/downloads/salesmanApp.apk?${DateTime.now().millisecondsSinceEpoch}';

  // static String sliderImg =
  // 'https://distribution.alturush.com/assets/photos/slider_img/';
}

//Uncomment this if you want to use local
/*class UrlAddress {
  static String server = "LOCAL";
  static String live_url = 'http://172.16.43.180/distapp2/';
  //static String live_url = 'https://distApp2.alturush.com/';
  static String url = 'http://172.16.43.180/distapp2/';

  // static String url = 'http://172.16.161.100/distribution/';
  //static String url = 'https://distApp2.alturush.com/';
  static String userImg = live_url + 'img/user/';
  static String itemImg = live_url + 'img/';
  static String chequeImg = live_url + 'img/cheque/';
  static String categImg = live_url + 'img/category/';
  static String principalImg = 'https://distribution.alturush.com/principal-images/';
  //static String principalImg = 'http://172.16.43.155:8001/principal-images/';
  static String appLink = 'https://distribution.alturush.com/downloads/salesmanApp.apk';

// static String sliderImg =
// 'https://distribution.alturush.com/assets/photos/slider_img/';
}*/

/*class UrlAddress {
  static String server = "LOCAL";
  static String live_url = 'http://172.16.43.180/distapp2.alturush.com/';
  //static String live_url = 'https://distApp2.alturush.com/';
  static String url = 'http://172.16.43.180/distapp2.alturush.com/';

  // static String url = 'http://172.16.161.100/distribution/';
  //static String url = 'https://distApp2.alturush.com/';
  static String userImg = live_url + 'img/user/';
  static String itemImg = live_url + 'img/';
  static String chequeImg = live_url + 'img/cheque/';
  static String categImg = live_url + 'img/category/';
  // static String principalImg = 'https://distribution.alturush.com/principal-images/';
  static String principalImg = 'http://172.16.43.155:8001/principal-images/';
  static String appLink = 'https://distribution.alturush.com/downloads/salesmanApp.apk';

// static String sliderImg =
// 'https://distribution.alturush.com/assets/photos/slider_img/';
}*/
