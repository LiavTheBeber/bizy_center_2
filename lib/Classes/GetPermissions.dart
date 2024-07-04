import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';


class Getpermissions{

  static Future<bool> getCameraPermission() async{
    PermissionStatus permissionStatus = await Permission.camera.request();

    if(permissionStatus.isGranted){
      return true;
    }else if(permissionStatus.isDenied){
      PermissionStatus status = await Permission.camera.request();
      if(status.isGranted){
        return true;
      }else{
        Fluttertoast.showToast(msg: "Camera permission is required");
        return false;
      }
    }
    return false;
  }



  static Future<bool> getStoragePermission() async{
    PermissionStatus permissionStatus = await Permission.storage.request();

    if(permissionStatus.isGranted){
      return true;
    }else if(permissionStatus.isDenied){
      PermissionStatus status = await Permission.storage.request();
      if(status.isGranted){
        return true;
      }else{
        Fluttertoast.showToast(msg: "Storage permission is required");
        return false;
      }
    }
    return false;
  }

}