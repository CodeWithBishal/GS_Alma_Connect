class PublicUserDataModal {
  final String uid;
  final String fullname;
  final String userName;
  final String imgURL;
  final bool isVerified;
  final String fcmToken;
  final bool isAllowDM;
  final String communityRole;
  List conversationIDs;

  PublicUserDataModal({
    required this.uid,
    required this.fullname,
    required this.userName,
    required this.imgURL,
    required this.isVerified,
    required this.fcmToken,
    required this.isAllowDM,
    required this.conversationIDs,
    required this.communityRole,
  });
  Map<String, dynamic> toMap() {
    return {
      'UID': uid,
      'fullname': fullname,
      'UserName': userName,
      'imgURL': imgURL,
      'isVerified': isVerified,
      'fcmToken': fcmToken,
      'isAllowDM': isAllowDM,
      'communityRole': communityRole,
      'conversationIDs': conversationIDs,
    };
  }
}
