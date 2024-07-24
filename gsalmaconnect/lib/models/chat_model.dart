//This model is for the chat page preview
class ChatForUIModel {
  final String chatID;
  final String lastTimeStamp;
  final String lastMessage;
  final bool isNewMessage;
  final String senderID;
  final bool isConversationActive;

  ChatForUIModel({
    required this.chatID,
    required this.lastTimeStamp,
    required this.lastMessage,
    required this.isNewMessage,
    required this.senderID,
    required this.isConversationActive,
  });
  Map<String, dynamic> toMap() {
    return {
      'chatID': chatID,
      'lastMessage': lastMessage,
      'lastTimeStamp': lastTimeStamp,
      'isNewMessage': isNewMessage,
      'senderID': senderID,
      'isConversationActive': isConversationActive,
    };
  }
}

// class ChatPerson {
//   final String uid1;
//   final String uid2;

//   ChatPerson({
//     required this.uid1,
//     required this.uid2,
//   });
//   Map<String, dynamic> toMap() {
//     return {
//       'uid1': uid1,
//       'uid2': uid2,
//     };
//   }
// }

class Messages {
  final String message;
  final String timeStamp;
  final String uid;
  final String chatID;
  final String messageType;

  Messages({
    required this.chatID,
    required this.message,
    required this.timeStamp,
    required this.uid,
    required this.messageType,
  });

  Map<String, dynamic> toMap() {
    return {
      'chatID': chatID,
      'message': message,
      'timeStamp': timeStamp,
      'uid': uid,
      'messageType': messageType,
    };
  }
}

//This model is to store conversation

// class ConversationUsers {
//   final ChatForUIModel chatForUIModel;
//   final ChatPerson chatPerson;
//   final int index;
//   final Messages messages;

//   ConversationUsers(
//       {required this.chatForUIModel,
//       required this.chatPerson,
//       required this.messages,
//       required this.index});

//   Map<String, dynamic> toMap() {
//     return {
//       'chatForUIModel': chatForUIModel.toMap(),
//       'chatPerson': chatPerson.toMap(),
//       'messages': [
//         messages.toMap(),
//       ],
//       'index': index,
//     };
//   }
// }
