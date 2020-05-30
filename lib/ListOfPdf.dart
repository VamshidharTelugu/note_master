import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'dart:async';
import 'file:///C:/Users/T.%20Vamshidhar/AndroidStudioProjects/note_master/lib/Books.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:path_provider/path_provider.dart';

class ListOfPdf extends StatefulWidget {
  final Color filterColor;
  final String link;
  ListOfPdf(this.filterColor, this.link);

  @override
  _ListOfPdfState createState() => _ListOfPdfState();
}

class _ListOfPdfState extends State<ListOfPdf> {
  List<dynamic> myTitleList = [];
  List<dynamic> myLinkList = [];
  static double progress = 0;
  bool isDownloading;

  @override
  void initState() {
    super.initState();
    isDownloading = false;
  }

  Future<List<dynamic>> getList(titleList, linkList) async {
    String link = widget.link;
    var response = await http.get(link);
    if (response.statusCode == 200) {
      print(response.statusCode);
      var jsonResponse = convert.jsonDecode(response.body);
      List<dynamic> books = jsonResponse["books"];
      print(books);
      List<dynamic> links = jsonResponse["links"];
      print(links);
      // List<dynamic> onlineLinks = jsonResponse["onlineLinks"];
      List<Book> bookList = [];
      for (int i = 0; i < books.length; i++) {
        Book book = Book(bookTitle: books[i], bookLink: links[i]);
        bookList.add(book);
      }
      print(bookList);
      return bookList;
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return isDownloading
        ? SafeArea(
            child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.grey[850],
                ),
                backgroundColor: Colors.grey[850],
                body: Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          CircularProgressIndicator(
                            strokeWidth: 5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            "Downloading.. ${(progress * 100).toStringAsFixed(0)}% \nPlease don't close the app!",
                            style: TextStyle(color: Colors.black),
                          )
                        ],
                      ),
                    ),
                  ),
                )),
          )
        : ColorFiltered(
            colorFilter:
                ColorFilter.mode(widget.filterColor, BlendMode.overlay),
            child: SafeArea(
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  backgroundColor: Colors.black,
                ),
                body: Container(
                    child: FutureBuilder(
                        future: getList(myTitleList, myLinkList),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.data == null) {
                            return Center(
                                child: CircularProgressIndicator(
                              value: null,
                              strokeWidth: 5,
                            ));
                          } else {
                            return ListView.builder(
                                itemCount: snapshot.data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                    onTap: () async {
                                      if (await ConnectivityWrapper
                                          .instance.isConnected) {
                                        AlertDialog alert = AlertDialog(
                                          title: Text("Message"),
                                          content: Text("Would you like to..."),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text("Cancel"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            // FlatButton(
                                            //   child: Text("View Online"),
                                            //   onPressed: () {
                                            //     Navigator.of(context).pop();
                                            //     Navigator.push(
                                            //       context,
                                            //       MaterialPageRoute(
                                            //           builder: (context) =>
                                            //               OnlineView(snapshot
                                            //                   .data[index]
                                            //                   .onlineLink)),
                                            //     );
                                            //   },
                                            // ),
                                            FlatButton(
                                              child: Text("Download"),
                                              onPressed: () async {
                                                //Navigator.of(context).pop();
                                                //await pr.show();
                                                print("crossed show");
                                                setState(() {
                                                  isDownloading = true;
                                                });
                                                DownloadFile(
                                                    context,
                                                    snapshot
                                                        .data[index].bookTitle,
                                                    snapshot
                                                        .data[index].bookLink);
                                                Navigator.of(context).pop();
                                              },
                                            )
                                          ],
                                        );
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return alert;
                                          },
                                        );
                                      } else {
                                        print("nope");
                                        Scaffold.of(context)
                                            .showSnackBar(SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text("No Connection"),
                                        ));
                                      }
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                          // borderRadius: BorderRadius.circular(0),
                                          color: Colors.grey,
                                        ),
                                        height: 65,
                                        margin: EdgeInsets.fromLTRB(3, 3, 3, 2),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Padding(
                                                  padding: EdgeInsets.all(10),
                                                  child: Text(
                                                    '${snapshot.data[index].bookTitle}',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    // "Some large text", maxLines: 2, overflow: TextOverflow.ellipsis
                                                    style: GoogleFonts.lato(
                                                        textStyle: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15,
                                                    )),
                                                  )),
                                            ),
                                          ],
                                        )),
                                  );
                                });
                          }
                        })),
              ),
            ),
          );
  }

  void DownloadFile(BuildContext context, String name, String link) async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String downloadsDirectoryPath;

    if (await Permission.storage.request().isGranted) {
      try {
        print("3");
        //checks if downloads directory is there are not
        bool exists =
            await Directory('${appDirectory.path}/Downloads').exists();
        if (!exists) {
          await new Directory(appDirectory.path + "/" + "Downloads")
              .create(recursive: false)
              // The created directory is returned as a Future.
              .then((Directory directory) {
            print(directory.path);
            downloadsDirectoryPath =
                (appDirectory.path + "/" + "Downloads").toString();
          });
        } else {
          downloadsDirectoryPath =
              (appDirectory.path + "/" + "Downloads").toString();
        }
      } on PlatformException {
        print('Could not get the downloads directory');
      }

      Dio dio = Dio();
      try {
        print("10");
        await dio.download(link, "$downloadsDirectoryPath/$name.pdf",
            onReceiveProgress: (int rec, int total) {
          //print("receives $rec total $total");
          double value = rec / total;
          //print(value);
          if (!mounted) {
            print("not mounted");
            return;
          }
          setState(() {
            //isDownloading = true;
            //print("setstate");
            progress = value;
          });
        });
        if (mounted) {
          setState(() {
            isDownloading = false;
            progress = 0;
          });
        }
        print("success");
      } catch (e) {
        print(e);
      }
    } else {
      print("Permission not granted");
      Scaffold.of(context).showSnackBar(SnackBar(
        content:
            Text("To download file, You need to grant storage permission!"),
      ));
    }
  }

//  showAlertDialog(BuildContext context, String fileName, String link) {
//    // set up the buttons
//    Widget cancelButton = FlatButton(
//      child: Text("Cancel"),
//      onPressed: () {
//        Navigator.of(context).pop();
//      },
//    );
//    Widget viewOnlineButton = FlatButton(
//      child: Text("View Online"),
//      onPressed: () {
//        Navigator.push(
//          context,
//          MaterialPageRoute(
//              builder: (context) => OnlineView(
//                  "https://drive.google.com/file/d/190JL4GNuW2LebSHRrILU8Lif4SjXweKf/view?usp=sharing")),
//        );
//      },
//    );
//    Widget downloadButton = FlatButton(
//      child: Text("Start"),
//      onPressed: () {
//        DownloadFile(context, fileName, link);
//        Navigator.of(context).pop();
//      },
//    );
//
//    // set up the AlertDialog
//    AlertDialog alert = AlertDialog(
//      title: Text("Confirm"),
//      content: Text("Start download?"),
//      actions: [
//        cancelButton,
//        viewOnlineButton,
//        downloadButton,
//      ],
//    );
//
//    // show the dialog
//    showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        return alert;
//      },
//    );
//  }
}
