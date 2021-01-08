import 'package:flutter/material.dart';
import 'package:flutter_timetracker/Tree.dart';

class PageInfo extends StatefulWidget {
  Activity activity;

  PageInfo(this.activity);

  @override
  _PageInfoState createState() => _PageInfoState();
}

enum ActivityType { Project, Task }

class _PageInfoState extends State<PageInfo> {
  Activity activity;
  Future<Map<dynamic, dynamic>> projects;

  final formKey = GlobalKey<FormState>();
  final myController = TextEditingController();

  final myControllerStartDate = TextEditingController();
  final myControllerEndDate = TextEditingController();

  ActivityType activityType = ActivityType.Project;

  String currentProject;

  @override
  void initState() {
    activity = widget.activity;

    if (activity is Task) {
      activityType = ActivityType.Task;
    }

    String strInitialDate = activity.initialDate.toString().split('.')[0];
    String strFinalDate = activity.finalDate.toString().split('.')[0];

    myController.text = activity.name;
    myControllerStartDate.text = strInitialDate;
    myControllerEndDate.text = strFinalDate;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
          return Scaffold(
            resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              title: Text(activity.id.toString() + " - " + activity.name),
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
            SingleChildScrollView(child:
            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(title: new Text("Descripción")),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: new TextFormField(
                      focusNode: new AlwaysDisabledFocusNode(),
                      decoration: new InputDecoration(
                      ),
                      controller: myController,
                    ),
                  ),
                  ListTile(title: new Text("Tipo de actividad")),
                  ListTile(
                    title: const Text('Projecto'),
                    leading: Radio(
                      focusNode: new AlwaysDisabledFocusNode(),
                      value: ActivityType.Project,
                      groupValue: activityType,
                    ),
                  ),
                  ListTile(
                    title: const Text('Tarea'),
                    leading: Radio(
                      focusNode: new AlwaysDisabledFocusNode(),
                      value: ActivityType.Task,
                      groupValue: activityType,
                    ),
                  ),
                  ListTile(title: new Text("Fecha inicial")),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: new TextFormField(
                      focusNode: new AlwaysDisabledFocusNode(),
                      decoration: new InputDecoration(
                      ),
                      controller: myControllerStartDate,
                    ),
                  ),
              ListTile(title: new Text("Fecha final")),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: new TextFormField(
                      focusNode: new AlwaysDisabledFocusNode(),
                      decoration: new InputDecoration(
                      ),
                      controller: myControllerEndDate,
                    ),
                  ),

                ],
              ),
            ),
            ),
          );
  }

}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}