import 'package:botbridge_green/Model/Status.dart';
import 'package:flutter/material.dart';
import '../../Model/ApiInterface.dart';
import '../Model/ApiResponse.dart';
import '../Model/Response/AppoitmentAndRequestData.dart';


class CollectedSampleVM extends ChangeNotifier{


 final _myRepo = ApiInterface();

  ApiResponse<AppointmentAndRequestData> listCart = ApiResponse.loading();

  ApiResponse<AppointmentAndRequestData> get getCollectedSamplesList => listCart;

  setsampleDate(ApiResponse<AppointmentAndRequestData> response) {
    print("Response :: $response");
    print(response.data);
    listCart = response;
    notifyListeners();
  }

  Future<void> fetchsampledata(Map<String,dynamic> params) async {
    setsampleDate( ApiResponse.loading());
    _myRepo.getAppointmentAndRequest(params)
        .then((value) {
      return setsampleDate( ApiResponse.completed(value));
    })
        .onError((error, stackTrace) {
      return setsampleDate(ApiResponse.error(error.toString()));
    });
  }
}












