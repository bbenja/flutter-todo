import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/widgets/todoitem.dart';
import 'package:todoapp/model/todo.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final toDosList = ToDo.toDoList();
  List<ToDo> _found = [];
  final _toDoController = TextEditingController();

  String _haveStarted3Times = '';

  Future<int> _getIntFromSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    final startupNumber = prefs.getInt('startupNumber');
    if (startupNumber == null) {
      return 0;
    }
    return startupNumber;
  }

  Future<void> _resetCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('startupNumber', 0);
  }

  Future<void> _incrementStartup() async {
    final prefs = await SharedPreferences.getInstance();
    int last = await _getIntFromSharedPref();
    int current = last + 1;

    await prefs.setInt('startupNumber', current);

    setState(() => _haveStarted3Times = '$current Times');
  }

  @override
  void initState() {
    _found = toDosList; // assign data
    super.initState();
    _incrementStartup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFEEEFF5),
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            Text(_haveStarted3Times),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Column(
                  children: [
                    searchBox(),
                    Expanded(
                      child: ListView(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 15, bottom: 20),
                            child: const Text(
                              "All ToDos",
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.w500),
                            ),
                          ),
                          for (ToDo todoo in _found.reversed)
                            ToDoItem(
                              todo: todoo,
                              onToDoChanged: _handleToDoChange,
                              onDeleteItem: _deleteToDoItem,
                            ),
                        ],
                      ),
                    )
                  ],
                )),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(
                          bottom: 20, right: 20, left: 20),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 0.0),
                            blurRadius: 10.0,
                            spreadRadius: 0.0,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                          controller: _toDoController,
                          decoration: const InputDecoration(
                              hintText: "Add new todo",
                              border: InputBorder.none)),
                    ),
                  ),
                  Container(
                      margin: const EdgeInsets.only(
                        bottom: 20,
                        right: 20,
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          _addToDoItem(_toDoController.text);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(60, 60),
                          elevation: 10,
                        ),
                        child: const Text(
                          "+",
                          style: TextStyle(fontSize: 40),
                        ),
                      ))
                ],
              ),
            )
          ],
        ));
  }

  void _handleToDoChange(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
  }

  void _deleteToDoItem(String id) {
    setState(() {
      toDosList.removeWhere((item) => item.id == id);
    });
  }

  void _addToDoItem(String todo) {
    setState(() {
      toDosList.add(ToDo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        toDoText: todo,
      ));
    });
    _toDoController.clear();
  }

  void _runFilter(String keyword) {
    List<ToDo> results = [];
    if (keyword.isEmpty) {
      results = toDosList;
    } else {
      results = toDosList
          .where((item) =>
              item.toDoText!.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _found = results;
    });
  }

  Widget searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: TextField(
        onChanged: (value) => _runFilter(value),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.black,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(maxHeight: 20, minWidth: 25),
          border: InputBorder.none,
          hintText: "Search",
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
        backgroundColor: const Color(0xFFEEEFF5),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              Icons.menu,
              color: Color(0xFF3a3a3a),
              size: 30,
            ),
            SizedBox(
              height: 40,
              width: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset("assets/image/46.jpg"),
              ),
            )
          ],
        ));
  }
}
