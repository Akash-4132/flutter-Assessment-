import 'package:flutter/material.dart';

class MyLogout extends StatefulWidget {
  const MyLogout({super.key});

  @override
  State<MyLogout> createState() => _MyLogoutState();
}

class _MyLogoutState extends State<MyLogout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logout"),
      ),
      
    );
  }
}