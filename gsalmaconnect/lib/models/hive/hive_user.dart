import 'package:hive_flutter/hive_flutter.dart';
part 'hive_user.g.dart';

@HiveType(typeId: 0)
class UserProfileData extends HiveObject {
  @HiveField(0)
  final String uid;
  @HiveField(1)
  final String fullname;
  @HiveField(2)
  final String phoneNumber;
  @HiveField(3)
  final String email;
  @HiveField(4)
  final String userName;
  @HiveField(5)
  final bool isVerified;
  @HiveField(6)
  final String dateTime;
  @HiveField(7)
  final String imgURL;
  @HiveField(8)
  final String enrollmentNo;
  @HiveField(9)
  final List domain;
  @HiveField(10)
  final String communityRole;
  @HiveField(11)
  final String lastProfileUpdateTime;
  @HiveField(12)
  final int noOfPosts;
  @HiveField(13)
  final String branch;
  @HiveField(14)
  final String enrollmentYear;
  @HiveField(15)
  final String profileHeadline;
  @HiveField(16)
  final String professionalBrief;
  @HiveField(17)
  final String course;
  @HiveField(18, defaultValue: [])
  final List otherUserData;
  @HiveField(19)
  final String fcmToken;
  UserProfileData({
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
    required this.professionalBrief,
    required this.course,
    required this.otherUserData,
    required this.fcmToken,
  });
}
