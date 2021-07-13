import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:podo_words/main.dart';
import 'package:podo_words/purchasable_product.dart';

class Purchase extends ChangeNotifier{

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
      print('에러 : $error');
    }
  }

  Future<void> loadPurchases() async {
    final available = await iapConnection.isAvailable();

    if (!available) {
      notifyListeners();
      print('LoadPurchases FAILED');
      return;
    }

    const ids = <String> {
      inAppPurchaseId
    };

    final response = await iapConnection.queryProductDetails(ids);
    response.notFoundIDs.forEach((element) {
      print('Purchase $element not found');
    });
    products = response.productDetails.map((e) => PurchasableProduct(e)).toList();
    notifyListeners();
  }


  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> buy(PurchasableProduct product) async {
    final purchaseParam = PurchaseParam(productDetails: product.productDetails);
    await iapConnection.buyConsumable(purchaseParam: purchaseParam);
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    // Handle purchases here
    print('업데이트 : $purchaseDetailsList');
    PurchaseDetails purchaseDetails = purchaseDetailsList[0];

    if(purchaseDetails.status == PurchaseStatus.purchased) {
      //todo: 구매완료 코드 추가
      print('구매완료!');
    }

    if(purchaseDetails.pendingCompletePurchase) {
      iapConnection.completePurchase(purchaseDetails);
    }
  }

  void _updateStreamOnDone() {
    print('Done!');
    _subscription.cancel();
  }

  void _updateStreamOnError(dynamic error) {
    //Handle error here
    print('StreamError : $error');
  }
}