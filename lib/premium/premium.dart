import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:podo_words/common/data_storage.dart';
import 'package:podo_words/logo.dart';
import 'package:podo_words/common/my_colors.dart';
import 'package:podo_words/common/show_snack_bar.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Premium extends StatefulWidget {
  @override
  State<Premium> createState() => _PremiumState();
}

class _PremiumState extends State<Premium> {
  Package? selectedPackage;
  bool btnEnabled = false;
  Color btnColor = Colors.grey;
  bool isRestoring = false;
  int selectedPlan = 0;
  late Future<Offerings> offerings;
  late List<Package> packages;

  @override
  void initState() {
    super.initState();
    offerings = Purchases.getOfferings();
  }

  makePurchase() async {
    selectedPackage ??= packages[0];
    try {
      CustomerInfo purchaserInfo = await Purchases.purchasePackage(selectedPackage!);
      final isPremium = purchaserInfo.entitlements.active.isNotEmpty;
      if (isPremium) {
        setPremiumUser();
      }
    } on PlatformException catch (e) {
      showErrorMsg('Purchase error', e);
    }
  }

  setPremiumUser() {
    DataStorage().isPremiumUser = true;
    ShowSnackBar().getSnackBar(context, 'Thank you for purchasing.');
    Get.offAll(() => Logo());
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
      final isPremium = restoredInfo.entitlements.active.isNotEmpty;
      print('이즈액티브 : $isPremium');
      if (isPremium) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: MyColors().purple),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Text(
                'Upgrade to Podo Words Premium',
                style: TextStyle(color: MyColors().purple, fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Expanded(
                child: Column(
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
                            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          ),
                        ),
                        Container(
                          height: 100.0,
                          width: 100.0,
                          child: Icon(
                            Icons.block_rounded,
                            size: 50.0,
                            color: MyColors().purple,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Remove Ads',
                      style: TextStyle(
                        color: MyColors().purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              FutureBuilder<Offerings>(
                  future: offerings,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.connectionState != ConnectionState.waiting) {
                      packages = snapshot.data!.current!.availablePackages;
                      return ListView.separated(
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        shrinkWrap: true,
                        itemCount: packages.length,
                        itemBuilder: (context, index) {
                          final package = packages[index];
                          final price = package.storeProduct.priceString;
                          String plan = '';
                          String description = '';
                          final packageType = package.packageType;
                          if (packageType == PackageType.lifetime) {
                            plan = 'Lifetime';
                            description = 'Pay once, learn forever.';
                          } else if (packageType == PackageType.monthly) {
                            plan = 'Monthly';
                            description = 'Affordable monthly plan.';
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(10),
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                      color: selectedPlan == index ? MyColors().purple : Colors.transparent,
                                      width: 2),
                                ),
                                backgroundColor: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedPackage = package;
                                  selectedPlan = index;
                                });
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(plan,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: MyColors().purple)),
                                      selectedPlan == index
                                          ? Icon(Icons.check_circle, color: MyColors().green)
                                          : const SizedBox.shrink()
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(description, style: TextStyle(fontSize: 15, color: MyColors().navy)),
                                  Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(price,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                                      packageType == PackageType.monthly
                                          ? Text(' / month',
                                              style: TextStyle(fontSize: 15, color: Colors.black))
                                          : const SizedBox.shrink()
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  }),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors().purple,
                  elevation: 5.0,
                  shape: StadiumBorder(),
                ),
                onPressed: () {
                  print('인앱구매 시작');
                  makePurchase();
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                      child: Text(
                    'Start Premium',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  )),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      restorePurchase();
                    },
                    child: Text('Restore Purchase',
                        style: TextStyle(color: MyColors().purple, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                  SizedBox(width: 10.0),
                  Visibility(
                    visible: isRestoring,
                    child: SizedBox(
                      width: 10.0,
                      height: 10.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.0,
                        color: MyColors().purple,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(10),
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: 'Terms of Use',
                      style: TextStyle(color: Colors.blue, fontSize: 15),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launchUrl(Uri.parse('https://www.podokorean.com/words_termsOfUse.html'));
                        },
                    ),
                    TextSpan(text: ' and ', style: TextStyle(color: Colors.grey, fontSize: 15)),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(color: Colors.blue, fontSize: 15),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launchUrl(Uri.parse('https://www.podokorean.com/words_privacyPolicy.html'));
                        },
                    )
                  ]),
                ),
              ),
              const SizedBox(height: 50),
              // Text(
              //   'Premium subscriptions are automatically renewed and billed through the payment method registered to your app store account. Subscriptions will renew at the current price unless canceled at least 24 hours before the end of the current billing period. You may cancel auto-renewal at any time through your device’s account settings. Once canceled, your subscription will remain active until the end of the current period. To report a system error, please contact \'contact@podokorean.com\'.',
              //   style: TextStyle(fontSize: 15),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
