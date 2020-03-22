import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'home.dart';

class LoginPage extends StatefulWidget {
  final Function(String, String, String) onLoggedIn;

  LoginPage({Key key, @required this.onLoggedIn}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

enum Status {
  LoadingLocation, LoadingNetworkInfo, Done
}

enum SetupStage {
  AccountCreation, HomeSetup, Login
}

class _LoginPageState extends State<LoginPage> {
  PanelController _panelController = new PanelController();
  String _wifiName;
  String _location;
  Status _loadingStatus = Status.Done;
  bool _isLocationCorrect = false;
  bool _isWifiCorrect = false;
  SetupStage _setupStage = SetupStage.AccountCreation;
  bool _isLoggingIn = false;
  bool _isCreatingAccount = false;
  String _accessToken;

  TextEditingController _usernameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _password2Controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Fehlermeldung"),
          content: new Text(message),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Schließen"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void loadWifiName() async {
    if (_loadingStatus != Status.Done) return;

    setState(() {
      _loadingStatus = Status.LoadingLocation;
      _isLocationCorrect = false;
      _isWifiCorrect = false;
    });

    var status = await Connectivity().getLocationServiceAuthorization();

    if (status != LocationAuthorizationStatus.authorizedWhenInUse) {
      setState(() {
        _setupStage = SetupStage.AccountCreation;
      });

      showError("Die App benötigt Zugriff auf Standortsdaten!");
      return;
    }

    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    if (position == null) {
      setState(() {
        _loadingStatus = Status.Done;
        _setupStage = SetupStage.AccountCreation;
      });

      showError("Dein Standort konnte leider nicht ermittelt werden.");
      return;
    }

    var placemark = await Geolocator().placemarkFromPosition(position);

    setState(() {
      _loadingStatus = Status.LoadingNetworkInfo;
    });

    var wifiName = await Connectivity().getWifiName();
    if (wifiName == null) {
      setState(() {
        _loadingStatus = Status.Done;
        _setupStage = SetupStage.AccountCreation;
      });

      showError("Du musst mit deinem Heim WiFi-Netzwerk verbunden sein um die App-Einrichtungen abschließen zu können!");
      return;
    }

    setState(() {
      _wifiName = wifiName;
      _location = placemark[0].name;
      _loadingStatus = Status.Done;
    });
  }

  void openPanel() {
    _panelController.open();
  }

  Widget buildAccountCreationPanel(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Text(
                  "Account Erstellen",
                  style: Theme.of(context).textTheme.headline
              ),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: "Username"
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 15),
              child: TextField(
                obscureText: true,
                controller: _passwordController,
                decoration: InputDecoration(
                    hintText: "Password"
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 15, bottom: 30),
              child: TextField(
                controller: _password2Controller,
                obscureText: true,
                decoration: InputDecoration(
                    hintText: "Password Wiederholen"
                ),
              ),
            ),
            RaisedButton(
              color: Theme.of(context).primaryColor,
              padding: EdgeInsets.all(15),
              onPressed: () async {
                if (_isCreatingAccount) return;

                var username = _usernameController.text.trim();
                var password = _passwordController.text;
                var password2 = _passwordController.text;

                if (username == "" || password == "" || password2 == "") {
                  showError("Bitte fülle alle Felder aus!");
                  return;
                }

                if (password != password2) {
                  showError("Beide Passwörter müssen übereinstimmen!");
                  return;
                }

                /*setState(() {
                  _isCreatingAccount = true;
                });*/

                setState(() {
                  _isCreatingAccount = false;
                  _setupStage = SetupStage.HomeSetup;
                  loadWifiName();
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    _isCreatingAccount ? "Lädt..." : "Weiter",
                    style: TextStyle(
                      color: Colors.white
                    ),
                  ),
                  Icon(Icons.chevron_right),
                ],
              ),
            ),
            Container(height: 7),
            RaisedButton(
              padding: EdgeInsets.all(10),
              onPressed: () async {
                _panelController.close();
              },
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Abbrechen"
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<Response> login(String username, String password) async {
    Map payloadMap = {
      'username': username,
      'password': password,
    };
    String body = json.encode(payloadMap);
    String url = 'https://api.homewins.quving.com/auth/token/';

    print(body);

    final Response response = await http.post(
      url,
      headers: { "Content-Type": "application/json" },
      body: body,
    );

    return response;
  }

  Future<Response> createAccount(String username, String password, String password2) async {
    Map payloadMap = {
      'username': username,
      'email': username + "@homewins.com",
      'password1': password,
      'password2': password2,
    };
    String body = json.encode(payloadMap);
    String url = 'https://api.homewins.quving.com/auth/registration/';

    print(body);

    final Response response = await http.post(
      url,
      headers: { "Content-Type": "application/json" },
      body: body,
    );

    return response;
  }

  Widget buildLoginPanel(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Text(
                  "Login",
                  style: Theme.of(context).textTheme.headline
              ),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                  hintText: "Username"
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 15, bottom: 30),
              child: TextField(
                obscureText: true,
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: "Password"
                ),
              ),
            ),
            RaisedButton(
              color: Theme.of(context).primaryColor,
              padding: EdgeInsets.all(15),
              onPressed: () async {
                if (_isLoggingIn) return;

                var username = _usernameController.text.trim();
                var password = _passwordController.text;

                if (username == "" || password == "") {
                  showError("Bitte fülle alle Felder aus!");
                  return;
                }

                setState(() {
                  _isLoggingIn = true;
                });

                var res = await login(username, password);

                print(res.statusCode);

                if (res.statusCode != 200) {
                  showError("Login ist fehlgeschlagen!");

                  setState(() {
                    _isLoggingIn = false;
                  });

                  return;
                }

                var jsonRes = jsonDecode(res.body);

                print(res.body);

                String accessToken = jsonRes["access"];

                setState(() {
                  _isLoggingIn = false;
                });

                widget.onLoggedIn(accessToken, "", "");
              },
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    _isLoggingIn ? "Lädt..." : "Einloggen",
                    style: TextStyle(
                        color: Colors.white
                    ),
                  ),
                  Icon(Icons.chevron_right),
                ],
              ),
            ),
            Container(height: 7),
            RaisedButton(
              padding: EdgeInsets.all(10),
              onPressed: () async {
                _panelController.close();
              },
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Abbrechen"
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildSetupPanel(BuildContext context) {
    if (_loadingStatus != Status.Done) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SpinKitDoubleBounce(
              color: Colors.grey,
              size: 50.0,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(_loadingStatus == Status.LoadingLocation ? "Standort wird ermittelt..." : "WiFi Netzwerk wird erkannt..."),
            )
          ],
        )
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 25),
              child: Text(
                  "Home Festlegen",
                  style: Theme.of(context).textTheme.headline
              ),
            ),
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  CheckboxListTile(
                    secondary: Icon(
                      Icons.add_location,
                      size: 50,
                    ),
                    title: Text("Ist dies dein Zuhause?"),
                    subtitle: Text(_location + " (Die Addresse kann leicht abweichen)"),
                    value: _isLocationCorrect,
                    onChanged: (v) {
                      setState(() {
                        _isLocationCorrect = !_isLocationCorrect;
                      });
                    },
                  )
                ]
              )
            ),
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  CheckboxListTile(
                    secondary: Icon(
                      Icons.network_wifi,
                      size: 50,
                    ),
                    title: Text("Ist dies dein WiFi-Netzwerk zuhause?"),
                    subtitle: Text(_wifiName),
                    value: _isWifiCorrect,
                    onChanged: (v) {
                      setState(() {
                        _isWifiCorrect = !_isWifiCorrect;
                      });
                    },
                  )
                ]
              )
            ),
            Container(
              height: 30,
            ),
            RaisedButton(
              elevation: 3,
              padding: EdgeInsets.all(15),
              color: Theme.of(context).primaryColor,
              onPressed: () async {
                if (!_isLocationCorrect || !_isWifiCorrect) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // return object of type Dialog
                      return AlertDialog(
                        title: new Text(!_isLocationCorrect ? "Bitte bestätige deinen Standort" : "Bitte bestätige dein WiFi Netzwerk"),
                        actions: <Widget>[
                          // usually buttons at the bottom of the dialog
                          new FlatButton(
                            child: new Text("Schließen"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                setState(() {
                  _isCreatingAccount = true;
                });

                var res = await createAccount(_usernameController.text.trim(), _passwordController.text, _password2Controller.text);

                print(res.statusCode);

                if (res.statusCode != 201) {
                  if (res.statusCode == 400) {
                    Map jsonRes = jsonDecode(res.body);
                    String text = "";

                    // TODO: Display more human friendly errors
                    for (var key in jsonRes.keys) {
                      for (var error in jsonRes[key]) {
                        text += key + ": " + error + "\n";
                      }
                    }

                    showError(text);
                  } else {
                    showError("Registrierung ist fehlgeschlagen!");
                  }

                  setState(() {
                    _setupStage = SetupStage.AccountCreation;
                    _isCreatingAccount = false;
                  });

                  return;
                }

                var jsonRes = jsonDecode(res.body);

                print(res.body);

                _accessToken = jsonRes["key"];

                setState(() {
                  _isCreatingAccount = false;
                });

                _panelController.close();

                widget.onLoggedIn(_accessToken, _location, _wifiName);
              },
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    _isCreatingAccount ? "Account wird erstellt..." : "Account Erstellen",
                    style: TextStyle(
                      color: Colors.white
                    ),
                  ),
                  Icon(Icons.chevron_right),
                ],
              ),
            ),
            Container(height: 7),
            RaisedButton(
              onPressed: () async {
                _panelController.close();
              },
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Abbrechen"
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildPanel(BuildContext context) {
    if (_setupStage == SetupStage.AccountCreation) {
      return buildAccountCreationPanel(context);
    }

    if (_setupStage == SetupStage.Login) {
      return buildLoginPanel(context);
    }

    return buildSetupPanel(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Login"),
        ),
        body: SlidingUpPanel(
          controller: _panelController,
          /*borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),*/
          minHeight: 0,
          maxHeight: 550,
          padding: EdgeInsets.all(15),
          panel: buildPanel(context),
          body: Center(
              child: Padding(
                  padding: EdgeInsets.all(30).add(EdgeInsets.only(bottom: 80)),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 30),
                            child: Text(
                                "Hallo!",
                                style: Theme.of(context).textTheme.title
                            )
                        ),
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Container(
                                child: Text(
                                  "Als erstes musst du einen Account erstellen, dem wir deine Punkte beifügen können. Falls du bereits einen hast, kannst du dich auch mit diesem hier einloggen.",
                                  style: Theme.of(context).textTheme.subhead,
                                  textAlign: TextAlign.center,
                                )
                            )
                        ),
                        Container(
                          height: 30,
                        ),
                        RaisedButton(
                          color: Theme.of(context).primaryColor,
                          padding: EdgeInsets.all(15),
                          onPressed: () async {
                            _usernameController.text = "";
                            _passwordController.text = "";
                            _password2Controller.text = "";

                            setState(() {
                              _setupStage = SetupStage.AccountCreation;
                            });

                            openPanel();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Neuen Account Erstellen",
                                style: TextStyle(
                                  color: Colors.white
                                ),
                              ),
                              Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                        Container(height: 10),
                        RaisedButton(
                          padding: EdgeInsets.all(15),
                          onPressed: () async {
                            _usernameController.text = "";
                            _passwordController.text = "";
                            _password2Controller.text = "";

                            setState(() {
                              _setupStage = SetupStage.Login;
                            });

                            openPanel();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Mit Account Einloggen"
                              ),
                              Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                        Container(
                          height: 50,
                        )
                      ]
                  )
              )
          )
        )
    );
  }
}