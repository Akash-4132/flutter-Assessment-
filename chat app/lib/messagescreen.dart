import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MessageScreen extends StatefulWidget {
  final DocumentSnapshot userSnapshot;

  const MessageScreen({super.key, required this.userSnapshot});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _msgController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;
  late String chatId;
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    chatId = getChatId(currentUser.uid, widget.userSnapshot.id);
    setTypingStatus(false);
  }

  String getChatId(String id1, String id2) {
    return id1.hashCode <= id2.hashCode ? "$id1\_$id2" : "$id2\_$id1";
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formatTime = DateFormat.jm().format(dateTime);
    String formattedDate = DateFormat.yMMMd().format(dateTime);
    return '$formattedDate at $formatTime';
  }

  void sendMessage() async {
    String messageText = _msgController.text.trim();
    if (messageText.isNotEmpty) {
      await FirebaseFirestore.instance.collection("message").add({
        "chatId": chatId,
        "sender": currentUser.uid,
        "receiver": widget.userSnapshot.id,
        "message": messageText,
        "timestamp": Timestamp.now(),
        "isSeen": false,
      });
      _msgController.clear();
      setTypingStatus(false);
    }
  }

  void setTypingStatus(bool status) {
    FirebaseFirestore.instance.collection("typing").doc(chatId).set({
      currentUser.uid: status,
    }, SetOptions(merge: true));
  }

  void markMessagesSeen(List<QueryDocumentSnapshot> messages) async {
    for (var message in messages) {
      if (message['receiver'] == currentUser.uid && message['isSeen'] == false) {
        await message.reference.update({"isSeen": true});
      }
    }
  }

  @override
  void dispose() {
    setTypingStatus(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 28, 6, 20),
        elevation: 10,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.userSnapshot["username"],
              style: const TextStyle(color: Colors.white),
            ),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("typing")
                  .doc(chatId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.data!.data() != null &&
                    (snapshot.data!.data()
                            as Map<String, dynamic>)[widget.userSnapshot.id] ==
                        true) {
                  return const Text(
                    "Typing...",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("message")
                  .where("chatId", isEqualTo: chatId)
                  .orderBy("timestamp", descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return const Center(child: Text("No messages found"));
                }

                var messages = snapshot.data!.docs;

                // Mark incoming messages as seen
                markMessagesSeen(messages);

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isMe = message["sender"] == currentUser.uid;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? const Color.fromARGB(255, 40, 120, 255)
                              : const Color.fromARGB(255, 109, 48, 131),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMe
                                ? const Radius.circular(16)
                                : const Radius.circular(0),
                            bottomRight: isMe
                                ? const Radius.circular(0)
                                : const Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message["message"],
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formatTimestamp(
                                      message["timestamp"] as Timestamp),
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 10),
                                ),
                                if (isMe)
                                  Icon(
                                    message["isSeen"] == true
                                        ? Icons.done_all
                                        : Icons.check,
                                    size: 16,
                                    color: message["isSeen"] == true
                                        ? Colors.lightGreenAccent
                                        : Colors.white70,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.black,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    onChanged: (text) {
                      setTypingStatus(text.isNotEmpty);
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 35, 35, 35),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color.fromARGB(255, 28, 135, 206),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
