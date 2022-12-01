class ToDo {
  String? id;
  String? toDoText;
  bool isDone;

  ToDo({required this.id, required this.toDoText, this.isDone = false});

  static List<ToDo> toDoList() {
    return [
      ToDo(id: '01', toDoText: 'Flutter', isDone: false),
      ToDo(id: '02', toDoText: 'Emails', isDone: true),
    ];
  }
}
