import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data_storage.dart';
import 'main_frame.dart';
import 'package:package_info/package_info.dart';

import 'purchase.dart';

class Logo extends StatelessWidget {
  const Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String version = '';
    DataStorage dataStorage = DataStorage();
    PackageInfo.fromPlatform().then((value) {
      version = value.version;
    });

    return FutureBuilder(
      future: dataStorage.initData(),
      builder: (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
        if(snapshot.hasData) {
          print('데이타 있음 : $snapshot');
          if(!DataStorage().isPremiumUser) {
            Purchase();
          }
          SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
            Timer(Duration(seconds: 1), () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainFrame()));
            });
          });
        }
        return Scaffold(
            body: SafeArea(
              child: Container(
                color: Colors.white,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 20.0,
                      right: 20.0,
                      child: Text('version : $version')),
                    Center(child: Image.asset('assets/images/logo.png')),
                    Positioned(
                      bottom: 100.0,
                      child: Row(
                        children: [
                          SizedBox(
                            child: CircularProgressIndicator(
                              strokeWidth: 1.0,
                            ),
                            height: 20.0,
                            width: 20.0,
                          ),
                          SizedBox(width: 20.0),
                          Text('Loading...')
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
        );
      },
    );
  }
}
