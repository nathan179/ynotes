import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ynotes/UI/screens/settingsPage.dart';
import 'package:ynotes/UI/screens/spacePageWidgets/agenda.dart';
import 'package:ynotes/UI/screens/spacePageWidgets/downloadsExplorer.dart';
import 'package:ynotes/UI/screens/spacePageWidgets/news.dart';
import 'package:ynotes/UI/screens/tabBuilder.dart';
import 'package:ynotes/usefulMethods.dart';
import 'package:dio/src/response.dart' as dioResponse;
import 'package:ynotes/UI/components/dialogs.dart';
import 'package:dio/dio.dart' as dio;

class SpacePage extends StatefulWidget {
  State<StatefulWidget> createState() {
    return _SpacePageState();
  }
}

int segmentedControlGroupValue = 0;

class _SpacePageState extends State<SpacePage> with TickerProviderStateMixin {
  // ignore: must_call_super
  void initState() {
    helpDialogs[3].showDialog(context);
  }

  Widget build(BuildContext context) {
    MediaQueryData screenSize = MediaQuery.of(context);
    final Map<int, Widget> spaceTabs = <int, Widget>{
      0: Text("Outils",
          style: TextStyle(
              color: isDarkModeEnabled ? Colors.white : Colors.black,
              fontFamily: "Asap",
              fontWeight: FontWeight.bold,
              fontSize: screenSize.size.width / 5 * 0.2)),
      1: Text("Organisation",
          style: TextStyle(
              color: isDarkModeEnabled ? Colors.white : Colors.black,
              fontFamily: "Asap",
              fontWeight: FontWeight.bold,
              fontSize: screenSize.size.width / 5 * 0.2))
    };

    return Container(
      width: screenSize.size.width / 5 * 3.2,
      margin: EdgeInsets.only(top: screenSize.size.height / 10 * 0.2),
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: <Widget>[
            Material(
              borderRadius: BorderRadius.circular(11),
              color: Theme.of(context).primaryColor,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(router(SettingsPage()));
                },
                borderRadius: BorderRadius.circular(11),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: screenSize.size.height / 10 * 0.2),
                  width: screenSize.size.width / 5 * 4.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.settings,
                        color: isDarkModeEnabled ? Colors.white : Colors.black,
                      ),
                      Container(
                        child: Text(
                          "Accéder aux préférences",
                          style: TextStyle(
                              color: isDarkModeEnabled ? Colors.white : Colors.black,
                              fontFamily: "Asap",
                              fontWeight: FontWeight.bold,
                              fontSize: screenSize.size.width / 5 * 0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(
                    top: screenSize.size.height / 10 * 0.2,
                    bottom: screenSize.size.height / 10 * 0.4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  color: Theme.of(context).primaryColorDark,
                ),
                height: screenSize.size.height / 10 * 7.5,
                padding: EdgeInsets.symmetric(horizontal: screenSize.size.width / 5 * 0.1),
                child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: screenSize.size.height / 10 * 0.1,
                      ),
                      CupertinoSlidingSegmentedControl(
                          thumbColor: Theme.of(context).primaryColor,
                          backgroundColor: darken(Theme.of(context).primaryColorDark),
                          groupValue: segmentedControlGroupValue,
                          children: spaceTabs,
                          onValueChanged: (int i) {
                     
                              setState(() {
                                segmentedControlGroupValue = i;
                              });
                            
                          }),
                      SizedBox(
                        height: screenSize.size.height / 10 * 0.1,
                      ),
                      Container(
                        height: screenSize.size.height / 10 * 6.8,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(bottom: screenSize.size.height / 10 * 0.3),
                          scrollDirection: Axis.vertical,
                
                          child: Column(
                            children: <Widget>[
                              AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                   
                                    return FadeTransition(child: child, opacity: animation);
                                  },
                                  child: segmentedControlGroupValue == 0
                                      ? Column(
                                        key:  ValueKey<int>(segmentedControlGroupValue),
                                          children: [
                                            DownloadsExplorer(),
                                            //News
                                            News(),
                                          ],
                                        )
                                      : Agenda()),

                              //News
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppNews {
  static Future<List> checkAppNews() async {
    try {
      dioResponse.Response response = await dio.Dio().get("https://ynotes.fr/src/app-src/news.json",
          options: dio.Options(responseType: dio.ResponseType.plain));

      Map map = json.decode(response.data.toString());
      List list = map["tickets"];
      list.sort((a, b) => a["ticketnb"].compareTo(b["ticketnb"]));
      return list.reversed.toList();
    } catch (e) {
      print(e);
      return null;
    }
  }
}