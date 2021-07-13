import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:podo_words/data_storage.dart';
import 'package:podo_words/main.dart';
import 'package:podo_words/purchasable_product.dart';
import 'package:podo_words/show_snack_bar.dart';

import 'logo.dart';


class Purchase{

  static final Purchase _instance = Purchase.init();


  factory Purchase() {
    return _instance;
  }

  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<PurchasableProduct> products = [];

  final iapConnection = IAPConnection.instance;
  static const String inAppPurchaseId = 'test';

  Purchase.init() {
    print('purchase 초기화');
    try {
      final purchaseUpdated = iapConnection.purchaseStream;
      _subscription = purchaseUpdated.listen(
        _onPurchaseUpdate,
        onDone: _updateStreamOnDone,
        onError: _updateStreamOnError,
      );
      loadPurchases();

    } on Exception catch (error) {
      Get.snackbar('Purchase init error', '$error');
    }
  }

  Future<void> loadPurchases() async {
    final available = await iapConnection.isAvailable();

    if (!available) {
      Get.snackbar('loadPurchases failed', '');
      return;
    }

    const ids = <String> {
      inAppPurchaseId
    };

    final response = await iapConnection.queryProductDetails(ids);
    response.notFoundIDs.forEach((element) {
      Get.snackbar('not found IDs', '$element');
    });
    products = response.productDetails.map((e) => PurchasableProduct(e)).toList();
  }

  @override
  void dispose() {
    _subscription.cancel();
  }

  Future<void> buy(PurchasableProduct product) async {
    final purchaseParam = PurchaseParam(productDetails: product.productDetails);
    await iapConnection.buyConsumable(purchaseParam: purchaseParam);
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    PurchaseDetails purchaseDetails = purchaseDetailsList[0];

    if(purchaseDetails.status != PurchaseStatus.pending) {
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        DataStorage().setPremiumUser(true);
        if (purchaseDetails.pendingCompletePurchase) {
          iapConnection.completePurchase(purchaseDetails);
        }
        Get.offAll(Logo());

      } else if(purchaseDetails.status == PurchaseStatus.error) {
        Get.snackbar('Purchasing is failed', 'Please try it again');
      }
    }
  }

  void _updateStreamOnDone() {
    _subscription.cancel();
  }

  void _updateStreamOnError(dynamic error) {
    Get.snackbar('StreamError','$error');
  }
}