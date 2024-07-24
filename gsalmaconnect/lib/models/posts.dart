class PostModel {
  String uid;
  String sharedID;
  String message;
  List likes;
  String imgURL;
  String dateTime;
  String extURL;
  bool isAllowDM;
  bool isHidden;
  String id;
  List isReported;
  int views;
  String userName;
  String userPfp;
  String name;
  String communityRole;
  String fcmToken;
  List tags;

  PostModel({
    required this.uid,
    required this.sharedID,
    required this.message,
    required this.likes,
    required this.imgURL,
    required this.extURL,
    required this.dateTime,
    required this.isAllowDM,
    required this.isHidden,
    required this.id,
    required this.isReported,
    required this.views,
    required this.userName,
    required this.userPfp,
    required this.name,
    required this.communityRole,
    required this.tags,
    required this.fcmToken,
  });
  Map<String, dynamic> toMap() {
    return {
      'ID': id,
      'sharedID': sharedID,
      'UID': uid,
      'Message': message,
      'Likes': likes,
      'imgURL': imgURL,
      'dateTime': dateTime,
      'isAllowDM': isAllowDM,
      'extURL': extURL,
      'isHidden': isHidden,
      'isReported': isReported,
      'views': views,
      'userName': userName,
      'userPfp': userPfp,
      'name': name,
      'tags': tags,
      'communityRole': communityRole,
      'fcmToken': fcmToken,
    };
  }
}
