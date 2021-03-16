import 'package:flutter/material.dart';
import 'package:podo_words/appBar_info.dart';

class MainLearning extends StatefulWidget {

  @override
  _MainLearningState createState() => _MainLearningState();
}

class _MainLearningState extends State<MainLearning> {
  final list = ['sun', 'mon', 'tue'];

  final icons = [Icons.directions_bike, Icons.directions_boat, Icons.bus_alert];

  Widget titleList() {
    return Container(
      margin: EdgeInsets.all(10.0),
      height: 200,
      child: ListView.builder(
          itemCount: list.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return Container(
              width: 200,
              margin: EdgeInsets.only(right: 10.0),
              child: GestureDetector(
                onTap: (){print('titleCard clicked : $index');},
                child: Card(
                  child: Container(
                    color: Colors.yellow,
                    child: Column(
                      children: [
                        Text('title'),
                        ListTile(
                          leading: Icon(Icons.title),
                          title: Text(list[index]),
                          subtitle: Text('index$index'),
                          trailing: Icon(Icons.more_vert),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
      ),
    );
  }

  Widget wordsList(context, index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.0),
      height: 80.0,
      child: GestureDetector(
        onPanUpdate: (detail) {
          if(detail.delta.dx > 0) {
            print('오른쪽 스와이프 : $index');
          } else {
            print('왼쪽 스와이프 : $index');
          }
        },
        child: Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('front $index'),
              Text('back'),
            ],
          ),
        ),
      ),
    );
  }

  renderSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.purple,
      expandedHeight: 200.0,
      pinned: true,
      floating: true,
      //flexibleSpace: Image.asset('assets/', fit: BoxFit.cover,),
      title: Text('Seoul'),
      flexibleSpace: titleList(),
    );
  }

  renderSliverList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
          (context, index) {
            return wordsList(context, index);
          },
        childCount: 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBarInfo('Review').getAppBar(),
      body: CustomScrollView(
        slivers: [
          renderSliverAppBar(),
          renderSliverList(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {},
          child: Text('Learn'),
        ),
      ),
    );
  }
}

class MainBody extends StatelessWidget {
  final list = ['sun', 'mon', 'tue'];
  final icons = [Icons.directions_bike, Icons.directions_boat, Icons.bus_alert];

  @override
  Widget build(BuildContext context) {
    return customListView(context);
  }

  Widget customListView(BuildContext context) {

    Widget titleCard(context, index) {
      return Container(
        width: 200,
        margin: EdgeInsets.only(right: 10.0),
        child: GestureDetector(
          onTap: (){print('titleCard clicked : $index');},
          child: Card(
            child: Container(
              color: Colors.yellow,
              child: Column(
                children: [
                  Text('title'),
                  ListTile(
                    leading: Icon(Icons.title),
                    title: Text(list[index]),
                    subtitle: Text('index$index'),
                    trailing: Icon(Icons.more_vert),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Text(
          'Title',
          style: TextStyle(fontSize: 20),
        ),
        Container(
          margin: EdgeInsets.all(10.0),
          height: 200,
            child: ListView.builder(
                itemCount: list.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return titleCard(context, index);
                }
            ),
        ),
        Text(
          'title 2',
          style: TextStyle(fontSize: 20),
        ),
        Expanded(
            child: ListView.builder(
              itemBuilder: (ctx, idx) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 10.0),
                    height: 80.0,
                    child: GestureDetector(
                      onPanUpdate: (detail) {
                        if(detail.delta.dx > 0) {
                          print('오른쪽 스와이프 : $idx');
                        } else {
                          print('왼쪽 스와이프 : $idx');
                        }
                      },
                      child: Card(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('card 2 $idx'),
                            Text('subtitle'),
                          ],
                        ),
                      ),
                    ),
                  );
                }
            )
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10.0),
          child: ElevatedButton(
              onPressed: (){
                print('btn Clicked');
                },
              child: Text('learn!')
          ),
        )
      ],
    );
  }
}


