class ClassRoom {
  int rowId;
  String code;
  String name;
  String spreadSheetName;

  ClassRoom({
    required this.rowId,
    required this.code,
    required this.name,
    required this.spreadSheetName,
  });

  @override
  String toString() {
    return "[ID] $rowId - [Code] $code - [Name] $name - [SpreadSheetName] $spreadSheetName";
  }
}
