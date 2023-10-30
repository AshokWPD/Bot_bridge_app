import 'package:botbridge_green/Model/Status.dart';
import 'package:flutter/material.dart';
import '../../Model/ApiInterface.dart';
import '../Model/ApiResponse.dart';
import '../Model/Response/ReferalDataList.dart';

class ReferalDataVM extends ChangeNotifier{

  final _myRepo = ApiInterface();

  ApiResponse<ReferalData> listREF = ApiResponse.loading();

  ApiResponse<ReferalData> get getReferalList => listREF;

setreferalData(ApiResponse<ReferalData> response) {
  print("Response :: $response");
  if (response.status == Status.Completed) {
    print("Data :: ${response.data?.lstReferral}");
  }
  listREF = response;
  notifyListeners();
}


  Future<void> fetchrefdata(Map<String,dynamic> params, ) async {
    setreferalData( ApiResponse.loading());
    _myRepo.GetReferralDetails(params)
        .then((value) {
      return setreferalData( ApiResponse.completed(value));
    })
        .onError((error, stackTrace) {
      return setreferalData(ApiResponse.error(error.toString()));
    });
  }
}

