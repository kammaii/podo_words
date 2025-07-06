import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:podo_words/data_storage.dart';
import 'package:podo_words/logo.dart';
import 'package:podo_words/my_colors.dart';
import 'package:podo_words/show_snack_bar.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:intl/intl.dart';


class Premium extends StatefulWidget {
  @override
  State<Premium> createState() => _PremiumState();
}

class _PremiumState extends State<Premium> {
  late Package package;
  bool btnEnabled = false;
  Color btnColor = Colors.grey;
  bool isRestoring = false;
  String originalPrice = "";
  String discountPrice = "";
  static const String productId = "podo_words_1000";

  getOfferings() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        package = offerings.current!.availablePackages[0];
        print(package);
        String currency = package.storeProduct.currencyCode;
        var f = NumberFormat('$currency ###,###,###,###.##');
        double price = package.storeProduct.price;
        discountPrice = f.format(price);
        originalPrice = f.format(price.round() * 10);
        btnEnabled = true;
        btnColor = MyColors().purple;
      }
    } on PlatformException catch (e) {
      showErrorMsg('getOfferings error', e);
    }
  }


  makePurchase() async {
    try {
      CustomerInfo purchaserInfo = await Purchases.purchasePackage(package);
      var isPremium = purchaserInfo.entitlements.all[productId]!.isActive;
      if (isPremium) {
        setPremiumUser();
      }
    } on PlatformException catch (e) {
      showErrorMsg('Purchase error', e);
    }
  }

  setPremiumUser() {
    DataStorage().setPremiumUser(true);
    ShowSnackBar().getSnackBar(context, 'Thank you for purchasing.');
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Logo()), (Route<dynamic> route) => false);
  }

  restorePurchase() async {
    setState(() {
      isRestoring = true;
      btnEnabled = false;
      btnColor = Colors.grey;
    });
    try {
      CustomerInfo restoredInfo = await Purchases.restorePurchases();
      print('리스토어: $restoredInfo');
      var isPremium = restoredInfo.entitlements.all[productId];
      print('이즈액티브 : $isPremium');
      if(isPremium != null && isPremium.isActive) {
        setPremiumUser();
      } else {
        Get.snackbar('restorePurchase error', 'There\'s no purchasing record');
      }

    } on PlatformException catch (e) {
      showErrorMsg('restorePurchase error', e);
    }
    setState(() {
      isRestoring = false;
      btnEnabled = true;
      btnColor = MyColors().purple;
    });
  }

  showErrorMsg(String title, PlatformException e) {
    var errorCode = PurchasesErrorHelper.getErrorCode(e);
    Get.snackbar(title, errorCode.toString());
  }


  @override
  void initState() {
    super.initState();
    getOfferings().whenComplete(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: MyColors().purple),
          onPressed: () {Navigator.pop(context);},
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Get podo premium', textScaleFactor: 1.5,
                        style: TextStyle(
                            color: MyColors().purple,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              Material(
                                shape: CircleBorder(),
                                elevation: 5.0,
                                child: Container(
                                  height: 100.0,
                                  width: 100.0,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle
                                  ),
                                ),
                              ),
                              Container(
                                height: 100.0,
                                width: 100.0,
                                child: Icon(Icons.lock_open,
                                  size: 50.0,
                                  color: MyColors().purple,
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 20.0),
                          Text('Unlock every lessons', textScaleFactor: 1.3,
                            style: TextStyle(
                                color: MyColors().purple,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text('(life-time)', textScaleFactor: 1.2,
                            style: TextStyle(
                                color: MyColors().purple,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                      Text(discountPrice, textScaleFactor: 2,
                        style: TextStyle(
                            color: MyColors().purple,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.0),
                IgnorePointer(
                  ignoring: !btnEnabled,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors().purple,
                        elevation: 5.0,
                        shape: StadiumBorder(),

                   ),
                    onPressed: (){
                      print('인앱구매 시작');
                      makePurchase();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Center(
                          child: Text('Get Premium', textScaleFactor: 1.3, style: TextStyle(color: Colors.white),
                          )
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          restorePurchase();
                        },
                        child: Text('Do you want to restore your purchase?', style: TextStyle(color: MyColors().purple)),
                      ),
                      SizedBox(width: 10.0),
                      Visibility(
                        visible: isRestoring,
                        child: SizedBox(
                          width: 10.0, height: 10.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.0,
                            color: MyColors().purple,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Text('The fee will be charged after the confirmation of purchase.'
                    ' This is one-time purchase for life-time use. You can request a refund within 24 hours.'
                    ' To report a system error, please contact \'akorean.app@gmail.com\'.',
                  textScaleFactor: 1,
                  style: TextStyle(color: Colors.grey.shade400),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
