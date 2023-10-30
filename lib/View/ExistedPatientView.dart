import 'package:botbridge_green/ViewModel/ExistPatientVM.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Model/Status.dart';
import '../Utils/NavigateController.dart';
import 'Helper/ThemeCard.dart';



class ExistedPatientView extends StatefulWidget {
  const ExistedPatientView({Key? key}) : super(key: key);

  @override
  _ExistedPatientViewState createState() => _ExistedPatientViewState();
}

class _ExistedPatientViewState extends State<ExistedPatientView> {
  bool isFetching = true;
  final ExistingPatientVM _api = ExistingPatientVM();

  final TextEditingController searchKey = TextEditingController();
  FocusNode inputNode = FocusNode();
// to open keyboard call this function;
  void openKeyboard(){
    FocusScope.of(context).requestFocus(inputNode);
  }

  searchPatient(String searchText) {
    Map<String,dynamic> params = {
      "SearchText": searchKey.text,
      "TenantNo": "106",
      "TenantBranchNo": "219"
    };
    _api.fetchExistedPatientDetails(params);
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
                  Container(
                    height: height * 0.17,
                    width: width,
                    decoration: BoxDecoration(
                        color: CustomTheme.background_green,
                        boxShadow: const [
                          BoxShadow(
                            offset: Offset(1,4),
                            blurRadius: 6,
                            color: Colors.black12
                          )
                        ],
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(height * 0.2/3.5))
                    ),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(11),
                            child: InkWell(
                                onTap: (){
                                  NavigateController.pagePOP(context);
                                },
                                child: const Icon(Icons.arrow_back_ios,color: Colors.white,)),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: height * 0.02,
                              ),
                               SizedBox(
                                          width: width * 0.67,
                                          height: height * 0.053,
                                          child: Center(
                                            child: TextFormField(
                                              controller: searchKey,
                                              cursorColor: Colors.black45,
                                              onChanged: (value) {
                                                if (value.length > 2) {
                                                    searchPatient(value.toString());
                                                }
                                              },
                                              textInputAction: TextInputAction.go,
                                              onFieldSubmitted: (value){
                                                print(value);
                                                return;
                                              },

                                              focusNode: inputNode,
                                                autofocus:true,
                                              decoration: InputDecoration(

                                                filled: true,
                                                fillColor:const Color(0xffBFFCC3) ,
                                                contentPadding: const EdgeInsets.only(top: 4,left: 12),
                                                  enabledBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(22),
                                                      borderSide: const BorderSide(color: Colors.transparent)
                                                  ),
                                                  focusedBorder:OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(22),
                                                      borderSide: const BorderSide(color: Colors.transparent)
                                                  ),
                                                  hintText: 'Search..',
                                                suffixIcon:  const Icon(Icons.search,color: Colors.black45,size: 19,),
                                                hintStyle: const TextStyle(color: Colors.black54,fontSize: 14)
                                              ),
                                            ),
                                          ),
                                        ),
                              SizedBox(
                                height: height * 0.02,
                              ),
                              const Text("Book New Test",style: TextStyle(color: Colors.white,fontSize: 19,fontWeight: FontWeight.w600),),

                          
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
               
                  Container(
                    height: height * 0.75,
                    child:ChangeNotifierProvider<ExistingPatientVM>(
                      create: (BuildContext context) => _api,
                      child: Consumer<ExistingPatientVM>(builder: (context, viewModel, _) {
                        switch (viewModel.getExistedPatient.status) {
                          case Status.Loading:
                            return searchKey.text.isNotEmpty ? const Center(child: CircularProgressIndicator()) : const Center(child:Center(child: Text("Enter Text",style: TextStyle(fontSize: 36,color: Colors.black38),),));
                          case Status.Error:
                            return const Center(child: Center(child: Text("Something Issue"),))  ;
                          case Status.Completed:
                          // updateData();
                            var VM = viewModel.getExistedPatient.data!;
                            return
                              VM.lstExistsPatientInfo == null ?
                              const Center(child:Center(child: Text("No Record Found",style: TextStyle(fontWeight: FontWeight.bold),),)) :
                              SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Flex(direction: Axis.vertical,
                                      children: [
                                        ListView.builder(
                                          itemCount: VM.lstExistsPatientInfo!.length,
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemBuilder: (BuildContext context, int index) {
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 2,horizontal: 8),
                                              child: Card(
                                                color: Colors.white,
                                                shape: const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(
                                                        Radius.circular(15))),
                                                child: ListTile(
                                                  onTap: () {
                                                    Map<String,dynamic> data = {
                                                      'fname':VM.lstExistsPatientInfo![index].firstName.toString(),
                                                      'lname':VM.lstExistsPatientInfo![index].firstName.toString(),
                                                      'no':VM.lstExistsPatientInfo![index].phoneNo.toString(),
                                                      'mail':VM.lstExistsPatientInfo![index].email.toString(),
                                                      'age':VM.lstExistsPatientInfo![index].age!.replaceAll("Y", ""),
                                                      'dob':VM.lstExistsPatientInfo![index].dOB,
                                                      'gender':VM.lstExistsPatientInfo![index].gender,
                                                      'pincode':VM.lstExistsPatientInfo![index].pincode,
                                                    };
                                                    Navigator.pop(context,data);
                                                    // [{"CustomerID":"CUS678","ServiceNo":"73162","ServiceCode":"Albumin","ServiceType":"ANA","IsFasting":false,"Remarks":"NIL"}]
                                                  },
                                                  leading:  CircleAvatar(
                                                    backgroundColor:  const Color(0xffEFEFEF),
                                                    radius: 26,
                                                    child: Image.asset('assets/images/client.png',height: height*0.04,) ,
                                                  ),
                                                  title:  Text("${VM.lstExistsPatientInfo![index].name}",style: const TextStyle(fontSize: 15,color: Color(0xff2454FF),fontWeight: FontWeight.w400)),
                                                  subtitle:  Text("${VM.lstExistsPatientInfo![index].title}",style: const TextStyle(fontSize: 12,color: Colors.grey),),
                                                ),
                                              ),
                                            );
                                          },

                                        )
                                      ],
                                    ),
                                    SizedBox(height: height * 0.04,),
                                  ],
                                ),
                              );

                          default:
                        }
                        return Container();
                      }),
                    ),

                  )
                ],
              ),
            ),
          ),
        )
    );
  }
}
