import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notekeeper/models/note.dart';
import 'package:notekeeper/utils/database_helper.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  const NoteDetail({Key key, this.appBarTitle, this.note}) : super(key: key);

  @override
  _NoteDetailState createState() => _NoteDetailState();
}

class _NoteDetailState extends State<NoteDetail> {
  static var _priorities = ['High', 'Low'];
  String valueSelectedByUser = 'Low';

  DatabaseHelper databaseHelper = DatabaseHelper();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    titleController.text = widget.note.title;
    descriptionController.text = widget.note.description;
    return Scaffold(
      appBar: AppBar(title: Text('${widget.appBarTitle}')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(children: <Widget>[
          ListTile(
            title: DropdownButton(
                items: _priorities
                    .map((String dropDownStringItem) => DropdownMenuItem(
                          value: dropDownStringItem,
                          child: Text(dropDownStringItem),
                        ))
                    .toList(),
                value: getPriorityAsString(widget.note.priority),
                onChanged: (value) {
                  setState(() {
                    valueSelectedByUser = value;
                    updatePriorityAsInt(value);
                  });
                  return print("$value");
                }),
          ),
          TextFormField(
            onChanged: (value) {
              updateTitle();
            },
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
            controller: titleController,
            decoration: InputDecoration(
                labelText: "Title", border: OutlineInputBorder()),
          ),
          SizedBox(height: 15.0),
          TextFormField(
            onChanged: (value) {
              updateDescription();
            },
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
            minLines: 5,
            maxLines: 10,
            controller: descriptionController,
            decoration: InputDecoration(
                labelText: "Description", border: OutlineInputBorder()),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Row(children: <Widget>[
              Expanded(
                child: MaterialButton(
                  color: Colors.pink[900],
                  onPressed: () {
                    _save();
                  },
                  child: Text(
                    "Save",
                    textScaleFactor: 1.5,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: MaterialButton(
                  color: Colors.pink[900],
                  onPressed: () {
                    _delete();
                  },
                  child: Text(
                    "Delete",
                    textScaleFactor: 1.5,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ]),
          )
        ]),
      ),
    );
  }

  void updatePriorityAsInt(String value) {
    switch(value) {
      case 'High':
        widget.note.priority = 1;
        break;
      case 'Low':
        widget.note.priority = 2;
        break;
    }
  }

  String getPriorityAsString(int value) {
    String priority;
    switch(value){
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
  }

  void updateTitle() {
    widget.note.title = titleController.text;
  }

  void updateDescription(){
    widget.note.description = descriptionController.text;
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void _save() async {

    //validation
    if(widget.note.title == '' || widget.note.description == '') {
      _showAlertDialogue('Status', 'Fill Empty Fields');
      return;
    }
    moveToLastScreen();
    widget.note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if(widget.note.id != null) {
      result = await databaseHelper.updateNote(widget.note);
    }else{
      result = await databaseHelper.insertNote(widget.note);
    }

    if(result != 0) {
      _showAlertDialogue('Status', 'Note Saved Successfully');
    }else{
      _showAlertDialogue('Status', 'Problem Saving Note');
    }
  }


  void _delete() async {

    moveToLastScreen();

    // Case 1: If user is trying to delete the NEW NOTE i.e. he has come to
    // the detail page by pressing the FAB of NoteList page.
    if (widget.note.id == null) {
      _showAlertDialogue('Status', 'No Note was deleted');
      return;
    }

    // Case 2: User is trying to delete the old note that already has a valid ID.
    int result = await databaseHelper.deleteNote(widget.note.id);
    if (result != 0) {
      _showAlertDialogue('Status', 'Note Deleted Successfully');
    } else {
      _showAlertDialogue('Status', 'Error Occured while Deleting Note');
    }
  }

  void _showAlertDialogue(String title, String message){
      AlertDialog alertDialog = AlertDialog(title: Text(title), content: Text(message));
      showDialog(context: context, builder: (context) => alertDialog);
  }
}
