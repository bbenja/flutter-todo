class ToDo {
  String? id;
  String? toDoText;
  bool isDone;
  bool personal;

  ToDo({
    required this.id,
    required this.toDoText,
    this.isDone = false,
    this.personal = true,
  });

  ToDo.fromMap(Map map)
      : this.id = map["id"],
        this.toDoText = map["todotext"],
        this.isDone = map["isdone"],
        this.personal = map["personal"];

  Map toMap() {
    return {
      "id": this.id,
      "todotext": this.toDoText,
      "isdone": this.isDone,
      "personal": this.personal,
    };
  }
}
