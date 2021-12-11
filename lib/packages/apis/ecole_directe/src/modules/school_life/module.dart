part of ecole_directe;

class _SchoolLifeModule extends SchoolLifeModule<_SchoolLifeRepository> {
  _SchoolLifeModule(SchoolApi api, {required bool isSupported, required bool isAvailable})
      : super(isSupported: isSupported, isAvailable: isAvailable, repository: _SchoolLifeRepository(api), api: api);

  @override
  Future<Response<void>> fetch({bool online = false}) async {
    fetching = true;
    notifyListeners();
    if (online) {
      final res = await repository.get();
      if (res.error != null) return res;
      tickets = res.data!["tickets"];
      sanctions = res.data!["sanctions"];
      await offline.setTickets(tickets);
      await offline.setSanctions(sanctions);
    } else {
      tickets = await offline.getTickets();
      sanctions = await offline.getSanctions();
    }
    fetching = false;
    notifyListeners();
    return const Response();
  }
}