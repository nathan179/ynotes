import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:ynotes/core/logic/modelsExporter.dart';

class LvsHomeworkConverter {
  static List<Homework> homework(homeworkData) {
    List hws = json.decode(homeworkData);

    List<Homework> hwList = [];
    hws.forEach((sHw) {
      String discipline = sHw['subject'];
      DateTime date = DateFormat('yyyy-MM-dd').parse('2021-06-07');
      bool done = false;
      String teacherName = sHw['text'];
      done = sHw['activitesMaisonTerminees'];

      sHw['activitesData'].forEach((element) {
        String id = element['id'].toString();
        String content = element['description'];

        bool toReturn = false;
        bool isATest = false;
        if (['SURV', 'EVAL', 'PSURV'].contains(element['code'])) {
          isATest = true;
        }
        bool loaded = true;

        Homework hw = Homework(
            discipline: discipline,
            disciplineCode: null,
            id: id,
            rawContent: content,
            sessionRawContent: null,
            date: date,
            entryDate: null,
            done: done,
            toReturn: toReturn,
            isATest: isATest,
            teacherName: teacherName,
            loaded: loaded);
        hwList.add(hw);
      });
    });
    return hwList;
  }
}
