import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_app/auth/databaseService.dart';
import 'package:first_app/customize/my_flutter_app_icons.dart';
import 'package:first_app/provider/studio_provider.dart';
import 'package:first_app/studio_code/sconstants.dart';
import 'package:first_app/studio_code/spages/sinboxPages/chatPage.dart';
import 'package:first_app/utils/bottom_gallary_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class SMessagePage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  final String profilePic;
  final String adminProfilePic;
  final String chatUserId;

  const SMessagePage({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.userName,
    required this.adminProfilePic,
    required this.profilePic,
    required this.chatUserId,
  }) : super(key: key);

  static const String routeName = "/smessage-page";

  @override
  State<SMessagePage> createState() => _SMessagePageState();
}

class _SMessagePageState extends State<SMessagePage> {
  late TextEditingController _textController;
  Stream<QuerySnapshot>? chats;
  String admin = "";
  Stream? members;

  List<String> message = [];

  chatMessages(double screenHeight, double screenWidth) {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? Container(
                width: screenWidth,
                height: screenHeight,
                padding: EdgeInsets.only(bottom: screenHeight * 0.07),
                child: ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    int reverseIndex = snapshot.data.docs.length - index - 1;
                    return ChatPage(
                      message: snapshot.data.docs[reverseIndex]['message'],
                      sender: snapshot.data.docs[reverseIndex]['sender'],
                      sentByMe: widget.userName ==
                          snapshot.data.docs[reverseIndex]['sender'],
                      profilePic: widget.profilePic,
                      adminProfilePic: widget.adminProfilePic,
                    );
                  },
                ),
              )
            : Container();
      },
    );
  }

  sendMessage() {
    if (_textController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": _textController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };
      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        _textController.clear();
      });
      DatabaseService(uid: widget.chatUserId).updateNotification(
          "${widget.userName} has sent you a message__${widget.adminProfilePic}_${DateTime.now()}");
    }
  }

  getChatandAdmin() {
    DatabaseService().getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });

    DatabaseService().getGroupAdmin(widget.groupId).then((val) {
      setState(() {
        admin = val;
      });
    });

    DatabaseService().getProfilePic(widget.groupId).then((value) {
      print(value);
    });
  }

  getMembers() async {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getMembers(widget.groupId)
        .then((val) {
      setState(() {
        members = val;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    getChatandAdmin();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    var sUser = Provider.of<StudioProvider>(context).user;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: screenHeight * 0.1,
          actions: [
            Column(
              children: [
                SizedBox(
                  width: screenWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(MyFlutterApp.bi_arrow_down,
                            color: Colors.black),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: screenWidth * 0.25),
                        child: const Text(
                          "Messages",
                          style: TextStyle(
                            color: thirdColor,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: screenWidth,
                  padding: EdgeInsets.only(left: screenWidth * 0.03),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: widget.profilePic.isEmpty
                              ? Container(
                                  color: Colors.black,
                                )
                              : CachedNetworkImage(
                                  imageUrl: widget.profilePic,
                                  fit: BoxFit.cover,
                                  // child: Image.network(
                                  //     widget.profilePic,
                                  //     fit: BoxFit.cover,
                                  //   ),
                                ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Text(
                        widget.groupName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Stack(
          children: [
            chatMessages(screenHeight, screenWidth),
            messageSendingArea(screenWidth, screenHeight, context, sUser),
          ],
        ));
  }

  Column messageSendingArea(
      double screenWidth, double screenHeight, BuildContext context, sUser) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.02,
            vertical: screenHeight * 0.005,
          ),
          child: Material(
            borderRadius: BorderRadius.circular(20),
            elevation: 4,
            child: Container(
              width: screenWidth,
              // height: screenHeight * 0.06,
              // constraints: BoxConstraints(
              //   minHeight: screenHeight * 0.06,
              // ),
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(
                  left: screenWidth * 0.03, right: screenWidth * 0.02),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey[200],
              ),
              child: TextFormField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Type your message here",
                  hintStyle: const TextStyle(
                    fontSize: 15,
                    fontFamily: fontFamily,
                    color: placeholderTextColor,
                  ),
                  border: InputBorder.none,
                  // prefixIcon: IconButton(
                  //   onPressed: () {
                  //     showDialog(
                  //       barrierColor: Colors.transparent,
                  //       context: context,
                  //       builder: ((context) {
                  //         return Dialog(
                  //           insetPadding:
                  //               EdgeInsets.only(top: screenHeight * 0.49),
                  //           elevation: 4,
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(10),
                  //           ),
                  //           child: Container(
                  //             width: screenWidth * 0.95,
                  //             height: screenHeight * 0.30,
                  //             padding: EdgeInsets.all(screenWidth * 0.05),
                  //             decoration: BoxDecoration(
                  //               borderRadius: BorderRadius.circular(10),
                  //               color: Colors.grey[200],
                  //             ),
                  //             child: Column(
                  //               children: [
                  //                 Row(
                  //                   mainAxisAlignment:
                  //                       MainAxisAlignment.spaceBetween,
                  //                   children: [
                  //                     sendDocumentButton(screenWidth,
                  //                         MyFlutterApp.camera_2_fill, sUser),
                  //                     sendDocumentButton(screenWidth,
                  //                         MyFlutterApp.live_fill, sUser),
                  //                     sendDocumentButton(screenWidth,
                  //                         MyFlutterApp.mic_fill, sUser),
                  //                   ],
                  //                 ),
                  //                 SizedBox(height: screenHeight * 0.02),
                  //                 Row(
                  //                   mainAxisAlignment:
                  //                       MainAxisAlignment.spaceBetween,
                  //                   children: [
                  //                     sendDocumentButton(screenWidth,
                  //                         MyFlutterApp.paper, sUser),
                  //                   ],
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         );
                  //       }),
                  //     );
                  //   },
                  //   icon: const Icon(MyFlutterApp.clarity_attachment_line,
                  //       color: Colors.black),
                  // ),
                  suffixIcon: IconButton(
                    icon: SvgPicture.asset("asset/icons/send_button.svg"),
                    onPressed: () {
                      // if (_textController.text.isNotEmpty) {
                      //   print("hello");
                      //   setState(() {
                      //     message.add(_textController.text);
                      //     _textController.clear();

                      //     print(message[0]);
                      //   });
                      // }

                      sendMessage();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget sendDocumentButton(double screenWidth, IconData icon, sUser) {
    return InkWell(
      onTap: () {
        BottomMediaUp().showPickerMedia(context, sUser.id, "photos");
      },
      child: Container(
        width: screenWidth * 0.15,
        height: screenWidth * 0.15,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: secondoryColor,
        ),
        child: Icon(icon),
      ),
    );
  }
}
