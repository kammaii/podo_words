import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:podo_words/main.dart';
import 'package:podo_words/purchasable_product.dart';

class Purchase extends ChangeNotifier {
  //DashCounter counter;
  //StoreState storeState = StoreState.loading;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<PurchasableProduct> products = [];

  // bool get beautifiedDash => _beautifiedDashUpgrade;
  // ignore: prefer_final_fields
  // bool _beautifiedDashUpgrade = false;

  final iapConnection = IAPConnection.instance;

  Purchase() {
    print('creating Purchase');
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
      //storeState = StoreState.notAvailable;
      notifyListeners();
      print('LoadPurchases FAILED');
      return;
    }

    const ids = <String> {
      'test'
    };

    final response = await iapConnection.queryProductDetails(ids);
    print('response : $response');
    response.notFoundIDs.forEach((element) {
      print('Purchase $element not found');
    });
    products = response.productDetails.map((e) => PurchasableProduct(e)).toList();
    //storeState = StoreState.available;
    notifyListeners();
  }


  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> buy(PurchasableProduct product) async {
    product.status = ProductStatus.pending;
    print(product.status);
    notifyListeners();

    await Future<void>.delayed(const Duration(seconds: 5));
    product.status = ProductStatus.purchased;
    print(product.status);
    notifyListeners();

    await Future<void>.delayed(const Duration(seconds: 5));
    product.status = ProductStatus.purchasable;
    print(product.status);
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