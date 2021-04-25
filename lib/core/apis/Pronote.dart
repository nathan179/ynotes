import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ynotes/core/apis/Pronote/PronoteAPI.dart';
import 'package:ynotes/core/apis/Pronote/PronoteCas.dart';
import 'package:ynotes/core/apis/Pronote/pronoteMethods.dart';
import 'package:ynotes/core/apis/model.dart';
import 'package:ynotes/core/apis/utils.dart';
import 'package:ynotes/core/logic/modelsExporter.dart';
import 'package:ynotes/core/logic/shared/loginController.dart';
import 'package:ynotes/core/offline/offline.dart';
import 'package:ynotes/globals.dart';
import 'package:ynotes/ui/screens/settings/sub_pages/logsPage.dart';
import 'package:ynotes/usefulMethods.dart';

bool gradeLock = false;
//Locks are use to prohibit the app to send too much requests while collecting data and ensure there are made one by one
//They are ABSOLUTELY needed or user will be quickly IP suspended
bool gradeRefreshRecursive = false;
bool hwLock = false;
bool hwRefreshRecursive = false;
bool lessonsLock = false;
bool lessonsRefreshRecursive = false;
late PronoteClient localClient;
bool loginLock = false;
bool pollsLock = false;
bool pollsRefreshRecursive = false;

Future<List<PollInfo>?> getPronotePolls(bool forced) async {
  List<PollInfo>? listPolls;
  try {
    if (forced) {
      listPolls = await localClient.polls() as List<PollInfo>;
      await appSys.offline.polls.update(listPolls);
      return listPolls;
    } else {
      listPolls = await appSys.offline.polls.get();
      if (listPolls == null) {
        print("Error while returning offline polls");
        listPolls = await localClient.polls() as List<PollInfo>;
        await appSys.offline.polls.update(listPolls);
        return listPolls;
      } else {
        return listPolls;
      }
    }
  } catch (e) {
    listPolls = await appSys.offline.polls.get();
    return listPolls;
  }
}

class APIPronote extends API {
  late PronoteMethod pronoteMethod;

  int loginReqNumber = 0;

  APIPronote(Offline offlineController) : super(offlineController) {
    localClient = PronoteClient("");
    pronoteMethod = PronoteMethod(localClient, appSys.account, this.offlineController);
  }

  @override
  Future app(String appname, {String? args, String? action, CloudItem? folder}) async {
    switch (appname) {
      case "polls":
        {
          if (action == "get") {
            int req = 0;
            while (pollsLock == true && req < 10) {
              req++;
              await Future.delayed(const Duration(seconds: 2), () => "1");
            }
            if (pollsLock == false) {
              try {
                pollsLock = true;
                List<PollInfo>? toReturn = await getPronotePolls(args == "forced");
                pollsLock = false;
                return toReturn;
              } catch (e) {
                if (!pollsRefreshRecursive) {
                  pollsRefreshRecursive = true;
                  pollsLock = false;
                  await pronoteMethod.refreshClient();
                  List<PollInfo>? toReturn = await getPronotePolls(args == "forced");

                  return toReturn;
                }
                pollsLock = false;
                print("Erreur pendant la collection des sondages/informations " + e.toString());
              }
            }
          }
          if (action == "read") {
            int req = 0;
            while (pollsLock == true && req < 10) {
              req++;
              await Future.delayed(const Duration(seconds: 2), () => "1");
            }
            try {
              pollsLock = true;
              await localClient.setPollRead(args ?? "");
              pollsLock = false;
            } catch (e) {
              pollsLock = false;
              if (!pollsRefreshRecursive) {
                await pronoteMethod.refreshClient();
                await localClient.setPollRead(args ?? "");
              }
            }
          }
          if (action == "answer") {
            int req = 0;
            while (pollsLock == true && req < 10) {
              req++;
              await Future.delayed(const Duration(seconds: 2), () => "1");
            }
            try {
              pollsLock = true;
              await localClient.setPollResponse(args ?? "");
              pollsLock = false;
            } catch (e) {
              pollsLock = false;
              if (!pollsRefreshRecursive) {
                await pronoteMethod.refreshClient();
                await localClient.setPollResponse(args ?? "");
              }
            }
          }
        }
        break;
    }
  }

  @override
  Future<http.Request> downloadRequest(Document document) async {
    String url = await localClient.downloadUrl(document);
    http.Request request = http.Request('GET', Uri.parse(url));
    return request;
  }

  @override
  Future<List<SchoolAccount>> getAccounts() {
    // TODO: implement getAccounts
    throw UnimplementedError();
  }

  @override
  Future<List<DateTime>> getDatesNextHomework() {
    // TODO: implement getDatesNextHomework
    throw UnimplementedError();
  }

  @override
  // TODO: implement listApp

  @override
  Future<List<Discipline>?> getGrades({bool? forceReload}) async {
    return (await pronoteMethod.fetchAnyData(
        pronoteMethod.grades, offlineController.disciplines.getDisciplines, "grades",
        forceFetch: forceReload ?? false, isOfflineLocked: super.offlineController.locked));
  }

  @override
  Future<List<Homework>?> getHomeworkFor(DateTime? dateHomework) async {
    if (dateHomework != null) {
      return (await pronoteMethod.onlineFetchWithLock(pronoteMethod.homeworkFor, "homeworkFor",
          arguments: dateHomework));
    }
  }

  @override
  Future<List<Homework>?> getNextHomework({bool? forceReload}) async {
    return (await pronoteMethod.fetchAnyData(
        pronoteMethod.nextHomework, offlineController.homework.getHomework, "homework",
        forceFetch: forceReload ?? false, isOfflineLocked: super.offlineController.locked));
  }

  @override
  Future<List<Lesson>?> getNextLessons(DateTime dateToUse, {bool? forceReload}) async {
    List<Lesson>? lessons = await pronoteMethod.fetchAnyData(
        pronoteMethod.lessons, offlineController.lessons.get, "lessons",
        forceFetch: forceReload ?? false,
        isOfflineLocked: super.offlineController.locked,
        onlineArguments: dateToUse,
        offlineArguments: await getWeek(dateToUse));
    if (lessons != null) {
      lessons.retainWhere((lesson) =>
          DateTime.parse(DateFormat("yyyy-MM-dd").format(lesson.start!)) ==
          DateTime.parse(DateFormat("yyyy-MM-dd").format(dateToUse)));
    }
    return lessons;
  }

  getOfflinePeriods() async {
    try {
      List<Period> listPeriods = [];
      List<Discipline>? disciplines = await appSys.offline.disciplines.getDisciplines();
      List<Grade> grades =
          (disciplines ?? []).map((e) => e.gradesList).toList().map((e) => e).expand((element) => element!).toList();
      grades.forEach((grade) {
        if (!listPeriods.any((period) => period.name == grade.periodName)) {
          listPeriods.add(Period(grade.periodName, grade.periodCode));
        }
      });

      listPeriods.sort((a, b) => a.name!.compareTo(b.name!));

      return listPeriods;
    } catch (e) {
      print("Error while collecting offline periods " + e.toString());
    }
  }

  getOnlinePeriods() async {
    try {
      List<Period> listPeriod = [];
      if (localClient.localPeriods != null) {
        localClient.localPeriods.forEach((pronotePeriod) {
          listPeriod.add(Period(pronotePeriod.name, pronotePeriod.id));
        });

        return listPeriod;
      } else {
        var listPronotePeriods = await localClient.periods();
        //refresh local pronote periods
        localClient.localPeriods = [];
        (listPronotePeriods).forEach((pronotePeriod) {
          listPeriod.add(Period(pronotePeriod.name, pronotePeriod.id));
        });
        return listPeriod;
      }
    } catch (e) {
      print("Erreur while getting period " + e.toString());
    }
  }

  @override
  Future<List<Period>> getPeriods() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    try {
      return await getOfflinePeriods();
    } catch (e) {
      print("Erreur while getting offline period " + e.toString());
      if (connectivityResult != ConnectivityResult.none && localClient != null) {
        if (localClient.loggedIn) {
          print("getting periods online");
          return await getOnlinePeriods();
        } else {
          throw "Pronote isn't logged in";
        }
      } else {
        try {
          return await getOfflinePeriods();
        } catch (e) {
          throw ("Error while collecting offline periods");
        }
      }
    }
  }

  @override
  Future<List> login(username, password, {url, cas, mobileCasLogin}) async {
    print(username + " " + password + " " + url);
    int req = 0;
    while (loginLock == true && req < 5 && appSys.loginController.actualState != loginStatus.loggedIn) {
      print("Locked, trying in 5 seconds...");
      req++;
      await Future.delayed(const Duration(seconds: 5), () => "1");
    }
    if (loginLock == false && loginReqNumber < 5) {
      loginReqNumber = 0;
      loginLock = true;
      try {
        var cookies = await callCas(cas, username, password, url ?? "");
        localClient =
            PronoteClient(url, username: username, password: password, mobileLogin: mobileCasLogin, cookies: cookies);

        await localClient.init();
        if (localClient != null && localClient.loggedIn) {
          this.loggedIn = true;
          loginLock = false;
          pronoteMethod = PronoteMethod(localClient, appSys.account, this.offlineController);

          return ([1, "Bienvenue $actualUser!"]);
        } else {
          loginLock = false;
          return ([
            0,
            "Oups, une erreur a eu lieu. Vérifiez votre mot de passe et les autres informations de connexion.",
            localClient.stepsLogger
          ]);
        }
      } catch (e) {
        loginLock = false;
        localClient.stepsLogger?.add("❌ Pronote login failed : " + e.toString());
        print(e);
        String error = "Une erreur a eu lieu. " + e.toString();
        if (e.toString().contains("invalid url")) {
          error = "L'URL entrée est invalide";
        }
        if (e.toString().contains("split")) {
          error =
              "Le format de l'URL entrée est invalide. Vérifiez qu'il correspond bien à celui fourni par votre établissement";
        }
        if (e.toString().contains("runes")) {
          error = "Le mot de passe et/ou l'identifiant saisi(s) est/sont incorrect(s)";
        }
        if (e.toString().contains("IP")) {
          error =
              "Une erreur inattendue  a eu lieu. Pronote a peut-être temporairement suspendu votre adresse IP. Veuillez recommencer dans quelques minutes.";
        }
        if (e.toString().contains("SocketException")) {
          error = "Impossible de se connecter à l'adresse saisie. Vérifiez cette dernière et votre connexion.";
        }
        if (e.toString().contains("Invalid or corrupted pad block")) {
          error = "Le mot de passe et/ou l'identifiant saisi(s) est/sont incorrect(s)";
        }
        if (e.toString().contains("HTML PAGE")) {
          error = "Problème de page HTML.";
        }
        if (e.toString().contains("nombre d'erreurs d'authentification autorisées")) {
          error =
              "Vous avez dépassé le nombre d'erreurs d'authentification authorisées ! Réessayez dans quelques minutes.";
        }
        if (e.toString().contains("Failed login request")) {
          error = "Impossible de se connecter à l'URL renseignée. Vérifiez votre connexion et l'URL entrée.";
        }
        print("test");
        await logFile(error);
        return ([0, error, localClient.stepsLogger]);
      }
    } else {
      loginReqNumber++;
      return [0, null];
    }
  }

  @override
  Future<bool?> testNewGrades() async {
    return null;
  }

  @override
  Future uploadFile(String contexte, String id, String filepath) {
    // TODO: implement sendFile
    throw UnimplementedError();
  }
}
