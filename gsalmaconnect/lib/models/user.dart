class UserModel {
  String uid;
  String fullname;
  String phoneNumber;
  String email;
  String userName;
  bool isVerified;
  String dateTime;
  String imgURL;
  String enrollmentNo;
  List domain;
  String communityRole;
  String lastProfileUpdateTime;
  int noOfPosts;
  String branch;
  String enrollmentYear;
  String profileHeadline;
  String researchBrief;
  String course;
  List otherData;
  String fcmToken;
  bool isAllowDM;
  UserModel({
    required this.uid,
    required this.fullname,
    required this.phoneNumber,
    required this.email,
    required this.userName,
    required this.dateTime,
    required this.isVerified,
    required this.imgURL,
    required this.enrollmentNo,
    required this.domain,
    required this.communityRole,
    required this.lastProfileUpdateTime,
    required this.noOfPosts,
    required this.branch,
    required this.enrollmentYear,
    required this.profileHeadline,
    required this.researchBrief,
    required this.course,
    required this.otherData,
    required this.fcmToken,
    required this.isAllowDM,
  });
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'phoneNumber': phoneNumber,
      'fullname': fullname,
      'dateTime': dateTime,
      'userName': userName,
      'isVerified': isVerified,
      'imgURL': imgURL,
      'enrollmentNo': enrollmentNo,
      'domain': domain,
      'communityRole': communityRole,
      'lastProfileUpdateTime': lastProfileUpdateTime,
      'noOfPosts': noOfPosts,
      'branch': branch,
      'enrollmentYear': enrollmentYear,
      'profileHeadline': profileHeadline,
      'researchBrief': researchBrief,
      'course': course,
      'otherData': otherData,
      'fcmToken': fcmToken,
      'isAllowDM': isAllowDM,
    };
  }
}
