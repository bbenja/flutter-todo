class ToDo {
  String? id;
  String? toDoText;
  bool isDone;

  ToDo({required this.id, required this.toDoText, this.isDone = false});

  ToDo.fromMap(Map map)
      : this.id = map["id"],
        this.toDoText = map["todotext"],
        this.isDone = map["isdone"];

  Map toMap() {
    return {
      "id": this.id,
      "todotext": this.toDoText,
      "isdone": this.isDone,
    };
  }
}
