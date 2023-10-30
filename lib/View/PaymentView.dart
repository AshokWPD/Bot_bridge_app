import 'dart:convert';

import 'package:botbridge_green/Model/Response/AppoitmentAndRequestData.dart';
import 'package:botbridge_green/Model/ServerURL.dart';
import 'package:botbridge_green/Utils/LocalDB.dart';
import 'package:botbridge_green/View/AppointmentView.dart';
import 'package:botbridge_green/View/HomeView.dart';
import 'package:botbridge_green/View/PatientDetailsView.dart';
import 'package:botbridge_green/View/upipayView.dart';
import 'package:botbridge_green/ViewModel/PatientDetailsVM.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Model/ApiClient.dart';
import '../Utils/NavigateController.dart';
import '../ViewModel/BookedServiceVM.dart';
import 'Helper/LoadingIndicator.dart';
import 'Helper/ThemeCard.dart';
import 'NewRequestView.dart';
import 'package:http/http.dart'as http;


class PaymentView extends StatefulWidget {
  final String bookingID;
  final String bookingType;
  int ScreenType;
  final nextpage;
   PaymentView({Key? key, required this.bookingID, required this.ScreenType, required this.bookingType, required this.nextpage}) : super(key: key);

  @override
  _PaymentViewState createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  bool isFetching = true;


 AppointmentAndRequestData? data;




  TextEditingController editAmount = TextEditingController();
  int totalPayAmount=0;
  int grossPayAmount=0;
  int discountAmount=0;
  bool isOther = false;
  bool isCheque = false;
  int paymentCheckbox = 1;
  int amountCheckbox = 0;
  Color container = Colors.white;
    DateTime currentdate = DateTime.now();


//   getData() {
//     BookedServiceVM model = Provider.of<BookedServiceVM>(
//         context, listen: false);
//     setState(() {
//      totalPayAmount = model.getBookedService.data?.lstPatientResponse?[0]?.totalTestAmount?.toInt() ?? 0;
// grossPayAmount = model.getBookedService.data?.lstPatientResponse?[0]?.totalTestAmount?.toInt() ?? 0;

//     });
//   }
@override
  void initState() {
    fetchData(widget.bookingID);

    // TODO: implement initState
    super.initState();
  }
                LstPatientResponse? patient;

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
      "registerdDateTime": "$currentdate"

    });

     
    final response = await http.post(url, headers: headers, body: requestBody);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      setState(() {
        data = AppointmentAndRequestData.fromJson(jsonResponse);

        isFetching=false;
  patient = data!.lstPatientResponse![0];

                totalPayAmount=(patient!.totalTestAmount!.toInt());
  grossPayAmount =(patient!.totalTestAmount!.toInt());

      });
      print("price:::::::${patient!.totalTestAmount!.toInt()}");

    } else {
      throw Exception('Failed to load data');
    }
  }


  @override
  Widget build(BuildContext context) {

    if(isFetching==false){
      if (data != null && data!.lstPatientResponse != null && data!.lstPatientResponse!.isNotEmpty) {
  patient = data!.lstPatientResponse![0];
} else {
  patient = null;
}
setState(() {
  // totalPayAmount=(data!.lstPatientResponse==null?0:patient!.totalTestAmount!.toInt());
  // grossPayAmount =(data!.lstPatientResponse==null?0:patient!.totalTestAmount!.toInt());
  print(totalPayAmount);
});
    }


    // BookedServiceVM vm = Provider.of<BookedServiceVM>(context);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
        child: GestureDetector(
          onTap: ()=>FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: const Color(0xffEFEFEF),
            body:Column(
              children: [
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
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
                                        if(widget.ScreenType == 1){
                                          NavigateController.pagePushLikePop(context,  const AppointmentView());
                                        }else if(widget.ScreenType == 2){
                                          NavigateController.pagePushLikePop(context, const NewRequestView());
                                        }else{
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: const Icon(Icons.arrow_back_ios,color: Colors.white,)),
                                ),
                              ),
                              const Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.all(11),
                                  child: Text("Payment Details",style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.w600),),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: height * 0.03),
                        Container(
                          height: height * 0.25,
                          width: width * 0.9,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(height * 0.3/10),
                            color: Colors.white
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: height * 0.01),
                              Row(
                                children: [
                                  SizedBox(width: width * 0.04,),
                                  const Text("Amount to pay",style: TextStyle(color: Color(0xff203298),fontWeight: FontWeight.w600),),
                                ],
                              ),
                              SizedBox(height: height * 0.01),
                              Row(
                                children: [
                                  SizedBox(width: width * 0.1,),
                                  const Text("Gross Amount: ",style: TextStyle(color: Colors.black54,fontWeight: FontWeight.w600),),
                                   Text("₹$grossPayAmount",style: const TextStyle(color: Color(0xff203298),fontWeight: FontWeight.w600),),

                                ],
                              ),
                              SizedBox(height: height * 0.01),
                              Row(
                                children: [
                                  SizedBox(width: width * 0.1,),
                                  const Text("Discount Amount",style: TextStyle(color:  Colors.black54,fontWeight: FontWeight.w600),),
                                  SizedBox(width: width * 0.02,),
                                  SizedBox(
                                      height: height* 0.04,
                                      width: width * 0.3,
                                      child: TextFormField(
                                        style: const TextStyle(fontSize: 12),
                                        cursorColor: Colors.black54,
                                        controller: editAmount,
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          print(value);
            
                                          if(value.isNotEmpty){
                                                setState(() {
                                                totalPayAmount =
                                                (grossPayAmount - int.parse(value));
                                              });
                                            
                                          }

                                        },
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.only(bottom: 3,left: 8),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            borderSide: const BorderSide(color: Colors.black54)
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(20),
                                              borderSide: const BorderSide(color: Colors.black54)
                                          ),
                                        ),
                                      ))
                                ],
                              ),
                              SizedBox(height: height * 0.03),
                              Row(
                                children: [
                                  SizedBox(width: width * 0.04,),
                                  const Text("Total Amount to pay: ",style: TextStyle(color:Color(0xff203298),fontWeight: FontWeight.w600),),
                                   Text("₹$totalPayAmount",style: const TextStyle(color: Colors.black54,fontWeight: FontWeight.w600),),

                                ],
                              ),
                              SizedBox(height: height * 0.01),
                              Row(
                                children: [
                                  SizedBox(width: width * 0.04,),
                                  const Text("Other Pay Amount",style: TextStyle(color:Color(0xff203298),fontWeight: FontWeight.w600),),
                                  SizedBox(width: width * 0.02,),
                                  SizedBox(
                                      height: height* 0.04,
                                      width: width * 0.3,
                                      )
                                ],
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        Row(
                          children: [
                            SizedBox(width: width * 0.06,),
                            const Text("Preferred Payment",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),),
                          ],
                        ),
                        SizedBox(height: height * 0.01),
                        Container(
                          height: height * 0.23,
                          width: width * 0.9,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(height * 0.3/10),
                              color: Colors.white
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: height * 0.03),
                              Row(
                                children: [
                                  SizedBox(width: width * 0.04,),
                                  const Icon(Icons.wysiwyg,size: 15,color: Colors.grey,),
                                  SizedBox(width: width * 0.004,),
                                  const Text("Google Pay",style: TextStyle(color: Colors.black38,fontSize: 14),),
                                  const Spacer(),
                                  Container(
                                    height: height * 0.02,
                                    width:  height * 0.02,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: CustomTheme.circle_green,
                                    ),
                                  ),
                                  SizedBox(width: width * 0.04,),
                                ],
                              ),
                              SizedBox(height: height * 0.01),
                              InkWell(
                                onTap:()async{
                                  Navigator.push(context, MaterialPageRoute(builder:(context) => upi_pay_view(bookingID: widget.bookingID, amount: totalPayAmount, bookingType: 1,),));

                                },
                                child: Container(
                                  height: 35,
                                  width:200,
                                  decoration: BoxDecoration(
                                      color: CustomTheme.background_green,
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Colors.black26,
                                            offset: Offset(1,2),
                                            blurRadius: 6
                                        )
                                      ]
                                  ),
                                  child: const Center(
                                    child: Text('Pay Via GPay',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),),
                                  ),
                                ),
                              ),
                              SizedBox(height: height * 0.01),
                             const Divider(color: Colors.black12,thickness: 1,),
                             
                              SizedBox(height: height * 0.02),
                              Row(
                                children: [
                                  SizedBox(width: width * 0.04,),
                                  const Icon(Icons.wysiwyg,size: 15,color: Colors.grey,),
                                  SizedBox(width: width * 0.004,),
                                  const Text("xxx2929",style: TextStyle(color: Colors.black38,fontSize: 14),),
                                  const Spacer(),
                                  Container(
                                    height: height * 0.02,
                                    width:  height * 0.02,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      border: Border.all(color: Colors.black54)
                                    ),
                                  ),
                                  SizedBox(width: width * 0.04,),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: height * 0.03),
                        Row(
                          children: [
                            SizedBox(width: width * 0.06,),
                            const Text("UPI",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),),
                          ],
                        ),
                        SizedBox(height: height * 0.01),
                        Container(
                          height: height * 0.18,
                          width: width * 0.9,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(height * 0.3/10),
                              color: Colors.white
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: height * 0.03),
                              InkWell(
                                onTap:(){
                                  Navigator.push(context, MaterialPageRoute(builder:(context) => upi_pay_view(bookingID: widget.bookingID, amount: totalPayAmount, bookingType: 1,),));
                                  // await  paytmTransaction(paytmapp);

                                },
                                child: Row(
                                  children: [
                                    SizedBox(width: width * 0.04,),
                                    const Icon(Icons.wysiwyg,size: 15,color: Colors.blue,),
                                    SizedBox(width: width * 0.004,),
                                    const Text("Paytm UPI",style: TextStyle(color: Colors.blue,fontSize: 14),),
                                    const Spacer(),
                                    Image.asset("assets/images/paytm-icon.png",scale: 10,),
                                    SizedBox(width: width*0.07,)
                              
                                  ],
                                ),
                              ),
                              SizedBox(height: height * 0.01),
                              const Divider(color: Colors.black12,thickness: 1,),
                              SizedBox(height: height * 0.02),
                              Row(
                                children: [
                                  SizedBox(width: width * 0.04,),
                                  Container(
                                    height: height * 0.035,
                                    width:  width * 0.12,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xff203298))
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.add,color: Color(0xff203298),size: 17,),
                                    ),
                                  ),
                                  SizedBox(width: width * 0.02,),
                                  const Text("ADD NEW UPI ID",style: TextStyle(color: Colors.black38,fontSize: 14),),
                                  const Spacer(),

                                  SizedBox(width: width * 0.04,),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: height * 0.03),
                        Row(
                          children: [
                            SizedBox(width: width * 0.06,),
                            const Text("Credit & Debit Card",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),),
                          ],
                        ),
                        SizedBox(height: height * 0.01),
                        Container(
                          height: height * 0.1,
                          width: width * 0.9,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(height * 0.3/10),
                              color: Colors.white
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  SizedBox(width: width * 0.04,),
                                  Container(
                                    height: height * 0.035,
                                    width:  width * 0.12,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xff203298))
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.add,color: Color(0xff203298),size: 17,),
                                    ),
                                  ),
                                  SizedBox(width: width * 0.02,),
                                  const Text("ADD CARD",style: TextStyle(color: Colors.black38,fontSize: 14),),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: height * 0.03),
                        Row(
                          children: [
                            SizedBox(width: width * 0.06,),
                            const Text("More Payment Option",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),),
                          ],
                        ),
                        SizedBox(height: height * 0.01),
                        Container(
                          height: height * 0.15,
                          width: width * 0.9,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(height * 0.3/10),
                              color: Colors.white
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: (){
                                  setState(() {
                                    isCheque = !isCheque;
                                  });
                                },
                                child: SizedBox(
                                  child: InkWell(
                                    onTap:()async{
                                  Navigator.push(context, MaterialPageRoute(builder:(context) => upi_pay_view(bookingID: widget.bookingID, amount: totalPayAmount, bookingType: 1,),));

                                },
                                    child: Row(
                                      children: [
                                        SizedBox(width: width * 0.04,),
                                        const Icon(Icons.wysiwyg,size: 15,color: Colors.grey,),
                                        SizedBox(width: width * 0.004,),
                                        const Text("Amazon Pay",style: TextStyle(color: Colors.black38,fontSize: 14),),
                                         const Spacer(),
                                      Image.asset("assets/images/amazon-pay-icon.png",scale: 7,),
                                      SizedBox(width: width*0.07,)
                                  
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: height * 0.01),
                              const Divider(color: Colors.black12,thickness: 1,),
                              SizedBox(height: height * 0.01),
                              InkWell(
                                onTap: (){
                                  showDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (_) => paymentAlert(context,height,width,"CASH")
                                  );
                                },
                                child: SizedBox(
                                  child: Row(
                                    children: [
                                      SizedBox(width: width * 0.04,),
                                      const Icon(Icons.wysiwyg,size: 15,color: Colors.grey,),
                                      SizedBox(width: width * 0.004,),
                                      const Text("Pay On Delivery",style: TextStyle(color: Colors.black38,fontSize: 14),),
                                      const Spacer(),
                                      const Icon(Icons.done,color: Colors.green,size: 18,),
                                      SizedBox(width: width * 0.04,),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: height * 0.02),
                        isCheque ?
                        Container(
                          width: width * 0.9,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(height * 0.3/10),
                              color: Colors.white
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: height * 0.02),
                              isChequeCard(
                                width, height, "Cheque No", TextInputType.number,),
                              SizedBox(height: height / 50),
                              isChequeCard(
                                width, height, "Cheque Date", TextInputType.name,),
                              SizedBox(height: height / 50),
                              isChequeCard(
                                width, height, "Bank Name", TextInputType.name,),
                              SizedBox(height: height * 0.02),
                              InkWell(
                                onTap: (){
                                },
                                child: Container(
                                  height: 40,
                                  width:140,
                                  decoration: BoxDecoration(
                                      color: CustomTheme.background_green,
                                      borderRadius: BorderRadius.circular(30)
                                  ),
                                  child: const Center(
                                    child: Text('Submit Payment',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600,fontSize: 13),),
                                  ),
                                ),
                              ),
                              SizedBox(height: height * 0.02),
                            ],
                          ),
                        ) :
                        const SizedBox(),
                        SizedBox(height: height * 0.02),
                      ],
                    ),
                  ),
                ),
              ],
            ) ,
          ),
        ));
  }
  submitPayment(height,width,String paytype) async {
    var userNo = await LocalDB.getLDB('userID');
    int disAmount = editAmount.text.isEmpty ? 0 : int.parse(editAmount.text);

    // BookedServiceVM model1 = Provider.of<BookedServiceVM>(context, listen: false);

    // var listOfTest = model1.getNewBookData;

    // print("listof test $listOfTest");
    // BookedServiceVM model = Provider.of<BookedServiceVM>(
    //     context, listen: false);

    int NetAmount = totalPayAmount;

    Map<String, dynamic> params = {
      "bookingID": widget.bookingID,
      //hide "PhileBotomyID": userNo,
      // "RequestFrom": "PHIL",
      "grossAmount":grossPayAmount,
      "discountAmount": disAmount,
      "netAmount": NetAmount,
      "paidAmount": NetAmount,
      "collectedAmount": NetAmount
      // "Amount": NetAmount
    };

    Map<String, dynamic> jsonObj = {};
    jsonObj["paymentType"] = paytype;
    jsonObj["amount"] = NetAmount;
 

    params["lstPaymentDetails"] = [jsonObj];
    print("page responce $params");
    scrollIndicator( context,height,width);
    ApiClient()
        .fetchpayment(ServerURL().getUrl(RequestType.InsertPayment), params)
        .then((value) {
          print("fetch value$value");
      Navigator.pop(context);
      if (value["status"] == 1) {

        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => WillPopScope(onWillPop: ()=>NavigateController.disableBackBt(),
            child: successStatusPOPUP(context,height,width,0,''))
        );
      } else {
        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (_) => WillPopScope(onWillPop: ()=>NavigateController.disableBackBt(),
                child: successStatusPOPUP(context,height,width,1,value['message'] ?? "Failed"))
        );
      }
    });
  }

  Widget paymentAlert(BuildContext context,height,width,String paytype){
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
              const Text("Confirm Payment",style: TextStyle(color:Colors.black54,fontSize: 18),),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: (){
                      Navigator.pop(context);
                      submitPayment(height,width,paytype);
                    },
                    child: const Center(
                      child: Text( "Yes",style: TextStyle(color:Color(0xff2454FF),fontSize: 15,fontWeight: FontWeight.w600),),
                    ),
                  ),
                  SizedBox(width: width * 0.03),
                  InkWell(
                    onTap: (){
                      NavigateController.pagePOP(context);

                    },
                    child: const Center(
                      child: Text( "No",style: TextStyle(color: Colors.black54,fontSize: 15),),
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

  
  Widget successStatusPOPUP(BuildContext context,height,width,int type,content){

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          height:height * 0.24,
          width: width * 0.82,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0)
          ),
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor:type == 0 ? CustomTheme.circle_green : Colors.redAccent,
                child:  Center(
                  child: Icon(type == 0 ?Icons.done:Icons.clear,color: Colors.white,),
                )
              ),
              const SizedBox(height: 10),
               Text(type == 0 ? "Payment submitted successfully" : content,style: const TextStyle(color:Colors.black54,fontSize: 18,),maxLines: 2,),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: (){
        // NavigateController.pagePush(context, widget.nextpage);

                      type == 0 ? NavigateController.pagePush(context, widget.nextpage) : Navigator.pop(context);
                    },
                    child: const Center(
                      child: Text( "Next",style: TextStyle(color:Color(0xff2454FF),fontSize: 15,fontWeight: FontWeight.w600),),
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
  Widget isChequeCard(width, height, String label, TextInputType keyboard) {
    return SizedBox(
      width: width * 0.78,
      child: TextFormField(
        keyboardType: keyboard,
        cursorColor: Colors.white,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
                color:  Colors.black54 ),
            focusColor: Colors.grey,
            enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black45)),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black45))),
      ),
    );
  }
}