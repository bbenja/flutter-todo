import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/widgets/todoitem.dart';
import 'package:todoapp/model/todo.dart';
import 'package:todoapp/assets/colors.dart';
//import 'package:todoapp/assets/46.JPG';
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<ToDo> personallist = [];
  List<ToDo> worklist = [];
  final _toDoController = TextEditingController();
  static late SharedPreferences sharedPreferences;
  static const List<Tab> tabs = <Tab>[
    Tab(
      child: const Text(
        "Personal",
        style: TextStyle(fontSize: 18, color: gainsboro),
      ),
    ),
    Tab(
      child: const Text(
        "Work",
        style: TextStyle(fontSize: 18, color: gainsboro),
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
    //await sharedPreferences.clear();
    loadData();
  }

  void saveData() {
    List<String> slist =
        personallist.map((item) => json.encode(item.toMap())).toList();
    sharedPreferences.setStringList("personallist", slist);
    slist = worklist.map((item) => json.encode(item.toMap())).toList();
    sharedPreferences.setStringList("worklist", slist);
  }

  void loadData() {
    List<String> slist = sharedPreferences.getStringList("personallist")!;
    personallist =
        slist.map((item) => ToDo.fromMap(json.decode(item))).toList();
    slist = sharedPreferences.getStringList("worklist")!;
    worklist = slist.map((item) => ToDo.fromMap(json.decode(item))).toList();
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
        backgroundColor: eerieblack,
        appBar: AppBar(
          shadowColor: charcoal,
          elevation: 2,
          backgroundColor: eerieblack,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(
                Icons.menu,
                color: gainsboro,
                size: 30,
              ),
              SizedBox(
                height: 40,
                width: 40,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset("46.jpg"),
                ),
              )
            ],
          ),
          bottom: PreferredSize(
            preferredSize: _tabBar.preferredSize,
            child: Material(
              color: eerieblack,
              child: _tabBar,
            ),
          ),
        ),
        body: Container(
          child: TabBarView(
            children: [
              Container(child: buildColumn(personallist)),
              Container(child: buildColumn(worklist)),
            ],
          ),
        ),
      ),
    );
  }

  TabBar get _tabBar => TabBar(
        tabs: tabs,
        indicatorColor: gainsboro,
      );

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Material(
          elevation: 10,
          color: burnsienna.withOpacity(0.0),
          shadowColor: persiangreen.withOpacity(0.1),
          child: child,
        );
      },
      child: child,
    );
  }

  Column buildColumn(List<ToDo> list) {
    return Column(
      children: [
        Expanded(
          child: Material(
            color: eerieblack,
            child: ReorderableListView(
              proxyDecorator: proxyDecorator,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = list.removeAt(oldIndex);
                  list.insert(newIndex, item);
                });
              },
              padding: EdgeInsets.all(15),
              children: [
                for (ToDo todoo in list)
                  ToDoItem(
                    key: ValueKey(todoo),
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
                    color: gainsboro,
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
                    _addToDoItem(_toDoController.text, list);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bluetiful,
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

  void _deleteToDoItem(ToDo todo) {
    print(todo.personal);
    setState(() {
      if (todo.personal) {
        personallist.removeWhere((item) => item.id == todo.id);
      } else {
        worklist.removeWhere((item) => item.id == todo.id);
      }
    });
    saveData();
  }

  void _addToDoItem(String todo, List<ToDo> list) {
    setState(() {
      if (list == personallist) {
        personallist.insert(
            0,
            ToDo(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                toDoText: todo,
                personal: true));
      } else {
        worklist.insert(
            0,
            ToDo(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                toDoText: todo,
                personal: false));
      }
    });
    _toDoController.clear();
    saveData();
  }

  void _runFilter(String keyword) {
    List<ToDo> results = [];
    if (keyword.isEmpty) {
      results = personallist;
    } else {
      results = personallist
          .where((item) =>
              item.toDoText!.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    setState(() {
      personallist = results;
    });
  }

  Widget searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          color: gainsboro, borderRadius: BorderRadius.circular(20)),
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
      backgroundColor: eerieblack,
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
              child: Image.asset("46.jpg"),
            ),
          )
        ],
      ),
    );
  }
}
