import 'package:botbridge_green/MainData.dart';
import 'package:botbridge_green/Model/ApiClient.dart';
import 'package:botbridge_green/View/Helper/ErrorPopUp.dart';
import 'package:botbridge_green/View/PatientDetailsView.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import '../Model/ServerURL.dart';
import '../Model/Status.dart';
import '../Utils/LocalDB.dart';
import '../Utils/NavigateController.dart';
import '../ViewModel/SampleWiseServiceVM.dart';
import 'Helper/ThemeCard.dart';



class BarcodePage extends StatefulWidget {
  final String bookingType;
  final String bookingID;
  final int screentype;
  final bool ispaid;
    final String regdate;

  const BarcodePage({Key? key, required this.bookingType, required this.bookingID, required this.screentype, required this.ispaid, required this.regdate}) : super(key: key);

  @override
  _BarcodePageState createState() => _BarcodePageState();
}

class _BarcodePageState extends State<BarcodePage> {
  final SampleWiseServiceDataVM _api = SampleWiseServiceDataVM();
  String? scanResult;
  String latitude = "";
  String longitude = "";
      DateTime currentdate = DateTime.now();

TextEditingController Qrtext =TextEditingController();



void updateStatus(height,width)async{
   var userno = await LocalDB.getLDB("userID") ?? "";

    var venueNo = await LocalDB.getLDB("venueNo") ?? "";
    var venueBranchNo = await LocalDB.getLDB("venueBranchNo") ?? "";

    Map<String,dynamic> params =
      {
        "userNo": userno,
        "venueNo": venueNo,
        "venueBranchNo": venueBranchNo,
        "reason": "",
        "bookingID": widget.bookingID,
        "bookingStatus": MainData.statusArrival
    };
    String url = ServerURL().getUrl(RequestType.UpdatePatientStatus);
    ApiClient().fetchData(url, params).then((response){
            if(response["status"]==1){
              successStatusPOPUP(context, height, width, "The patient status Updated!", PatientDetailsView(screenType: 4, bookingType: 'SAMPLE', bookingID: widget.bookingID, regdate: widget.regdate,));

            }else{
                  Navigator.pop(context);
        errorPopUp(context);
            }
    });
}



 getData() async {
    LocalDB.getLDB( "latitude").then((value) {
      setState(() {
        latitude =value;
      print("latitude: $latitude");
   

      });
    });


    LocalDB.getLDB("longitude").then((value) {
      setState(() {
        longitude =value;
       print(longitude);
      });
    });

  }
  @override
  void initState() {
    getData();
    // TODO: implement initState

    LocalDB.getLDB('userID').then((value) {
      print("Appointviewuserid $value");
      Map<String,dynamic> params1 = {
        "bookingID": widget.bookingID,
        "userNo":value,
        "type": widget.bookingType,
        "mobileNumber":"",
          "registerdDateTime": widget.regdate
      
      };
      _api.fetchSampleWiseTest(params1);  //fetchSampleWiseTest
    });

    // Map<String,dynamic> params = {
    //   "BookingID":widget.bookingID,
    //    "userNO": 2,
    // };
    // _api.fetchSampleWiseTest( params);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xffEFEFEF),
            body: WillPopScope(
                onWillPop: ()async {
            print("working-----------------------");
     NavigateController.pagePushLikePop(context, PatientDetailsView(screenType: widget.screentype, bookingType: widget.bookingType, bookingID: widget.bookingID, regdate: widget.regdate,));
    return false;
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
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(height * 0.6/25))
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  left: width * 0.02,
                                  top: height * 0.02,
                                  child: GestureDetector(
                                      onTap: (){
                                        print('Start');
     NavigateController.pagePushLikePop(context, PatientDetailsView(screenType: widget.screentype, bookingType: widget.bookingType, bookingID: widget.bookingID, regdate: widget.regdate,));
                                      },
                                      child: const Icon(Icons.arrow_back_ios,color: Colors.white,)),
                                ),
                                const Align(
                                  alignment: Alignment.center,
                                  child: Text("Sample Wise Test",style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.w600),),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height * 0.86,
                      child: SizedBox(
                        width: width * 0.96,
                        child:  ChangeNotifierProvider<SampleWiseServiceDataVM>(
                          create: (BuildContext context) => _api,
                          child: Consumer<SampleWiseServiceDataVM>(builder: (context, viewModel, _) {
                            switch (viewModel.getAddToCart.status) {
                              case Status.Loading:
                                return  const Center(child: CircularProgressIndicator());
                              case Status.Error:
                                return  const Text("No Data",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),);
                              case Status.Completed:
                              // updateData();
                              print("hello");
                                var VM = viewModel.getAddToCart.data!;
                                return
                                  VM.lstPatientResponse == null  ?  const Center(child:Center(child: Text("No Record Found",style: TextStyle(fontWeight: FontWeight.bold),),))  :
                                  VM.lstPatientResponse!.isEmpty  ? const Center(child:Center(child: Text("No Record Found",style: TextStyle(fontWeight: FontWeight.bold),),))  :
                                  VM.lstPatientResponse![0].lstTestSampleWise == null ?
                                  const SizedBox() :
                                  VM.lstPatientResponse![0].lstTestSampleWise!.isEmpty ?
                                  const SizedBox() :
                                  Column(
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
                                                        physics:const NeverScrollableScrollPhysics(),
                                                        shrinkWrap: true,
                                                        itemCount: VM.lstPatientResponse![0].lstTestSampleWise!.length,
                                                        itemBuilder: (BuildContext context,index){
                                                          return  Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  color: Colors.white,
                                                                  borderRadius:const BorderRadius.all(Radius.circular(15)
                                                                  ),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors.black45.withOpacity(0.2),
                                                                      blurRadius: 8,
                                                                      offset: const Offset(4, 8),
                                                                    ),
                                                                  ]
                                                              ),
                                                              child: ListTile(
                                                                  leading:  CircleAvatar(
                                                                      radius: 20,
                                                                      backgroundColor: Colors.transparent,
                                                                      child: Image.asset('assets/images/qr-code_new.gif',height: height*0.05)),
                                                                  title:  Text(
                                                                    "${VM.lstPatientResponse![0].lstTestSampleWise![index].testName}",
                                                                    style: const TextStyle(fontWeight: FontWeight.w600,color:  Color(0xff182893)),
                                                                  ),
                                                                  subtitle: const Text(
                                                                    "Tap to Scan",
                                                                    style: TextStyle(
                                                                        color: Colors.black87, fontWeight: FontWeight.w400),
                                                                  ),
                                                                  onTap: () {

                                                                    showRequest(context, "SCAN", VM.lstPatientResponse![0].lstTestSampleWise![index].bookingId!, height, width, VM.lstPatientResponse![0].lstTestSampleWise![index].testNo, VM.lstPatientResponse![0].lstTestSampleWise![index].sampleNo);

                                                                    // _barscanner(VM.lstPatientResponse![0].lstTestSampleWise![index].testNo,VM.lstPatientResponse![0].lstTestSampleWise![index].bookingId,VM.lstPatientResponse![0].lstTestSampleWise![index].sampleNo,height,width);
                                                                    print(VM.lstPatientResponse![0].lstTestSampleWise![index].testNo);
                                                                    print(VM.lstPatientResponse![0].lstTestSampleWise![index].bookingId);
                                                                    print(VM.lstPatientResponse![0].lstTestSampleWise![index].sampleNo);
            
        
                                                                  },
                                                                  trailing:VM.lstPatientResponse![0].lstTestSampleWise![index].barcodeNo.toString()=="null" || VM.lstPatientResponse![0].lstTestSampleWise![index].barcodeNo.toString()==""? Column(children: [ Image.asset("assets/images/info-ani.gif",height: 35,),const Text("Add Barcode", style: TextStyle(color: Colors.red),)],):
                                                                   Text("Barcode No :${VM.lstPatientResponse![0].lstTestSampleWise![index].barcodeNo}"),
                                                                  ),
                                                            ),
                                                          );
                                                        } 
                                                        ),
                                                  )
                                                ],
                                              ),
                                            

                                          
                                            ],
                                          ),
                                        ),
                                      ),
                                   
                                      const Spacer(),
                                          widget.screentype==1?
                                            InkWell(
                                                  onTap: () {
                                                    alertpopup(context, height, width, "Make sure all Barcodes are added!");
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
                                                        'Submit',
                                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                                      ),
                                                    ),
                                                  ),
                                                ):const SizedBox(),
                                                SizedBox(height: height*0.03,)
                                    ],
                                  );
            
                              default:
                            }
                            return Container();
                          }),
                        ),
            
            
                      ),
                    ),
                  ],
                ),
              ),
            )
    ));
  }

  Future<void> _barscanner(testname, bookingid, sampleno,hight,width) async {
  String scanResult;
  try {
    scanResult = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", true, ScanMode.BARCODE);
  } on PlatformException {
    scanResult = "Failed";
  }
  if (!mounted) return;

  setState(() {
    this.scanResult = scanResult;
  });

  // Show your custom confirmation dialog
  bool shouldUpload = await showDialog(
    context: context,
    builder: (context) {
      return QRalart(context, hight, width,);
    });

  if (shouldUpload ) {
    Map<String, dynamic> params = {
      "lstBarcode": [
        {"sampleNo": sampleno, "barcodeNo": scanResult.toString()}
      ],
      "test_id": testname ?? "",
      "bookingID": bookingid
    };
    dynamic response = await ApiClient().fetchData(ServerURL().getUrl(RequestType.ValidatePrePrintedBarcode), params);
    print("barcode success $response");
    Fluttertoast.showToast(
      msg: "Uploaded..",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black45,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }
}

 showRequest( BuildContext context,String title,String bookingID,hight,width,testname, sampleno,){
   QuickAlert.show(
 context: context,
 type:QuickAlertType.confirm,
//  customAsset: "assets/images/QR-scan.gif",
 text: title,
 confirmBtnText: 'Sacn',
 cancelBtnText: 'Manual',
 onConfirmBtnTap: (){
  _barscanner(testname, bookingID, sampleno, hight, width);

 },
 onCancelBtnTap: (){
  _manualSacn(testname, bookingID, sampleno, hight, width);
 },
 confirmBtnColor: Colors.green,
);
  }




    Widget QRalart(BuildContext context,height,width){
    Color textBorder = const Color(0xff0272B1);
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          height:height * 0.18,
          width: width * 0.7,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0)
          ),
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const Text("Confirm Barcode Upload",style: TextStyle(color:Colors.black54,fontSize: 18),),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: (){
    NavigateController.pagePushLikePop(context, BarcodePage(bookingType: widget.bookingType, bookingID: widget.bookingID, screentype: widget.screentype, ispaid: widget.ispaid, regdate: widget.regdate,));
                    },
                    child: const Center(
                      child: Text( "Yes",style: TextStyle(color:Color(0xff2454FF),fontSize: 15,fontWeight: FontWeight.w600),),
                    ),
                  ),
                  SizedBox(width: width * 0.03),
                  InkWell(
                    onTap: (){
                     Navigator.of(context).pop(false);
                    },
                    child: const Center(
                      child: Text( "No",style: TextStyle(color: Colors.black54,fontSize: 15),),
                    ),
                  ),
                  SizedBox(width: width * 0.12,),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

    void  successStatusPOPUP(BuildContext context,double height,double width,content,page){
      print("called");


QuickAlert.show(
 context: context,
 type:QuickAlertType.success,
//  customAsset: "assets/images/ok_popup.gif",

 text: content,
 confirmBtnText: 'Next',
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


/// alert
 void  alertpopup(BuildContext context,double height,double width,content){
      print("called");


QuickAlert.show(
 context: context,
 type:QuickAlertType.info,
//  customAsset: "assets/images/ok_popup.gif",

 text: content,
 confirmBtnText: 'Next',
//  cancelBtnText: 'No',
 onConfirmBtnTap: (){
  updateStatus(height, width);
 },
//  onCancelBtnTap: (){
//   NavigateController.pagePOP(context);
//  },
 confirmBtnColor: Colors.green,
);


}

//success 
/// alert
 void  successpop(BuildContext context,double height,double width,content,page){
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


void _manualSacn(testname, bookingid, sampleno,hight,width){

  QuickAlert.show(
  context: context,
  type: QuickAlertType.custom,
  barrierDismissible: true,
  confirmBtnText: 'Save',
  // customAsset: 'assets/images/qr-code_new.gif',
  
  widget: TextFormField(
    controller: Qrtext,
  decoration: const InputDecoration(
     alignLabelWithHint: true,
     
     hintText: 'Barcode Number',
     prefixIcon: Icon(
     Icons.barcode_reader,
     ),
    ),
    textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
    ),
    onConfirmBtnTap: () async {
     if (Qrtext.text.isEmpty) {
      await QuickAlert.show(
       context: context,
       type: QuickAlertType.error,
       text: 'Please input something',
      );
      return;
    }
    else if(Qrtext.text.isNotEmpty){
  Map<String, dynamic> params = {
      "lstBarcode": [
        {"sampleNo": sampleno, "barcodeNo": Qrtext.text.toString()}
      ],
      "test_id": testname ?? "",
      "bookingID": bookingid
    };
    print(params);
    dynamic response = await ApiClient().fetchData(ServerURL().getUrl(RequestType.ValidatePrePrintedBarcode), params);
    successpop(context, hight, width, "The barcode is Added!",BarcodePage(bookingType: widget.bookingType, bookingID: widget.bookingID, screentype: widget.screentype, ispaid: widget.ispaid, regdate: widget.regdate,));
        // NavigateController.pagePushLikePop(context, BarcodePage(bookingType: widget.bookingType, bookingID: widget.bookingID, screentype: widget.screentype, ispaid: widget.ispaid));

    print("barcode success $response");
    Fluttertoast.showToast(
      msg: "Uploaded..",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black45,
      textColor: Colors.white,
      fontSize: 14.0,
    );
    }
    // Navigator.pop(context);
    //  await Future.delayed(const Duration(milliseconds: 1000));
    //  await QuickAlert.show(
    //   context: context,
    //   type: QuickAlertType.success,
    //   text: "QR has been saved!.",
    //  );
    },
  );
 

}

}
