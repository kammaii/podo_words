import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:podo_words/data_storage.dart';
import 'package:podo_words/logo.dart';
import 'package:podo_words/my_colors.dart';
import 'package:podo_words/show_snack_bar.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class Premium extends StatefulWidget {
  @override
  State<Premium> createState() => _PremiumState();
}

class _PremiumState extends State<Premium> {
  late Package package;
  bool haveOfferings = false;
  Color btnColor = Colors.grey;
  bool isRestoring = false;
  String originalPrice = "";
  String discountPrice = "";

  getOfferings() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        package = offerings.current!.availablePackages[0];
        String currency = package.product.currencyCode;
        double price = package.product.price;
        discountPrice = currency + ' ' + price.toStringAsFixed(2);
        originalPrice = currency + ' ' + (price.round() * 10).toString();
        haveOfferings = true;
        btnColor = MyColors().purple;
      }
    } on PlatformException catch (e) {
      showErrorMsg('getOfferings error', e);
    }
  }

  makePurchase() async {
    try {
      PurchaserInfo purchaserInfo = await Purchases.purchasePackage(package);
      var isPro = purchaserInfo.entitlements.all["test"]!.isActive;
      if (isPro) {
        DataStorage().setPremiumUser(true);
        ShowSnackBar().getSnackBar(context, 'Thank you for purchasing.');
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Logo()), (Route<dynamic> route) => false);
      }
    } on PlatformException catch (e) {
      showErrorMsg('Purchase error', e);
    }
  }

  restorePurchase() async {
    setState(() {
      isRestoring = true;
    });
    try {
      PurchaserInfo restoredInfo = await Purchases.restoreTransactions();
      print('리스토어 : $restoredInfo');
    } on PlatformException catch (e) {
      showErrorMsg('restorePurchase error', e);
    }
    setState(() {
      isRestoring = false;
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
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              children: [
                Text('Get podo premium', textScaleFactor: 1.5,
                  style: TextStyle(
                      color: MyColors().purple,
                      fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 20.0),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 30.0),
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
                      SizedBox(height: 30.0),
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
                      SizedBox(height: 50.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(originalPrice, textScaleFactor: 1.5,
                            style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: MyColors().navy,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Icon(Icons.arrow_forward_outlined, color: MyColors().navy),
                          ),
                          Text(discountPrice, textScaleFactor: 2,
                            style: TextStyle(
                                color: MyColors().purple,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.0),
                IgnorePointer(
                  ignoring: !haveOfferings,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 5.0,
                      shape: StadiumBorder(),
                      primary: btnColor
                    ),
                    onPressed: (){
                     // 인앱구매 실행
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
                SizedBox(height: 20.0),
                Row(
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
                SizedBox(height: 10.0),
                Text('The payment will be charged after the confirmation of purchase.'
                    ' This purchase is one-time purchase. You can request a refund within 24 hours.'
                    ' Premium benefit is applied only to the device that have been paid.'
                    ' If you have any trouble with purchasing, please contact \'akorean.app@gmail.com\'.',
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
