class TransactionCategory {
  int? identifier;
  String name;
  String icon;
  String type;
  int sequence;
  bool isDeleted;

  TransactionCategory({
    this.identifier,
    required this.name,
    required this.icon,
    required this.type,
    required this.sequence,
    required this.isDeleted
  });

  factory TransactionCategory.fromMap(Map<String, dynamic> map) {
    return TransactionCategory(
      identifier: map['IDENTIFIER'],
      name: map['NAME'], 
      icon: map['ICON'], 
      type: map['TYPE'],
      sequence: map['SEQUENCE'],
      isDeleted: map['IS_DELETED'] == 1 ? true : false
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic> {
      'NAME': name,
      'ICON': icon,
      'TYPE': type,
      'SEQUENCE': sequence,
      'IS_DELETED': isDeleted ? 1 : 0
    };

    if (identifier != null) {
      map['IDENTIFIER'] = identifier;
    }

    return map;
  }
}