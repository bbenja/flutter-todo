import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/widgets/todoitem.dart';
import 'package:todoapp/model/todo.dart';
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<ToDo> _found = [];
  final _toDoController = TextEditingController();
  static late SharedPreferences sharedPreferences;
  static const List<Tab> tabs = <Tab>[
    Tab(
      child: const Text(
        "Personal",
        style: TextStyle(fontSize: 18, color: Colors.black),
      ),
    ),
    Tab(
      child: const Text(
        "Work",
        style: TextStyle(fontSize: 18, color: Colors.black),
      ),
    )
  ];

  @override
  void initState() {
    initSharedPreferences();
    super.initState();
  }

  initSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
    loadData();
  }

  void saveData() {
    List<String> slist =
        _found.map((item) => json.encode(item.toMap())).toList();
    sharedPreferences.setStringList("list", slist);
    //print(slist);
  }

  void loadData() {
    List<String> slist = sharedPreferences.getStringList("list")!;
    _found = slist.map((item) => ToDo.fromMap(json.decode(item))).toList();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFEEEFF5),
        appBar: AppBar(
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
            ),
            bottom: PreferredSize(
              preferredSize: _tabBar.preferredSize,
              child: Material(
                color: Colors.white,
                child: _tabBar,
              ),
            )),
        body: Container(
          child: TabBarView(
            children: [
              Container(child: buildPersonalColumn()),
              Container(child: Text("Other")),
            ],
          ),
        ),
      ),
    );
  }

  TabBar get _tabBar => TabBar(
        tabs: tabs,
      );

  Column buildWorkColumn() {
    return Column(
      children: [
        Expanded(
            child: Scaffold(
          body: Expanded(
            child: Material(
              color: const Color(0xFFEEEFF5),
              child: ListView(
                children: [Text("list2")],
              ),
            ),
          ),
        )),
      ],
    );
  }

  Column buildPersonalColumn() {
    return Column(
      children: [
        Expanded(
          child: Material(
            color: const Color(0xFFEEEFF5),
            child: ListView(
              padding: EdgeInsets.all(15),
              children: [
                for (ToDo todoo in _found.reversed)
                  ToDoItem(
                    todo: todoo,
                    onToDoChanged: _handleToDoChange,
                    onDeleteItem: _deleteToDoItem,
                  ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin:
                      const EdgeInsets.only(bottom: 20, right: 20, left: 20),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
                          hintText: "Add new todo", border: InputBorder.none)),
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
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  void _handleToDoChange(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
    saveData();
  }

  void _deleteToDoItem(String id) {
    setState(() {
      _found.removeWhere((item) => item.id == id);
    });
    saveData();
  }

  void _addToDoItem(String todo) {
    setState(() {
      _found.add(ToDo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        toDoText: todo,
      ));
    });
    _toDoController.clear();
    saveData();
  }

  void _runFilter(String keyword) {
    List<ToDo> results = [];
    if (keyword.isEmpty) {
      results = _found;
    } else {
      results = _found
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
      ),
    );
  }
}
