import 'dart:convert';
import 'package:botbridge_green/Utils/LocalDB.dart';
import 'package:botbridge_green/View/AppointmentView.dart';
import 'package:botbridge_green/View/BorcodeView.dart';
import 'package:botbridge_green/View/CollectedSamplesView.dart';
import 'package:botbridge_green/View/HistoryView.dart';
import 'package:botbridge_green/View/HomeView.dart';
import 'package:botbridge_green/View/NewRequestView.dart';
import 'package:botbridge_green/View/PaymentView.dart';
import 'package:botbridge_green/ViewModel/AppointmentListVM.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_icons/weather_icons.dart';
import '../MainData.dart';
import '../Model/ApiClient.dart';
import '../Model/Response/AppoitmentAndRequestData.dart';
import '../Model/ServerURL.dart';
import '../Utils/NavigateController.dart';
import '../ViewModel/CollectedSamplesVM.dart';
import 'AddPrescriptionView.dart';
import 'AddToCartView.dart';
import 'Helper/ErrorPopUp.dart';
import 'Helper/LoadingIndicator.dart';
import 'Helper/ThemeCard.dart';
import 'package:http/http.dart'as http;



class PatientDetailsView extends StatefulWidget {
  final int screenType;
  final String bookingType;
  final String bookingID;
  final String regdate;
   const PatientDetailsView({Key? key, required this.screenType, required this.bookingType, required this.bookingID, required this.regdate}) : super(key: key);

  @override
  _PatientDetailsViewState createState() => _PatientDetailsViewState();
}

class _PatientDetailsViewState extends State<PatientDetailsView> {

  //hide String? phileBotomyID;
  bool isFetching = true;
  bool isclick=false;
  final AppointmentListVM _api = AppointmentListVM();
  ScrollController control = ScrollController();
  bool floatingButtonVisible = false;
  String? selectedGender;
  String? selectedReferral;
  String weathermain="";
  String weatherdes="";
  String weatherIcon='';
  bool isupdated=false;
  DateTime selectedDate = DateTime.now();
      DateTime currentdate = DateTime.now();

  // final TextEditingController _patientname =TextEditingController();
  // final TextEditingController _mobileno =TextEditingController();
  // final TextEditingController _age =TextEditingController();
  // final TextEditingController _gender =TextEditingController();
  // final TextEditingController _address =TextEditingController();
  // final TextEditingController _scedule =TextEditingController();
  // final TextEditingController _reftype =TextEditingController();

// ignore: prefer_typing_uninitialized_variables


 AppointmentAndRequestData? data;


  Future<void> fetchData(String bookid,) async {
    var userno = await LocalDB.getLDB("userID") ?? "";
    var venueNo = await LocalDB.getLDB("venueNo") ?? "";
    var venueBranchNo = await LocalDB.getLDB("venueBranchNo") ?? "";
    final url = Uri.parse(ServerURL().getUrl(RequestType.LoadAppointment)); // Replace with your API endpoint
    final headers = {'Content-Type': 'application/json'};
    final requestBody = jsonEncode({
       "bookingID": bookid,
      "mobileNumber": "",
      "type": widget.bookingType,
      "userNo": userno,
      "venueNo": venueNo,
      "venueBranchNo": venueBranchNo,
      "registerdDateTime": widget.regdate
    });

     
    final response = await http.post(url, headers: headers, body: requestBody);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      
      setState(() {
        data = AppointmentAndRequestData.fromJson(jsonResponse);
        data!.lstPatientResponse==null?warningPopUp(context):null;

        isFetching=false;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }


  void  warningPopUp(BuildContext context){
      print("called**************");


QuickAlert.show(
 context: context,
 type:QuickAlertType.error,
//  customAsset: "assets/images/ok_popup.gif",

 text: "Somthing went wrong",
 confirmBtnText: 'Ok',
//  cancelBtnText: 'No',
 onConfirmBtnTap: (){
NavigateController.pagePushLikePop(context,  const HomeView());
 },
//  onCancelBtnTap: (){
//   NavigateController.pagePOP(context);
//  },
 confirmBtnColor: Colors.green,
);

  }


Future<void> fetchWeatherData() async {
    var latitude = await LocalDB.getLDB("latitude") ?? "";
    var longitude = await LocalDB.getLDB("longitude") ?? "";
   

  final Uri uri = Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=442e685066f5e2d23963617c73c8165c');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);

    // Extract the "weather" information
    final List<dynamic> weatherData = data['weather'];

    if (weatherData.isNotEmpty) {
      final Map<String, dynamic> weatherInfo = weatherData[0];

      setState(() {
               weathermain = weatherInfo['main'];
     weatherdes = weatherInfo['description'];
          weatherIcon = weatherInfo['icon'];

      });
       weathermain = weatherInfo['main'];
     weatherdes = weatherInfo['description'];
          weatherIcon = weatherInfo['icon'];


      // Now you can use weatherId and weatherMain in your Flutter code
      print('Weather Main: $weathermain');
      print('Weather description: $weatherdes');
            print('Weather icon: $weatherIcon');

    } else {
      // Handle the case where there is no weather data
      print('No weather data available');
    }
  } else {
    // Handle errors in the API response
    print('Failed to fetch data: ${response.statusCode}');
  }
}



Icon getWeatherIcon(String iconCode) {
  switch (iconCode) {
    case '01d':
      return const Icon(WeatherIcons.day_sunny_overcast,color: Colors.white,size: 30,);
    case '01n':
      return const Icon(WeatherIcons.night_clear,);
    case '02d':
      return const Icon(WeatherIcons.day_cloudy,);
    case '02n':
      return const Icon(WeatherIcons.night_cloudy,);
    case '03d':
    case '03n':
      return const Icon(WeatherIcons.cloud,);
    // Add more cases for other weather conditions as needed
    default:
      return const Icon(WeatherIcons.na,); // Default icon for unknown conditions
  }
}


  @override
  void initState() {
 
    // TODO: implement initState
    super.initState();
    fetchWeatherData();
isupdated=false;
    print(widget.bookingType);
 
      fetchData(widget.bookingID);

  }
      
  

  UnderlineInputBorder outline = const UnderlineInputBorder(
      // borderRadius: BorderRadius.circular(25),
      borderSide: BorderSide(width: 0,color: Colors.black45)
  );
  @override
  Widget build(BuildContext context) {
  LstPatientResponse? patient;

if (data != null && data!.lstPatientResponse != null && data!.lstPatientResponse!.isNotEmpty) {
  patient = data!.lstPatientResponse![0];
} else {
  patient = null;
}
  // final patienttest =  patient.lstTestDetails![0];
        
final height = MediaQuery.of(context).size.height;
final width = MediaQuery.of(context).size.width;

    return SafeArea(
        child: GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xffEFEFEF),
        body: WillPopScope(
            onWillPop:isupdated?()async{
              NavigateController.pagePushLikePop(context, const HomeView());
                                    return false;

            }: ()async {
            print("working-----------------------");
                   if(widget.screenType == 1){
                     if (kDebugMode) {
                       print("Appoitment");
                     }
                     NavigateController.pagePushLikePop(context,   const AppointmentView());
                   }else if(widget.screenType == 2){
                     NavigateController.pagePushLikePop(context,   const NewRequestView());
                   }
                   else  if(widget.screenType == 4) {
                     NavigateController.pagePushLikePop(context,   const CollectedSamplesView());
                   }  
                   else if(widget.screenType == 3){
                    NavigateController.pagePushLikePop(context,   const HistoryView());
                   }
                   else{
                    NavigateController.pagePOP(context);
                   }
                      return false;
          },
          child: Column(
            children: [
              Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          height: height * 0.08,
                          width: width,
                          decoration: BoxDecoration(
                              color: CustomTheme.background_green,
                              borderRadius: BorderRadius.only(
                                  bottomLeft:
                                      Radius.circular(height * 0.6 / 25))),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width: width * 0.02,),
                              InkWell(
                                  onTap:isupdated?(){
                        NavigateController.pagePushLikePop(context, const HomeView());

                                  }:  () {
                                     print("working-----------------------");
                                            if(widget.screenType == 1){
                                              if (kDebugMode) {
                                                print("Appoitment");
                                              }
                                              NavigateController.pagePushLikePop(context,   const AppointmentView());
                                            }else if(widget.screenType == 2){
                                              NavigateController.pagePushLikePop(context,   const NewRequestView());
                                            }
                                            else  if(widget.screenType == 4) {
                                              NavigateController.pagePushLikePop(context,   const CollectedSamplesView());
                                            }  
                                            else if(widget.screenType == 3){
                                             NavigateController.pagePushLikePop(context,   const HistoryView());
                                            }
                                            else{
                                             NavigateController.pagePOP(context);
                                            }
                                   },
                                  child: const Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.white,
                                  )),
                              const Spacer(),
                              const Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Patient Details ",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                  height: height * 0.05,
                                  child: Visibility(
                                      visible: widget.screenType == 1 || widget.screenType == 2,
                                      child:isFetching?const Text(""): buildSpeedDial(context, height, width,data!.lstPatientResponse == null ? "": patient!.isPaid))),
                              SizedBox(width: width * 0.02,),
                            ],
                          ),
                        ),
                       
                      ],
                    ),
                  )),
                  
        
        isFetching? const Expanded(child: Center(child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 40,)
          ],
        ))) 
        :
      
         Expanded(
                flex: 9,
        
                child:SingleChildScrollView(
        
                          
                          controller: control,
                          child: Column(
                            children: [
                       
                              SizedBox(
                                height: height * 0.01,
                              ),
                              SizedBox(
                                width: width * 0.9,
                                height: height * 0.07,
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  cursorColor: Colors.black,
                                  readOnly: true,
                                  // controller: _patientname,
        
                                  initialValue:data!.lstPatientResponse == null ? "": patient!.patientName,
                                  // initialValue:VM.lstPatientResponse == null ? "": VM.lstPatientResponse![0].patientName ,
                                  style: const TextStyle(color: Colors.black54),
                                  decoration: InputDecoration(
                                      // filled: true,
                                      // focusColor: const Color(0xffEFEFEF),
                                      // contentPadding: const EdgeInsets.only(bottom: 4,left: 12),
                                      enabledBorder: outline,
                                      focusedBorder: outline,
                                      label: const Text(
                                        'Patient Name',
                                        style: TextStyle(
                                            color: Colors.black54, fontSize: 14),
                                      )),
                                ),
                              ),
                              SizedBox(height: height * 0.013),
                              SizedBox(
                                width: width * 0.9,
                                height: height * 0.07,
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  cursorColor: Colors.black,
                                  readOnly: true,
                                  initialValue: data!.lstPatientResponse == null ? "":patient!.mobileNumber,
                                  style: const TextStyle(color: Colors.black54),
                                  decoration: InputDecoration(
                                      // filled: true,
                                      // focusColor: const Color(0xffEFEFEF),
                                      enabledBorder: outline,
                                      focusedBorder:outline,
                                      label: const Text(
                                        'Mobile No',
                                        style: TextStyle(
                                            color: Colors.black54, fontSize: 14),
                                      )),
                                ),
                              ),
                              SizedBox(height: height * 0.013),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: width * 0.4,
                                    height: height * 0.07,
                                    child: TextFormField(
                                      initialValue:data!.lstPatientResponse == null ? "":patient!.age!,
                                      textInputAction: TextInputAction.next,
                                      readOnly: true,
                                      cursorColor: Colors.black,
                                      style: const TextStyle(color: Colors.black54),
                                      decoration: InputDecoration(
                                          // filled: true,
                                          // focusColor: const Color(0xffEFEFEF),
                                          // contentPadding: const EdgeInsets.only(bottom: 4,left: 12),
                                          enabledBorder: outline,
                                          focusedBorder: outline,
                                          label: const Text(
                                            'Age',
                                            style: TextStyle(
                                                color: Colors.black54, fontSize: 14),
                                          )),
                                    ),
                                  ),
                                  SizedBox(width: width * 0.08),
                                  SizedBox(
                                    width: width * 0.4,
                                    height: height * 0.07,
                                    child: TextFormField(
                                      readOnly: true,
                                      initialValue:data!.lstPatientResponse == null ? "":patient!.gender == "Male" ? "Male" : "Female",
                                      textInputAction: TextInputAction.next,
                                      cursorColor: Colors.black,
                                      style: const TextStyle(color: Colors.black54),
                                      decoration: InputDecoration(
                                          // filled: true,
                                          // focusColor: const Color(0xffEFEFEF),
                                          // contentPadding: const EdgeInsets.only(bottom: 4,left: 12),
                                          enabledBorder: outline,
                                          focusedBorder: outline,
                                          label: const Text(
                                            'Gender',
                                            style: TextStyle(
                                                color: Colors.black54, fontSize: 14),
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: height * 0.013),
                              SizedBox(
                                width: width * 0.9,
                                // height: height * 0.07,
                                child: TextFormField(
                                  readOnly: true,
                                  textInputAction: TextInputAction.next,
                                  cursorColor: Colors.black,
                                  initialValue:data!.lstPatientResponse == null ? "":"${patient!.address} , ${patient.area} , ${patient.pincode}",
                                  maxLines: 2,
                                  style: const TextStyle(color: Colors.black54,),
                                  decoration: InputDecoration(
                                      // filled: true,
                                      // focusColor: const Color(0xffEFEFEF),
                                      // contentPadding: const EdgeInsets.only(bottom: 4,left: 12),
                                      enabledBorder: outline,
                                      focusedBorder: outline,
                                      label: const Text(
                                        'Address*',
                                        style: TextStyle(
                                            color: Colors.black54, fontSize: 14),
                                      )),
                                ),
                              ),
                              SizedBox(height: height * 0.013),
                              SizedBox(
                                width: width * 0.9,
                                height: height * 0.07,
                                child: TextFormField(
                                  readOnly: true,
                                  initialValue:data!.lstPatientResponse == null ? "":patient!.registeredDateTime,
                                  textInputAction: TextInputAction.next,
                                  cursorColor: Colors.black,
                                  style: const TextStyle(color: Colors.black54),
                                  decoration: InputDecoration(
                                      // filled: true,
                                      // focusColor: const Color(0xffEFEFEF),
                                      // contentPadding: const EdgeInsets.only(bottom: 4,left: 12),
                                      enabledBorder: outline,
                                      focusedBorder: outline,
                                      label: const Text(
                                        'Scheduled on',
                                        style: TextStyle(
                                            color: Colors.black54, fontSize: 14),
                                      )),
                                ),
                              ),
                              SizedBox(height: height * 0.013),
                              patient!.physicianName.toString()=='null'?
                              SizedBox():
                              SizedBox(
                                width: width * 0.9,
                                height: height * 0.07,
                                child: TextFormField(
                                  readOnly: true,
                                  initialValue:data!.lstPatientResponse == null ? "":patient!.physicianName.toString(),
                                  textInputAction: TextInputAction.next,
                                  cursorColor: Colors.black,
                                  style: const TextStyle(color: Colors.black54),
                                  decoration: InputDecoration(
                                      // filled: true,
                                      // focusColor: const Color(0xffEFEFEF),
                                      // contentPadding: const EdgeInsets.only(bottom: 4,left: 12),
                                      enabledBorder: outline,
                                      focusedBorder: outline,
                                      label: const Text(
                                        'physician Name',
                                        style: TextStyle(
                                            color: Colors.black54, fontSize: 14),
                                      )),
                                ),
                              ),
                              SizedBox(height: height * 0.02),
                             
                                      SizedBox(
                                        height: height* 0.3,
                                        width: width * 0.96,
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: height * 0.2,
                                              child: SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  Flex(
                                                    direction: Axis.vertical,
                                                    children: [
                                                      Scrollbar(
                                                        thickness: 50,
                                                        child: ListView.builder(
                                                            physics:
                                                            const NeverScrollableScrollPhysics(),
                                                            shrinkWrap: true,
                                                            itemCount: patient!.lstTestDetails!.length,
                                                            itemBuilder:
                                                                (BuildContext context, index) {
                                                                                  final testDetail = patient!.lstTestDetails![index];
                                                                                 final testsmapledetails = patient.lstTestSampleWise![index];

                                                              return Align(
                                                                alignment: Alignment.centerRight,
                                                                child: Stack(
                                                                  children: <Widget>[
                                                                    InkWell(
                                                                      onTap: () {
                                                                        // NavigateController.pagePush(context, const PatientDetailsView(screenType: 1,));
                                                                      },
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(8.0),
                                                                        child: Container(
                                                                          height: height * 0.1,
                                                                          decoration: BoxDecoration(
                                                                              color: Colors.white,
                                                                              borderRadius:
                                                                              BorderRadius.circular(
                                                                                  17)),
                                                                          child: Stack(
                                                                            children: [
                                                                              Positioned(
                                                                                  right:width * 0.0,
                                                                                  bottom: height * 0.0,
                                                                                  child: Image.asset('assets/images/side_illustrate.png',height: height*0.05,color:  const Color(0xff182893),)
                                                                              ),
                                                                              Positioned(
                                                                                left:width * 0.03,
                                                                                top: height * 0.026,
                                                                                child: Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children:   [
                                                                                    CircleAvatar(
                                                                                      backgroundColor: Colors.white,
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.all(4.0),
                                                                                        child: Image.asset('assets/images/testube.png',height: height*0.06,color:  const Color(0xff182893),),
                                                                                      ),),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              Positioned(
                                                                                left:width * 0.175,
                                                                                top: height * 0.016,
                                                                                child: Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children:  [
                                                                                    SizedBox(
                                                                                        width:width* 0.65,
                                                                                        child: Text(testDetail.testName.toString(),style: const TextStyle(color: Color(0xff203298),fontWeight: FontWeight.w600),overflow: TextOverflow.ellipsis,maxLines: 1,)),
                                                                                    SizedBox(height: height * 0.001,),
                                                                                    testsmapledetails.barcodeNo.toString()=="null"?const SizedBox():
                                                                                     Text(testsmapledetails.barcodeNo.toString(),style: const TextStyle(fontSize: 10),),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              Positioned(
                                                                                left:width * 0.175,
                                                                                bottom: height * 0.003,
                                                                                child: const Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children:   [
                                                                                    // Text(testDetail.testType.toString(),style: const TextStyle(fontSize: 12),),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              Positioned(
                                                                                top: height * 0.066 ,
                                                                                right:width * 0.03 ,
                                                                                child: Text(
                                                                                  "₹${testDetail.amount!.toInt()}",
                                                                                  style: const TextStyle(
                                                                                      color: Colors.white,
                                                                                      fontWeight: FontWeight.w500,
                                                                                      fontSize: 14),
                                                                                ),)
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
        
        
                                                            }),
                                                      )
                                                    ],
                                                  ),
        
                                                 
        
                                                ],
                                              ),
                                    ),
                                            ),
                                            const Spacer(),
                                            Visibility(
                                                visible:patient.lstTestDetails != null ,
                                                child: setAction(widget.screenType,patient,height,width, patient.isPaid)),
                                                // child: setAction(widget.screenType,patient,height,width, data!.lstPatientResponse == null ? "":patient.isPaid)),
                                            SizedBox(height: height * 0.03),
                                          ],
                                        ),
                                      )])))]),
        ))));
                              // viewModel.getAddToCart.data!.lstCartDetailsGet!.isEmpty ? Center(child: Image.asset("assets/images/empty_box.png",height: 170,),) :

                              }

                              
  String getReferral(String type){
    switch (type) {
      case "0": //"SF"
        return "Self";
      case "Client":
        return "CLI";
      case "1": //"DOC"
        return "Doctor";
      default:
        return "Doctor";
    }
  }

  Widget setAction(int type, LstPatientResponse param,height,width,ispaid) {
    switch (type) {
      case 1:
        return appointmentAction(height,width,ispaid);
      case 2:
        return newRequestAction(param,height,width,ispaid);
      case 3:
        return historyAction();
      default:
        return sampleAction(height,width);
    }
  }
  Widget sampleAction(height,width,) {
    return InkWell(
      onTap: () {
        updateStatus(MainData.statusSubmitToLab,widget.bookingID,context,true,height,width,);
      },
      child: Container(
        height: 45,
        width: 140,
        decoration: BoxDecoration(
            color: CustomTheme.background_green,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, offset: Offset(1, 2), blurRadius: 6)
            ]),
        child: const Center(
          child: Text(
            'Submit to Lab',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget appointmentAction(height,width,ispaid) {
    return InkWell(
      onTap: () {

        NavigateController.pagePush(context,ispaid==true?
BarcodePage(bookingID: widget.bookingID, bookingType: widget.bookingType, screentype: widget.screenType, ispaid:ispaid, regdate: widget.regdate ,):
PaymentView(bookingID: widget.bookingID, ScreenType: widget.screenType, bookingType: widget.bookingType, nextpage: BarcodePage(bookingID: widget.bookingID, bookingType: widget.bookingType, screentype: widget.screenType, ispaid:ispaid, regdate: widget.regdate ,), ));
        // updateStatus(MainData.statusCollected,widget.bookingID,context,ispaid,height,width,);
        // updateStatus(MainData.statusArrival,widget.bookingID,context,ispaid,height,width,);
          },
      child: Container(
        height: 40,
        width: 120,
        decoration: BoxDecoration(
            color: CustomTheme.background_green,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, offset: Offset(1, 2), blurRadius: 6)
            ]),
        child: const Center(
          child: Text(
            'Next',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );}



  Widget newRequestAction(LstPatientResponse param,height,width,ispaid) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            showRequest(context,"Decline Request","Are you sure to want Decline ?",widget.bookingID,MainData.statusReject,height,width,ispaid);
          },
          child: Container(
        height: 40,
        width: 120,
        decoration: BoxDecoration(
          color: CustomTheme.background_green,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26,
                offset: Offset(1, 2),
                blurRadius: 6)
          ]),
        child: const Center(
          child: Text(
          'Decline',
          style:
          TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      )

        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.1,
        ),
        InkWell(
          onTap: () {
            showRequest(context,"Accept Request","Are you sure to want accept ?",widget.bookingID,MainData.statusAccept,height,width,ispaid);
          },
         child: Container(
           height: 40,
           width: 120,
           decoration: BoxDecoration(
               color: CustomTheme.background_green,
               borderRadius: BorderRadius.circular(30),
               boxShadow: const [
                 BoxShadow(
                     color: Colors.black26,
                     offset: Offset(1, 2),
                     blurRadius: 6)
               ]),
           child: const Center(
             child: Text(
               'Accept',
               style:
               TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
             ),
           ),
         )
       
        ),
      ],
    );
  }

  Widget historyAction() {
    return Container();
  }

//Floating action button
  SpeedDial buildSpeedDial(BuildContext context, height, width,ispaid) {
    Color textBorder = const Color(0xff0272B1);
    return SpeedDial(
      animatedIconTheme: const IconThemeData(size: 30.0),
      // backgroundColor:const Color(0xff182893),
      backgroundColor:Colors.white,
      icon: Icons.message, //icon on Floating action button
      activeIcon: Icons.close, //icon when menu is expanded on button
      foregroundColor: Colors.green, //font color, icon color in button
      activeBackgroundColor: Colors.white,
      activeForegroundColor:Colors.green,
      visible: true,
      direction: SpeedDialDirection.down,
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.1,
      children: [
        SpeedDialChild(
          child: Image.asset('assets/images/add_prescripton.png',height: height*0.025,color:   Colors.white,),
          backgroundColor: const Color(0xff84DF8F),
          onTap: () {


            NavigateController.pagePush(context,  AddPrescriptionView(bookingID: widget.bookingID, screenType: widget.screenType, booktype: widget.bookingType, regdate: widget.regdate,));
          },
         
        ),
        SpeedDialChild(
        
       

          child: Image.asset('assets/images/add_test.png',height: height*0.032,color: Colors.white,),
          backgroundColor: const Color(0xff84DF8F),
          onTap: () {
            NavigateController.pagePush(context,AddToCartView( bookingType: widget.bookingType, bookID: widget.bookingID, regdate: widget.regdate, isbooking: false, ontap: () {  }, ));
          },

       
        ),
        SpeedDialChild(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/images/barcode.png',height: height*0.028,color:Colors.white,),
          ),
          backgroundColor:const Color(0xff84DF8F) ,
          onTap: () {
            NavigateController.pagePush(context,  BarcodePage(bookingID: widget.bookingID, bookingType: widget.bookingType, screentype: widget.screenType, ispaid:ispaid, regdate: widget.regdate ,));
          },
      
        ),
      ],
      child: const Center(child:  Icon(Icons.add)),
    );
  }


  updateStatus(String bookingStatus,String bookingID,BuildContext context,ispaid,height,width) async {
    setState(() {
      isclick=true;
    });

    // isclick?
    // scrollIndicator( context,  MediaQuery.of(context).size.height,  MediaQuery.of(context).size.width):null;
    SharedPreferences pref = await SharedPreferences.getInstance();
   


    var userno = await LocalDB.getLDB("userID") ?? "";

    var venueNo = await LocalDB.getLDB("venueNo") ?? "";
    var venueBranchNo = await LocalDB.getLDB("venueBranchNo") ?? "";

    Map<String,dynamic> params =
      {
        "userNo": userno,
        "venueNo": venueNo,
        "venueBranchNo": venueBranchNo,
        "reason": "",
        "bookingID": bookingID,
        "bookingStatus": bookingStatus

    };

    String url = ServerURL().getUrl(RequestType.UpdatePatientStatus);
    // if (MainData.statusReject == bookingStatus || MainData.statusAccept == bookingStatus) {
    //   url = ServerURL().getUrl(RequestType.UpdatePatientStatus); // InsertAppointmentAndRequest
    // }
    print(url);
    print("latest $params");
    print("testing-------------=");
    ApiClient().fetchData(url, params).then((response){
      setState(() {
        isupdated=true;
        isclick=false;
      });

      print("latesturl $url");
      print("latestresponse $response");
      if(response["status"]==1){
        if(bookingStatus == MainData.statusSubmitToLab){
          CollectedSampleVM model = Provider.of<CollectedSampleVM>(context, listen: false);
          LocalDB.getLDB('userID').then((value) {
            print(value);
            Map<String,dynamic> params = {
              // "PhileBotomyID":value,
              // "BookingID":"",
              // "Page": widget.bookingType,
              // "Latitude": "",
              // "Longitude": ""
      "bookingID": bookingID,
      "type":  widget.bookingType,
      "bookingStatus": bookingStatus,
      "userNo": value,
      "registeredDateTime":widget.regdate,
      "mobilenumber":""

            };
            print("testing-------------3");
            model.fetchsampledata(params);
          });
        }else{

          // Navigator.pop(context);
          // pagePush(context,  PaymentPage(bookingID: widget.userID));
        }
        if(widget.screenType == 1){

          print("go to payment");
          // Navigator.pop(context);
          print(widget.bookingID);
          ispaid==true?
        successStatusPOPUP(context, height, width, "Patient status Updated", BarcodePage(bookingID: widget.bookingID, bookingType: widget.bookingType, screentype: widget.screenType, ispaid:ispaid, regdate: widget.regdate ,),"Next"):
        successStatusPOPUP(context, height, width, "Patient status Updated", PaymentView(bookingID: widget.bookingID, ScreenType: widget.screenType, bookingType: widget.bookingType, nextpage: BarcodePage(bookingID: widget.bookingID, bookingType: widget.bookingType, screentype: widget.screenType, ispaid:ispaid, regdate: widget.regdate ,), ),"Next");

        }else if(widget.screenType == 2){
          bookingStatus==MainData.statusReject?
              rejectPOPUP(context, height, width, "Request Rejected",const NewRequestView()):
              successStatusPOPUP(context, height, width, "Request Accepted", const NewRequestView(),"Done");


              // successStatusPOPUP(context, height, width, "Request Accepted",  BarcodePage(bookingID: widget.bookingID, bookingType: "APP", screentype: 1, ispaid:ispaid, regdate: widget.regdate ,),"Next"):
              // successStatusPOPUP(context, height, width, "Request Accepted", PaymentView(bookingID: widget.bookingID, ScreenType: 1, bookingType: "APP", nextpage: BarcodePage(bookingID: widget.bookingID, bookingType: "APP", screentype:1, ispaid:ispaid, regdate: widget.regdate ,),),"Next");


              // successStatusPOPUP(context, height, width, "Patient Accepted",  PatientDetailsView(screenType: 1, bookingType: 'APP', bookingID: widget.bookingID, regdate: widget.regdate,));

//  NavigateController.pagePush(context,  PatientDetailsView(screenType: 1, bookingType: 'APP', bookingID: widget.bookingID,))  ;
        }else if(widget.screenType == 4){
          successStatusPOPUP(context, height, width, "Sample Submited to Lab", const CollectedSamplesView(),"Done");

        }
        else{
          print("go out");
          Navigator.pop(context);
        }

      }
      else{
        print("errorpop");
        Navigator.pop(context);
        errorPopUp(context,'Something went wrong.\nPlease try again.');
      }
    }).catchError((error){
      print("errorrrrrrrrr $error");
      Navigator.pop(context);
      errorPopUp(context,'Something went wrong.\nPlease try again.');
    }).onError((error, stackTrace) {
      print(error);
      Navigator.pop(context);
      errorPopUp(context,'Something went wrong.\nPlease try again.');
    });
  }



 showRequest( BuildContext context,String title,String sub,String bookingID,String status,hight,width,ispaid){
   QuickAlert.show(
 context: context,
 type:QuickAlertType.confirm,
 customAsset: "assets/images/yes_no.gif",
 text: title,
 confirmBtnText: 'yes',
 cancelBtnText: 'No',
 onConfirmBtnTap: (){

  updateStatus(status,bookingID,context,ispaid,hight,width);

 },
 onCancelBtnTap: (){
            Navigator.pop(context);
 },
 confirmBtnColor: Colors.green,
);
  }


  oshowRequest( BuildContext context,String title,String sub,String bookingID,String status,hight,width){
    return showDialog(context: context, builder: (context){
      return  AlertDialog(
        backgroundColor: Colors.white,
        title: Center(child: Text(title,style:const TextStyle(color: Colors.white),)),
        content: Text(sub,style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () async {
            updateStatus(status,bookingID,context,true,hight,width);
          },
              child:const Text("Yes",style: TextStyle(color: Colors.orange),)),
          TextButton(onPressed: (){
            Navigator.pop(context);
          },
              child:const Text("No",style: TextStyle(color: Colors.orange)))
        ],
        shape:const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),

      );
    }
    );
  }


   void  successStatusPOPUP(BuildContext context,double height,double width,content,page,button){
      print("called");


QuickAlert.show(
 context: context,
 type:QuickAlertType.success,
//  customAsset: "assets/images/ok_popup.gif",

 text: content,
 confirmBtnText: button,
//  cancelBtnText: 'No',
 onConfirmBtnTap: (){
NavigateController.pagePush(context,  page);
 },
//  onCancelBtnTap: (){
//   NavigateController.pagePOP(context);
//  },
 confirmBtnColor: Colors.green,
);




  }

  void  rejectPOPUP(BuildContext context,double height,double width,content,page){
      print("called");


QuickAlert.show(
 context: context,
 type:QuickAlertType.success,
//  customAsset: "assets/images/ok_popup.gif",

 text: content,
 confirmBtnText: 'Ok',
//  cancelBtnText: 'No',
 onConfirmBtnTap: (){
NavigateController.pagePush(context,  page);
 },
//  onCancelBtnTap: (){
//   NavigateController.pagePOP(context);
//  },
 confirmBtnColor: Colors.green,
);

  }
  
}







