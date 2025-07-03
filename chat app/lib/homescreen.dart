import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firbaseprojet/login.dart';
import 'package:firbaseprojet/messagescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Replace with your actual message screen widget
class MyMessageScreen extends StatelessWidget {
  final DocumentSnapshot userSnapshot;

  MyMessageScreen({required this.userSnapshot});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with ${userSnapshot["username"]}')),
      body: Center(
        child: Text('Messaging screen for ${userSnapshot["username"]}'),
      ),
    );
  }
}

class Myhomescreen extends StatefulWidget {
  final User? user;
  Myhomescreen({super.key, required this.user});

  @override
  State<Myhomescreen> createState() => _MyhomescreenState();
}

class _MyhomescreenState extends State<Myhomescreen> {
  String? username = "";
  TextEditingController _searchController = TextEditingController();

  List<DocumentSnapshot>? allusers;
  List<DocumentSnapshot>? filterUsers;

  Future<void> getUserRecord() async {
    var document = await FirebaseFirestore.instance
        .collection("user")
        .doc(widget.user!.uid)
        .get();

    setState(() {
      username = document["username"];
    });
  }

  @override
  void initState() {
    super.initState();
    getUserRecord();
  }

  void searchUser(String keyword) {
    setState(() {
      if (keyword.isEmpty) {
        filterUsers = allusers;
      } else {
        filterUsers = allusers!
            .where((user) => user["username"]
                .toString()
                .toLowerCase()
                .contains(keyword.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text("Welcome, $username"),
        backgroundColor: Colors.blueAccent,
        actions: [
          TextButton.icon(
            icon: Icon(Icons.logout, color: Colors.white),
            label: Text("Logout", style: TextStyle(color: Colors.white)),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyLogin()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: searchUser,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Search...',
                hintText: 'Enter Search Keywords',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('user').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  allusers = snapshot.data!.docs
                      .where((element) => element.id != widget.user!.uid)
                      .toList();

                  filterUsers ??= List.from(allusers!);

                  print(filterUsers); // Debug print

                  return ListView.builder(
                    itemCount: filterUsers!.length,
                    itemBuilder: (context, index) {
                      final user = filterUsers![index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>MessageScreen(
                                userSnapshot: user,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Card(
                            color: Colors.deepPurpleAccent[100],
                            child: ListTile(
                              title: Text(
                                user["username"] ?? "No name",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}



// // homescreen.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class Myhomescreen extends StatelessWidget {
//   final User? user;
//   const Myhomescreen({super.key, this.user});

//   Future<DocumentSnapshot> _getUserData() async {
//     return await FirebaseFirestore.instance.collection('user').doc(user!.uid).get();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Home")),
//       body: FutureBuilder<DocumentSnapshot>(
//         future: _getUserData(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.hasError) {
//             return const Center(child: Text("Failed to load user data"));
//           }

//           final data = snapshot.data!.data() as Map<String, dynamic>?;
//           final username = data?["username"] ?? "No username";
//           final email = data?["email"] ?? "No email";
//           final profilePic = data?["profilepic"] ?? "";

//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircleAvatar(
//                   radius: 50,
//                   backgroundImage:
//                       profilePic.isNotEmpty ? NetworkImage(profilePic) : null,
//                   child: profilePic.isEmpty ? const Icon(Icons.person, size: 50) : null,
//                 ),
//                 const SizedBox(height: 20),
//                 Text("Username: $username"),
//                 Text("Email: $email"),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }