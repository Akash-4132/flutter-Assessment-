// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';

// class MessageScreen extends StatefulWidget {
//   final DocumentSnapshot userSnapshot;

//   const MessageScreen({super.key, required this.userSnapshot});

//   @override
//   State<MessageScreen> createState() => _MessageScreenState();
// }

// class _MessageScreenState extends State<MessageScreen> {
//   TextEditingController _msgController = TextEditingController();

//   String formatTimestamp(Timestamp timestamp) {
//     DateTime dateTime = timestamp.toDate();
//     String formatTime = DateFormat.jm().format(dateTime);
//     String formattedDate = DateFormat.yMMMd().format(dateTime);
//     return '$formattedDate at $formatTime';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 28, 6, 20),
//         elevation: 30,
//         automaticallyImplyLeading: false,
//         title: Row(
//           children: [
//             CircleAvatar(
//               backgroundImage: NetworkImage(widget.userSnapshot["profilepic"]),
//             ),
//             const SizedBox(width: 10),
//             Text(
//               "${widget.userSnapshot["username"]}",
//               style: const TextStyle(color: Colors.white),
//             )
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder(
//               stream: FirebaseFirestore.instance
//                   .collection("message")
//                   .where("reciever", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
//                   .where("sender", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
//                   .orderBy("timestamp")
//                   .snapshots(),
//               builder: (context, senderSnapshot) {
//                 if (senderSnapshot.hasData) {
//                   var senderMessages = senderSnapshot.data!.docs;

//                   return StreamBuilder(
//                     stream: FirebaseFirestore.instance
//                         .collection("message")
//                         .where("sender", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
//                         .where("reciever", isEqualTo: widget.userSnapshot.id)
//                         .orderBy("timestamp")
//                         .snapshots(),
//                     builder: (context, receiverSnapshot) {
//                       if (receiverSnapshot.hasData) {
//                         var receiverMessages = receiverSnapshot.data!.docs;
//                         var allMessages = [
//                           ...senderMessages,
//                           ...receiverMessages,
//                         ];

//                         allMessages.sort((a, b) =>
//                             (a['timestamp'] as Timestamp).compareTo(b['timestamp'] as Timestamp));

//                         return ListView.builder(
//                           itemCount: allMessages.length,
//                           itemBuilder: (context, index) {
//                             var message = allMessages[index];
//                             String senderId = message['sender'];
//                             bool isCurrentUserSender =
//                                 senderId == FirebaseAuth.instance.currentUser!.uid;

//                             return Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Row(
//                                 mainAxisAlignment: isCurrentUserSender
//                                     ? MainAxisAlignment.end
//                                     : MainAxisAlignment.start,
//                                 children: [
//                                   if (!isCurrentUserSender)
//                                     CircleAvatar(
//                                       child: Text("${widget.userSnapshot["username"][0]}"),
//                                     )
//                                   else
//                                     const SizedBox(width: 32),
//                                   const SizedBox(width: 8.0),
//                                   Flexible(
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                         color: isCurrentUserSender
//                                             ? const Color.fromARGB(255, 17, 7, 55)
//                                             : const Color.fromARGB(255, 65, 6, 74),
//                                         borderRadius: BorderRadius.circular(8.0),
//                                       ),
//                                       child: Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             vertical: 8.0, horizontal: 12.0),
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               "${message["message"]}",
//                                               style: const TextStyle(color: Colors.white),
//                                             ),
//                                             const SizedBox(height: 4),
//                                             Text(
//                                               formatTimestamp(message["timestamp"] as Timestamp),
//                                               style: const TextStyle(
//                                                   color: Colors.white54, fontSize: 10),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         );
//                       } else if (receiverSnapshot.hasError) {
//                         print(".........................>>> ERROR${receiverSnapshot.error}");
//                         return const Center(child: CircularProgressIndicator());
//                       } else {
//                         return const Center(child: CircularProgressIndicator());
//                       }
//                     },
//                   );
//                 } else if (senderSnapshot.hasError) {
//                   print("______________________>>>> ERROR ${senderSnapshot.error}");
//                   return const Center(child: CircularProgressIndicator());
//                 } else {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//               },
//             ),

//           ),
          
        
//         ],
//       ),
//       child:Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Row(
//           children: [
//             Flexible(child: TextField(
//               controller: _msgController,
//               decoration: InputDecoration(
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: BorderSide(
//                     color: Color.fromARGB(255, 28, 135, 206)  ),
//                     borderRadius: BorderRadius.circular(20),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(
//                     color: Color.fromARGB(255, 28, 135, 206)),
//                     borderRadius: BorderRadius.circular(20),
//                 ),
//                 hintText: "type Message here",
//                 hintStyle: TextStyle(color: Colors.teal),
//               ),
//               style: TextStyle(color: Colors.yellow),
//             ),),
//             IconButton(onPressed:() {
//               String messageText = _msgController.text.toString();
//               if(messageText.isNotEmpty){
//                 FirebaseAuth.instance.collection("message").add({
//                   "sender":FirebaseAuth.instance.currentUser!.uid,
//                   "receiver":widget.userSnapshot.id,
//                   "message":messageText,
//                   "timestamp":DateTime.now(),
//                 });
//                 _msgController.clear();
//               }

//             }, icon: Icon(
//               Icons.send,
//               color: Color.fromARGB(255, 6, 49, 85),
//               size: 30,
//             ))
//           ],
//         ),
//       )
//     );
//   }
// }
