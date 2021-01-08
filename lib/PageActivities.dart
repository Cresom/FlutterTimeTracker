import 'package:flutter/material.dart';

import 'package:flutter_timetracker/Requests.dart';
import 'package:flutter_timetracker/Tree.dart' hide getTree;

import 'PageInfo.dart';
import 'PageNew.dart';
import 'PageIntervals.dart';
import 'dart:async';

class PageActivities extends StatefulWidget {
  int id;
  String parentName;

  PageActivities(this.id, this.parentName);

  @override
  _PageActivitiesState createState() => _PageActivitiesState();
}

class _PageActivitiesState extends State<PageActivities> {
  int id;
  String parentName;
  Future<Tree> futureTree;

  String actualName;

  Timer _timer;
  static const int periodeRefresh = 2;
  // better a multiple of periode in TimeTracker, 2 seconds

  @override
  void initState() {
    super.initState();
    id = widget.id;
    parentName = widget.parentName;
    futureTree = getTree(id);
    _activateTimer();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Tree>(
      future: futureTree,
      // this makes the tree of children, when available, go into snapshot.data
      builder: (context, snapshot) {
        // anonymous function
        if (snapshot.hasData) {
          actualName = snapshot.data.root.id == 0 ? "" : snapshot.data.root.name;
          return Scaffold(
            appBar: AppBar(
              title: (snapshot.data.root.name == "Root project") ? Text("Temporizador de tareas") : Text(parentName == "" ? snapshot.data.root.name : "..." + parentName + "\\" + snapshot.data.root.name),
              leading: GestureDetector(
                onTap: () {
                  if (Navigator.of(context).canPop())
                    Navigator.of(context).pop();
                  },
                child: Icon(
                  (snapshot.data.root.name == "Root project") ? Icons.menu : Icons.keyboard_return_outlined,  // add custom icons also
                ),
              ),
              actions: <Widget>[
                IconButton(icon: Icon(Icons.home),
                    onPressed: () {
                      while(Navigator.of(context).canPop()) {
                        print("pop");
                        Navigator.of(context).pop();
                      }
                      PageActivities(0, "");
                    }),
                //TODO other actions
              ],
            ),

            body: ListView.separated(
              // it's like ListView.builder() but better because it includes a separator between items
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data.root.children.length,
              itemBuilder: (BuildContext context, int index) =>
                  _buildRow(snapshot.data.root.children[index], index),
              separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
            ),
              floatingActionButton: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      child: Icon(Icons.note_add_outlined),
                      heroTag: null,
                      onPressed: () {
                        _navigateToNew(snapshot.data.root.id);
                      },
                    ),
                  ]
              )
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        // By default, show a progress indicator
        return Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(),
            ));
      },
    );
  }

  Widget _buildRow(Activity activity, int index) {

    String strDuration = Duration(seconds: activity.duration).toString().split('.').first;
    // split by '.' and taking first element of resulting list removes the microseconds part
    if (activity is Project) {
      return ListTile(
        title: Text('${activity.name}',
            style: TextStyle(fontWeight: activity.active ? FontWeight.bold : FontWeight.normal, color: activity.active ? Colors.blue : Colors.black)),
        leading: Icon(Icons.folder_outlined, color: activity.active ? Colors.blue : Colors.black),
        trailing: Text('$strDuration',
            style: TextStyle(fontWeight: activity.active ? FontWeight.bold : FontWeight.normal, color: activity.active ? Colors.blue : Colors.black)),
        onTap: () => _navigateDownActivities(activity.id, activity.id == 0 ? "" : actualName),
        onLongPress: () {
          _navigateToInfo(activity);
        },
      );
    } else if (activity is Task) {
      Task task = activity as Task;
      // at the moment is the same, maybe changes in the future
      Widget trailing;
      trailing = Row(
          mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('$strDuration',
                      style: TextStyle(fontWeight: activity.active ? FontWeight.bold : FontWeight.normal, color: activity.active ? Colors.blue : Colors.black)),
                  IconButton(
                    icon: Icon(task.active ? Icons.pause : Icons.play_arrow, color: activity.active ? Colors.blue : Colors.black),
                    onPressed: () {
                      task.active ? stop(task.id) : start(task.id);
                      _refresh(); // to show immediately that task has started
                    },
                  ),


          ]);

      return ListTile(
        title: Text('${activity.name}',
            style: TextStyle(fontWeight: activity.active ? FontWeight.bold : FontWeight.normal, color: activity.active ? Colors.blue : Colors.black)),
        leading: Icon(Icons.note_outlined, color: activity.active ? Colors.blue : Colors.black),
        trailing: trailing,
        onTap: () => _navigateDownIntervals(activity.id, activity.id == 0 ? "" : actualName),
        onLongPress: () {
          _navigateToInfo(activity);
        },
      );
    }
  }

  void _refresh() async {
    futureTree = getTree(id); // to be used in build()
    setState(() {});
  }

  void _navigateDownActivities(int childId, String parentName) {
    _timer.cancel();
    // we can not do just _refresh() because then the up arrow doesnt appear in the appbar
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
      builder: (context) => PageActivities(childId, parentName),
    )).then( (var value) {
      _activateTimer();
      _refresh();
    });
  }

  void _navigateDownIntervals(int childId, String parentName) {
    _timer.cancel();
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
      builder: (context) => PageIntervals(childId, parentName),
    )).then( (var value) {
      _activateTimer();
      _refresh();
    });
  }

  void _navigateToNew(int parentId) {
    _timer.cancel();
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
      builder: (context) => PageNew(parentId),
    )).then( (var value) {
      _activateTimer();
      _refresh();
    });
  }

  void _navigateToInfo(Activity activity) {
    _timer.cancel();
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
      builder: (context) => PageInfo(activity),
    )).then( (var value) {
      _activateTimer();
      _refresh();
    });
  }


  void _activateTimer() {
    _timer = Timer.periodic(Duration(seconds: periodeRefresh), (Timer t) {
      futureTree = getTree(id);
      setState(() {});
    });
  }

  @override
  void dispose() {
    // "The framework calls this method when this State object will never build again"
    // therefore when going up
    _timer.cancel();
    super.dispose();
  }
}