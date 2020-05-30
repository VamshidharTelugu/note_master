import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'ListOfPdf.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String directory;
  List file = new List();
  PageController _pageController;
  Widget SubjectsView;
  Widget DownloadsView;
  final globalKey = GlobalKey<ScaffoldState>();

  //list of subjects to be shown on homescreen
  static List<dynamic> subjects = [
    "Network Analysis",
    "Python",
    "English",
    "Mathematics",
    "Chemistry",
    "NA Lab",
    "AutoCAD",
    "Chemistry Lab",
    "QuestionBank - Answers",
    "Regulation - 2019",
    "Extras"
  ];

  //list of colors associated with the subjects
  static List<dynamic> colors = [
    Colors.blue[300],
    Colors.cyan[300],
    Colors.greenAccent,
    Colors.pink[100],
    Colors.orange[200],
    Colors.purple[200],
    Colors.amber[200],
    Colors.red[200],
    Colors.teal[200],
    Colors.yellow[100],
    Colors.brown[200]
  ];
  //Their associated links where the list of pdf for that particular subject will be present
  static List<dynamic> links = [
    "https://raw.githubusercontent.com/VamshidharTelugu/files/master/naList.json",
    "https://raw.githubusercontent.com/VamshidharTelugu/files/master/pythonList.json",
    "https://raw.githubusercontent.com/VamshidharTelugu/files/master/englishList.json",
    "https://raw.githubusercontent.com/VamshidharTelugu/files/master/mathsList.json",
    "https://raw.githubusercontent.com/VamshidharTelugu/files/master/chemistryList.json",
    "https://raw.githubusercontent.com/VamshidharTelugu/files/master/naLabList.json",
    "https://raw.githubusercontent.com/VamshidharTelugu/files/master/cadLab.json",
    "https://raw.githubusercontent.com/VamshidharTelugu/files/master/cheLabList.json",
    "https://raw.githubusercontent.com/VamshidharTelugu/files/master/Solutions.json",
    "https://raw.githubusercontent.com/VamshidharTelugu/files/master/Regulation.json",
    "https://raw.githubusercontent.com/VamshidharTelugu/files/master/Extras.json"
  ];

  @override
  void initState() {
    super.initState();
    //creating the widget using method createsubjectview so that i can include it in list of widgets for view pager in the body of scaffold
    SubjectsView = createSubjectsListView(context);
    //method to get files in downloads directory
    CreateDownoadsList();
    //need to initialise pagecontroller for viewpager to work
    _pageController = PageController();
  }

  void CreateDownoadsList() async {
    directory = (await getApplicationDocumentsDirectory()).path;
    bool exists = await Directory('$directory/Downloads').exists();
    if (exists) {
      file = await Directory("$directory/Downloads/").listSync();
      if (file.length == 0) {
        DownloadsView = InkWell(
          focusColor: Colors.blueGrey[900],
          onTap: () {
            setState(() {
              CreateDownoadsList();
            });
          },
          child: Container(
            color: Colors.transparent,
            child: Center(
                child: Text(
              "No Downloads Found, Tap to Refresh",
              style: TextStyle(fontSize: 15, color: Colors.grey),
            )),
          ),
        );
      } else {
        DownloadsView = createDownloadsListView(context);
      }
    } else {
      DownloadsView = InkWell(
        focusColor: Colors.blueGrey[900],
        onTap: () {
          setState(() {
            CreateDownoadsList();
          });
        },
        child: Container(
          color: Colors.transparent,
          child: Center(
              child: Text(
            "No Downloads Found, Tap to Refresh",
            style: TextStyle(fontSize: 15, color: Colors.grey),
          )),
        ),
      );
    }
  }

  //method to create the subjects listview using listview builder //than using a listview
  Widget createSubjectsListView(BuildContext context) {
    return ListView.builder(
        itemCount: subjects.length,
        itemBuilder: (context, int index) {
          return SubjectConatinerWidget(
              context, subjects[index], colors[index], links[index]);
        });
  }

  Widget createDownloadsListView(BuildContext context) {
    print("I was called");
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(Duration(seconds: 1));
        setState(() {
          CreateDownoadsList();
        });
        return null;
      },
      child: ListView.builder(
        itemCount: file.length,
        itemBuilder: (context, int index) {
          var name = file[index].toString();
          Widget myWidget = DownloadsContainerWidget((name.substring(
              name.lastIndexOf("/") + 1, name.lastIndexOf("'"))));
          return myWidget;
        },
      ),
    );
  }

  //don't know what it does but viewpager needs this
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("build loki vacha");
    return SafeArea(
      child: Scaffold(
        key: globalKey,
        backgroundColor: Colors.blueGrey[900],
        appBar: AppBar(
          backgroundColor: Colors.blueGrey[800],
          centerTitle: true,
          title: Text(
            "Btech Buddy",
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                  color: Colors.white, fontSize: 17, letterSpacing: 2),
            ),
          ),
        ),
        body: SizedBox.expand(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            children: <Widget>[
              SubjectsView,
              DownloadsView
              //Center(child: Text("Downloads Page"),),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavyBar(
          backgroundColor: Colors.blueGrey[50],
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          selectedIndex: _currentIndex,
          onItemSelected: (index) {
            // _onItemTapped(index);
            setState(() => _currentIndex = index);
            _pageController.jumpToPage(index);
          },
          items: <BottomNavyBarItem>[
            BottomNavyBarItem(
                title: Text('Home'),
                icon: Icon(Icons.apps),
                textAlign: TextAlign.center,
                inactiveColor: Colors.grey[850],
                activeColor: Colors.blue),
            BottomNavyBarItem(
                title: Text('Downloads'),
                icon: Icon(Icons.arrow_downward),
                textAlign: TextAlign.center,
                inactiveColor: Colors.grey[850],
                activeColor: Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget DownloadsContainerWidget(String name) {
    print("downloads container $name");
    return InkWell(
      onLongPress: () async {
        showAlertDialog(context, name);
      },
      onTap: () async {
        Directory downloadsDirectory = await getApplicationDocumentsDirectory();
        String path = downloadsDirectory.path + "/Downloads/" + "$name";
        print(path);
        try {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PDFScreen(path)),
          );
        } catch (e) {
          print(e.toString());
        }
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(4, 2, 4, 2),
        alignment: Alignment.centerLeft,
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              // "Some large text", maxLines: 2, overflow: TextOverflow.ellipsis
              style: GoogleFonts.lato(
                  textStyle: TextStyle(
                color: Colors.black,
                fontSize: 15,
              )),
            )),
        height: 70,
        decoration: BoxDecoration(
          color: Colors.blueGrey[100],
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context, String name) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = Column(
      children: <Widget>[
        Container(
          child: FlatButton(
            child: Text("Delete"),
            onPressed: () async {
              Directory downloadsDirectory =
                  await getApplicationDocumentsDirectory();
              String path = downloadsDirectory.path + "/Downloads/" + "$name";
              try {
                await File(path).delete(recursive: true);
                setState(() {
                  CreateDownoadsList();
                });
                Navigator.of(context).pop();
              } catch (e) {
                Navigator.of(context).pop();
                final snackBar = SnackBar(
                    backgroundColor: Colors.blueGrey,
                    content: Text(
                      'The file has been deleted, Pull down to refresh!',
                      style: TextStyle(color: Colors.black),
                    ));
                globalKey.currentState.showSnackBar(snackBar);
              }
            },
          ),
        ),
      ],
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Confirm"),
      content: Text("This will delete the selected file"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

Widget SubjectConatinerWidget(
    BuildContext context, String title, Color color, String link) {
  return InkWell(
    onTap: () async {
      if (await ConnectivityWrapper.instance.isConnected) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ListOfPdf(color, link)),
        );
        print("connnected");
      } else {
        print("nope");
        Scaffold.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text("No Connection"),
        ));
      }
    },
    child: Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Center(
        child: Text(
          title,
          style: GoogleFonts.lato(
            textStyle:
                TextStyle(color: Colors.black, fontSize: 17, letterSpacing: 2),
          ),
        ),
      ),
      height: 150,
      decoration: BoxDecoration(
        color: color,
      ),
    ),
  );
}

class PDFScreen extends StatelessWidget {
  String pathPDF = "";
  PDFScreen(this.pathPDF);

  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text("Document"),
          actions: <Widget>[],
        ),
        path: pathPDF);
  }
}
