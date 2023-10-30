class ReferalData {
  int? status;
  String? message;
  List<LstReferalDetails>? lstReferral; // Change the property name to match the response

  ReferalData({this.status, this.message, this.lstReferral});

  ReferalData.fromJson(Map<String, dynamic> json) {
    status = json['status']; // Use lowercase 'status' to match the response
    message = json['message']; // Use lowercase 'message' to match the response
    if (json['lstReferral'] != null) { // Use lowercase 'lstReferral' to match the response
      lstReferral = <LstReferalDetails>[];
      json['lstReferral'].forEach((v) {
        lstReferral!.add(new LstReferalDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status; // Use lowercase 'status' to match the response
    data['message'] = this.message; // Use lowercase 'message' to match the response
    if (this.lstReferral != null) { // Use lowercase 'lstReferral' to match the response
      data['lstReferral'] =
          this.lstReferral!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LstReferalDetails {
  String? commonNo;
  String? commonKey;
  String? commonCode;
  String? commonName;
  String? commonValue;
  bool? isDefault;
  int? sequenceNo;

  LstReferalDetails({
    this.commonNo,
    this.commonKey,
    this.commonCode,
    this.commonName,
    this.commonValue,
    this.isDefault,
    this.sequenceNo,
  });

  LstReferalDetails.fromJson(Map<String, dynamic> json) {
    commonNo = json['commonNo'].toString(); // Convert to String
    commonKey = json['commonKey'];
    commonCode = json['commonCode'];
    commonName = json['commonName'];
    commonValue = json['commonValue'];
    isDefault = json['isDefault'];
    sequenceNo = json['sequenceNo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['commonNo'] = commonNo;
    data['commonKey'] = commonKey;
    data['commonCode'] = commonCode;
    data['commonName'] = commonName;
    data['commonValue'] = commonValue;
    data['isDefault'] = isDefault;
    data['sequenceNo'] = sequenceNo;
    return data;
  }
}
