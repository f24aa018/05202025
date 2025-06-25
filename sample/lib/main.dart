import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'ToDo 外部保存', home: const TodoListPage());
  }
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<String> _todoItems = [];
  final TextEditingController _controller = TextEditingController();
  late File _todoFile;

  @override
  void initState() {
    super.initState();
    _setupFile();
  }

  Future<void> _setupFile() async {
    final directory = await getApplicationDocumentsDirectory();
    // または外部に置きたいならこのようにもできる：
    // final directory = Directory('C:/Users/あなたの名前/Documents');

    final path = '${directory.path}/todo_list.txt';
    _todoFile = File(path);

    if (await _todoFile.exists()) {
      final lines = await _todoFile.readAsLines();
      setState(() {
        _todoItems = lines;
      });
    }
  }

  Future<void> _saveToFile() async {
    await _todoFile.writeAsString(_todoItems.join('\n'));
  }

  void _addTodo() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _todoItems.add(_controller.text);
        _controller.clear();
        _saveToFile();
      });
    }
  }

  void _removeTodo(int index) {
    setState(() {
      _todoItems.removeAt(index);
      _saveToFile();
    });
  }

  void _clearAll() {
    setState(() {
      _todoItems.clear();
      _saveToFile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo 外部保存'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _todoItems.isEmpty ? null : _clearAll,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'タスクを入力',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('追加'),
                  onPressed: _addTodo,
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _todoItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_todoItems[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeTodo(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
