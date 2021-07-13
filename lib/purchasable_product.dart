import 'package:in_app_purchase/in_app_purchase.dart';

class PurchasableProduct {
  String get id => productDetails.id;
  String get title => productDetails.title;
  String get description => productDetails.description;
  String get price => productDetails.price;
  ProductDetails productDetails;

  PurchasableProduct(this.productDetails);
}