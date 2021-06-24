import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:podo_words/main.dart';
import 'package:podo_words/purchasable_product.dart';

class WidgetPurchase extends ChangeNotifier {
  //DashCounter counter;
  //StoreState storeState = StoreState.notAvailable;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<PurchasableProduct> products = [
    PurchasableProduct(
      'Spring is in the air',
      'Many dashes flying out from their nests',
      '\$0.99',
    ),
    PurchasableProduct(
      'Jet engine',
      'Doubles you clicks per second for a day',
      '\$1.99',
    ),
  ];

  bool get beautifiedDash => _beautifiedDashUpgrade;
  // ignore: prefer_final_fields
  bool _beautifiedDashUpgrade = false;
  final iapConnection = IAPConnection.instance;

  WidgetPurchase() {
    try {
      final purchaseUpdated = iapConnection.purchaseStream;
      _subscription = purchaseUpdated.listen(
        _onPurchaseUpdate,
        onDone: _updateStreamOnDone,
        onError: _updateStreamOnError,
      );

    } on Exception catch (error) {
      print('에러 : $error');
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> buy(PurchasableProduct product) async {
    print(product);
    product.status = ProductStatus.pending;
    notifyListeners();
    await Future<void>.delayed(const Duration(seconds: 5));
    product.status = ProductStatus.purchased;
    notifyListeners();
    await Future<void>.delayed(const Duration(seconds: 5));
    product.status = ProductStatus.purchasable;
    notifyListeners();
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    // Handle purchases here
    print('업데이트 : $purchaseDetailsList');
  }

  void _updateStreamOnDone() {
    print('Done!');
    _subscription.cancel();
  }

  void _updateStreamOnError(dynamic error) {
    print('StreemError : $error');

    //Handle error here
  }
}