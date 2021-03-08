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
    Widget column = Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: Icon(Icons.computer),
                title: Text("computer"),
                subtitle: Text('subtitle'),
              ),
            )
          ],
        )
    );

    return ListView.builder(
        itemBuilder: (context, index) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  column,
                  column,
                  column,
                ],
              ),
            ),
          );
        }
    );
  }
}


