import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting the due date
import 'package:taskcw6/models/task.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _taskController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _selectedPriority;
  DateTime? _selectedDueDate;
  String? _selectedSortOption; // Null initial state

  // Get a greeting based on time of day
  String _getGreeting() {
    int hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 18) return "Good Afternoon";
    return "Good Evening";
  }

  // Logout function
  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Add a task for the current user
  void _addTask() async {
    if (_taskController.text.isEmpty ||
        _selectedPriority == null ||
        _selectedDueDate == null) return;

    Task task = Task(
      id: '', // Firestore will generate this
      name: _taskController.text,
      priority: _selectedPriority!,
      dueDate: _selectedDueDate!,
      isCompleted: false,
    );

    DocumentReference docRef = await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('tasks')
        .add(task.toMap());

    setState(() {
      task.id = docRef.id;
      _taskController.clear();
      _selectedPriority = null;
      _selectedDueDate = null;
    });
  }

  // Function to open date picker
  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  // Toggle task completion status
  void _toggleTaskCompletion(String taskId, bool isCompleted) {
    _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('tasks')
        .doc(taskId)
        .update({'isCompleted': !isCompleted});
  }

  // Delete a task
  void _deleteTask(String taskId) {
    _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  // Show dialog to add/edit sub-tasks
  void _showSubTaskDialog(String taskId) {
    TextEditingController _subTaskController = TextEditingController();
    TextEditingController _timeFrameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Sub-Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _timeFrameController,
                decoration: InputDecoration(labelText: 'Time Frame'),
              ),
              TextField(
                controller: _subTaskController,
                decoration: InputDecoration(labelText: 'Sub-Task Details'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _addSubTask(
                    taskId, _timeFrameController.text, _subTaskController.text);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Add a sub-task for the current user
  void _addSubTask(String taskId, String timeFrame, String details) async {
    if (timeFrame.isEmpty || details.isEmpty) return;

    SubTask subTask = SubTask(
      timeFrame: timeFrame,
      details: details,
    );

    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('tasks')
        .doc(taskId)
        .collection('subTasks')
        .add(subTask.toMap());
  }

  // Sort tasks based on the selected sort option
  List<Task> _sortTasks(List<Task> tasks) {
    // Define a custom priority comparison for three priorities
    Map<String, int> priorityOrder = {
      'High': 3,
      'Medium': 2,
      'Low': 1,
    };

    if (_selectedSortOption == 'Priority (High to Low)') {
      tasks.sort((a, b) =>
          priorityOrder[b.priority]!.compareTo(priorityOrder[a.priority]!));
    } else if (_selectedSortOption == 'Priority (Low to High)') {
      tasks.sort((a, b) =>
          priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!));
    } else if (_selectedSortOption == 'Due Date (Earliest to Latest)') {
      tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    } else if (_selectedSortOption == 'Due Date (Latest to Earliest)') {
      tasks.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    } else if (_selectedSortOption == 'Task Completion (Pending)') {
      tasks.sort((a, b) => a.isCompleted ? 1 : -1);
    } else if (_selectedSortOption == 'Task Completion (Completed)') {
      tasks.sort((a, b) => a.isCompleted ? -1 : 1);
    }

    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    String userName = _auth.currentUser?.displayName ?? "User";

    return Scaffold(
      appBar: AppBar(
        title: Text("${_getGreeting()}, $userName"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _taskController,
                  decoration: InputDecoration(labelText: 'Enter Task Name'),
                ),
                DropdownButton<String>(
                  value: _selectedPriority,
                  hint: Text("Select Priority"),
                  items: <String>['High', 'Medium', 'Low'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPriority = newValue!;
                    });
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDueDate == null
                            ? 'Select Due Date'
                            : 'Due Date: ${DateFormat('yyyy-MM-dd').format(_selectedDueDate!)}',
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDueDate(context),
                    ),
                  ],
                ),
                ElevatedButton(onPressed: _addTask, child: Text('Add Task')),
                // Updated Sort Dropdown with new options
                DropdownButton<String>(
                  value: _selectedSortOption,
                  hint: Text("Select sort criteria"), // Default hint text
                  items: [
                    'Priority (High to Low)',
                    'Priority (Low to High)',
                    'Due Date (Earliest to Latest)',
                    'Due Date (Latest to Earliest)',
                    'Task Completion (Pending)',
                    'Task Completion (Completed)',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSortOption = newValue;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('users')
                  .doc(_auth.currentUser!.uid)
                  .collection('tasks')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();

                var tasks = snapshot.data!.docs.map((doc) {
                  return Task.fromMap(
                      doc.data() as Map<String, dynamic>, doc.id);
                }).toList();

                // Apply sorting
                tasks = _sortTasks(tasks);

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    Task task = tasks[index];

                    return ExpansionTile(
                      title: Text(task.name),
                      subtitle: Text(
                          '${task.priority} Priority | Due: ${DateFormat('yyyy-MM-dd').format(task.dueDate)} | ${task.isCompleted ? 'Completed' : 'Pending'}'),
                      children: [
                        StreamBuilder(
                          stream: _firestore
                              .collection('users')
                              .doc(_auth.currentUser!.uid)
                              .collection('tasks')
                              .doc(task.id)
                              .collection('subTasks')
                              .snapshots(),
                          builder: (context,
                              AsyncSnapshot<QuerySnapshot> subSnapshot) {
                            if (!subSnapshot.hasData) return SizedBox.shrink();
                            var subTasks = subSnapshot.data!.docs.map((doc) {
                              return SubTask.fromMap(
                                  doc.data() as Map<String, dynamic>);
                            }).toList();

                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: subTasks.length,
                              itemBuilder: (context, subIndex) {
                                SubTask subTask = subTasks[subIndex];
                                return ListTile(
                                  title: Text(subTask.details),
                                  subtitle: Text(subTask.timeFrame),
                                );
                              },
                            );
                          },
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                task.isCompleted
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                              ),
                              onPressed: () => _toggleTaskCompletion(
                                  task.id, task.isCompleted),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteTask(task.id),
                            ),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () => _showSubTaskDialog(task.id),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
