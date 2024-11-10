import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  String? _selectedSortOption;

  String _getGreeting() {
    int hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 18) return "Good Afternoon";
    return "Good Evening";
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _addTask() async {
    if (_taskController.text.isEmpty ||
        _selectedPriority == null ||
        _selectedDueDate == null) return;

    Task task = Task(
      id: '',
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

  void _toggleTaskCompletion(String taskId, bool isCompleted) {
    _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('tasks')
        .doc(taskId)
        .update({'isCompleted': !isCompleted});
  }

  void _deleteTask(String taskId) {
    _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  void _deleteSubTask(String taskId, String subTaskId) {
    _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('tasks')
        .doc(taskId)
        .collection('subTasks')
        .doc(subTaskId)
        .delete();
  }

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

  void _addSubTask(String taskId, String timeFrame, String details) async {
    if (timeFrame.isEmpty || details.isEmpty) return;

    SubTask subTask = SubTask(
      timeFrame: timeFrame,
      details: details,
    );

    DocumentReference docRef = await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('tasks')
        .doc(taskId)
        .collection('subTasks')
        .add(subTask.toMap());

    setState(() {
      // Assign the Firestore ID to the SubTask object
      subTask.id = docRef.id;
    });
  }

  void _showEditTaskDialog(Task task) {
    TextEditingController _nameController =
        TextEditingController(text: task.name);
    String? _priority = task.priority;
    DateTime? _dueDate = task.dueDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Task Name'),
                  ),
                  DropdownButtonFormField<String>(
                    value: _priority,
                    hint: Text("Select Priority"),
                    items:
                        <String>['High', 'Medium', 'Low'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _priority = newValue;
                      });
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _dueDate == null
                              ? 'Select Due Date'
                              : 'Due Date: ${DateFormat('yyyy-MM-dd').format(_dueDate!)}',
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _dueDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null && picked != _dueDate) {
                            setState(() {
                              _dueDate = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _editTask(
                        task.id, _nameController.text, _priority, _dueDate);
                    Navigator.pop(context);
                  },
                  child: Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editTask(
      String taskId, String name, String? priority, DateTime? dueDate) {
    if (name.isEmpty || priority == null || dueDate == null) return;

    _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('tasks')
        .doc(taskId)
        .update({
      'name': name,
      'priority': priority,
      'dueDate': dueDate,
    });
  }

  void _showEditSubTaskDialog(
      String taskId, String subTaskId, SubTask subTask) {
    TextEditingController _subTaskController =
        TextEditingController(text: subTask.details);
    TextEditingController _timeFrameController =
        TextEditingController(text: subTask.timeFrame);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Sub-Task'),
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
                _editSubTask(taskId, subTaskId, _timeFrameController.text,
                    _subTaskController.text);
                Navigator.pop(context);
              },
              child: Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  void _editSubTask(
      String taskId, String subTaskId, String timeFrame, String details) {
    if (timeFrame.isEmpty || details.isEmpty) return;

    _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('tasks')
        .doc(taskId)
        .collection('subTasks')
        .doc(subTaskId)
        .update({
      'timeFrame': timeFrame,
      'details': details,
    });
  }

  List<Task> _sortTasks(List<Task> tasks) {
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

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.yellow;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
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
          // Add Task Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _taskController,
                      decoration: InputDecoration(
                        labelText: 'Enter Task Name',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.task_alt),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedPriority,
                            decoration: InputDecoration(
                              labelText: "Priority",
                              border: OutlineInputBorder(),
                            ),
                            items: <String>['High', 'Medium', 'Low']
                                .map((String value) {
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
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDueDate(context),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Due Date',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _selectedDueDate == null
                                    ? 'Select Date'
                                    : DateFormat('yyyy-MM-dd')
                                        .format(_selectedDueDate!),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _addTask,
                      child: Text('Add Task'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Sort Criteria Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedSortOption,
              hint: Text("Select sort criteria"),
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
          ),

          // Expanded Task List
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

                tasks = _sortTasks(tasks);

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    Task task = tasks[index];

                    return Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 3,
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: _getPriorityColor(task.priority),
                            radius: 10,
                          ),
                          title: Text(task.name,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            '${task.priority} Priority | Due: ${DateFormat('yyyy-MM-dd').format(task.dueDate)} | ${task.isCompleted ? 'Completed' : 'Pending'}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
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
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (!snapshot.hasData)
                                  return CircularProgressIndicator();

                                var subTasks = snapshot.data!.docs.map((doc) {
                                  return SubTask.fromMap(
                                      doc.data() as Map<String, dynamic>,
                                      doc.id);
                                }).toList();

                                return Column(
                                  children: [
                                    ...subTasks.map((subTask) {
                                      return ListTile(
                                        title: Text(subTask.timeFrame),
                                        subtitle: Text(subTask.details),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.edit,
                                                  color: Colors.green),
                                              onPressed: () =>
                                                  _showEditSubTaskDialog(
                                                      task.id,
                                                      subTask.id!,
                                                      subTask),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () => _deleteSubTask(
                                                  task.id, subTask.id!),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    ListTile(
                                      title: TextButton(
                                        onPressed: () =>
                                            _showSubTaskDialog(task.id),
                                        child: Text('Add Sub-Task'),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Checkbox(
                                  value: task.isCompleted,
                                  onChanged: (bool? value) {
                                    _toggleTaskCompletion(
                                        task.id, task.isCompleted);
                                  },
                                ),
                                IconButton(
                                  onPressed: () => _showEditTaskDialog(task),
                                  icon: Icon(Icons.edit, color: Colors.green),
                                  tooltip: 'Edit Task',
                                ),
                                IconButton(
                                  onPressed: () => _deleteTask(task.id),
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'Delete Task',
                                ),
                              ],
                            ),
                          ],
                        ));
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
