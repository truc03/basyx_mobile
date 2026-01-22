class AAS {
  final String id;
  final String idShort;
  final String displayName;

  AAS({required this.id, required this.idShort, required this.displayName});

  factory AAS.fromJson(Map<String, dynamic> json) {
    return AAS(
      id: json['id'],
      idShort: json['idShort'],
      displayName: json['displayName'][0]['text'],
    );
  }
}
