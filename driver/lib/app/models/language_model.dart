class LanguageModel {
  String? id;
  String? name;
  String? code;
  bool? active;
  bool? isDefault;

  LanguageModel({this.id, this.name, this.code, this.active, this.isDefault});

  @override
  String toString() {
    return 'LanguageModel{id: $id, name: $name, code: $code, active: $active, isDefault: $isDefault}';
  }

  LanguageModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    active = json['active'];
    code = json['code'];
    isDefault = json['isDefault'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['active'] = active;
    data['code'] = code;
    data['isDefault'] = isDefault ?? false;
    return data;
  }
}
