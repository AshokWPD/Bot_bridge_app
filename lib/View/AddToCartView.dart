import 'dart:convert';
import 'package:botbridge_green/Model/Response/AppoitmentAndRequestData.dart';
import 'package:botbridge_green/Model/ServerURL.dart';
import 'package:botbridge_green/View/PatientDetailsView.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../Model/ApiClient.dart';
import '../Model/ApiResponse.dart';
import '../Model/Status.dart';
import '../Utils/LocalDB.dart';
import '../Utils/NavigateController.dart';
import '../ViewModel/BookedServiceVM.dart';
import 'Helper/ErrorPopUp.dart';
import 'Helper/ThemeCard.dart';
import 'TabbarView.dart';
import 'package:http/http.dart' as http;



class AddToCartView extends StatefulWidget {
  final String bookingType;
  final String bookID;
  final bool isbooking;
  final String regdate;
  final VoidCallback ontap;
  const AddToCartView(
      {Key? key,
      required this.bookingType,
      required this.bookID,
      required this.regdate,
      required this.isbooking,
      required this.ontap})
      : super(key: key);

  @override
  _AddToCartViewState createState() => _AddToCartViewState();
}

class _AddToCartViewState extends State<AddToCartView> {
  bool isemptty = false;
  String? userNo;
  List<String> testNames = [];

  bool isFetching = true;
  ScrollController control = ScrollController();
  bool floatingButtonVisible = false;
  String? selectedGender;
  String? selectedReferral;
  String? screentype;
  String latitude = "";
  String longitude = "";
  DateTime currentdate = DateTime.now();
  int? deletingIndex;
  getData() async {
    LocalDB.getLDB("latitude").then((value) {
      setState(() {
        latitude = value;
        print("latitude: $latitude");
      });
    });

    LocalDB.getLDB("longitude").then((value) {
      setState(() {
        longitude = value;
        print(longitude);
      });
    });
  }

  AppointmentAndRequestData? data;

  Future<void> fetchData(
    String bookid,
  ) async {
    isFetching = true;
    var userno = await LocalDB.getLDB("userID") ?? "";
    var venueNo = await LocalDB.getLDB("venueNo") ?? "";
    var venueBranchNo = await LocalDB.getLDB("venueBranchNo") ?? "";
    final url = Uri.parse(ServerURL()
        .getUrl(RequestType.LoadAppointment)); // Replace with your API endpoint
    final headers = {'Content-Type': 'application/json'};
    final requestBody = jsonEncode({
      "bookingID": bookid,
      "mobileNumber": "",
      "type": widget.bookingType,
      "userNo": userno,
      "venueNo": venueNo,
      "venueBranchNo": venueBranchNo,
      "registerdDateTime": "$currentdate"
    });

    final response = await http.post(url, headers: headers, body: requestBody);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      setState(() {
        data = AppointmentAndRequestData.fromJson(jsonResponse);

        isFetching = false;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  List<String> TestDetailName = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    BookedServiceVM model =
        Provider.of<BookedServiceVM>(context, listen: false);
    setState(() {
      TestDetailName = model.getTestNames();
      print(TestDetailName);
    });
// if(widget.isbooking==true){
//     setState(() {
//       widget.isbooking=false;
//   });
//   NavigateController.pagePush(context,  SearchTests(BookingID: widget.bookID, referalID: '', bookingType: widget.bookingType, regdate: widget.regdate, TestList: testNames,));

//   }else{}

    getData();
    print(widget.bookingType);
    LocalDB.getLDB('userID').then((value) async {
      setState(() {
        userNo = value;
      });

      Map<String, dynamic> params1 = {
        "bookingID": userNo,
        "userNo": value,
        "type": widget.bookingType,
        "Latitude": latitude,
        "Longitude": longitude
      };

      fetchData(widget.bookID);

      if (widget.bookingType == "NewBooking") {
        print("NEW Booking");
        setState(() {
          isFetching = false;
        });
      } else {
        fetchData(widget.bookID);
        // BookedServiceVM model = Provider.of<BookedServiceVM>(context, listen: false);
        // model.fetchBookedService(params1, model,false).then((value){
        //   setState(() {
        //     isFetching = false;
        //   });
        // });
      }
      // Fetch test names using the fetchTestNames function
    });
  }

  @override
  Widget build(BuildContext context) {
    LstPatientResponse? patient;

    if (data != null &&
        data!.lstPatientResponse != null &&
        data!.lstPatientResponse!.isNotEmpty) {
      patient = data!.lstPatientResponse![0];
    } else {
      // setState(() {
      //   isemptty=true;
      // });
    }

    void gettestCount() {
      for (int index = 0; index < patient!.lstTestDetails!.length; index++) {
        String testName = patient.lstTestDetails![index].testName.toString();
        if (!testNames.contains(testName)) {
          testNames.add(testName);
        }
      }
    }

// int testCount=0;
    BookedServiceVM testCount = Provider.of<BookedServiceVM>(context);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
            backgroundColor: const Color(0xffEFEFEF),
            body: WillPopScope(
              onWillPop: () async {
                widget.ontap();
                print("working-----------------------");
                widget.bookingType == "APP"
                    ? NavigateController.pagePush(
                        context,
                        PatientDetailsView(
                          screenType: 1,
                          bookingType: widget.bookingType,
                          bookingID: widget.bookID,
                          regdate: widget.regdate,
                        ))
                    : widget.bookingType == "NR"
                        ? NavigateController.pagePush(
                            context,
                            PatientDetailsView(
                              screenType: 2,
                              bookingType: widget.bookingType,
                              bookingID: widget.bookID,
                              regdate: widget.regdate,
                            ))
                        : NavigateController.pagePOP(context);
                return true;
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: height * 0.1,
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
                            child: Stack(
                              children: [
                                Positioned(
                                  left: width * 0.02,
                                  top: height * 0.02,
                                  child: GestureDetector(
                                      onTap: () {
                                        widget.ontap();

                                        widget.bookingType == "APP"
                                            ? NavigateController.pagePush(
                                                context,
                                                PatientDetailsView(
                                                  screenType: 1,
                                                  bookingType:
                                                      widget.bookingType,
                                                  bookingID: widget.bookID,
                                                  regdate: widget.regdate,
                                                ))
                                            : widget.bookingType == "NR"
                                                ? NavigateController.pagePush(
                                                    context,
                                                    PatientDetailsView(
                                                      screenType: 2,
                                                      bookingType:
                                                          widget.bookingType,
                                                      bookingID: widget.bookID,
                                                      regdate: widget.regdate,
                                                    ))
                                                : NavigateController.pagePOP(
                                                    context);
                                      },
                                      child: const Icon(
                                        Icons.arrow_back_ios,
                                        color: Colors.white,
                                      )),
                                ),
                                const Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Add Cart",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Positioned(
                                  right: width * 0.02,
                                  top: height * 0.02,
                                  child: GestureDetector(
                                      onTap: () {
                                        NavigateController.pagePush(
                                            context,
                                            SearchTests(
                                              BookingID: widget.bookID,
                                              referalID: '',
                                              bookingType: widget.bookingType,
                                              regdate: widget.regdate,
                                              TestList: widget.bookingType ==
                                                      "NewBooking"
                                                  ? TestDetailName
                                                  : testNames,
                                              ontap: widget.ontap,
                                            ));
                                        gettestCount();

                                        // if(widget.bookingType=="NewBooking"){
                                        // NavigateController.pageReplace(context,  SearchTests(BookingID: widget.bookID, referalID: '', bookingType: widget.bookingType, regdate: widget.regdate, TestList:testNames,));
                                        // }else{
                                        // NavigateController.pagePush(context,  SearchTests(BookingID: widget.bookID, referalID: '', bookingType: widget.bookingType, regdate: widget.regdate, TestList:testNames,));
                                        // }
                                        // var refID = testCount.getBookedService.data!.lstPhileBotomyAppointmentAndRequest![0].primaryReffflerralType.toString();
                                        // print(refID);
                                        //
                                        // switch(refID){
                                        //   case "DR":
                                        //     NavigateController.pagePush(context,  SearchTests(BookingID: widget.userID, referalID: testCount.getBookedService.data!.lstPhileBotomyAppointmentAndRequest![0].doctorId.toString(), bookingType: widget.bookingType,));
                                        //     break;
                                        //   case "CLI":
                                        //     NavigateController.pagePush(context,  SearchTests(BookingID: widget.userID, referalID:testCount.getBookedService.data!.lstPhileBotomyAppointmentAndRequest![0].clientID.toString(), bookingType: widget.bookingType,));
                                        //     break;
                                        //   case "HMC":
                                        //     NavigateController.pagePush(context,  SearchTests(BookingID: widget.userID, referalID: '', bookingType: widget.bookingType,));
                                        //     break;
                                        //   default:
                                        //     NavigateController.pagePush(context,  SearchTests(BookingID: widget.userID, referalID: '', bookingType: widget.bookingType,));
                                        //     break;
                                        // }
                                      },
                                      child: const Icon(Icons.add,
                                          color: Colors.white, size: 28)),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    //     isemptty?
                    // Container(
                    //  height: height-170,width: width,

                    // child: Center(child: Text("Please select Test")),):
                    isFetching
                        ? SizedBox(
                            height: height - 170,
                            width: width,
                            child: const Center(
                                child: CircularProgressIndicator()))
                        : widget.bookingType == "NewBooking"
                            ? SizedBox(
                                height: height * 0.86,
                                child: SizedBox(
                                  width: width * 0.96,
                                  child: Consumer<BookedServiceVM>(
                                      builder: (context, viewModel, _) {
                                    switch (viewModel.getBookedService.status) {
                                      case Status.Loading:
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      case Status.Error:
                                        return const Text(
                                          "No Data",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        );
                                      case Status.Completed:
                                        // updateData();
                                        var VM =
                                            viewModel.getBookedService.data!;
                                        print(
                                            "Count-----${VM.totalCountTest}-----Count");
                                        return VM.lstPatientResponse == null
                                            ? const SizedBox()
                                            : VM.lstPatientResponse!.isEmpty
                                                ? const SizedBox()
                                                : VM.lstPatientResponse![0]
                                                            .lstTestDetails ==
                                                        null
                                                    ? const SizedBox()
                                                    : VM
                                                            .lstPatientResponse![
                                                                0]
                                                            .lstTestDetails!
                                                            .isEmpty
                                                        ? const SizedBox()
                                                        : Column(
                                                            children: [
                                                              Expanded(
                                                                flex: 8,
                                                                child: SizedBox(
                                                                  child:
                                                                      SingleChildScrollView(
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Flex(
                                                                          direction:
                                                                              Axis.vertical,
                                                                          children: [
                                                                            Scrollbar(
                                                                              thickness: 50,
                                                                              child: ListView.builder(
                                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                                  shrinkWrap: true,
                                                                                  itemCount: VM.lstPatientResponse![0].lstTestDetails!.length,
                                                                                  itemBuilder: (BuildContext context, index) {
                                                                                    String testName = VM.lstPatientResponse![0].lstTestDetails![index].testName.toString();

                                                                                    // print("${VM.lstPatientResponse![0].lstTestDetails!.length}+++++++++++++++++++++++++++++++++++");
                                                                                    // testNames.add(testName);
                                                                                    // Provider.of<TestNamesProvider>(context, listen: false).addTestName(testName);

                                                                                    print(testName);
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
                                                                                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17)),
                                                                                                child: Stack(
                                                                                                  children: [
                                                                                                    Positioned(
                                                                                                        right: width * 0.0,
                                                                                                        bottom: height * 0.0,
                                                                                                        child: Image.asset(
                                                                                                          'assets/images/side_illustrate.png',
                                                                                                          height: height * 0.05,
                                                                                                          color: const Color(0xff182893),
                                                                                                        )),
                                                                                                    Positioned(
                                                                                                      left: width * 0.03,
                                                                                                      top: height * 0.026,
                                                                                                      child: Column(
                                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                                        children: [
                                                                                                          CircleAvatar(
                                                                                                            backgroundColor: Colors.white,
                                                                                                            child: Padding(
                                                                                                              padding: const EdgeInsets.all(4.0),
                                                                                                              child: Image.asset(
                                                                                                                'assets/images/testube.png',
                                                                                                                height: height * 0.06,
                                                                                                                color: const Color(0xff182893),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                    Positioned(
                                                                                                      left: width * 0.175,
                                                                                                      top: height * 0.016,
                                                                                                      child: Column(
                                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                        children: [
                                                                                                          SizedBox(
                                                                                                              width: width * 0.65,
                                                                                                              child: Text(
                                                                                                                VM.lstPatientResponse![0].lstTestDetails![index].testName.toString(),
                                                                                                                style: const TextStyle(color: Color(0xff203298), fontWeight: FontWeight.w600),
                                                                                                                overflow: TextOverflow.ellipsis,
                                                                                                                maxLines: 1,
                                                                                                              )),
                                                                                                          SizedBox(
                                                                                                            height: height * 0.001,
                                                                                                          ),
                                                                                                          //  Text(VM.lstPatientResponse![0].lstTestDetails![index].testNo.toString() == "null" ? "" :VM.lstPatientResponse![0].lstTestDetails![index].testNo.toString(),style: const TextStyle(fontSize: 10),),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                    Positioned(
                                                                                                      left: width * 0.175,
                                                                                                      bottom: height * 0.003,
                                                                                                      child: Column(
                                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                        children: [
                                                                                                          Text(
                                                                                                            VM.lstPatientResponse![0].lstTestDetails![index].testType ?? "",
                                                                                                            style: const TextStyle(fontSize: 12),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                    Positioned(
                                                                                                      top: height * 0.066,
                                                                                                      right: width * 0.03,
                                                                                                      child: Text(
                                                                                                        "₹${VM.lstPatientResponse![0].lstTestDetails![index].amount!.toInt()}",
                                                                                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
                                                                                                      ),
                                                                                                    )
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          cartCount != 0
                                                                                              ? Positioned(
                                                                                                  right: 10,
                                                                                                  top: 5,
                                                                                                  child: GestureDetector(
                                                                                                    onTap: () {
                                                                                                      if (widget.bookingType == "NewBooking") {
                                                                                                        // Remove the test from NewBookData list first
                                                                                                        viewModel.NewBookData.removeAt(index);

                                                                                                        // Then, remove the test from lstTestDetails
                                                                                                        viewModel.getBookedService.data!.lstPatientResponse![0].lstTestDetails!.removeAt(index);

                                                                                                        // Update the view model
                                                                                                        final jsonData = AppointmentAndRequestData.fromJson(viewModel.getBookedService.data!.toJson());
                                                                                                        viewModel.setBookedService(ApiResponse.completed(jsonData));

                                                                                                        Fluttertoast.showToast(msg: "Test Removed", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 14.0);
                                                                                                      } else {
                                                                                                        Map<String, dynamic> data = {
                                                                                                          "bookingID": widget.bookID,
                                                                                                          "bookingTestNo": VM.lstPatientResponse![0].lstTestDetails![index].testNo,
                                                                                                          "userNo": userNo,
                                                                                                        };
                                                                                                        ApiClient().fetchData(ServerURL().getUrl(RequestType.DeleteServiceTest), data).then((value) {
                                                                                                          if (value["status"] == 1) {
                                                                                                            // Remove the test from NewBookData list first
                                                                                                            viewModel.NewBookData.removeAt(index);

                                                                                                            // Then, remove the test from lstTestDetails
                                                                                                            viewModel.getBookedService.data!.lstPatientResponse![0].lstTestDetails!.removeAt(index);

                                                                                                            // Update the view model
                                                                                                            final jsonData = AppointmentAndRequestData.fromJson(viewModel.getBookedService.data!.toJson());
                                                                                                            viewModel.setBookedService(ApiResponse.completed(jsonData));
                                                                                                            Fluttertoast.showToast(msg: "Test Removed", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 14.0);
                                                                                                          } else {
                                                                                                            errorPopUp(context, 'Something went wrong.\nPlease try again.');
                                                                                                          }
                                                                                                        });
                                                                                                      }
                                                                                                    },

                                                                                                    // onTap:(){
                                                                                                    //   if(widget.bookingType == "NewBooking"){
                                                                                                    //     viewModel.getBookedService.data!.lstPatientResponse![0].lstTestDetails!.removeAt(index);
                                                                                                    //     final jsonData = AppointmentAndRequestData.fromJson(viewModel.getBookedService.data!.toJson());
                                                                                                    //     viewModel.setBookedService(ApiResponse.completed(jsonData));
                                                                                                    //   }else{
                                                                                                    //     Map<String,dynamic> data = {
                                                                                                    //       "bookingID": widget.bookID,
                                                                                                    //       "bookingTestNo":VM.lstPatientResponse![0].lstTestDetails![index].testNo,
                                                                                                    //       "userNo": userNo,
                                                                                                    //     };
                                                                                                    //     ApiClient().fetchData(ServerURL().getUrl(RequestType.DeleteServiceTest), data).then((value){
                                                                                                    //       if(value["status"] == 1) {
                                                                                                    //         // BookedServiceVM model = Provider.of<BookedServiceVM>(context, listen: false);

                                                                                                    //         // AddToCartListVM model = Provider.of<AddToCartListVM>(context, listen: false);
                                                                                                    //         // model.setAddCartMain(ApiResponse.loading());
                                                                                                    //         // viewModel.getAddToCart.data!.totalServiceAmount = (viewModel.getAddToCart.data!.totalServiceAmount!.toInt() - viewModel.getAddToCart.data!.lstCartDetailsGet![index].serviceAmount!.toInt()).toDouble();
                                                                                                    //         viewModel.getBookedService.data!.lstPatientResponse![0].lstTestDetails!.removeAt(index);
                                                                                                    //         final jsonData = AppointmentAndRequestData.fromJson(viewModel.getBookedService.data!.toJson());
                                                                                                    //         viewModel.setBookedService(ApiResponse.completed(jsonData));
                                                                                                    //         //
                                                                                                    //         // Map<String,dynamic> params1 = {
                                                                                                    //         //   "PhileBotomyID":phileBotomyID,
                                                                                                    //         //   "BookingID":widget.userID,
                                                                                                    //         //   "Page":widget.bookingType,
                                                                                                    //         //   "Latitude": "",
                                                                                                    //         //   "Longitude": ""
                                                                                                    //         // };
                                                                                                    //         // VM.fetchBookedService(params1, VM);
                                                                                                    //       }else{
                                                                                                    //         errorPopUp(context,'Something went wrong.\nPlease try again.');
                                                                                                    //       }

                                                                                                    //     });
                                                                                                    //   }

                                                                                                    //   // deleteAlert(  context,viewModel , index);
                                                                                                    // },
                                                                                                    child: Container(
                                                                                                      padding: const EdgeInsets.all(2),
                                                                                                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                                                                                      constraints: const BoxConstraints(
                                                                                                        minWidth: 25,
                                                                                                        minHeight: 25,
                                                                                                      ),
                                                                                                      child: const Center(
                                                                                                          child: Icon(
                                                                                                        Icons.clear,
                                                                                                        color: Colors.white,
                                                                                                        size: 15,
                                                                                                      )),
                                                                                                    ),
                                                                                                  ),
                                                                                                )
                                                                                              : Container()
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
                                                              ),
                                                            ],
                                                          );

                                      default:
                                    }
                                    return Container();
                                  }),
                                ),
                              )
                            : SizedBox(
                                // height: height* 0.86,
                                width: width * 0.96,
                                child: Column(
                                  children: [
                                    SizedBox(
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
                                                      itemCount: patient!
                                                          .lstTestDetails!
                                                          .length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              index) {
                                                        //         void gettestCount(){
                                                        //            String testName =
                                                        //     patient!
                                                        //         .lstTestDetails![
                                                        //             index]
                                                        //         .testName
                                                        //         .toString();
                                                        //   !testNames.contains(testName)?
                                                        // testNames.add(testName):null;

                                                        //         }
                                                        // String testName =
                                                        //     patient!
                                                        //         .lstTestDetails![
                                                        //             index]
                                                        //         .testName
                                                        //         .toString();
                                                        //   !testNames.contains(testName)?
                                                        // testNames.add(testName):null;
                                                        // print(testName);
                                                        final testDetail = patient!
                                                                .lstTestDetails![
                                                            index];
                                                        return Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Stack(
                                                            children: <Widget>[
                                                              InkWell(
                                                                onTap: () {
                                                                  // NavigateController.pagePush(context, const PatientDetailsView(screenType: 1,));
                                                                },
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child:
                                                                      Container(
                                                                    height:
                                                                        height *
                                                                            0.1,
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        borderRadius:
                                                                            BorderRadius.circular(17)),
                                                                    child:
                                                                        Stack(
                                                                      children: [
                                                                        Positioned(
                                                                            right: width *
                                                                                0.0,
                                                                            bottom: height *
                                                                                0.0,
                                                                            child:
                                                                                Image.asset(
                                                                              'assets/images/side_illustrate.png',
                                                                              height: height * 0.05,
                                                                              color: const Color(0xff182893),
                                                                            )),
                                                                        Positioned(
                                                                          left: width *
                                                                              0.03,
                                                                          top: height *
                                                                              0.026,
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              CircleAvatar(
                                                                                backgroundColor: Colors.white,
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(4.0),
                                                                                  child: Image.asset(
                                                                                    'assets/images/testube.png',
                                                                                    height: height * 0.06,
                                                                                    color: const Color(0xff182893),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Positioned(
                                                                          left: width *
                                                                              0.175,
                                                                          top: height *
                                                                              0.016,
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              SizedBox(
                                                                                  width: width * 0.65,
                                                                                  child: Text(
                                                                                    testDetail.testName.toString(),
                                                                                    style: const TextStyle(color: Color(0xff203298), fontWeight: FontWeight.w600),
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                    maxLines: 1,
                                                                                  )),
                                                                              SizedBox(
                                                                                height: height * 0.001,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Positioned(
                                                                          left: width *
                                                                              0.175,
                                                                          bottom:
                                                                              height * 0.003,
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                testDetail.testType.toString(),
                                                                                style: const TextStyle(fontSize: 12),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Positioned(
                                                                          top: height *
                                                                              0.066,
                                                                          right:
                                                                              width * 0.03,
                                                                          child:
                                                                              Text(
                                                                            "₹${testDetail.amount!.toInt()}",
                                                                            style: const TextStyle(
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.w500,
                                                                                fontSize: 14),
                                                                          ),
                                                                        ),
                                                                        Positioned(
                                                                          right:
                                                                              10,
                                                                          top:
                                                                              5,
                                                                          child:
                                                                              GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              setState(() {
                                                                                deletingIndex = index;
                                                                              });

                                                                              deleteAlert(context, testDetail.testNo, height, width, patient!.lstTestDetails![index].testName.toString());
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              padding: const EdgeInsets.all(2),
                                                                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                                                              constraints: const BoxConstraints(
                                                                                minWidth: 25,
                                                                                minHeight: 25,
                                                                              ),
                                                                              child: Center(
                                                                                  child: index == deletingIndex && isdelete
                                                                                      ? const CircularProgressIndicator()
                                                                                      : const Icon(
                                                                                          Icons.clear,
                                                                                          color: Colors.white,
                                                                                          size: 15,
                                                                                        )),
                                                                            ),
                                                                          ),
                                                                        )
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
                                  ],
                                ),
                              )
                  ],
                ),
              ),
            )));
  }

  bool isdelete = false;

  void removeStringFromList(String textToRemove) {
    testNames.removeWhere((item) => item == textToRemove);

    setState(() {
      isdelete = false;
    });

    print('$textToRemove removed from the list');
  }

  deleteAlert(BuildContext context, booktestNo, height, width, testnamee) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: CustomTheme.circle_green,
            title: const Text(
              "Are you sure want to remove service ?",
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                  onPressed: () {
                    setState(() {
                      isdelete = true;
                    });
                    removeStringFromList(testnamee);
                    Map<String, dynamic> data = {
                      "bookingID": widget.bookID,
                      "bookingTestNo": booktestNo,
                      "userNo": userNo,
                    };
                    ApiClient()
                        .fetchData(
                            ServerURL().getUrl(RequestType.DeleteServiceTest),
                            data)
                        .then((value) {
                      if (value["Status"] == 1) {
                        fetchData(widget.bookID);
                      } else {
                        fetchData(widget.bookID);
                      }
                    });

                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Yes",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("No",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)))
            ],
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
          );
        });
  }

  Widget successStatusPOPUP(
    BuildContext context,
    height,
    width,
  ) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: height * 0.24,
          width: width * 0.82,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(15.0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Test Deleted successfully",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 18,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Center(
                      child: Text(
                        "OK",
                        style: TextStyle(
                            color: Color(0xff2454FF),
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
