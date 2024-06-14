import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'abertura.dart';

class TodoListApp extends StatefulWidget {
  final String viagemId;
  TodoListApp({required this.viagemId});

  @override
  _TodoListAppState createState() => _TodoListAppState();
}

class _TodoListAppState extends State<TodoListApp> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;
  late String _userId;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _userId = _user.uid;
  }

  Future<void> _addTask(String task) async {
    await _firestore.collection('tasks').add({
      'userId': _userId,
      'viagemId': widget.viagemId,
      'task': task,
      'done': false,
    });
  }

  Future<void> _updateTask(String taskId, bool done) async {
    await _firestore.collection('tasks').doc(taskId).update({'done': done});
  }

  Future<void> _deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Abertura()));
          },
        ),
        title: Text('Lista de Tarefas'),
        backgroundColor: const Color.fromARGB(255, 138, 181, 202),
      ),
      backgroundColor: const Color.fromARGB(
          255, 161, 207, 240), // Define a cor de fundo com contraste azul
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('tasks')
            .where('userId', isEqualTo: _userId)
            .where('viagemId', isEqualTo: widget.viagemId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final tasks = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final taskId = task.id;
              final taskName = task['task'];
              final taskDone = task['done'];

              return ListTile(
                title: Text(
                  taskName,
                  style: TextStyle(
                    decoration: taskDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                leading: Checkbox(
                  value: taskDone,
                  onChanged: (bool? value) {
                    if (value != null) {
                      _updateTask(taskId, value);
                    }
                  },
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteTask(taskId);
                  },
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: ElevatedButton(
        child: Text('Adicionar Tarefa'),
        style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(
      Color.fromARGB(255, 66, 152, 212),
    ),
    foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
  ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              final TextEditingController taskController =
                  TextEditingController();

              return AlertDialog(
                title: Text('Nova Tarefa'),
                content: TextField(
                  controller: taskController,
                  decoration: InputDecoration(labelText: 'Tarefa'),
                ),
                actions: [
                  TextButton(
                    child: Text('Cancelar'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Adicionar'),
                    onPressed: () {
                      _addTask(taskController.text);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
