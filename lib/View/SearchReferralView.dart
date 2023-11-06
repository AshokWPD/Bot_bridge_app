import 'dart:convert';

import 'package:botbridge_green/Model/Response/ReferalDataList.dart';
import 'package:botbridge_green/Model/ServerURL.dart';
import 'package:botbridge_green/Utils/LocalDB.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart'as http ;
import '../Model/Status.dart';
import '../ViewModel/ReferalDataVM.dart';



class SearchReferralView extends StatefulWidget {
  final String type;
  final String searchType;
  const SearchReferralView({Key? key, required this.type, required this.searchType}) : super(key: key);

  @override
  _SearchReferralViewState createState() => _SearchReferralViewState();
}

class _SearchReferralViewState extends State<SearchReferralView> {
  bool isFetching = true;
  bool nodata=false;
bool iserror=false;
bool nameshow=false;
bool allshow=true;
int userno=0;
  // final ReferalDataVM _api = ReferalDataVM();
    List<LstReferalDetails>? _lastTestDetails=[];
    List<LstReferalDetails>? _filteredData=[]; // Store the list of patients here

    Future<void> fetchData() async {
      print("working-----------------------");
     var venueNo = await LocalDB.getLDB("venueNo") ?? "";
    var venueBranchNo = await LocalDB.getLDB("venueBranchNo") ?? "";
    var userno = await LocalDB.getLDB("userID") ?? "";

    final url = Uri.parse(ServerURL().getUrl(RequestType.GetReferralDetails)); // Replace with your API endpoint
    final headers = {'Content-Type': 'application/json'};
    final requestBody = jsonEncode({
   
"searchKey": "",
"searchType": "physician",
"venueNo": 1,
"venueBranchNo": 1

    });
    print("$requestBody");

    final response = await http.post(url, headers: headers, body: requestBody);

    if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    print(jsonResponse);

    final data = ReferalData.fromJson(jsonResponse);
    final lastTestDetails = data.lstReferral;

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


  void _filterData(String query) {
    setState(() {
      nameshow=true;
      allshow=false;
    });
 
         _filteredData = _lastTestDetails!
          .where((item) => item.commonName!.toLowerCase().contains(query.toLowerCase()))
          .toList();

      }
  

   @override
  void initState() {

    // TODO: implement initState
    LocalDB.getLDB('userID').then((onevalue) {
    
setState(() {
  userno=int.parse(onevalue);
});

      print("Appointviewuserid $userno");
    
          fetchData();

    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return SafeArea(
        child: GestureDetector(
          onTap: ()=>FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: const Color(0xffEFEFEF),
      body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                  height: height * 0.1,
                  child: Column(
                    children: [
                      SizedBox(height: height * 0.02),
                      Row(
                        children: [
                          IconButton(onPressed: (){
                            Navigator.pop(context, false);
                          }, icon: const Icon(Icons.arrow_back_ios,color: Color.fromARGB(255, 0, 0, 0),)),
                          SizedBox(
                            width: width * 0.78,
                            height: height *0.07,
                            child: Center(
                              child: TextFormField(
                                // controller: searchKey,
                                // onChanged: (value) {
                                //   if (value.length > 2) {
                                //     searchPatient(value.toString());
                                //   }
                                //
                                // },
                                onChanged: _filterData,
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.only(top: 4,left: 12),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: const BorderSide(color: Colors.grey)
                                    ),
                                    focusedBorder:OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: const BorderSide(color: Color.fromARGB(255, 0, 0, 0))
                                    ),
                                    hintText: 'Search'
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: width * 0.03,)
                        ],
                      ),
                    ],
                  )),
            SizedBox(
  height: height * 0.86,
  child:
  nodata?
              Container(
               height: height-170,width: width,
            
                child: Center(child: Text("Somthing went wrong")),):  isFetching?
       Container(
      height: height-170,width: width,
      child: Center(child: CircularProgressIndicator())):
   SingleChildScrollView(
              child: Column(
                children: [
                  nameshow?
                  ListView.builder(
                      itemCount: _filteredData!.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                            var item = _filteredData![index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                        child: Card(
                          color: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                          ),
                          child: ListTile(
                            onTap: () {
                              Map<String, dynamic> data = {
                                'name': "${item.commonName}",
                                'id': item.commonNo.toString(),
                              };
                              Navigator.pop(context, data);
                            },
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xffEFEFEF),
                              radius: 26,
                              child: widget.type == "DOCTOR"
                                  ? Image.asset('assets/images/medical-team.png', height: height * 0.4)
                                  : Image.asset('assets/images/client.png', height: height * 0.04),
                            ),
                            title: Text("${item.commonName}", style: const TextStyle(fontSize: 15, color: Color(0xff2454FF), fontWeight: FontWeight.w400)),
                            subtitle: Text("${item.commonKey}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ),
                        ),
                      );
                    },
                  ):
                  Text(""),
                  allshow?
                   ListView.builder(
                      itemCount: _lastTestDetails!.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                            var item = _lastTestDetails![index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                        child: Card(
                          color: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                          ),
                          child: ListTile(
                            onTap: () {
                              Map<String, dynamic> data = {
                                'name': "${item.commonName}",
                                'id': item.commonNo.toString(),
                              };
                              Navigator.pop(context, data);
                            },
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xffEFEFEF),
                              radius: 26,
                              child: widget.type == "DOCTOR"
                                  ? Image.asset('assets/images/medical-team.png', height: height * 0.4)
                                  : Image.asset('assets/images/client.png', height: height * 0.04),
                            ),
                            title: Text("${item.commonName}", style: const TextStyle(fontSize: 15, color: Color(0xff2454FF), fontWeight: FontWeight.w400)),
                            subtitle: Text("${item.commonKey}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ),
                        ),
                      );
                    },
                  ):
                  iserror?
                   Center(child: Text("No Records found!!!")):
                  Text(""),

                ],
              ),
            ))])))));
            }}