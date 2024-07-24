class UserNameModal {
  final String uid;
  final String userName;

  UserNameModal({
    required this.uid,
    required this.userName,
  });
  Map<String, dynamic> toMap() {
    return {
      'UID': uid,
      'UserName': userName,
    };
  }
}
