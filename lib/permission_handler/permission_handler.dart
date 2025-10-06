import 'package:permission_handler/permission_handler.dart';

Future<bool> ensureStoragePermission() async {
  if (await Permission.manageExternalStorage.isGranted ||
      await Permission.storage.isGranted) {
    return true;
  }

  var status = await Permission.manageExternalStorage.request();
  if (status.isGranted) return true;

  status = await Permission.storage.request();
  return status.isGranted;
}
