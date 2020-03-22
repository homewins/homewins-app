import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homewins/login.dart';

class HomePage extends StatefulWidget {
  final String accessToken;
  final String homeLocation;
  final String homeWifiSsid;
  final int points;
  final Function onLogout;

  HomePage({Key key, @required this.points, @required this.accessToken, @required this.homeLocation, @required this.homeWifiSsid, @required this.onLogout}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    var names = [
      "Tim",
      "Vinh",
      "Max",
      "Simon",
      "Maria",
      "Adib",
      "Janelle",
      "Omar",
      "Timo",
      "JaeYon",
      "Alex",
    ];

    var pts = [23, 23, 22, 22, 22, 21, 19, 16, 15, 24];

    List<Widget> leaderboard = [];
    for (var i = 0; i < 10; ++i) {
      leaderboard.add(Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 30,
                  child: Text((i + 1).toString() + "."),
                ),
                Expanded(
                  child: Text(
                    names[i],
                    style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Container(
                  width: 60,
                  child: Text(pts[i].toString() + " Pts."),
                ),
              ],
            ),
          )
      ));
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("HomeWins"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 10).add(EdgeInsets.symmetric(horizontal: 10)),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Card(
                    elevation: 2,
                    child: Column(
                      children: <Widget>[
                        Container(height: 20),
                        Center(
                          child: Text(
                            widget.points.toString() + " Punkte",
                            style: Theme.of(context).textTheme.headline.apply(fontWeightDelta: 5, fontSizeDelta: 17),
                          ),
                        ),
                        Container(height: 10),
                        Center(
                          child: Text(
                            "Du bist Zuhause! Weiter so!",
                            style: Theme.of(context).textTheme.headline.apply(fontWeightDelta: 2, color: Colors.green, fontSizeDelta: -5),
                          ),
                        ),
                        Container(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            FlatButton(
                              child: Text("Logout"),
                              onPressed: () {
                                widget.onLogout();
                              },
                            ),
                            FlatButton(
                              child: Text("Fortschritt Teilen"),
                              onPressed: () {
                                widget.onLogout();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(height: 25),
                  Center(
                    child: Text(
                      "Leaderboards",
                      style: Theme.of(context).textTheme.headline.apply(fontWeightDelta: 2),
                    ),
                  ),
                  Center(
                    child: Text(
                      "26-22 März",
                      style: Theme.of(context).textTheme.subhead,
                    ),
                  ),
                  Container(height: 16),
                  ...leaderboard,
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColor,
                          padding: EdgeInsets.all(2),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.chevron_left),
                              Text(
                                  "Zurück",
                                  style: TextStyle(
                                      color: Colors.white
                                  )
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(width: 5),
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColor,
                          padding: EdgeInsets.all(2),
                          onPressed: () async {
                            // TODO: YO
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                  "Weiter",
                                  style: TextStyle(
                                      color: Colors.white
                                  )
                              ),
                              Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                ]
            ),
          ),
        )
    );
  }
}