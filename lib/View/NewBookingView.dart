import 'dart:async';
import 'dart:convert';
import 'package:botbridge_green/Model/ServerURL.dart';
import 'package:botbridge_green/Utils/NavigateController.dart';
import 'package:botbridge_green/View/HomeView.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Model/ApiClient.dart';
import '../Utils/LocalDB.dart';
import '../ViewModel/BookedServiceVM.dart';
import 'AddToCartView.dart';
import 'Helper/ThemeCard.dart';
import 'PaymentView.dart';
import 'package:http/http.dart' as http;
import 'TabbarView.dart';

class NewBookingView extends StatefulWidget {
  const NewBookingView({Key? key}) : super(key: key);

  @override
  _NewBookingViewState createState() => _NewBookingViewState();
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class _NewBookingViewState extends State<NewBookingView> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController mobileNo = TextEditingController();
  final TextEditingController emailID = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController gender = TextEditingController();
  final TextEditingController area = TextEditingController();
  final TextEditingController pincode = TextEditingController();
  final TextEditingController remark = TextEditingController();
  final TextEditingController dob = TextEditingController();
  final TextEditingController doctorName = TextEditingController();
  final TextEditingController clientName = TextEditingController();
  final TextEditingController age = TextEditingController();
  DateFormat dateformat = DateFormat('dd/MM/yyyy');
  DateFormat dateformatnow = DateFormat('yyyy-MM-dd 00:00:00.000');
  FocusNode referalfocuse = FocusNode();
  DateTime selectedDate = DateTime.now();
  String accountuser = '';
  final scaffoldkey = GlobalKey<ScaffoldState>();
  late Color col = Colors.white;
  String genderType = '';
  String titleType = "";
  String referralType = "";
  int physicanNo = 0;
  String physicianName = '';
  int clintno = 0;
  bool isSelf = false;
  bool isDoctor = false;
  bool isClient = false;
  bool isClicked = false;
  bool iscompleted = false;
  String txtdate = '';
  bool emailerror = false;
  bool ageerror = false;
  bool isGenderAutoUpdated = false;

  GoogleMapController? mapController;
  Set<Marker> markers = {};
  final Completer<GoogleMapController> _controller = Completer();
  Position? currentLoc;
  startFetching() async {
    print("Start2");
    bool serviceEnabled;
    LocationPermission permission;
    // List<String> testNames = [];

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
        permission = await Geolocator.requestPermission();
      } else {}
    } else {
      print("Start3");
      Position userLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print(userLocation);
      if (mounted) {
        setState(() {
          currentLoc = userLocation;
        });
      }

      markers.add(Marker(
          //add start location marker
          markerId: MarkerId(
              LatLng(userLocation.latitude, userLocation.longitude).toString()),
          position: LatLng(userLocation.latitude,
              userLocation.longitude), //position of marker
          infoWindow: const InfoWindow(
            //popup info
            title: 'Home',
            snippet: 'Start Marker',
          ),
          icon: await BitmapDescriptor.fromAssetImage(
              const ImageConfiguration(devicePixelRatio: 3.2),
              "assets/images/home_mark.png") //Icon for Marker
          ));
      GoogleMapController gMapController = await _controller.future;

      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
      Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position? position) {
        if (position != null) {
          gMapController.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                  zoom: 13.3,
                  target: LatLng(position.latitude, position.longitude))));
        }
      });
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

//   // In another page where you have an instance of BookedServiceVM
// int testDetailsLength = bookedServiceVM.getTestDetailsLength();
// print("Test Details Length: $testDetailsLength");

//   int getTestDetailsLength() {
//   if (listBookedService.status == Status.Completed &&
//       listBookedService.data != null &&
//       listBookedService.data!.lstPatientResponse != null &&
//       listBookedService.data!.lstPatientResponse!.isNotEmpty &&
//       listBookedService.data!.lstPatientResponse![0].lstTestDetails != null) {
//     return listBookedService.data!.lstPatientResponse![0].lstTestDetails!.length;
//   } else {
//     return 0;
//   }
// }

  ScrollController control = ScrollController();
  bool floatingButtonVisible = false;
  String? selectedGender;
  String? selectedTitle;
  String? selectedReferral;
  int selectRefno = 1;
  // _scrollListener() {
  //   bool isTop = control.position.pixels == 0;
  //   setState(() {
  //     if (isTop) {
  //       floatingButtonVisible = false;
  //       print('At the top');
  //     } else {
  //       floatingButtonVisible = true;
  //       print('At the bottom');
  //     }
  //   });
  // }

  getData() async {
    LocalDB.getLDB("AccountName").then((value) {
      setState(() {
        accountuser = value;
        print("Account name $accountuser");
      });
    });

//  var uuid = await LocalDB.getLDB("UID")??'';
//  print("checkkkkkk $uuid");
  }

  bool usererror = false;
  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  int listOfTestcount = 0;

  void didPop() {
    BookedServiceVM model =
        Provider.of<BookedServiceVM>(context, listen: false);
    int lengthOfTestDetails = model.getLstTestDetailsLength();
    print("Length of lstTestDetails: $lengthOfTestDetails");

    setState(() {
      listOfTestcount = lengthOfTestDetails;
    });
  }

//   void didPop(int count) {

//      BookedServiceVM model =
//           Provider.of<BookedServiceVM>(context, listen: false);
//           int lengthOfTestDetails = model.getLstTestDetailsLength();
// print("Length of lstTestDetails: $lengthOfTestDetails");

// setState(() {
//        listOfTestcount = lengthOfTestDetails;

// });

//   }

  @override
  void initState() {
    super.initState();
    listOfTestcount = 0;
    // BookedServiceVM model =
    //     Provider.of<BookedServiceVM>(context, listen: false);
    // setState(() {
    //   listOfTestcount = model.getNewBookData.length;
    // });
    emailID.text = '';
    txtdate = dateformatnow.format(DateTime.now()).toString();
    getData();
    control.addListener(_scrollListener);

    Future.delayed(Duration.zero, () {
      BookedServiceVM model =
          Provider.of<BookedServiceVM>(context, listen: false);
      model.fetchBookedService({}, model, true);
      startFetching();
    });

    usererror = false;
  }

  void _scrollListener() {
    bool isTop = control.position.pixels == 0;
    if (isTop) {
      setState(() {
        floatingButtonVisible = false;
        print('At the top');
      });
    } else {
      setState(() {
        floatingButtonVisible = true;
        print('At the bottom');
      });
    }
  }

  UnderlineInputBorder outline = const UnderlineInputBorder(
      // borderRadius: BorderRadius.circular(25),
      borderSide: BorderSide(width: 0, color: Colors.black45));
  @override
  Widget build(BuildContext context) {
    bool isdateselected = false;

    Future<void> fetchpin(String pinpin) async {
      var request = http.Request(
          'GET', Uri.parse('https://api.postalpincode.in/pincode/$pinpin'));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        List<dynamic> jsonResponse = json.decode(responseBody);

        if (jsonResponse.isNotEmpty) {
          List<dynamic> postOfficeData = jsonResponse[0]['PostOffice'];

          if (postOfficeData.isNotEmpty) {
            var firstPostOffice = postOfficeData[0];
            setState(() {
              area.text = firstPostOffice['Name'];
              address.text =
                  "${firstPostOffice['District']},${firstPostOffice['State']}";
              // firstPostOffice['State'];
            });
            // String name = firstPostOffice['Name'];
            // String district = firstPostOffice['District'];
            // String state = firstPostOffice['State'];

            print('Name: $area');
            print('District: $address');
            // print('State: $state');
          }
        } else {
          print('No data available');
        }
      } else {
        print(response.reasonPhrase);
      }
    }

    String userNo = '2';

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    void submitbutton() {
      BookedServiceVM model =
          Provider.of<BookedServiceVM>(context, listen: false);
      var listOfTest = model.getNewBookData;
      print(listOfTest);

      // bool referralCompleted = false;
      // DateTime currentDateTime = DateTime.now();
      LocalDB.getLDB('userID').then((value) {
        setState(() {
          userNo = value;
        });
        print(listOfTest.length);
        // DateFormat appDate =
        // DateFormat("yyyy-MM-dd HH:mm:ss");
        // DateFormat appTime =
        // DateFormat("yyyy-MM-dd HH:mm:ss");
        // if (_formkey.currentState!.validate()) {
        if (listOfTest.isNotEmpty&& listOfTestcount!=0) {
          LocalDB.getLDB('userID').then((value) {
            Map<String, dynamic> params = {
              "titleCode": titleType,
              "firstName": firstName.text,
              "middleName": "",
              "lastName": lastName.text,
              "age": age.text.isEmpty
                  ? ''
                  : age
                      .text, //age.text.isEmpty ? '' : "${age.text}Y", //laxmi change
              "ageType": "Y",
              "dob": isdateselected ? selectedDate.toString() : txtdate,
              "gender": genderType,
              "mobileNumber": mobileNo.text,
              "whatsappNo": mobileNo.text,
              "emailID": emailID.text,
              "address": address.text,
              "countryNo": 91,
              "refferralTypeNo": selectRefno,
              "customerNo": clintno,
              "physicianNo": physicanNo,
              "physicianName": physicianName,
              "registeredDateTime": DateFormat("yyyy-MM-dd HH:mm:ss")
                  .format(DateTime.now()), // "2022-05-07 10:20",
              "stateNo": 1,
              "cityNo": 3,
              "areaName": area.text,
              "pincode": pincode.text,
              "riderNo": value,
              "userNo": value,
              "IsPatientPaid": false,
              "lstCartList": listOfTest
            };
            // showDialog(
            //     context: context,
            //     barrierDismissible: false,
            //     builder: (_) => successStatusPOPUP(context,height,width,"3")
            // );
            ApiClient()
                .fetchData(
                    ServerURL().getUrl(RequestType.InsertBooking), params)
                .then((response) {
              print("insertbooking $response");
              print("$params");

              if (response["status"] == 1) {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => successStatusPOPUP(
                        context,
                        height,
                        width,
                        response["bookingID"],
                        DateFormat("yyyy-MM-dd HH:mm:ss")
                            .format(DateTime.now())));
              } else {}
            }).catchError((error) {
              print(error);
            });
          });
        } else {
          showGuide(context, "Please Add Test");
        }
      });
    }

    void isfill() {
      if (ageerror != true &&
          firstName.text.isNotEmpty &&
          selectedTitle!.isNotEmpty &&
          mobileNo.text.isNotEmpty &&
          genderType.isNotEmpty &&
          age.text.isNotEmpty &&
          address.text.isNotEmpty &&
          area.text.isNotEmpty &&
          pincode.text.isNotEmpty &&
          selectedReferral!.isNotEmpty) {
        selectedReferral != 'Doctor' || physicianName != ''
            ? submitbutton()
            : showGuide(context, "Please Fill All * Field");
      } else {
        showGuide(context, "Please Fill All * Field");
      }
    }
//  List<String> testNames = Provider.of<TestNamesProvider>(context).testNames;

    return SafeArea(
        child: GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: WillPopScope(
          onWillPop: () async {
            print("working-----------------------");
            FocusScope.of(context).unfocus();
            NavigateController.pagePushLikePop(context, const HomeView());
            return false;
          },
          child: Column(
            children: [
              Container(
                height: height * 0.059,
                width: width,
                decoration: BoxDecoration(
                    color: CustomTheme.background_green,
                    boxShadow: const [
                      BoxShadow(
                          offset: Offset(1, 4),
                          blurRadius: 6,
                          color: Colors.black12)
                    ],
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(height * 0.14 / 3.5))),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(11),
                        child: InkWell(
                            onTap: () {
                              NavigateController.pagePushLikePop(
                                  context, const HomeView());
                              // NavigateController.pagePOP(context);
                              // BookedServiceVM model = Provider.of<BookedServiceVM>(context, listen: false);
                              // model.clearbookedtest();
                            },
                            child: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                            )),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10, right: 10),
                            child: InkWell(
                                onTap: () {
                                  print(userNo);
                                  // NavigateController.pagePush(context,  SearchTests(BookingID: '', referalID: '', bookingType: "NewBooking", regdate: '', TestList: [],));

                                  NavigateController.pagePush(
                                      context,
                                      AddToCartView(
                                        bookingType: "NewBooking",
                                        bookID: '',
                                        regdate: '',
                                        isbooking: true,
                                        ontap: didPop,
                                      )); //widget.bookingType
                                },
                                child: SizedBox(
                                  height: height * 0.5,
                                  width: width * 0.09,
                                  child: Stack(children: [
                                    Image.asset(
                                      "assets/images/cart.png",
                                      height: 23,
                                    ),
                                    Positioned(
                                      top: 8,
                                      left: 14,
                                      child: Container(
                                        height: height * 0.025,
                                        width: width * 0.05,
                                        decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(30)),
                                            // shape: BoxShape.circle,
                                            color: Colors.black),
                                        child: Center(
                                            child: Text(
                                          "$listOfTestcount",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        )),
                                      ),
                                    ),
                                  ]),
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(11),
                            child: InkWell(
                                onTap: () {
                                  print(userNo);
                                  NavigateController.pagePush(
                                      context,
                                      SearchTests(
                                        BookingID: '',
                                        referalID: '',
                                        bookingType: "NewBooking",
                                        regdate: '',
                                        TestList:  [],
                                        ontap: didPop,
                                      ));

                                  // NavigateController.pagePush(
                                  //     context,
                                  //      AddToCartView(
                                  //       bookingType: "NewBooking",
                                  //       bookID: '',
                                  //       regdate: '', isbooking: true,

                                  //     )); //widget.bookingType
                                },
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                )),
                          ),
                        ],
                      ),
                    ),
                    const Align(
                      alignment: Alignment.center,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Book New Test",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: SizedBox(
                  // controller: control,
                  child: Form(
                    key: _formkey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: height * 0.03,
                          ),
                          SizedBox(
                            width: width * 0.9,
                            height: height * 0.078,
                            child: TextFormField(
                              textInputAction: TextInputAction.next,
                              cursorColor: Colors.black,
                              onChanged: (value) {
                                value.length >= 11
                                    ? setState(() {
                                        usererror = true;
                                      })
                                    : setState(() {
                                        usererror = false;
                                      });
                              },
                              controller: _username,
                              style: const TextStyle(color: Colors.black54),
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  errorStyle: const TextStyle(
                                    color: Colors.transparent,
                                    fontSize: 0,
                                  ),
                                  errorBorder: outline,
                                  focusedErrorBorder: outline,
                                  enabledBorder: outline,
                                  focusedBorder: outline,
                                  label: const Text(
                                    'UID',
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 14),
                                  )),
                            ),
                          ),
                          usererror
                              ? const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 20),
                                    child: Text(
                                      "Invalid User Name",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ))
                              : const Text(""),
                          SizedBox(height: height * 0.013),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // SizedBox(width: width * 0.08),
                              SizedBox(
                                width: width * 0.35,
                                height: height * 0.078,
                                child: DropdownButtonFormField2(
                                  dropdownDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  focusColor: Colors.white,
                                  validator: (value) {
                                    if (selectedTitle == null) {
                                      return "Please select title";
                                    }
                                    return null;
                                  },
                                  icon: const Padding(
                                    padding:
                                        EdgeInsets.only(bottom: 7, right: 8),
                                    child: Icon(Icons.keyboard_arrow_down),
                                  ),
                                  style: const TextStyle(color: Colors.black54),
                                  decoration: InputDecoration(
                                      errorStyle: const TextStyle(
                                        color: Colors.transparent,
                                        fontSize: 0,
                                      ),
                                      errorBorder: outline,
                                      focusedErrorBorder: outline,
                                      enabledBorder: outline,
                                      focusedBorder: outline,
                                      label: const Text(
                                        'Title*',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14),
                                      )),
                                  selectedItemBuilder: (BuildContext context) {
                                    return titleList.map<Widget>((Title item) {
                                      return Text(item.title,
                                          style: const TextStyle(
                                              color: Colors.black));
                                    }).toList();
                                  },
                                  items: titleList.map((Title item) {
                                    return DropdownMenuItem<String>(
                                      value: item.title,
                                      child: Text(
                                        item.title,
                                        style: const TextStyle(
                                            fontSize: 13, color: Colors.black),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (titleList) {
                                    setState(() {
                                      selectedTitle = titleList.toString();
                                      titleType = titleList.toString();

                                      // Update the gender selection only if it hasn't been manually updated
                                      if (titleee.contains(titleType)) {
                                        genderType =
                                            titleToGenderMapping[titleList] ??
                                                "";
                                        selectedGender =
                                            titleToGenderMapping[titleList];
                                        isGenderAutoUpdated = true;
                                      } else {
                                        isGenderAutoUpdated = false;
                                      }

                                      // Reset the flag after updating the gender based on title
                                    });
                                  },
                                  value: selectedTitle,
                                  isExpanded: true,
                                ),
                              ),

                              SizedBox(
                                width: width * 0.55,
                                height: height * 0.078,
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  cursorColor: Colors.black,
                                  controller: firstName,
                                  style: const TextStyle(color: Colors.black54),
                                  keyboardType: TextInputType.name,
                                  textCapitalization: TextCapitalization.words,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[a-zA-Z ]")),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'User Name is required';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                      errorStyle: const TextStyle(
                                        color: Colors.transparent,
                                        fontSize: 0,
                                      ),
                                      errorBorder: outline,
                                      focusedErrorBorder: outline,
                                      enabledBorder: outline,
                                      focusedBorder: outline,
                                      label: const Text(
                                        'First Name*',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14),
                                      )),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: height * 0.013),
                          SizedBox(
                            width: width * 0.9,
                            height: height * 0.078,
                            child: TextFormField(
                              textInputAction: TextInputAction.next,
                              cursorColor: Colors.black,
                              controller: lastName,
                              textCapitalization: TextCapitalization.words,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp("[a-zA-Z ]")),
                              ],
                              style: const TextStyle(color: Colors.black54),
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                  errorStyle: const TextStyle(
                                    color: Colors.transparent,
                                    fontSize: 0,
                                  ),
                                  errorBorder: outline,
                                  focusedErrorBorder: outline,
                                  enabledBorder: outline,
                                  focusedBorder: outline,
                                  floatingLabelStyle: const TextStyle(
                                      color: Colors.black54, fontSize: 14),
                                  label: const Text(
                                    'Last Name',
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 14),
                                  )),
                            ),
                          ),

                          SizedBox(height: height * 0.013),
                          SizedBox(
                            width: width * 0.9,
                            height: height * 0.078,
                            child: TextFormField(
                              textInputAction: TextInputAction.next,
                              cursorColor: Colors.black,
                              controller: mobileNo,
                              style: const TextStyle(color: Colors.black54),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                              ],
                              textCapitalization: TextCapitalization.sentences,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter a valid 10-digit phone number';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                  errorStyle: const TextStyle(
                                    color: Colors.transparent,
                                    fontSize: 0,
                                  ),
                                  errorBorder: outline,
                                  focusedErrorBorder: outline,
                                  enabledBorder: outline,
                                  focusedBorder: outline,
                                  label: const Text(
                                    'Mobile No*',
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 14),
                                  )),
                            ),
                          ),
                          SizedBox(height: height * 0.013),
                          SizedBox(
                            width: width * 0.9,
                            height: height * 0.078,
                            child: TextFormField(
                              textInputAction: TextInputAction.next,
                              cursorColor: Colors.black,
                              controller: emailID,
                              style: const TextStyle(color: Colors.black54),
                              keyboardType: TextInputType.emailAddress,
                              textCapitalization: TextCapitalization.sentences,
                              onChanged: (value) {
                                // Remove spaces and convert to lowercase
                                String formattedText =
                                    value.replaceAll(' ', '').toLowerCase();

                                // Check for email format
                                if (formattedText.isNotEmpty &&
                                    (!RegExp(
                                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                        .hasMatch(formattedText))) {
                                  setState(() {
                                    emailerror = true;
                                  });
                                } else {
                                  setState(() {
                                    emailerror = false;
                                  });
                                }

                                // Update the text field
                                emailID.value = emailID.value.copyWith(
                                  text: formattedText,
                                  selection: TextSelection.fromPosition(
                                    TextPosition(offset: formattedText.length),
                                  ),
                                  composing: TextRange.empty,
                                );
                              },
                              decoration: InputDecoration(
                                  // filled: true,
                                  // focusColor: const Color(0xffEFEFEF),
                                  // contentPadding: const EdgeInsets.only(top: 4,left: 7),
                                  errorStyle: const TextStyle(
                                    color: Colors.transparent,
                                    fontSize: 0,
                                  ),
                                  errorBorder: outline,
                                  focusedErrorBorder: outline,
                                  enabledBorder: outline,
                                  focusedBorder: outline,
                                  label: const Text(
                                    'Email ID',
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 14),
                                  )),
                            ),
                          ),
                          emailerror
                              ? Column(
                                  children: [
                                    const SizedBox(
                                      height: 1,
                                    ),
                                    const Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "            Enter a valid email address",
                                          style: TextStyle(color: Colors.red),
                                        )),
                                    SizedBox(height: height * 0.01),
                                  ],
                                )
                              : SizedBox(height: height * 0.013),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: width * 0.4,
                                height: height * 0.078,
                                child: TextFormField(
                                  controller: dob,
                                  readOnly: true,
                                  onTap: () {
                                    setState(() {
                                      isdateselected = true;
                                    });
                                    selectDate(context, selectedDate);
                                  },
                                  // validator: (value) {
                                  //   if (value!.isEmpty) {
                                  //     return "Please Selected DOB";
                                  //   }
                                  //   return null;
                                  // },
                                  style: const TextStyle(color: Colors.black54),
                                  decoration: InputDecoration(
                                      // filled: true,
                                      // focusColor: const Color(0xffEFEFEF),
                                      errorStyle: const TextStyle(
                                        color: Colors.transparent,
                                        fontSize: 0,
                                      ),
                                      // contentPadding: const EdgeInsets.only(bottom: 4,left: 12),
                                      errorBorder: outline,
                                      focusedErrorBorder: outline,
                                      enabledBorder: outline,
                                      focusedBorder: outline,
                                      label: const Text(
                                        'DOB',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14),
                                      )),
                                ),
                              ),
                              SizedBox(width: width * 0.08),
                              SizedBox(
                                width: width * 0.4,
                                height: height * 0.078,
                                child: AbsorbPointer(
                                  absorbing: isGenderAutoUpdated,
                                  child: DropdownButtonFormField2(
                                    dropdownDecoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    focusColor: Colors.white,
                                    validator: (value) {
                                      if (selectedGender == null) {
                                        return "Please select Gender";
                                      }
                                      return null;
                                    },
                                    icon: const Padding(
                                      padding:
                                          EdgeInsets.only(bottom: 7, right: 8),
                                      child: Icon(Icons.keyboard_arrow_down),
                                    ),
                                    style:
                                        const TextStyle(color: Colors.black54),
                                    decoration: InputDecoration(
                                        errorStyle: const TextStyle(
                                          color: Colors.transparent,
                                          fontSize: 0,
                                        ),
                                        errorBorder: outline,
                                        focusedErrorBorder: outline,
                                        enabledBorder: outline,
                                        focusedBorder: outline,
                                        label: const Text(
                                          'Gender*',
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 14),
                                        )),
                                    selectedItemBuilder:
                                        (BuildContext context) {
                                      return genderList
                                          .map<Widget>((Gender item) {
                                        return Text(item.gender,
                                            style: const TextStyle(
                                                color: Colors.black));
                                      }).toList();
                                    },
                                    items: genderList.map((Gender item) {
                                      return DropdownMenuItem<String>(
                                        value: item.gender,
                                        // onTap: () {
                                        //   if (!isGenderAutoUpdated) {
                                        //     return;
                                        //   }
                                        // },
                                        child: Text(
                                          item.gender,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (genderList) {
                                      setState(() {
                                        selectedGender = genderList.toString();
                                        genderType = genderList.toString();

                                        // Set the flag to true when the gender is manually updated
                                      });
                                    },
                                    value: selectedGender,
                                    isExpanded: false,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height * 0.013),
                          SizedBox(
                            width: width * 0.9,
                            height: height * 0.078,
                            child: TextFormField(
                              textInputAction: TextInputAction.next,
                              cursorColor: Colors.black,
                              controller: age,
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                if (int.parse(value) >= 121) {
                                  setState(() {
                                    ageerror = true;
                                  });
                                } else {
                                  setState(() {
                                    ageerror = false;
                                  });
                                }
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter Age*";
                                }
                                return null;
                              },
                              style: const TextStyle(color: Colors.black54),
                              decoration: InputDecoration(
                                  errorStyle: const TextStyle(
                                    color: Colors.transparent,
                                    fontSize: 0,
                                  ),
                                  errorBorder: outline,
                                  focusedErrorBorder: outline,
                                  enabledBorder: outline,
                                  focusedBorder: outline,
                                  label: const Text(
                                    'Age*',
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 14),
                                  )),
                            ),
                          ),
                          SizedBox(height: height * 0.013),
                          ageerror
                              ? const Text(
                                  "Please enter valid age",
                                  style: TextStyle(color: Colors.red),
                                )
                              : const SizedBox(),
                          SizedBox(
                            width: width * 0.9,
                            height: height * 0.078,
                            child: TextFormField(
                              textInputAction: TextInputAction.next,
                              cursorColor: Colors.black,
                              controller: address,
                              keyboardType: TextInputType.streetAddress,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter Valid Address";
                                }
                                return null;
                              },
                              style: const TextStyle(color: Colors.black54),
                              decoration: InputDecoration(
                                  errorStyle: const TextStyle(
                                    color: Colors.transparent,
                                    fontSize: 0,
                                  ),
                                  errorBorder: outline,
                                  focusedErrorBorder: outline,
                                  enabledBorder: outline,
                                  focusedBorder: outline,
                                  suffixIcon: InkWell(
                                    onTap: () async {
                                      _scrollIndicator(context, height, width);
                                      var userLocation =
                                          await Geolocator.getCurrentPosition();
                                      double lat = userLocation.latitude;
                                      double log = userLocation.longitude;
                                      List<Placemark> placeMarks =
                                          await placemarkFromCoordinates(
                                              lat, log);
                                      Placemark place = placeMarks[0];
                                      Placemark place2 = placeMarks[2];
                                      Map<String, String> addressMap = {
                                        "street": place2.subLocality.toString(),
                                        "postalCode":
                                            place.postalCode.toString(),
                                        "locality": place.locality.toString(),
                                        "state": place2.administrativeArea
                                            .toString(),
                                        "country": place2.country.toString()
                                      };
                                      var address =
                                          "${addressMap['street'] != "" ? "${addressMap['street']}," : ""}${addressMap['locality'] != "" ? "${addressMap['locality']}," : ""} ${addressMap['postalCode'] != "" ? "${addressMap['postalCode']}," : ""} ${addressMap['state'] != "" ? "${addressMap['state']}," : ""} ${addressMap['country'] ?? ""}";
                                      var addData =
                                          '${place2.subLocality}, ${place.postalCode}, ${place.locality}, ${place2.administrativeArea}, ${place.country}';
                                      Navigator.pop(context);
                                      showDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          builder: (_) => setAddressPOPUP(
                                              context,
                                              height,
                                              width,
                                              address,
                                              addressMap));
                                      referalfocuse.requestFocus();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Image.asset(
                                          'assets/images/address_map.png',
                                          height: 23),
                                    ),
                                  ),
                                  label: const Text(
                                    'Address*',
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
                                height: height * 0.078,
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  cursorColor: Colors.black,
                                  controller: area,
                                  style: const TextStyle(color: Colors.black54),
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Please enter Valid Area";
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                      errorStyle: const TextStyle(
                                        color: Colors.transparent,
                                        fontSize: 0,
                                      ),
                                      errorBorder: outline,
                                      focusedErrorBorder: outline,
                                      enabledBorder: outline,
                                      focusedBorder: outline,
                                      label: const Text(
                                        'Area*',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14),
                                      )),
                                ),
                              ),
                              SizedBox(width: width * 0.08),
                              SizedBox(
                                width: width * 0.4,
                                height: height * 0.078,
                                child: TextFormField(
                                  onChanged: (value) async{
                                    if (value.length == 6) {
                                     await fetchpin(value.toString());
                                    }
                                  },
                                  textInputAction: TextInputAction.next,
                                  cursorColor: Colors.black,
                                  focusNode: referalfocuse,
                                  controller: pincode,
                                  keyboardType: TextInputType.number,
                                  // maxLength: 6,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(6),
                                  ],
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Please enter pincode";
                                    }
                                    return null;
                                  },
                                  style: const TextStyle(color: Colors.black54),
                                  decoration: InputDecoration(
                                      errorStyle: const TextStyle(
                                        color: Colors.transparent,
                                        fontSize: 0,
                                      ),
                                      errorBorder: outline,
                                      focusedErrorBorder: outline,
                                      enabledBorder: outline,
                                      focusedBorder: outline,
                                      label: const Text(
                                        'Pincode*',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14),
                                      )),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: height * 0.013),
                          SizedBox(
                            width: width * 0.9,
                            height: height * 0.11,
                            child: DropdownButtonFormField2(
                              dropdownDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              focusColor: Colors.white,
                              icon: const Padding(
                                padding: EdgeInsets.only(bottom: 7, right: 8),
                                child: Icon(Icons.keyboard_arrow_down),
                              ),
                              validator: (value) {
                                if (selectedReferral == null) {
                                  return "Please select Referral";
                                }
                                return null;
                              },
                              style: const TextStyle(color: Colors.black54),
                              decoration: InputDecoration(
                                  errorStyle: const TextStyle(
                                    color: Colors.transparent,
                                    fontSize: 0,
                                  ),
                                  errorBorder: outline,
                                  focusedErrorBorder: outline,
                                  enabledBorder: outline,
                                  focusedBorder: outline,
                                  label: const Text(
                                    'Referral*',
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 14),
                                  )),
                              selectedItemBuilder: (BuildContext context) {
                                return referralList
                                    .map<Widget>((Referral item) {
                                  return Text(item.type,
                                      style:
                                          const TextStyle(color: Colors.black));
                                }).toList();
                              },
                              items: referralList.map((Referral item) {
                                return DropdownMenuItem<String>(
                                  value: item.type,
                                  child: Text(
                                    item.type,
                                    style: const TextStyle(
                                        fontSize: 13, color: Colors.black),
                                  ),
                                );
                              }).toList(),
                              onChanged: (referralList) {
                                setState(() {
                                  selectedReferral = referralList.toString();
                                  if (selectedReferral == "Self") {
                                    setState(() {
                                      doctorName.text = '';
                                      physicianName = '';
                                      selectRefno = 1;
                                    });
                                    print(selectRefno);
                                  }
                                  if (selectedReferral == "Doctor") {
                                    setState(() {
                                      selectRefno = 2;
                                    });
                                    print(selectRefno);
                                  } else {
                                    // setState(() {
                                    // selectRefno=3;
                                    // });
                                    // print(selectRefno);
                                  }
                                  col = Colors.black54;
                                  referralType = referralList.toString();

                                  if (referralList == "Client") {
                                    Navigator.pushNamed(
                                            context, "SearchClientReferral")
                                        .then((value) {
                                      if (value != null) {
                                        if (value != false) {
                                          Map<String, dynamic> data =
                                              value as Map<String, dynamic>;
                                          print(data);
                                          clientName.text = data['name'];
                                          clintno = int.parse(data['id']);
                                          print("physican No : $clintno");
                                        }
                                        print(value);
                                      }
                                    });
                                  }
                                });
                              },
                              dropdownWidth: 160,
                              value: selectedReferral,
                              isExpanded: true,
                            ),
                          ),
                          // SizedBox(height: height * 0.013),
                          getReferralField(height, width),
                          SizedBox(height: height * 0.013),
                          Row(
                            children: <Widget>[
                              SizedBox(width: width * 0.06),
                              const Text("Remark",
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 14))
                            ],
                          ),
                          SizedBox(height: height * 0.002),
                          SizedBox(
                            width: width * 0.9,
                            child: TextFormField(
                              textInputAction: TextInputAction.next,
                              cursorColor: Colors.black,
                              style: const TextStyle(color: Colors.black54),
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              decoration: InputDecoration(
                                errorStyle: const TextStyle(
                                  color: Colors.transparent,
                                  fontSize: 0,
                                ),
                                errorBorder: outline,
                                focusedErrorBorder: outline,
                                enabledBorder: outline,
                                focusedBorder: outline,
                              ),
                            ),
                          ),

                          SizedBox(height: height * 0.013),
                          iscompleted
                              ? Column(
                                  children: [
                                    //   RichText(
                                    //    text: TextSpan(
                                    //      text: 'The  ',style: const TextStyle(color: Colors.black),
                                    //     //  style: DefaultTextStyle.of(context).style,
                                    //      children: <TextSpan>[
                                    //        TextSpan(
                                    //          text: "${firstName.text}'s",
                                    //          style: TextStyle(
                                    //            color: CustomTheme.background_green,
                                    //            fontWeight: FontWeight.bold // Set your desired color here
                                    //            // Add any other styling properties for the first name here
                                    //          ),
                                    //        ),
                                    //        const TextSpan(
                                    //          text: ' Test is Added!',
                                    //        ),
                                    //      ],
                                    //    ),
                                    //  ),
                                    SizedBox(height: height * 0.02),
                                    InkWell(
                                      onTap: () {
                                        NavigateController.pageReplace(
                                            context, const NewBookingView());
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 120,
                                        decoration: BoxDecoration(
                                            color: CustomTheme.background_green,
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        child: const Center(
                                          child: Text(
                                            'Add New Booking',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          iscompleted
                              ? const SizedBox()
                              : InkWell(
                                  onTap: () {
                                    if (_formkey.currentState!.validate()) {
                                      isfill();
                                      //  showToast('Patient Added Successfully');
                                    } else {
                                      showToast('Please Fill All * Fields');
                                    }
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 120,
                                    decoration: BoxDecoration(
                                        color: CustomTheme.background_green,
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child: const Center(
                                      child: Text(
                                        'Submit',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ),
                          SizedBox(height: height * 0.05),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  showGuide(BuildContext context, content) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text(content)),
            actions: [
              Center(
                child: TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                    child: Container(
                        height: 30,
                        width: 80,
                        decoration: BoxDecoration(
                            color: CustomTheme.circle_green,
                            borderRadius: BorderRadius.circular(6)),
                        child: const Center(
                            child: Text(
                          "OK",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600),
                        )))),
              ),
            ],
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(7.0))),
          );
        });
  }

  getReferralField(height, width) {
    switch (referralType) {
      // case "Client":
      //   return Column(
      //     children: [
      //       SizedBox(
      //         width: width * 0.9,
      //         height: height * 0.078,
      //         child: TextFormField(
      //           readOnly: true,
      //           controller: clientName,
      //           onTap: () {
      //             Navigator.pushNamed(context, "SearchClientReferral").then((value) {
      //               if (value != null){

      //                 Map<String,dynamic> data = value as Map<String,dynamic>;
      //                 print(data);
      //                 clientName.text = data['name'].toString();
      //                 // physicanNo=int.parse(data['id']);
      //               clintno=int.parse(data['id']);

      //                 print(value);
      //                 print(" the doctor name $physicanNo");
      //               }
      //             });
      //           },
      //           decoration: InputDecoration(

      //               errorStyle: const TextStyle(
      //                 color: Colors.transparent,
      //                 fontSize: 0,
      //               ),
      //               errorBorder: outline,
      //               focusedErrorBorder: outline,
      //               enabledBorder:outline,
      //               focusedBorder:outline,
      //               label: const Text('Client*',style: TextStyle(color: Colors.black54,fontSize: 14),)

      //           ),
      //         ),
      //       ),
      //       SizedBox(height: height * 0.013),
      //       doctorField(width,height, "Doctor(Optional)",)
      //     ],
      //   );
      case "Doctor":
        return doctorField(width, height, "Doctor*");
      case "Self":
        return doctorField(width, height, "Doctor(Optional)");
      case '':
        return const SizedBox();
    }
  }

  Widget successStatusPOPUP(
      BuildContext context, height, width, bookingID, final regdate) {
    Color textBorder = const Color(0xff0272B1);
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
              CircleAvatar(
                radius: 20,
                backgroundColor: CustomTheme.circle_green,
                child: const Center(
                  child: Icon(
                    Icons.done,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Patient Added Successfully",
                style: TextStyle(color: Colors.black54, fontSize: 18),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
//                        BookedServiceVM model = Provider.of<BookedServiceVM>(context, listen: false);
// model.clearbookedtest();
                      //NavigateController.pagePush(context,    PatientDetailsView(screenType: 1, bookingType: "APP", bookingID: bookingID, data2:{}));
                      // NavigateController.pagePush(context, PaymentView(bookingID: bookingID, ScreenType: 3, bookingType: 'APP', nextpage:  PatientDetailsView(screenType: 1, bookingType: 'APP', bookingID:bookingID, regdate: regdate, ), ));
                      NavigateController.pagePush(
                          context,
                          PaymentView(
                            bookingID: bookingID,
                            ScreenType: 3,
                            bookingType: 'APP',
                            nextpage: const HomeView(),
                          ));
                      setState(() {
                        iscompleted = true;
                      });
                      //NavigateController.pagePush(context,AppointmentView());
                    },
                    child: const Center(
                      child: Text(
                        "Next",
                        style: TextStyle(
                            color: Color(0xff2454FF),
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(width: width * 0.03),
                  InkWell(
                    onTap: () {
                      // didPop();
//                        BookedServiceVM model = Provider.of<BookedServiceVM>(context, listen: false);
// model.clearbookedtest();
                      // NavigateController.pagePOP(context);
                      NavigateController.pageReplace(
                          context, const NewBookingView());
                      setState(() {
                        iscompleted = true;
                        listOfTestcount = 0;
                      });
                      // NavigateController.pagePOP(context);
                    },
                    child: const Center(
                      child: Text(
                        "Back",
                        style: TextStyle(color: Colors.black54, fontSize: 15),
                      ),
                    ),
                  ),
                  SizedBox(width: width * 0.12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget doctorField(width, height, String title) {
    return Column(
      children: [
        SizedBox(
          width: width * 0.9,
          // height: height * 0.078,
          child: TextFormField(
            readOnly: true,
            controller: doctorName,
            onTap: () {
              Navigator.pushNamed(context, "SearchDoctorReferral")
                  .then((value) {
                if (value != null) {
                  if (value != false) {
                    Map<String, dynamic> data = value as Map<String, dynamic>;
                    print(data);
                    doctorName.text = data['name'].toString();
                    setState(() {
                      physicianName = data['name'].toString();
                      physicanNo = int.parse(data['id'].toString());
                    });
                  }
                  print(value);
                }
              });
            },
            decoration: InputDecoration(
                // filled: true,
                // focusColor: const Color(0xffEFEFEF),
                errorStyle: const TextStyle(
                  color: Colors.transparent,
                  fontSize: 0,
                ),
                errorBorder: outline,
                focusedErrorBorder: outline,
                enabledBorder: outline,
                focusedBorder: outline,
                label: Text(
                  title,
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                )),
          ),
        ),
      ],
    );
  }

  Widget setAddressPOPUP(
      BuildContext context, height, width, String adress, datas) {
    print(datas);
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: height * 0.69,
          width: width * 0.89,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(15.0)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: height * 0.01),
                Stack(
                  children: [
                    Positioned(
                        right: width * 0.04,
                        top: height * 0.004,
                        child: const Visibility(
                            visible: false,
                            child: Icon(
                              Icons.zoom_out_map,
                              color: Colors.black54,
                              size: 20,
                            ))),
                    const Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Current Location",
                          style: TextStyle(color: Colors.black54, fontSize: 18),
                        )),
                  ],
                ),
                SizedBox(height: height * 0.01),
                const Divider(
                  color: Colors.black12,
                  thickness: 1,
                ),
                SizedBox(height: height * 0.01),
                SizedBox(
                  height: height * 0.4,
                  width: width * 0.8,
                  child: currentLoc == null
                      ? const Center(child: CircularProgressIndicator())
                      : GoogleMap(
                          // zoomGesturesEnabled: true, //enable Zoom in, out on map
                          initialCameraPosition: CameraPosition(
                            //innital position in map
                            target: LatLng(currentLoc!.latitude,
                                currentLoc!.longitude), //initial position
                            zoom: 17.0, //initial zoom level
                          ),
                          // markers: markers, //markers to show on map
                          // polylines: Set<Polyline>.of(polylines.values), //polylines
                          mapType: MapType.normal,
                          markers: markers,
                          myLocationEnabled: true, //map type
                          myLocationButtonEnabled: true,
                          onMapCreated: (controller) {
                            _controller.complete(
                                controller); // method called when map is created
                            setState(() {
                              mapController = controller;
                            });
                          },
                        ),
                ),
                SizedBox(height: height * 0.01),
                Row(
                  children: [
                    SizedBox(
                      width: width * 0.04,
                    ),
                    const Text(
                      "Address",
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.01),
                SizedBox(
                  width: width * 0.8,
                  height: height * 0.078,
                  child: TextFormField(
                    initialValue: adress,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(top: 5, left: 7),
                      enabledBorder: outline,
                      focusedBorder: outline,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.01),
                InkWell(
                  onTap: () {
                    address.text =
                        "${datas['street'] != "" ? "${datas['street']}," : ""}${datas['state']}";
                    pincode.text = datas['postalCode'].toString();
                    area.text = datas['locality'].toString();
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 35,
                    width: 100,
                    decoration: BoxDecoration(
                        color: CustomTheme.background_green,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black26,
                              offset: Offset(1, 2),
                              blurRadius: 6)
                        ]),
                    child: const Center(
                        child: Icon(
                      Icons.done,
                      color: Colors.white,
                    )),
                  ),
                ),
                SizedBox(height: height * 0.01),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _scrollIndicator(BuildContext context, double height, double width) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: SizedBox(
            height: 70,
            width: 400,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(
                  width: 25,
                ),
                Text(
                  "Loading....",
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> selectDate(BuildContext context, selectedDate1) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        // helpText: "DOB",
        initialDate: selectedDate1,
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        firstDate: DateTime(1925, 8),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 30),
            child: Theme(
              data: ThemeData.light().copyWith(
                primaryColor: CustomTheme.circle_green,
                buttonTheme:
                    const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                colorScheme:
                    ColorScheme.light(primary: CustomTheme.circle_green)
                        .copyWith(secondary: CustomTheme.circle_green),
                dialogTheme: const DialogTheme(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)))),
              ),
              child: child!,
            ),
          );
        });
    if (picked != null && picked != selectedDate1) {
      DateFormat year = DateFormat('yyyy');
      var ag = year.format(picked);

      var now = year.format(DateTime.now());
      setState(() {
        selectedDate = picked;
        dob.text = dateformat.format(picked).toString();
        age.text = (int.parse(now) - int.parse(ag)).toString();
      });
    }
  }
}

class Title {
  String title;
  Title(this.title);
}

final List<Title> titleList = [
  Title("Mr. "),
  Title("Mrs. "),
  Title("Ms. "),
  Title("Dr. "),
  Title("Master. "),
  Title("Baby. "),
  Title("Prof. "),
  Title("Baby of. "),
  Title("Miss. "),
  Title("Er. "),
  Title("Sis. "),
];

class Gender {
  String gender;
  Gender(this.gender);
}

final List<Gender> genderList = [
  Gender("Male"),
  Gender("Female"),
];

List<String> titleee = ["Mr. ", "Mrs. ", "Ms. ", "Miss. ", "Sis. "];

final Map<String, String> titleToGenderMapping = {
  "Mr. ": "Male",
  "Mrs. ": "Female",
  "Ms. ": "Female",
  "Miss. ": "Female",
  "Sis. ": "Female",
};

class Referral {
  String type;
  Referral(this.type);
}

final List<Referral> referralList = [
  Referral("Self"),
  Referral("Doctor"),
  // Referral("Client"),
];
