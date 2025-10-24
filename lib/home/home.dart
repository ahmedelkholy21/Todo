import 'package:flutter/material.dart';
import 'package:todo/home/database.dart';
import 'package:todo/tools/addtasksheet.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> users = [];
  DB db = DB();

  Future<void> loadUsers() async {
    final data = await db.getUsers();
    setState(() {
      users = data;
    });
  }

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> deleteUser(int id) async {
    await db.deleteUser(id);
    loadUsers();
  }
  Future<void> edituser(int id,String oldtit,String olddis)async{
    TextEditingController newtit=TextEditingController(text: oldtit);
        TextEditingController newdis=TextEditingController(text: olddis);
         await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Edit User"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: newtit,
            decoration: const InputDecoration(labelText: "Name"),
          ),
          TextField(
            controller: newdis,
            decoration: const InputDecoration(labelText: "Price"),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
      onPressed: () async {
  final newtitle = newtit.text;
  final newdiscription = newdis.text;

  // متعدلش التاريخ، خليه زي ما هو
  final oldData = users.firstWhere((e) => e['id'] == id);
  final oldDescription = oldData['description'] ?? '';

  // لو القديم فيه تاريخ في الأول، نحافظ عليه ونحدث الباقي فقط
  String updatedDescription = oldDescription;
  final regex = RegExp(r'^\d{4}-\d{2}-\d{2}');
  if (regex.hasMatch(oldDescription)) {
    final datePart = regex.firstMatch(oldDescription)!.group(0)!;
    final rest = newdiscription;
    updatedDescription = "$datePart\n$rest";
  } else {
    updatedDescription = newdiscription;
  }

  await db.updateUser(id, newtitle, updatedDescription);
  Navigator.pop(context);
  loadUsers();
},
  child: const Text("Save"),
        ),],));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            builder: (context) {
              return AddTaskSheet(onTaskAdded: loadUsers);
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      backgroundColor: Colors.indigoAccent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          const Padding(
            padding: EdgeInsets.only(left: 30),
            child: Text(
              "Good Morning",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: users.isEmpty
                  ? const Center(child: Text("No tasks yet"))
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final item = users[index];
                        return Dismissible(
                          key: Key(item['id'].toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white70,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () => deleteUser(item['id']),
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                    size: 28,
                                  ),
                                ),
                                SizedBox(width: 20),
                                IconButton(
                                  onPressed: () =>edituser(item['id'], item['title'], item['description']),
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.green,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            await Future.delayed(const Duration(seconds: 3));

                            return false;
                          },

                          child: Card(
                            color: Colors.white,
                            elevation: 6,
                            shadowColor: Colors.black.withOpacity(0.2),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              title: Text(
                                item['title'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(item['description'] ?? ''),
                              leading: const Icon(
                                Icons.check_circle_outline,
                                color: Colors.indigoAccent,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
