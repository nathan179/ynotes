import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:ynotes/core/apis/Pronote.dart';
import 'package:ynotes/core/logic/grades/controller.dart';
import 'package:ynotes/core/logic/modelsExporter.dart';
import 'package:ynotes/core/logic/stats/gradesStats.dart';
import 'package:ynotes/core/utils/themeUtils.dart';
import 'package:ynotes/ui/components/buttons.dart';
import 'package:ynotes/ui/components/dialogs.dart';
import 'package:ynotes/ui/components/modalBottomSheets/gradesModalBottomSheet/stats.dart';

Future<Grade> simulatorModalBottomSheet(
  GradesController gradesController,
  BuildContext context,
) {
  MediaQueryData screenSize = MediaQuery.of(context);

  return showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      ),
      backgroundColor: Theme.of(context).primaryColorDark,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return SimulatorModalBottomSheet(
          gradesController: gradesController,
        );
      });
}

class SimulatorModalBottomSheet extends StatefulWidget {
  const SimulatorModalBottomSheet({
    Key key,
    this.gradesController,
  }) : super(key: key);

  final GradesController gradesController;
  @override
  _SimulatorModalBottomSheetState createState() => _SimulatorModalBottomSheetState();
}

class _SimulatorModalBottomSheetState extends State<SimulatorModalBottomSheet> {
  //Grade attributes

  //Chosen discipline
  Discipline disciplineChoice;
  double gradeValue;
  double gradeOn = 20;
  double gradeWeight = 1;

  //Chose "coefficient"
  Widget weightSelector() {
    var screenSize = MediaQuery.of(context);

    return Column(
      children: [
        Text(
          "Coefficient",
          style: TextStyle(fontFamily: "Asap", color: ThemeUtils.textColor()),
          textAlign: TextAlign.center,
        ),
        CustomButtons.materialButton(context, screenSize.size.width / 5 * 1.2, screenSize.size.height / 10 * 0.5,
            () async {
          var temp = await CustomDialogs.showNumberChoiceDialog(context, isDouble: true, text: "coefficient");
          if (temp != null) {
            setState(() {
              gradeWeight = temp;
            });
          }
        },
            label: gradeWeight != null ? gradeWeight.toString() : "--",
            backgroundColor: Theme.of(context).primaryColorLight)
      ],
    );
  }

//Chose "coefficient"
  Widget gradeOnSelector() {
    var screenSize = MediaQuery.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomButtons.materialButton(context, screenSize.size.width / 5 * 1.2, screenSize.size.height / 10 * 0.5,
            () async {
          var temp = await CustomDialogs.showNumberChoiceDialog(context, isDouble: true, text: "votre note");
          if (temp != null) {
            setState(() {
              gradeValue = temp;
            });
          }
        },
            label: gradeValue != null ? gradeValue.toString() : "--",
            backgroundColor: Theme.of(context).primaryColorLight),
        Container(
          padding: EdgeInsets.symmetric(horizontal: screenSize.size.width / 5 * 0.1),
          child: Text(
            "/",
            style: TextStyle(fontFamily: "Asap", color: ThemeUtils.textColor()),
          ),
        ),
        CustomButtons.materialButton(context, screenSize.size.width / 5 * 1.2, screenSize.size.height / 10 * 0.5,
            () async {
          var temp = await CustomDialogs.showNumberChoiceDialog(context, isDouble: true, text: "la note maximale");
          if (temp != null) {
            setState(() {
              gradeOn = temp;
            });
          }
        }, label: gradeOn != null ? gradeOn.toString() : "--", backgroundColor: Theme.of(context).primaryColorLight)
      ],
    );
  }

  Widget dropdown(List<Discipline> disciplines) {
    var screenSize = MediaQuery.of(context);

    List<Discipline> choices;
    //Add disciplines in choices
    if (disciplines != null) {
      choices = List();
      choices.clear();
      disciplines.forEach((element) {
        choices.add(element);
      });
      choices.add(null);
      print(choices);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Matière",
          style: TextStyle(fontFamily: "Asap", color: ThemeUtils.textColor()),
        ),
        Container(
          child: (disciplines == null)
              ? Container(
                  child: Text(
                    "Pas de periode",
                    style: TextStyle(fontFamily: "Asap", color: ThemeUtils.textColor()),
                  ),
                )
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: screenSize.size.width / 5 * 0.1),
                  height: screenSize.size.height / 10 * 0.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(screenSize.size.width / 5 * 0.15),
                    color: Theme.of(context).primaryColorLight,
                  ),
                  child: FittedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Theme(
                            data: Theme.of(context).copyWith(
                              canvasColor: Theme.of(context).primaryColorDark,
                            ),
                            child: (choices == null)
                                ? Container(
                                    child: Text(
                                      "Pas de matières",
                                      style: TextStyle(fontFamily: "Asap", color: ThemeUtils.textColor()),
                                    ),
                                  )
                                : DropdownButtonHideUnderline(
                                    child: DropdownButton<Discipline>(
                                      value: disciplineChoice,
                                      iconEnabledColor: ThemeUtils.textColor(),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: "Asap",
                                        color: ThemeUtils.textColor(),
                                      ),
                                      onChanged: (Discipline newValue) {
                                        setState(() {
                                          disciplineChoice = newValue;
                                        });
                                      },
                                      focusColor: Theme.of(context).primaryColor,
                                      items: choices.toSet().map<DropdownMenuItem<Discipline>>((Discipline discipline) {
                                        return DropdownMenuItem<Discipline>(
                                          value: discipline,
                                          child: Center(
                                            child: Text(
                                              discipline != null ? discipline.disciplineName : "-",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontFamily: "Asap",
                                                color: ThemeUtils.textColor(),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ))
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  ///Returns a widget containing free fields to edit a grade
  Widget editorFields(BuildContext context) {
    var screenSize = MediaQuery.of(context);

    return Container(
      height: screenSize.size.height / 5 * 1.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: screenSize.size.height / 5 * 0.1),
            height: screenSize.size.height / 5 * 0.5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: screenSize.size.width / 5 * 0.3,
                ),
                Expanded(child: dropdown(this.widget.gradesController.disciplines)),
                Expanded(child: weightSelector()),
                SizedBox(
                  width: screenSize.size.width / 5 * 0.3,
                ),
              ],
            ),
          ),
          gradeOnSelector(),
          Container(
            margin: EdgeInsets.only(top: screenSize.size.height / 10 * 0.25),
            child: CustomButtons.materialButton(
                context, screenSize.size.width / 5 * 2.5, screenSize.size.height / 10 * 0.5, () async {
              print(disciplineChoice.period);

              if (gradeValue != null && gradeOn != null && disciplineChoice != null) {
                if (gradeValue > gradeOn) {
                  CustomDialogs.showAnyDialog(context, "La note doit être inférieure à la note maximale possible");
                } else {
                  Grade finalGrade = Grade(
                      date: DateTime.now(),
                      entryDate: DateTime.now(),
                      value: gradeValue.toString(),
                      scale: gradeOn.toString(),
                      simulated: true,
                      notSignificant: false,
                      letters: false,
                      coefficient: gradeWeight.toString(),
                      periodName: disciplineChoice.period,
                      periodCode: widget.gradesController.periods
                          .firstWhere((period) => period.name == disciplineChoice.period)
                          .toString(),
                      disciplineName: disciplineChoice.disciplineName,
                      disciplineCode: disciplineChoice.disciplineCode);
                  Navigator.of(context).pop(finalGrade);
                }
              } else {
                CustomDialogs.showAnyDialog(context, "Remplissez tous les champs");
              }
            },
                label: "J'ajoute cette note",
                backgroundColor: Colors.blue,
                textColor: Colors.white,
                icon: MdiIcons.flaskEmptyPlus),
          )
        ],
      ),
    );
  }

  bool open = false;
  @override
  Widget build(BuildContext context) {
    MediaQueryData screenSize = MediaQuery.of(context);
    return Wrap(children: [
      new AnimatedContainer(
          duration: Duration(milliseconds: 250),
          padding: EdgeInsets.all(0),
          child: Column(
            children: [
              editorFields(context)
              /*Container(
                  height: (screenSize.size.height / 10 * 1.7),
                  child: new Stack(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            open = !open;
                          });
                        },
                        child: Card(
                            margin: EdgeInsets.only(top: screenSize.size.height / 10 * 0.1),
                            color: ThemeUtils.darken(Theme.of(context).primaryColorDark, forceAmount: 0.05),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                            child: Container(
                              width: screenSize.size.width / 5 * 4.5,
                              height: screenSize.size.height / 10 * 0.6,
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenSize.size.width / 5 * 0.2,
                                  vertical: screenSize.size.height / 10 * 0.1),
                              child: FittedBox(
                                child: Wrap(
                                  direction: Axis.horizontal,
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Container(
                                      width: screenSize.size.width / 5 * 0.4,
                                      height: screenSize.size.width / 5 * 0.4,
                                      child: RawMaterialButton(
                                        onPressed: () async {
                                          setState(() {
                                            open = !open;
                                          });
                                        },
                                        child: FittedBox(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: screenSize.size.width / 5 * 0.3,
                                                height: screenSize.size.width / 5 * 0.3,
                                                padding: EdgeInsets.all(
                                                  screenSize.size.width / 5 * 0.05,
                                                ),
                                                child: FittedBox(
                                                  child: new Icon(
                                                    Icons.bar_chart,
                                                    color: ThemeUtils.textColor(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        shape: new CircleBorder(),
                                        elevation: 1.0,
                                        fillColor: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    SizedBox(width: screenSize.size.width / 5 * 0.1),
                                    Container(
                                      height: screenSize.size.height / 10 * 0.2,
                                      child: FittedBox(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "SpaceStats",
                                              style: TextStyle(
                                                  fontFamily: "Asap",
                                                  color: ThemeUtils.textColor(),
                                                  textBaseline: TextBaseline.ideographic,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )),
                      ),
                      Card(
                          margin: EdgeInsets.only(
                              top: screenSize.size.height / 10 * 0.1, bottom: screenSize.size.height / 10 * 0.1),
                          color: ThemeUtils.darken(Theme.of(context).primaryColorDark, forceAmount: 0.05),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 250),
                            width: screenSize.size.width / 5 * 4.5,
                            height: screenSize.size.height / 10 * (open ? 4 : 0),
                            padding: EdgeInsets.symmetric(
                                horizontal: screenSize.size.width / 5 * 0.2,
                                vertical: screenSize.size.height / 10 * 0.1),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Tooltip(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(11),
                                        color: Theme.of(context).primaryColorLight),
                                    margin: EdgeInsets.symmetric(horizontal: screenSize.size.width / 5 * 0.7),
                                    message:
                                        "Indique le nombre de points d'impact sur la moyenne de la matière au moment de l'obtention de cette note.",
                                    textStyle: TextStyle(fontFamily: "Asap", color: ThemeUtils.textColor()),
                                    child: ImpactStat(
                                      impact: widget.stats.calculateAverageImpact(),
                                      label: "points de moyenne pour la matière (à l'obtention).",
                                    ),
                                  ),
                                  SizedBox(height: screenSize.size.height / 10 * 0.1),
                                  Tooltip(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(11),
                                        color: Theme.of(context).primaryColorLight),
                                    margin: EdgeInsets.symmetric(horizontal: screenSize.size.width / 5 * 0.7),
                                    message:
                                        "Indique le nombre de points d'impact sur la moyenne générale au moment de l'obtention de cette note.",
                                    textStyle: TextStyle(fontFamily: "Asap", color: ThemeUtils.textColor()),
                                    child: ImpactStat(
                                      impact: widget.stats.calculateGlobalAverageImpact(),
                                      label: "points de moyenne générale (à l'obtention).",
                                    ),
                                  ),
                                  SizedBox(height: screenSize.size.height / 10 * 0.1),
                                  Tooltip(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(11),
                                        color: Theme.of(context).primaryColorLight),
                                    margin: EdgeInsets.symmetric(horizontal: screenSize.size.width / 5 * 0.7),
                                    message:
                                        "Indique le nombre de points d'impact sur la moyenne générale avec ou sans la note.",
                                    textStyle: TextStyle(fontFamily: "Asap", color: ThemeUtils.textColor()),
                                    child: ImpactStat(
                                      impact: widget.stats.calculateGlobalAverageImpactOverall(),
                                      label: "points de moyenne générale (tout le temps).",
                                    ),
                                  ),
                                  SizedBox(height: screenSize.size.height / 10 * 0.1),
                                  Text(
                                    "A venir...",
                                    style:
                                        TextStyle(fontFamily: "Asap", color: ThemeUtils.textColor().withOpacity(0.5)),
                                  )
                                ],
                              ),
                            ),
                          ))
                    ],
                  )),*/
            ],
          ))
    ]);
  }
}
