import 'package:flutter/material.dart';
import 'package:notekeeper/models/note.dart';
import 'package:notekeeper/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

import 'note_detail.dart';

class NotesList extends StatefulWidget {
  @override
  _NotesListState createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int notesListItemCount = 5;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Note Keeper"),
      ),
      body: _noteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Note('', '', 2), "Add Note");
        },
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;

      default:
        return Colors.yellow;
    }
  }

  // return the priority color

  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;

      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  // return the priority icon

  void navigateToDetail(Note note, String title) async {
    bool result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetail(
          note: note,
          appBarTitle: title,
        ),
      ),
    );

    if(result){
      updateListView();
    }
  }

  // delete Note Function

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();

      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.notesListItemCount = noteList.length;
        });
      });
    });
  }

  // show Snaclbar function

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    updateListView();

    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully');
    }
  }

  Widget _noteListView() {
    TextStyle titleText = Theme.of(context).textTheme.subtitle2;
    return ListView.builder(
        itemCount: notesListItemCount,
        itemBuilder: (BuildContext context, index) {
          return Card(
              child: ListTile(
            onTap: () {
              navigateToDetail(this.noteList[index], "Edit Note");
            },
            leading: CircleAvatar(
                backgroundColor:
                    getPriorityColor(this.noteList[index].priority),
                child: getPriorityIcon(this.noteList[index].priority)),
            title: Text(
              this.noteList[index].title,
              style: titleText,
            ),
            subtitle: Text(this.noteList[index].date),
            trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _delete(context, noteList[index]);
                }),
          ));
        });
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }
}
