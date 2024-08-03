// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileDataAdapter extends TypeAdapter<UserProfileData> {
  @override
  final int typeId = 0;

  @override
  UserProfileData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfileData(
      uid: fields[0] as String,
      fullname: fields[1] as String,
      phoneNumber: fields[2] as String,
      email: fields[3] as String,
      userName: fields[4] as String,
      dateTime: fields[6] as String,
      isVerified: fields[5] as bool,
      imgURL: fields[7] as String,
      enrollmentNo: fields[8] as String,
      domain: (fields[9] as List).cast<dynamic>(),
      communityRole: fields[10] as String,
      lastProfileUpdateTime: fields[11] as String,
      noOfPosts: fields[12] as int,
      branch: fields[13] as String,
      enrollmentYear: fields[14] as String,
      profileHeadline: fields[15] as String,
      professionalBrief: fields[16] as String,
      course: fields[17] as String,
      otherUserData:
          fields[18] == null ? [] : (fields[18] as List).cast<dynamic>(),
      fcmToken: fields[19] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfileData obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.fullname)
      ..writeByte(2)
      ..write(obj.phoneNumber)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.userName)
      ..writeByte(5)
      ..write(obj.isVerified)
      ..writeByte(6)
      ..write(obj.dateTime)
      ..writeByte(7)
      ..write(obj.imgURL)
      ..writeByte(8)
      ..write(obj.enrollmentNo)
      ..writeByte(9)
      ..write(obj.domain)
      ..writeByte(10)
      ..write(obj.communityRole)
      ..writeByte(11)
      ..write(obj.lastProfileUpdateTime)
      ..writeByte(12)
      ..write(obj.noOfPosts)
      ..writeByte(13)
      ..write(obj.branch)
      ..writeByte(14)
      ..write(obj.enrollmentYear)
      ..writeByte(15)
      ..write(obj.profileHeadline)
      ..writeByte(16)
      ..write(obj.professionalBrief)
      ..writeByte(17)
      ..write(obj.course)
      ..writeByte(18)
      ..write(obj.otherUserData)
      ..writeByte(19)
      ..write(obj.fcmToken);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
