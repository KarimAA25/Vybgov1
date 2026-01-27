// ignore_for_file: depend_on_referenced_packages

class VerifyDocumentModel {
  String? documentId;
  String? name;
  String? number;
  String? dob;
  List<dynamic>? documentImage;
  bool? isVerify;

  VerifyDocumentModel({
    this.documentId,
    this.name,
    this.number,
    this.dob,
    this.documentImage,
    this.isVerify,
  });

  @override
  String toString() {
    return 'VerifyDocumentModel{documentId: $documentId, name: $name, number: $number, dob: $dob, documentImage: $documentImage, isVerify: $isVerify}';
  }

  VerifyDocumentModel.fromJson(Map<String, dynamic> json) {
    documentId = json['documentId'];
    name = json['name'];
    number = json['number'];
    dob = json['dob'];
    documentImage = json['documentImage'];
    isVerify = json['isVerify'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['documentId'] = documentId;
    data['name'] = name;
    data['number'] = number;
    data['dob'] = dob;
    data['documentImage'] = documentImage;
    data['isVerify'] = isVerify;
    return data;
  }

  VerifyDocumentModel copyWith({
    String? documentId,
    String? name,
    String? number,
    String? dob,
    List<dynamic>? documentImage,
    bool? isVerify,
  }) {
    return VerifyDocumentModel(
      documentId: documentId ?? this.documentId,
      name: name ?? this.name,
      number: number ?? this.number,
      dob: dob ?? this.dob,
      documentImage: documentImage ?? this.documentImage,
      isVerify: isVerify ?? this.isVerify,
    );
  }
}
