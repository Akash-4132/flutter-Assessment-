  import 'package:flutter/material.dart';
import 'package:offlinedatabase/dbhelper.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> notes = [];

  @override
  void initState() {
    super.initState();
    refreshNotes();
  }

  Future<void> refreshNotes() async {
    final data = await NoteDatabaseService.instance.fetchAllNotes();
    setState(() {
      notes = data;
    });
  }

  
  void showNoteDialog({Map<String, dynamic>? note}) {
    final titleController = TextEditingController(text: note != null ? note['title'] : '');
    final descriptionController = TextEditingController(text: note != null ? note['description'] : '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(note == null ? 'Add Note' : 'Edit Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final description = descriptionController.text.trim();

              if (title.isEmpty || description.isEmpty) return;

              if (note == null) {
                // Add new note
                await NoteDatabaseService.instance.insertNote(
                  title: title,
                  description: description,
                );
              } else {
                // Update existing note
                await NoteDatabaseService.instance.modifyNote(
                  id: note['id'],
                  title: title,
                  description: description,
                );
              }

              Navigator.of(context).pop();
              refreshNotes();
            },
            child: Text('Save'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Delete note
  void deleteNote(int id) async {
    await NoteDatabaseService.instance.removeNote(id: id);
    refreshNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Notes'),
      ),
      body: notes.isEmpty
          ? Center(child: Text('No notes available.'))
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return ListTile(
                  title: Text(note['title']),
                  subtitle: Text(note['description']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => showNoteDialog(note: note),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deleteNote(note['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showNoteDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
