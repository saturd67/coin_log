import 'package:coin_log/services/DatabaseService.dart';
import 'package:coin_log/shared_widgets/showConfirmationDialog.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DataDetail extends StatefulWidget {

  @override
  State<DataDetail> createState() => _DataDetailState();
}

class _DataDetailState extends State<DataDetail> {

  DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Theme.of(context).colorScheme.surface,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text("Data Details"),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.secondary,
        padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Export Data:"),
            ExportData(),
            SizedBox(
              height: 15,
            ),
            Text("Import Data:"),
            ImportData()
          ],
        ),
      ),
    );
  }
}

class ExportData extends StatefulWidget{

  @override
  State<ExportData> createState() => _ExportDataState();
}

class _ExportDataState extends State<ExportData> {
  DatabaseService _databaseService = DatabaseService();

  String exportDirectory = "/storage/emulated/0/Document";
  String exportedFilename = "coin_log_backup.db";
  String filePath = "";

  Future<void> pickDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    setState(() {
      exportDirectory = selectedDirectory ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(6,3,6,3),
              height: 35,
              width: MediaQuery.of(context).size.width - 75,
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black12,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6)
              ),
              alignment: Alignment.centerLeft,
              child: Text("$exportDirectory/$exportedFilename", style: Theme.of(context).textTheme.bodySmall),
            ),
            IconButton(
              onPressed: pickDirectory,
              icon: Icon(Icons.folder),
            )
          ],
        ),
        Row(
          children: [
            SizedBox(
              height: 35,
              width: 100,
              child: ElevatedButton(
                  onPressed: () async {
                    if (exportDirectory != "" && exportedFilename != "") {
                      String output = await _databaseService.exportDatabase(exportDirectory, exportedFilename);
                      Fluttertoast.showToast(msg: output);
                    }

                    else {
                      Fluttertoast.showToast(msg: "Export path is empty.");
                    }
                  },
                  child: Text("Export")
              ),
            ),
          ]
        )
      ],
    );
  }
}

class ImportData extends StatefulWidget{

  @override
  State<ImportData> createState() => _ImportDataState();
}

class _ImportDataState extends State<ImportData> {
  DatabaseService _databaseService = DatabaseService();

  String importFile = "";

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    setState(() {
      if (result != null) {
        importFile = result.files.single.path ?? "";
      }
      else {
        importFile = "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(6,3,6,3),
              height: 35,
              width: MediaQuery.of(context).size.width - 75,
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black12,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6)
              ),
              alignment: Alignment.centerLeft,
              child: Text(importFile, style: Theme.of(context).textTheme.bodySmall),
            ),
            IconButton(
              onPressed: pickFile,
              icon: Icon(Icons.folder),
            )
          ],
        ),
        Row(
            children: [
              SizedBox(
                height: 35,
                width: 100,
                child: ElevatedButton(
                    onPressed: () {
                      showConfirmationDialog(
                          context,
                          "After importing you original data will be replaced.",
                          () async {
                            if (importFile != "") {
                              String output = await _databaseService.importDatabase(importFile);
                              Fluttertoast.showToast(msg: output);
                            }

                            else {
                              Fluttertoast.showToast(msg: "Export path is empty.");
                            }
                          },
                          () {}
                      );
                    },
                    child: Text("Import")
                ),
              ),
            ]
        )
      ],
    );
  }
}