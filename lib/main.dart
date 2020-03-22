import 'package:flutter/material.dart';
import 'package:homewins/home.dart';
import 'package:homewins/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(HomeWinsApp());

class HomeWinsApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeWinsAppState();
}

class _HomeWinsAppState extends State<HomeWinsApp> {
  String _accessToken;
  String _homeLocation;
  String _homeWifiSsid;
  bool _isInitializing = true;

  Future<Null> authenticate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey("accessToken")) {
      print("No username :(");
    } else {
      _accessToken = prefs.getString("accessToken");
      _homeLocation = prefs.getString("homeLocation");
      _homeWifiSsid = prefs.getString("homeWifiSsid");
    }

    setState(() {
      _isInitializing = false;
    });
  }

  onLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove("accessToken");
    await prefs.remove("homeLocation");
    await prefs.remove("homeWifiSsid");

    setState(() {
      _accessToken = null;
      _homeLocation = null;
      _homeWifiSsid = null;
    });
  }

  onLoggedIn(String accessToken, String homeLocation, String homeWifiSsid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString("accessToken", accessToken);
    await prefs.setString("homeLocation", homeLocation);
    await prefs.setString("homeWifiSsid", homeWifiSsid);

    setState(() {
      _accessToken = accessToken;
      _homeLocation = homeLocation;
      _homeWifiSsid = homeWifiSsid;
    });
  }

  @override
  void initState() {
    super.initState();
    authenticate();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Container(
        decoration: new BoxDecoration(
          color: Colors.blue
        ),
      );
    }

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.deepOrange,
      ),
      home: _accessToken == null ? LoginPage(onLoggedIn: this.onLoggedIn) : HomePage(onLogout: onLogout, accessToken: _accessToken, homeLocation: _homeLocation, homeWifiSsid: _homeWifiSsid)
    );
  }
}

