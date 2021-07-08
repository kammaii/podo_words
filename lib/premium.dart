import 'package:flutter/material.dart';
import 'package:podo_words/my_colors.dart';
import 'package:provider/provider.dart';
import 'package:podo_words/purchasable_product.dart';
import 'package:podo_words/purchase.dart';

class Premium extends StatelessWidget {
  const Premium({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int originalPrice = 10;
    int price = 1;

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
                          Text('\$10', textScaleFactor: 1.5,
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
                          Text('\$1', textScaleFactor: 2,
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
                InkWell(
                  onTap: (){
                     //todo: 인앱구매 실행
                    print('버튼');
                    //PurchasableProduct product = Purchase().products[0];
                    //Purchase().buy(products[0]);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: MyColors().purple,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
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
                Text('The payment will be charged to your Google account at the confirmation of purchase.'
                    'This purchase is one-time purchase. You can request a refund within 24 hours.'
                    'If you have any trouble with purchasing, please contact akorean.app@gmail.com.',
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
