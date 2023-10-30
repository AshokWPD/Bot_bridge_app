import 'dart:core';

import 'package:botbridge_green/Utils/NavigateController.dart';
import 'package:botbridge_green/View/AppointmentView.dart';
import 'package:botbridge_green/View/Helper/ThemeCard.dart';
import 'package:botbridge_green/View/HomeView.dart';
import 'package:botbridge_green/View/PaymentView.dart';
import 'package:flutter/material.dart';
import 'package:upi_india/upi_india.dart';


class upi_pay_view extends StatefulWidget {
  final String bookingID;
   final int amount;
   int bookingType;
   upi_pay_view({super.key,  required this.bookingID, required this.amount, required this.bookingType });


  @override
  _upi_pay_viewState createState() => _upi_pay_viewState();
}

class _upi_pay_viewState extends State<upi_pay_view> {
  Future<UpiResponse>? _transaction;
  final UpiIndia _upiIndia = UpiIndia();
  List<UpiApp>? apps;

  TextStyle header = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  TextStyle value = const TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );

 String bookid='';
 double payamount=0;


  @override
  void initState() {
    setState(() {
      bookid=widget.bookingID;
      payamount=double.parse("${widget.amount}") ;
    });
    _upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value) {
      setState(() {
        apps = value;
      });
    }).catchError((e) {
      apps = [];
    });
    super.initState();
  }


  Future<UpiResponse> initiateTransaction(UpiApp app) async {
    return _upiIndia.startTransaction(
      app: app,
      receiverUpiId: "9791524279@ybl",
      receiverName: 'T. Durai',
      transactionRefId: 'UPI INDIA',
      transactionNote: 'Bot Bridge payment',
      amount: 1.00,
    );
  }


  Widget displayUpiApps() {
    if (apps == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (apps!.isEmpty)
      return Center(
        child: Text(
          "No apps found to handle transaction.",
          style: header,
        ),
      );
    else
      return Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Wrap(
            children: apps!.map<Widget>((UpiApp app) {
              return GestureDetector(
                onTap: () {
                  _transaction = initiateTransaction(app);
                },
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.memory(
                        app.icon,
                        height: 60,
                        width: 60,
                      ),
                      Text(app.name),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
  }

  String _upiErrorHandler(error) {
    switch (error) {
      case UpiIndiaAppNotInstalledException:
        return 'Requested app not installed on device';
      case UpiIndiaUserCancelledException:
        return 'You cancelled the transaction';
      case UpiIndiaNullResponseException:
        return 'Requested app didn\'t return any response';
      case UpiIndiaInvalidParametersException:
        return 'Requested app cannot handle the transaction';
      default:
        return 'An Unknown error has occurred';
    }
  }

  void _checkTxnStatus(String status) {
    switch (status) {
      case UpiPaymentStatus.SUCCESS:
        print('Transaction Successful');
        break;
      case UpiPaymentStatus.SUBMITTED:
        print('Transaction Submitted');
        break;
      case UpiPaymentStatus.FAILURE:
        print('Transaction Failed');
        break;
      default:
        print('Received an Unknown transaction status');
    }
  }

  Widget displayTransactionData(title, body) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title: ", style: header),
          Flexible(
              child: Text(
            body,
            style: value,
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                                        Navigator.pop(context);
                                  // Navigator.push(context, MaterialPageRoute(builder:(context) => PaymentView(bookingID: widget.bookingID,ScreenType: ,),));
                                      
                                      },
                                      child: const Icon(Icons.arrow_back_ios,color: Colors.white,)),
                                ),
                              ),
                              const Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.all(11),
                                  child: Text("UPI Payment",style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.w600),),
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
          Expanded(
            child: displayUpiApps(),
          ),
          Expanded(
            child: FutureBuilder(
              future: _transaction,
              builder: (BuildContext context, AsyncSnapshot<UpiResponse> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        _upiErrorHandler(snapshot.error.runtimeType),
                        style: header,
                      ), // Print's text message on screen
                    );
                  }

                  // If we have data then definitely we will have UpiResponse.
                  // It cannot be null
                  UpiResponse upiResponse = snapshot.data!;

                  // Data in UpiResponse can be null. Check before printing
                  String txnId = upiResponse.transactionId ?? 'Failed';
                  String resCode = upiResponse.responseCode ?? 'Failed';
                  String txnRef = upiResponse.transactionRefId ?? 'Failed';
                  String status = upiResponse.status ?? 'Failed';
                  String approvalRef = upiResponse.approvalRefNo ?? 'Failed';
                  _checkTxnStatus(status);

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        displayTransactionData('Transaction Id', txnId),
                        displayTransactionData('Response Code', resCode),
                        displayTransactionData('Reference Id', txnRef),
                        displayTransactionData('Status', status.toUpperCase()),
                        displayTransactionData('Approval No', approvalRef),
                      ],
                    ),
                  );
                } else {
                  return const Center(
                    child: Text(''),
                  );
                }
              },
            ),
          )
        ],
      ),
    ))]))));
  }
}