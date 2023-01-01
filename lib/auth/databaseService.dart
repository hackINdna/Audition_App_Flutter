import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  // final CollectionReference studioCollection =
  //     FirebaseFirestore.instance.collection("studioUsers");
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  Future updateUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "notification": [],
      "profilePic": "",
      "uid": uid,
    });
  }

  Future updateUserProfilePic(String profilePic) async {
    return await userCollection.doc(uid).update({
      "profilePic": profilePic,
    });
  }

  Future<List<List<String>>> getAllUserNotifications(String userId) async {
    List<String> allNotifications = [];
    List<String> allNotificationsPic = [];
    var notifications = await userCollection.doc(userId).get();
    for (var element in notifications['notification']) {
      if (element.isNotEmpty) {
        allNotifications.add(element.toString().split("__")[0]);
        allNotificationsPic.add(element.toString().split("__")[1]);
      }
    }
    return [allNotifications, allNotificationsPic];
  }

  Future updateNotification(String notificationText) async {
    print("notifications");
    print(notificationText);
    print(uid);
    return await userCollection.doc(uid).update({
      "notification": FieldValue.arrayUnion([notificationText]),
    });
  }

  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  // Future updateStudioUserData(String fullName, String email) async {
  //   return await studioCollection.doc(uid).set({
  //     "fullName": fullName,
  //     "email": email,
  //     "groups": [],
  //     "profilePic": "",
  //     "uid": uid,
  //   });
  // }

  // Future gettingStudioUserData(String email) async {
  //   QuerySnapshot snapshot =
  //       await studioCollection.where("email", isEqualTo: email).get();
  //   return snapshot;
  // }

  Future getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  Future getUserGroupsRecentMessage() async {
    var u = await userCollection.doc(uid).get();
    List<String> recentMessages = [];
    for (var element in u['groups']) {
      var newGroupId = element.toString().split("_")[0];
      var g = await groupCollection.doc(newGroupId).get();
      // var gmsg =
      //     await groupCollection.doc(newGroupId).collection("messages").get();
      recentMessages.add(g['recentMessage']);

      // print(gmsg.docs[0]['seen']);
    }
    return recentMessages;
  }

  Future<List<String>> getUserGroupsProfilePic(String user) async {
    List<String> profilePics = [];
    var d = await userCollection.doc(uid).get();
    for (var element in d['groups']) {
      var newGroupId = element.toString().split("_")[0];
      var g = await groupCollection.doc(newGroupId).get();
      var newUserId =
          g['groupName'].toString().split("_")[user == "studio" ? 0 : 1];
      var newUserData = await userCollection.doc(newUserId).get();
      var pp =
          (newUserData.data() as Map<String, dynamic>)['profilePic'].toString();
      profilePics.add(pp);
    }
    return profilePics;
  }

  Future<List<String>> getChatUserId(String user) async {
    List<String> allUserId = [];
    var d = await userCollection.doc(uid).get();
    for (var element in d['groups']) {
      var newGroupId = element.toString().split("_")[0];
      var g = await groupCollection.doc(newGroupId).get();
      var newUserId =
          g['groupName'].toString().split("_")[user == "studio" ? 0 : 1];
      var newUserData = await userCollection.doc(newUserId).get();
      // var pp =
      //     (newUserData.data() as Map<String, dynamic>)['profilePic'].toString();
      allUserId.add(newUserId);
    }
    return allUserId;
  }

  Future createGroup(String userName, String id, String userName2) async {
    var allGroupColl = await groupCollection.get();
    var allGroupCollDocs = allGroupColl.docs.where((element) =>
        (element.data() as Map<String, dynamic>)["members"][1]
            .toString()
            .split("_")[0] ==
        id);
    var userData = await userCollection.doc(uid).get();
    var user2Data = await userCollection.doc(id).get();

    if (allGroupCollDocs.isEmpty) {
      DocumentReference groupDocumentReference = await groupCollection.add({
        "groupName": "${id}_$uid",
        "groupIcon": "",
        "admin": "${uid}_$userName",
        "members": [],
        "groupId": "",
        "recentMessage": "",
        "recentMessageSender": "",
      });

      await groupDocumentReference.update({
        "members":
            FieldValue.arrayUnion(["${uid}_$userName", "${id}_$userName2"]),
        "groupId": groupDocumentReference.id,
      });

      DocumentReference userDocumentReference = userCollection.doc(uid);
      DocumentReference user2DocumentReference = userCollection.doc(id);
      await userDocumentReference.update({
        "groups":
            FieldValue.arrayUnion(["${groupDocumentReference.id}_$userName2"]),
      });
      await user2DocumentReference.update({
        "groups":
            FieldValue.arrayUnion(["${groupDocumentReference.id}_$userName"]),
      });

      return [
        groupDocumentReference.id,
        userName2,
        userName,
        (user2Data.data() as Map<String, dynamic>)['profilePic'],
        (userData.data() as Map<String, dynamic>)['profilePic'],
      ];
    } else {
      var allGroupCollDocs1 = allGroupColl.docs.where((element) =>
          (element.data() as Map<String, dynamic>)['groupName'].toString() ==
          "${id}_$uid");
      if (allGroupCollDocs1.length == 1) {
        return [
          (allGroupCollDocs1.first.data() as Map<String, dynamic>)['groupId'],
          userName2,
          userName,
          (user2Data.data() as Map<String, dynamic>)['profilePic'],
          (userData.data() as Map<String, dynamic>)['profilePic'],
        ];
      }

      return [];
    }
  }

  // Future<dynamic> createStudioGroup(
  //     String userName, String id, String groupName) async {
  //   DocumentReference groupDocumentReference = await groupCollection.add({
  //     "groupName": groupName,
  //     "groupIcon": "",
  //     "admin": "${id}_$userName",
  //     "members": [],
  //     "groupId": "",
  //     "recentMessage": "",
  //     "recentMessageSender": "",
  //   });

  //   await groupDocumentReference.update({
  //     "members":
  //         FieldValue.arrayUnion(["${uid}_$userName", "${uid}_$groupName"]),
  //     "groupId": groupDocumentReference.id,
  //   });

  //   DocumentReference studioDocumentReference = studioCollection.doc(uid);
  //   await studioDocumentReference.update({
  //     "groups":
  //         FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"]),
  //   });
  //   return [groupDocumentReference.id, groupName, userName];
  // }

  getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  Future getProfilePic(String groupId) async {
    var d = await groupCollection.doc(groupId).get();
    var user2 = d['groupName'];
    print(user2.toString().split("_")[0]);
    user2 = await userCollection.doc(user2.toString().split("_")[0]).get();
    print(user2['profilePic']);
  }

  Future getGroupAdmin(String groupId) async {
    DocumentReference d = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }

  getMembers(String groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];

    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  Future toggleGroupJoin(
      String groupId, String userName, String groupName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];

    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"]),
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"]),
      });
    } else {
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"]),
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      });
    }
  }

  sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(groupId).collection("messages").add(chatMessageData);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });
  }
}
