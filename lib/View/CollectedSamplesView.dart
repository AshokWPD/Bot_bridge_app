import 'dart:convert';

import 'package:botbridge_green/Model/Response/AppoitmentAndRequestData.dart';
import 'package:botbridge_green/Model/ServerURL.dart';
import 'package:botbridge_green/ViewModel/CollectedSamplesVM.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart'as http;
import '../Model/Status.dart';
import '../Utils/LocalDB.dart';
import '../Utils/NavigateController.dart';
import 'Helper/ThemeCard.dart';
import 'HomeView.dart';
import 'PatientDetailsView.dart';



class CollectedSamplesView extends StatefulWidget {
  const CollectedSamplesView({Key? key}) : super(key: key);

  @override
  _CollectedSamplesViewState createState() => _CollectedSamplesViewState();
}

class _CollectedSamplesViewState extends State<CollectedSamplesView> {

  String BookingType = "SAMPLE"; //PRA
  bool isSearchbar = true;
    bool isFetching = true;
    DateTime currentdate = DateTime.now();
  final CollectedSampleVM _api = CollectedSampleVM();
  DateTime selectedDate = DateTime.now();
  List<LstPatientResponse>? _lastTestDetails=[];
    List<LstPatientResponse>? _filteredData=[]; // Store the list of patients here
  // List<LstPatientResponse>? _filtere_dated; // Store the list of patients here
 // Store the list of patients here
  DateFormat dateformat = DateFormat('dd-MM-yyyy');
String filterdate="";
bool iserror=false;
final bool _calendefil=true;
bool allshow =true;
bool mobileshow=false;
bool dateshow=false;
int userno=0;
var searchdate;
   DateTime? picked ;
bool nodata=false;


  // Define a method to fetch data and update the list
  Future<void> fetchData() async {
     var venueNo = await LocalDB.getLDB("venueNo") ?? "";
    var venueBranchNo = await LocalDB.getLDB("venueBranchNo") ?? "";
    var userno = await LocalDB.getLDB("userID") ?? "";

    final url = Uri.parse(ServerURL().getUrl(RequestType.LoadAppointment)); // Replace with your API endpoint
    final headers = {'Content-Type': 'application/json'};
    final requestBody = jsonEncode({
      "bookingID": "",
      "mobileNumber": "",
      "type": BookingType,
      "userNo": userno,
      "venueNo": venueNo,
      "venueBranchNo": venueBranchNo,
      "registerdDateTime": "$currentdate",
    });

    final response = await http.post(url, headers: headers, body: requestBody);

   if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    print(jsonResponse);

    final data = AppointmentAndRequestData.fromJson(jsonResponse);
    final lastTestDetails = data.lstPatientResponse;

    if (lastTestDetails != null) {
      setState(() {
        _lastTestDetails = lastTestDetails;
        isFetching = false;
      });
    } else {
nodata=true;
      // Handle the case when the data is null
      setState(() {
        isFetching = false;
        iserror = true;
      });
    }
  } else {
    // Handle the case when the API call fails
    throw Exception('Failed to load data');
  }
}

bool usenumber=false;


String formatDateString(String inputDateString, String desiredDateFormat) {
  // Parse the input date string into a DateTime object
  DateTime inputDate = DateTime.parse(inputDateString);

  // Format the date as per the desired format and return it as a string
  String formattedDate = DateFormat(desiredDateFormat).format(inputDate);

  return formattedDate;
}  

  String desiredDateFormat = "dd-MM-yyyy";


  void _filterData(String query) {
    setState(() {
      mobileshow=true;
      allshow=false;
      dateshow=false;
      if(isNumber(query)){
        setState(() {
          usenumber=true;
        });

         _filteredData = _lastTestDetails!
          .where((item) => item.mobileNumber.toString().contains(query.toString()))
          .toList();

      }else{
         setState(() {
          usenumber=false;
        });
         _filteredData = _lastTestDetails!
          .where((item) => item.patientName!.toLowerCase().contains(query.toLowerCase()))
          .toList();

      }
      
     

          
    });
  }


  @override
  void initState() {
    print(selectedDate);
    // TODO: implement initState
    LocalDB.getLDB('userID').then((value) {
      print("Appointviewuserid $value");
           fetchData();
setState(() {
  userno=int.parse(value);
});
 
    });
    super.initState();
  }


bool isNumber(String input) {
  final numberRegex = RegExp(r'^-?(\d+|\d*\.\d+)$');
  return numberRegex.hasMatch(input);
}



  
  @override
  Widget build(BuildContext context) {
  //   final patient = data!.lstPatientResponse?.isNotEmpty == true
  // ? data!.lstPatientResponse![0]
  // : null;
  //       print(patient!.gender);
  // final patienttest= patient.lstTestDetails?.isNotEmpty==true?
  // patient.lstTestDetails![0]:null;
        
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;



    return SafeArea(
        child: GestureDetector(
          onTap: ()=>FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: const Color(0xffEFEFEF),
            body:WillPopScope(
                  onWillPop: ()async {
            print("working-----------------------");
                 FocusScope.of(context).unfocus();
      NavigateController.pagePushLikePop(context,  const HomeView());     return false;
          },
              child: Column(
                children: [
                  SizedBox(
                      height: height * 0.16,
                      child: Column(
                        children: [
                          Container(
                            height: height * 0.07,
                            width: width,
                            decoration: BoxDecoration(
                                color: CustomTheme.background_green,
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(height * 0.6/25))
                            ),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.all(11),
                                    child: InkWell(
                                        onTap: (){
                                          FocusScope.of(context).unfocus();
                                          NavigateController.pagePushLikePop(context,  const HomeView());
                                        },
                                        child: const Icon(Icons.arrow_back_ios,color: Colors.white,)),
                                  ),
                                ),
                                const Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: EdgeInsets.all(11),
                                    child: Text("Sample",style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.w600),),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: height * 0.02,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: width * 0.8,
                                height: height * 0.066,
                                child: TextFormField(
                                  cursorColor: Colors.grey,
                                  onChanged:_filterData,
                              
                                  decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.only(top: 4,left: 13),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide:  BorderSide(color: CustomTheme.background_green,width: 2)
                                      ),
                                      focusedBorder:OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide:  BorderSide(color: CustomTheme.background_green,width: 2)
                                      ),
                                      hintText: 'Search'
                                  ),
                                ),
                              ),
                              SizedBox(width: width * 0.015,),
                              GestureDetector(
                                  onTap:
                                   () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2023, 1, 1),
                lastDate: DateTime.now().add(Duration(days: 30)),
                   builder: (context, child) {
                      return Padding(
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 30),
              child: Theme(
              data: ThemeData.light().copyWith(
                primaryColor: CustomTheme.circle_green,
            
                buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                colorScheme:  ColorScheme.light(primary: CustomTheme.circle_green)
                    .copyWith(secondary: CustomTheme.circle_green),
                dialogTheme: const DialogTheme(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)))),
              ),
              child: child!,
              ),
                      );
                    }
                );
            
                if (pickedDate != null && pickedDate != selectedDate) {
                  fetchData();
            
                  setState(() {
                    dateshow=true;
                    mobileshow=false;
                    allshow=false;
                    selectedDate = pickedDate;
                    print(selectedDate);
                    filterdate = dateformat.format(selectedDate).toString();
            fetchData();
                 print(filterdate);
                //  _lastTestDetails(filterdate);
            
                  });
                }
              },
                                  child: Image.asset('assets/images/calender.png',color: CustomTheme.background_green,height: height*0.05))
                            ],
                          ),
                        ],
                      )),
                          Expanded(
                            child: nodata?
                                      Container(
                                       height: height-170,width: width,
                          
                                      child: Center(child: Text("No New Sample")),):
                                            isFetching?
                                             Container(
                                              height: height-170,width: width,
                                              child: Center(child: CircularProgressIndicator())):                  // Container(
                                SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Flex(
                                        direction: Axis.vertical,
                                        children: [
                                          //////////////////////////////////////////////////////////////
                                          
                          
                                          mobileshow?
                                          
                                     ListView.builder(
                                     itemCount: _filteredData!
                                                 .length,                                 
                                                        shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemBuilder: (BuildContext context, int index) {
                               var item = _filteredData![index];
                          
                                            return InkWell(
                                              onTap: (){
                                                NavigateController.pagePush(context,  PatientDetailsView(screenType: 4, bookingType: BookingType, bookingID: item.bookingId.toString(), regdate: item.registeredDateTime.toString(), ));
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                                                child: Container(
                                                  height: height * 0.14,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(17)
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Positioned(
                                                          right:width * 0.0,
                                                          bottom: height * 0.0,
                                                          child: Image.asset('assets/images/side_illustrate.png',height: height*0.05,color:  Color(0xff182893),)
                                                      ),
                                                      Positioned(
                                                        bottom: height * 0.012,
                                                        right:width * 0.02 ,
                                                        child: Text(
                                                          item.isPaid == true ? "PAID" : "UNPAID",
                                                          style: const TextStyle(
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.w500,
                                                              fontSize: 11),
                                                        ),),
                                                      Positioned(
                                                        left:width * 0.03,
                                                        top: height * 0.035,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children:  const [
                                                            CircleAvatar(
                                                              backgroundColor:  Color(0xffEFEFEF),
                                                              radius: 26,
                                                              backgroundImage: AssetImage('assets/images/profile.png'),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Positioned(
                                                        left:width * 0.21,
                                                        top: height * 0.034,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children:  [
                                                            Row(
                                                              children:  [
                                                                Text("${item.patientName}",style: TextStyle(color: Color(0xff203298),fontWeight: FontWeight.w600),overflow: TextOverflow.ellipsis,),
                                                                Text(" ${item.age!.replaceAll('Y', "")}, ${item.gender == "Male" ? "Male" : "Female" }",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w600,fontSize: 13),),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: height * 0.01,
                                                            ),
                                                            SizedBox(
                                                                width: width * 0.6,
                                                                child: Text("${item.address}",style: const TextStyle(color: Colors.grey,fontWeight: FontWeight.w600),maxLines: 1,overflow: TextOverflow.ellipsis,)),
                                                            SizedBox(
                                                              height: height * 0.01,
                                                            ),
                                                            Text("${item.patientVisitNo}",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w600),),
                                                          ],
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: height * 0.01,
                                                        right: width * 0.02,
                                                        child:
                                                        Text(
                                                          "${CustomTheme.normalDate.format(DateFormat("yyyy-MM-dd HH:mm").parse(item.registeredDateTime.toString()))}"
                                                          // "${VM.lstPatientResponse![index].registeredDateTime}"
                                                              ""
                                                          ,style: const TextStyle(color: Colors.grey,fontWeight: FontWeight.w600),),
                                                        // Text("${VM.lstPatientResponse![index].currentStatusName}",style: const TextStyle(color: Colors.grey,fontWeight: FontWeight.w600,fontSize: 13),),
                                                      ),
                                                      // Positioned(
                                                      //   bottom: height * 0.03,
                                                      //   right: width * 0.06,
                                                      //   child:
                                                      //   const Text("Paid",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w600,fontSize: 13),),
                                                      // )
                                                    ],
                                                  ),
                                                ),
                          
                                              ),
                                            );
                                          },
                          
                                        ):
                                            dateshow?
                          
                                            
                                    ListView.builder(
                                             itemCount: _lastTestDetails!.where((item) =>
                                      formatDateString(item.registeredDateTime.toString(), desiredDateFormat)  == filterdate)
                                      .length,
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemBuilder: (BuildContext context, int index) {
                                              var item = _lastTestDetails!.where((item) =>
                                      formatDateString(item.registeredDateTime.toString(), desiredDateFormat)  == filterdate)
                                      .toList()[index];
                                            return InkWell(
                                              onTap: (){
                                                NavigateController.pagePush(context,  PatientDetailsView(screenType: 4, bookingType: BookingType, bookingID: item.bookingId.toString(), regdate:item.registeredDateTime.toString(), ));
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                                                child: Container(
                                                  height: height * 0.14,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(17)
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Positioned(
                                                          right:width * 0.0,
                                                          bottom: height * 0.0,
                                                          child: Image.asset('assets/images/side_illustrate.png',height: height*0.05,color:  Color(0xff182893),)
                                                      ),
                                                      Positioned(
                                                        bottom: height * 0.012,
                                                        right:width * 0.02 ,
                                                        child: Text(
                                                          item.isPaid == true ? "PAID" : "UNPAID",
                                                          style: const TextStyle(
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.w500,
                                                              fontSize: 11),
                                                        ),),
                                                      Positioned(
                                                        left:width * 0.03,
                                                        top: height * 0.035,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children:  const [
                                                            CircleAvatar(
                                                              backgroundColor:  Color(0xffEFEFEF),
                                                              radius: 26,
                                                              backgroundImage: AssetImage('assets/images/profile.png'),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Positioned(
                                                        left:width * 0.21,
                                                        top: height * 0.034,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children:  [
                                                            Row(
                                                              children:  [
                                                                Text("${item.patientName}",style: TextStyle(color: Color(0xff203298),fontWeight: FontWeight.w600),overflow: TextOverflow.ellipsis,),
                                                                Text(" ${item.age!.replaceAll('Y', "")}, ${item.gender == "Male" ? "Male" : "Female" }",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w600,fontSize: 13),),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: height * 0.01,
                                                            ),
                                                            SizedBox(
                                                                width: width * 0.6,
                                                                child: Text("${item.address}",style: const TextStyle(color: Colors.grey,fontWeight: FontWeight.w600),maxLines: 1,overflow: TextOverflow.ellipsis,)),
                                                            SizedBox(
                                                              height: height * 0.01,
                                                            ),
                                                            Text("${item.patientVisitNo}",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w600),),
                                                          ],
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: height * 0.01,
                                                        right: width * 0.02,
                                                        child:
                                                        Text(
                                                          "${CustomTheme.normalDate.format(DateFormat("yyyy-MM-dd HH:mm").parse(item.registeredDateTime.toString()))}"
                                                              ""
                                                          ,style: const TextStyle(color: Colors.grey,fontWeight: FontWeight.w600),),
                                                      ),
                                                 
                                                    ],
                                                  ),
                                                ),
                          
                                              ),
                                            );
                                          },
                          
                                        )
                                            : const SizedBox(),

                                          // const Text("No data in the selected date"),
                                     
                                     allshow?
                                         
                                     ListView.builder(
                                            itemCount: _lastTestDetails!.length,
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemBuilder: (BuildContext context, int index) {
                                           var item = _lastTestDetails![index];
                          
                                            return InkWell(
                                              onTap: (){
                                                NavigateController.pagePush(context,  PatientDetailsView(screenType: 4, bookingType: BookingType, bookingID: item.bookingId.toString(), regdate: item.registeredDateTime.toString(),));
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                                                child: Container(
                                                  height: height * 0.14,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(17)
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Positioned(
                                                          right:width * 0.0,
                                                          bottom: height * 0.0,
                                                          child: Image.asset('assets/images/side_illustrate.png',height: height*0.05,color:  Color(0xff182893),)
                                                      ),
                                                      Positioned(
                                                        bottom: height * 0.012,
                                                        right:width * 0.02 ,
                                                        child: Text(
                                                          item.isPaid == true ? "PAID" : "UNPAID",
                                                          style: const TextStyle(
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.w500,
                                                              fontSize: 11),
                                                        ),),
                                                      Positioned(
                                                        left:width * 0.03,
                                                        top: height * 0.035,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children:  const [
                                                            CircleAvatar(
                                                              backgroundColor:  Color(0xffEFEFEF),
                                                              radius: 26,
                                                              backgroundImage: AssetImage('assets/images/profile.png'),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Positioned(
                                                        left:width * 0.21,
                                                        top: height * 0.034,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children:  [
                                                            Row(
                                                              children:  [
                                                                Text("${item.patientName}",style: TextStyle(color: Color(0xff203298),fontWeight: FontWeight.w600),overflow: TextOverflow.ellipsis,),
                                                                Text(" ${item.age!.replaceAll('Y', "")}, ${item.gender == "Male" ? "Male" : "Female" }",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w600,fontSize: 13),),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: height * 0.01,
                                                            ),
                                                            SizedBox(
                                                                width: width * 0.6,
                                                                child: Text("${item.address}",style: const TextStyle(color: Colors.grey,fontWeight: FontWeight.w600),maxLines: 1,overflow: TextOverflow.ellipsis,)),
                                                            SizedBox(
                                                              height: height * 0.01,
                                                            ),
                                                            Text("${item.patientVisitNo}",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w600),),
                                                          ],
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: height * 0.01,
                                                        right: width * 0.02,
                                                        child:
                                                        Text(
                                                          "${CustomTheme.normalDate.format(DateFormat("yyyy-MM-dd HH:mm").parse(item.registeredDateTime.toString()))}"
                                                          // "${VM.lstPatientResponse![index].registeredDateTime}"
                                                              ""
                                                          ,style: const TextStyle(color: Colors.grey,fontWeight: FontWeight.w600),),
                                                      ),
                                                    
                                                    ],
                                                  ),
                                                ),
                          
                                              ),
                                            );
                                          },
                          
                                        )
                                          :
                          
                          
                                     iserror?const Center(child: Text("No Samples found!!!"))
                                          
                                          :_lastTestDetails!
                                                          .where((item) =>
                                                              formatDateString(
                                                                  item.registeredDateTime
                                                                      .toString(),
                                                                  desiredDateFormat) ==
                                                              filterdate)
                                                          .length==0? Text(""): const Text("Shortlisted Record"),

                          
                                    
                                   
                                          
                                        ],
                                      ),
                                      SizedBox(height: height * 0.04,),
                                    ],
                                  ),
                                ),
                          )
            
                          // default:
             ]),
            ))));
  }}