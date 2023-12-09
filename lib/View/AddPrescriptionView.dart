import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:botbridge_green/MainData.dart';
import 'package:botbridge_green/View/PatientDetailsView.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/ApiClient.dart';
import '../Model/ServerURL.dart';
import '../Utils/NavigateController.dart';
import 'Helper/ThemeCard.dart';


class AddPrescriptionView extends StatefulWidget {
  final String bookingID;
  final int screenType;
  final String booktype;
  final String regdate;

  const AddPrescriptionView({
    Key? key,
    required this.bookingID,
    required this.screenType,
    required this.booktype,
    required this.regdate,
  }) : super(key: key);

  @override
  _AddPrescriptionViewState createState() => _AddPrescriptionViewState();
}

class _AddPrescriptionViewState extends State<AddPrescriptionView> {
 final ImagePicker pickImage = ImagePicker();
  List<XFile> selectedImages = [];
  List<String> _selectedImagePaths = [];
  bool showSubmitButton = false;
  bool uploaded = false;

  @override
  void initState() {
    super.initState();
    _loadSelectedImagePaths();
  }

  Future<void> _loadSelectedImagePaths() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? storedImagePaths = prefs.getStringList('${widget.bookingID}selectedImagePaths');

    if (storedImagePaths != null) {
      setState(() {
        _selectedImagePaths = storedImagePaths;
      });
    }
  }

  String? _getImageType(String imagePath) {
    final List<String> parts = imagePath.split('.');
    if (parts.length > 1) {
      return parts.last;
    }
    return null;
  }

Future<void> _updateStoredImagePaths() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setStringList('${widget.bookingID}selectedImagePaths', _selectedImagePaths);

}


 void showGuide( BuildContext context,content){
QuickAlert.show(
 context: context,
 type:QuickAlertType.success,
//  customAsset: "assets/images/ok_popup.gif",

 text: content,
 confirmBtnText: 'Done',
//  cancelBtnText: 'No',
 onConfirmBtnTap: (){
 NavigateController.pagePushLikePop(context, PatientDetailsView(screenType: widget.screenType, bookingType: widget.booktype, bookingID: widget.bookingID, regdate: widget.regdate,));        // Change this to your desired behavior


 },
//  onCancelBtnTap: (){
//   NavigateController.pagePOP(context);
//  },
 confirmBtnColor: Colors.green,
);
  }

  Future<void> captureImage() async {
    final XFile? capturedImage = await pickImage.pickImage(source: ImageSource.camera);

    if (capturedImage != null) {
      setState(() {
        selectedImages = selectedImages ?? [];
        selectedImages!.add(capturedImage);
        showSubmitButton = true;
      });
    }
  }

  Future<void> selectImages() async {
    final List<XFile>? selectedImage = await pickImage.pickMultiImage();
    if (selectedImage != null && selectedImage.isNotEmpty) {
      setState(() {
        selectedImages = selectedImages ?? [];
        selectedImages!.addAll(selectedImage);
        showSubmitButton = true;
      });
    }
  }




void processImages(List<XFile> images) async {
   List<Map<String, dynamic>> imageList = [];

    // setState(() {
    //   _selectedImagePaths.addAll(images.map((image) => image.path));
    // });

    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setStringList('${widget.bookingID}selectedImagePaths', _selectedImagePaths);

    for (final image in images) {
      File _image = File(image.path);
      Uint8List imagebytes = await _image.readAsBytes();

      String imageType = _getImageType(image.path) ?? "jpg";

      String base64Image = base64.encode(imagebytes);

      Map<String, dynamic> imageMap = {
        "imageType": imageType,
        "imageName": image.name.toString(),
        "base64": base64.encode(imagebytes),
      };

      imageList.add(imageMap);
            _selectedImagePaths.add(image.path); // Add the new image path

    }
  SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('${widget.bookingID}selectedImagePaths', _selectedImagePaths);

  Map<String, dynamic> params = {
    "bookingID": widget.bookingID,
    "venueNo": MainData.tenantNo,
    "venueBranchNo": MainData.tenantBranchNo,
    "prescriptionImglst": imageList,
  };

  await uploadImagesToServer(params);

  setState(() {
    showSubmitButton = true;
    uploaded = true;
  });
}


Future<void> uploadImagesToServer(Map<String, dynamic> params) async {
    ApiClient().fetchData(ServerURL().getUrl(RequestType.UploadPrescription), params).then((value) {
      showGuide(context, "prescription Uploaded Successfully");
      Fluttertoast.showToast(
        msg: "Uploaded Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black45,
        textColor: Colors.white,
        fontSize: 14.0,
      );});
}


  void uploadImages() {
    if (selectedImages != null && selectedImages!.isNotEmpty) {
      processImages(selectedImages!);
    }
  }

  void openSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.camera),
              title: Text('Capture Image'),
              onTap: () {
                Navigator.pop(context);
                captureImage();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('Select Image'),
              onTap: () {
                Navigator.pop(context);
                selectImages();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffEFEFEF),
        body: WillPopScope(
          onWillPop: () async {
 NavigateController.pagePushLikePop(context, PatientDetailsView(screenType: widget.screenType, bookingType: widget.booktype, bookingID: widget.bookingID, regdate: widget.regdate,));            return true; // Change this to your desired behavior
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                                Container(
                  height: height * 0.07,
                  width: width,
                  decoration: BoxDecoration(
                    color: CustomTheme.background_green,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(height * 0.8 / 25)),
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(11),
                          child: InkWell(
                            onTap: () {
                              NavigateController.pagePushLikePop(context, PatientDetailsView(screenType: widget.screenType, bookingType: widget.booktype, bookingID: widget.bookingID, regdate: widget.regdate,));
                            },
                            child: const Icon(Icons.arrow_back_ios, color: Colors.white),
                          ),
                        ),
                      ),
                      const Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.all(11),
                          child: Text("Add Prescription", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.02),

                // Display previously selected images here
                if (_selectedImagePaths.isNotEmpty)
                  Flex(
                    direction: Axis.vertical,
                    children: [
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                        itemCount: _selectedImagePaths.length,
                        itemBuilder: (BuildContext ctx, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [BoxShadow(color: Colors.green,offset: Offset(5, 5),blurRadius: 10,blurStyle:BlurStyle.solid )]
                                  ),
                                  child: Image.file(
                                    File(_selectedImagePaths[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                 Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                     onTap: () {
      setState(() {
        if (index < _selectedImagePaths.length) {
          _selectedImagePaths.removeAt(index);
        }

        if (selectedImages != null && index < selectedImages!.length) {
          selectedImages!.removeAt(index);
        }

        print("this is the button ------------");
      });

      if (_selectedImagePaths.isEmpty && (selectedImages == null || selectedImages!.isEmpty)) {
        setState(() {
          showSubmitButton = false;
        });
      }

      _updateStoredImagePaths(); // Update stored image paths
    },
                    child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.redAccent,
                      child: Center(
                        child: Icon(Icons.clear, size: 15, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                // Display newly selected images
                if (selectedImages != null && selectedImages!.isNotEmpty && !uploaded)
                  Flex(
                    direction: Axis.vertical,
                    children: [
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                        itemCount: selectedImages!.length,
                        itemBuilder: (BuildContext ctx, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [BoxShadow(color: Colors.green,offset: Offset(5, 5),blurRadius: 10,blurStyle:BlurStyle.solid )]
                                  ),
                                  child: Image.file(
                                    File(selectedImages![index].path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: InkWell(
                                     onTap: () {
      setState(() {
        if (index < _selectedImagePaths.length) {
          _selectedImagePaths.removeAt(index);
        }

        if (selectedImages != null && index < selectedImages!.length) {
          selectedImages!.removeAt(index);
        }

        print("this is the button ------------");
      });

      if (_selectedImagePaths.isEmpty && (selectedImages == null || selectedImages!.isEmpty)) {
        setState(() {
          showSubmitButton = false;
        });
      }

      _updateStoredImagePaths(); // Update stored image paths
    },
                                    child: const CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.redAccent,
                                      child: Center(
                                        child: Icon(Icons.clear, size: 15, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
 Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                     onTap: () {
      setState(() {
        if (index < _selectedImagePaths.length) {
          _selectedImagePaths.removeAt(index);
        }

        if (selectedImages != null && index < selectedImages!.length) {
          selectedImages!.removeAt(index);
        }

        print("this is the button ------------");
      });

      if (_selectedImagePaths.isEmpty && (selectedImages == null || selectedImages!.isEmpty)) {
        setState(() {
          showSubmitButton = false;
        });
      }

      _updateStoredImagePaths(); // Update stored image paths
    },
                    child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.redAccent,
                      child: Center(
                        child: Icon(Icons.clear, size: 15, color: Colors.white),
                      ),
                    ),
                  ),
                ),                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                // "Submit" Button
               // "Submit" Button
if (showSubmitButton && !uploaded)
  Container(
    color: Colors.white,
    padding: EdgeInsets.all(16.0),
    child: InkWell(
      onTap: () {
        uploadImages();
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
              blurRadius: 6,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Submit',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ),
  ),

// Add Image Button
if (!uploaded)
  Container(
    padding: EdgeInsets.all(16.0),
    child: InkWell(
      onTap: openSheet,
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
              blurRadius: 6,
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset('assets/images/add_appointment.png', height: height * 0.02),
              Text(
                'Image',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
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
      ),
    );

  


  }
}