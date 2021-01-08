import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timetracker/Requests.dart' as req;

import 'PageInfo.dart';

class PageNew extends StatefulWidget {
  int idParent;

  PageNew(this.idParent);

  @override
  _PageNewState createState() => _PageNewState();
}

enum ActivityType { Project, Task }

class _PageNewState extends State<PageNew> {
  int idParent;
  Future<Map<dynamic, dynamic>> projects;

  final myController = TextEditingController();
  final myControllerTags = TextEditingController();
  final myControllerParent = TextEditingController();

  final formKey = GlobalKey<FormState>();
  ActivityType activityType = ActivityType.Project;

  List<DropdownMenuItem<String>> dropDownMenuItems;
  String currentProject;

  @override
  void initState() {
    idParent = widget.idParent;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<dynamic, dynamic>>( future: req.getProjects(),
      builder: (context, snapshot) {
        List<DropdownMenuItem<String>> items = new List();
        final bottom = MediaQuery.of(context).viewInsets.bottom;

        snapshot.data.forEach((k,v) =>
            items.add(new DropdownMenuItem(value: k + " - " + v, child: new Text(v)
        )));

        dropDownMenuItems = items;
        currentProject = dropDownMenuItems.firstWhere((element) => idParent == int.parse(element.value.split("-")[0].trim())).value;
        myControllerParent.text = currentProject.toString();

        return Scaffold(
            resizeToAvoidBottomPadding: false,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
            title: Text("Nueva Actividad"),
            leading: GestureDetector(
              onTap: () {
                if (Navigator.of(context).canPop())
                  Navigator.of(context).pop();
              },
              child: Icon(
                Icons.keyboard_return_outlined, // add custom icons also
              ),
            ),
          ),

          body:
          SingleChildScrollView(reverse: true, child:
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(title: new Text("Descripción")),
                ListTile(
                leading: const Icon(Icons.description),
                title: new TextFormField(
                  decoration: new InputDecoration(
                      hintText: "Description",
                  ),
                    controller: myController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Es necesario introducir un texto';
                    } else {
                      return '';
                    }
                  },
                ),
              ),
                ListTile(title: new Text("Tipo de actividad")),
                ListTile(
                title: const Text('Projecto'),
                leading: Radio(
                  value: ActivityType.Project,
                  groupValue: activityType,
                  onChanged: (ActivityType value) {
                    setState(() {
                      activityType = value;
                    });
                  },
                ),
              ),
                ListTile(
                  title: const Text('Tarea'),
                  leading: Radio(
                    value: ActivityType.Task,
                    groupValue: activityType,
                    onChanged: (ActivityType value) {
                      setState(() {
                        activityType = value;
                      });
                    },
                  ),
                ),
                ListTile(title: new Text("Tags")),
                ListTile(
                  leading: const Icon(Icons.tag),
                  title: new TextFormField(
                    decoration: new InputDecoration(
                      hintText: "Tags (Flutter;Android;BDD)",
                    ),
                    controller: myControllerTags,
                  ),
                ),
                ListTile(title: new Text("Proyecto padre")),
                ListTile(
                  leading: const Icon(Icons.folder),
                  title: new TextFormField(
                    focusNode: new AlwaysDisabledFocusNode(),
                    decoration: new InputDecoration(
                    ),
                    controller: myControllerParent,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: bottom),
                  child: RaisedButton(
                    onPressed: () {
                      // devolverá true si el formulario es válido, o falso si
                      // el formulario no es válido.
                      if (formKey.currentState.validate()) {
                        // Si el formulario es válido, queremos mostrar un Snackbar
                        Scaffold.of(context)
                            .showSnackBar(SnackBar(
                            content: Text('Processing Data')));
                      }
                    },
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FloatingActionButton(
                          child: Icon(Icons.add_outlined),
                          heroTag: null,
                          onPressed: () {
                            if (activityType == ActivityType.Task)
                              req.addTask(myController.text, myControllerTags.text, int.parse(currentProject.split("-")[0].trim()));
                            else
                              req.addProject(myController.text, myControllerTags.text, int.parse(currentProject.split("-")[0].trim()));

                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              SystemNavigator.pop();
                            }
                          },
                        ),
                      ]
                  ),
                    ),
                ),
              ],
            ),
          ),
          ),
        );
      }
    );
  }
  void changedDropDownItem(String selectedProyect) {
    setState(() {
      currentProject = selectedProyect;
    });
  }

}