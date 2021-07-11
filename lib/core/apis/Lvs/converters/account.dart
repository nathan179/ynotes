import 'package:ynotes/core/apis/model.dart';
import 'package:ynotes/core/apis/utils.dart';
import 'package:ynotes/core/logic/modelsExporter.dart';
import 'package:ynotes/core/utils/nullSafeMapGetter.dart';
import 'package:uuid/uuid.dart';

class LvsAccountConverter {
  static AppAccount account(Map<dynamic, dynamic> accountData) {
    SchoolAccount _account = singleSchoolAccount(accountData);
    String? name = _account.name;
    String? surname = _account.surname;
    String? id = Uuid().v1();
    bool isParentMainAccount = false;
    return AppAccount(
        name: name,
        surname: surname,
        id: id,
        managableAccounts: [_account],
        isParentMainAccount: isParentMainAccount,
        apiType: API_TYPE.Pronote);
  }

  static List<appTabs> availableTabs() {
    List<appTabs> tabs = [];
    tabs.add(appTabs.HOMEWORK);
    tabs.add(appTabs.SUMMARY);
    return tabs;
  }

  static SchoolAccount singleSchoolAccount(
      Map<dynamic, dynamic> schoolAccountsData) {
    if (schoolAccountsData["infoUser"]["profil"] != 'Elève') {
      throw ('Account type must be "Elève"');
    }
    schoolAccountsData = mapGet(schoolAccountsData, ["infoUser"]);
    String? name = utf8convert(mapGet(schoolAccountsData, ["userPrenom"]));
    String? surname = utf8convert(mapGet(schoolAccountsData, ["userNom"]));
    String? schoolName = utf8convert(mapGet(schoolAccountsData, ["etabName"]));
    String? studentClass = "";
    String? studentID = mapGet(schoolAccountsData, ["id"]).toString();
    List<appTabs> tabs = availableTabs();
    return SchoolAccount(
        name: name,
        surname: surname,
        studentClass: studentClass,
        studentID: studentID,
        availableTabs: tabs,
        schoolName: schoolName);
  }
}
