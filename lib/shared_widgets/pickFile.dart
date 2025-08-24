import 'package:file_picker/file_picker.dart';

Future<void> pickFile() async{
  FilePickerResult? result = await FilePicker.platform.pickFiles();
}