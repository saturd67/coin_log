import 'package:file_picker/file_picker.dart';

Future<void> pickFile() async{
  PlatformFile? result = await FilePicker.pickFile();
}