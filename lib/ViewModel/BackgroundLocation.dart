import 'dart:async';
import 'package:botbridge_green/Model/ServerURL.dart';
import 'package:botbridge_green/Utils/LocalDB.dart';
import 'package:geolocator/geolocator.dart';
import '../MainData.dart';
import '../Model/ApiClient.dart';

class BackgroundLocation{

  startFetchLocation(){
    double constLat = 0.0;
    double constLong = 0.0;
    // Geolocator.getPositionStream().listen((event) {
    //   print(event);
    // });
    Timer.periodic(Duration(seconds: 10), (timer) async {
      Position userLocation = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print(userLocation.latitude);
      print(userLocation.longitude);
     

print("Ashok");

          LocalDB.getLDB("userNo").then((value) {

            Map<String,dynamic> params = {
              "IdentityType":MainData.appName,
              "PhileBotomyNo":value,
              "TenantNo":MainData.tenantNo,
              "TenantBranchNo":MainData.tenantBranchNo,
              "DeviceID":"Android",
              "Latitude":userLocation.latitude,
              "Longitude":userLocation.longitude,
              "Location":""
            };
            print(params);
            ApiClient().fetchData(ServerURL().getUrl(RequestType.LocationUpdate), params);
          });

          // print("-------------user move more than ${distance}---");
    //
    //     }else{
    //       print("-------------user move lesser than ${distance}---");
    //     }
    //   }else{
    //     print(constLat);
    //     print(constLong);
    //     print("user not moving");
    //   }
    //
    });

  }

}