import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

//Storage
final Reference feedPostsStorage =
    FirebaseStorage.instance.ref().child("FeedPosts");

final Reference userDPStorage =
    FirebaseStorage.instance.ref().child("User").child("DisplayPicture");

final Reference chatImageDataStorage =
    FirebaseStorage.instance.ref().child("chatDataStorage-images");

//Realtime Database
final DatabaseReference feedPostsRTDB =
    FirebaseDatabase.instance.ref("FeedPosts");

final DatabaseReference publicUserDataRTDB =
    FirebaseDatabase.instance.ref("PublicUserData");

final DatabaseReference userDataRTDB =
    FirebaseDatabase.instance.ref("UserData");

final DatabaseReference chatDataRTDB =
    FirebaseDatabase.instance.ref("ChatData");

final DatabaseReference officialUpdateRTDB =
    FirebaseDatabase.instance.ref("OfficialUpdate");

String getDiceBearURL(String name) {
  final encodedName = name.toString().replaceAll(
        " ",
        "%20",
      );
  return "https://api.dicebear.com/7.x/initials/png?seed=$encodedName";
}
