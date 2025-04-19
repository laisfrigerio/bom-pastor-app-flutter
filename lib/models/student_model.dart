class Student {
  int rowId;
  String name;
  int score;

  Student({required this.rowId, required this.name, required this.score});

  @override
  String toString() {
    return "[ID] $rowId - [Name] $name - [Score] $score";
  }
}
