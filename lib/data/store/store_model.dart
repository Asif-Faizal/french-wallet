// store_model.dart

class Store {
  final int storeId;
  final String storeName;
  final String storeLocation;
  final String storeCity;
  final List<Terminal>? terminalArray;

  Store({
    required this.storeId,
    required this.storeName,
    required this.storeLocation,
    required this.storeCity,
    this.terminalArray,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    var terminalJson = json['terminal_array'] as List?;
    List<Terminal>? terminals =
        terminalJson?.map((i) => Terminal.fromJson(i)).toList();

    return Store(
      storeId: json['store_id'],
      storeName: json['store_name'],
      storeLocation: json['store_location'],
      storeCity: json['store_city'],
      terminalArray: terminals,
    );
  }
}

class Terminal {
  final String terminalName;
  final String terminalLoc;
  final String terminalType;
  final String terminalModel;
  final String terminalId;
  final int storeId;
  final String terminalSerialnum;

  Terminal({
    required this.terminalName,
    required this.terminalLoc,
    required this.terminalType,
    required this.terminalModel,
    required this.terminalId,
    required this.storeId,
    required this.terminalSerialnum,
  });

  factory Terminal.fromJson(Map<String, dynamic> json) {
    return Terminal(
      terminalName: json['terminal_name'],
      terminalLoc: json['terminal_loc'],
      terminalType: json['terminal_type'],
      terminalModel: json['terminal_model'],
      terminalId: json['terminal_id'],
      storeId: json['store_id'],
      terminalSerialnum: json['terminal_serialnum'],
    );
  }
}
