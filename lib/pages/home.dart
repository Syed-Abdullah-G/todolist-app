import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/todo.dart';
import 'package:flutter_application_1/widgets/todo_item.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late List<ToDo> _filteredTodos;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _filteredTodos = [];
    _searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEEFF5),
      ),
      backgroundColor: const Color(0xFFEEEFF5),
      body: ValueListenableBuilder<Box<ToDo>>(
        valueListenable: Hive.box<ToDo>('todoBox').listenable(),
        builder: (context, box, _) {
          final List<ToDo> todosList = box.values.toList();
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              children: [
                _searchBox(),
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 30, bottom: 20),
                        child: const Text(
                          'All ToDos',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      for (ToDo todo in _filteredTodos.isEmpty
                          ? todosList.reversed
                          : _filteredTodos)
                        ToDoItem(
                          key: ValueKey(todo.id),
                          todo: todo,
                          onTodoChanged: () => _handleToDoChange(todo),
                          onDeleteItem: (ToDo toDo) =>
                              _onDeleteItem(context, todo),
                        ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addToDoItem(context),
        backgroundColor: const Color(0xFF5F52EE),
        child: const Icon(
          Icons.add,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }

  void _handleToDoChange(ToDo todo) {
    todo.isDone = !todo.isDone;
    todo.save();
  }

  void _onDeleteItem(BuildContext context, ToDo todo) {
    todo.delete();
  }

  void _addToDoItem(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final todoController = TextEditingController();
        return AlertDialog(
          title: const Text('Add a new item'),
          content: TextField(
            controller: todoController,
            decoration: const InputDecoration(
              hintText: 'Enter your todo',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final box = Hive.box<ToDo>('todoBox');
                final newToDo = ToDo(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  todoText: todoController.text,
                );
                box.add(newToDo);
                newToDo.save();
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _searchBox() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 236, 234, 234),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _runFilter,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(2),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.black,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(maxHeight: 15, minWidth: 35),
          border: InputBorder.none,
          hintText: "Search",
          hintStyle: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  void _runFilter(String enteredKeyword) {
    final box = Hive.box<ToDo>('todoBox');
    final List<ToDo> allTodos = box.values.toList();

    if (enteredKeyword.isEmpty) {
      setState(() {
        _filteredTodos = [];
      });
      return;
    }

    final List<String> keywords = enteredKeyword.toLowerCase().split(' ');

    setState(() {
      _filteredTodos = allTodos.where((todo) {
        if (todo.todoText != null) {
          for (final keyword in keywords) {
            if (!todo.todoText!.toLowerCase().contains(keyword)) {
              return false;
            }
          }
          return true;
        }
        return false;
      }).toList();
    });
  }
}