class TransactionCategory {
  int? identifier;
  String name;
  String icon;
  String type;
  int sequence;

  TransactionCategory({
    this.identifier,
    required this.name,
    required this.icon,
    required this.type,
    required this.sequence
  });

  factory TransactionCategory.fromMap(Map<String, dynamic> map) {
    return TransactionCategory(
      identifier: map['IDENTIFIER'],
      name: map['NAME'], 
      icon: map['ICON'], 
      type: map['TYPE'],
      sequence: map['SEQUENCE']
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic> {
      'NAME': name,
      'ICON': icon,
      'TYPE': type,
      'SEQUENCE': sequence,
    };

    if (identifier != null) {
      map['IDENTIFIER'] = identifier;
    }

    return map;
  }
}