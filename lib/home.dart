import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homewins/login.dart';

class HomePage extends StatefulWidget {
  final String accessToken;
  final String homeLocation;
  final String homeWifiSsid;
  final Function onLogout;

  HomePage({Key key, @required this.accessToken, @required this.homeLocation, @required this.homeWifiSsid, @required this.onLogout}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("HomeWins"),
        ),
        body: Padding(
          padding: const EdgeInsets.only(bottom: 80).add(EdgeInsets.symmetric(horizontal: 10)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Text(
                  "23 Punkte",
                  style: Theme.of(context).textTheme.headline.apply(fontWeightDelta: 5, fontSizeDelta: 17),
                ),
              ),
              Container(height: 10),
              Center(
                child: Text(
                  "Du bist Zuhause! Weiter so!",
                  style: Theme.of(context).textTheme.headline.apply(fontWeightDelta: 2, color: Colors.green),
                ),
              ),
              Container(height: 100),
              FlatButton(
                child: Text("Logout"),
                onPressed: () {
                  widget.onLogout();
                },
              )
            ]
          ),
        )
    );
  }
}