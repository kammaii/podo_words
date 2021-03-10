import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'podo_words',
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('podo_words'),

      ),
      body: MainBody(),
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

  Widget exampleListView(BuildContext context) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: Icon(icons[index]),
            title: Text(list[index]),
          ),
        );
      },
    );
  }

  Widget customListView(BuildContext context) {
    return Column(
      children: [
        Text(
          'Title',
          style: TextStyle(fontSize: 20),
        ),
        Expanded(
            child: ListView.builder(
                scrollDirection: Axis.horizontal,

                itemBuilder: (context, index) {
                  return Card(
                    child: Center(
                        child: Text('card text$index')),
                  );
                }
            ),
        ),
        Text(
          'title 2',
          style: TextStyle(fontSize: 20),
        ),
        Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemBuilder: (ctx, idx) {
                  return Card(
                    child: ListTile(
                      title: Text('card 2 $idx'),
                      subtitle: Text('subtitle'),
                    ),
                  );
                }
            )
        )
      ],
    );
  }
}


