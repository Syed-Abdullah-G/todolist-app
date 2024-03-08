import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/todo.dart';

class ToDoItem extends StatelessWidget {
  final ToDo todo;
  final Function() onTodoChanged;
  final Function(ToDo) onDeleteItem;

  const ToDoItem({
    super.key,
    required this.todo,
    required this.onTodoChanged,
    required this.onDeleteItem,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        tileColor: Colors.blue[100],
        shape: RoundedRectangleBorder(side: const BorderSide(width: 1.5),
        borderRadius: BorderRadius.circular(15)),
        title: Text(
          todo.todoText!,
          style: TextStyle(
            decoration: todo.isDone ? TextDecoration.lineThrough : null,
            fontSize: 20,fontWeight:FontWeight.w400
          ),
        ),
        leading: Checkbox(
          value: todo.isDone,
          onChanged: (_) {
            onTodoChanged();
          },
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            onDeleteItem(todo);
          },
        ),
      ),
    );
  }
}