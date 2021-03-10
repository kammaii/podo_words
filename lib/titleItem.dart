import 'package:flutter/cupertino.dart';

class TitleItem extends StatelessWidget{
  Icon illustration;
  String title;
  int itemNo;

  TitleItem(Icon illustration, String title, int itemNo) {
    this.illustration = illustration;
    this.title = title;
    this.itemNo = itemNo;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: illustration,
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Text(title),
                Text(itemNo.toString()),
              ],
            )
          )
        ],
      ),
    );
  }
}