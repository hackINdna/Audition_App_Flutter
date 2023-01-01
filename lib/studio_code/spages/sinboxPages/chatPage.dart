import 'package:cached_network_image/cached_network_image.dart';
import 'package:first_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';

class ChatPage extends StatefulWidget {
  final String message;
  final String sender;
  final String profilePic;
  final String adminProfilePic;
  final bool sentByMe;
  const ChatPage({
    super.key,
    required this.message,
    required this.sender,
    required this.profilePic,
    required this.adminProfilePic,
    required this.sentByMe,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.015,
      ),
      child: Row(
        mainAxisAlignment:
            widget.sentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: widget.sentByMe
            ? [
                chatBB(screenHeight, screenWidth),
                chatMsg(screenHeight, screenWidth),
              ]
            : [
                chatMsg(screenHeight, screenWidth),
                chatBB(screenHeight, screenWidth),
              ],
      ),
    );
  }

  Container chatMsg(double screenHeight, double screenWidth) {
    return Container(
      width: 32,
      height: 32,
      // margin: EdgeInsets.only(
      //   top: screenHeight * 0.025,
      //   bottom: screenHeight * 0.025,
      // ),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: widget.sentByMe
            ? widget.adminProfilePic.isEmpty
                ? Container(
                    color: Colors.black,
                  )
                : CachedNetworkImage(
                    imageUrl: widget.adminProfilePic,
                    fit: BoxFit.cover,
                  )
            : widget.profilePic.isEmpty
                ? Container(
                    color: Colors.black,
                  )
                : CachedNetworkImage(
                    imageUrl: widget.profilePic,
                    fit: BoxFit.cover,
                  ),
      ),
    );
  }

  ChatBubble chatBB(double screenHeight, double screenWidth) {
    return ChatBubble(
      clipper: ChatBubbleClipper1(
          type: widget.sentByMe
              ? BubbleType.sendBubble
              : BubbleType.receiverBubble),
      backGroundColor: secondoryColor,
      margin: EdgeInsets.only(
        top: screenHeight * 0.015,
        bottom: screenHeight * 0.015,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: screenWidth * 0.7,
        ),
        child: Text(
          widget.message,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
