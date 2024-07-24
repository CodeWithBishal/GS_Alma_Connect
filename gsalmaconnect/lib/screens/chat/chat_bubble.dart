import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gsconnect/models/chat_model.dart';
import 'package:gsconnect/screens/backend/update_profile.dart';
import 'package:gsconnect/theme/colors.dart';
import 'package:gsconnect/widgets/image.dart';
import 'package:gsconnect/widgets/image_dialog.dart';
import 'package:gsconnect/widgets/toast.dart';
import 'package:gsconnect/widgets/url_launcher.dart';
import 'package:readmore/readmore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.isNotMe,
    required this.isImage,
    required this.message,
    required this.isLastMessage,
  });

  final bool isNotMe;
  final bool isImage;
  final Messages message;
  final bool isLastMessage;

  @override
  Widget build(BuildContext context) => Align(
        alignment: isNotMe ? Alignment.topLeft : Alignment.topRight,
        child: Column(
          crossAxisAlignment:
              isNotMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isImage
                    ? Colors.transparent
                    : isNotMe
                        ? Colors.grey[350]
                        : ColorDefination.blue,
                borderRadius: isNotMe
                    ? const BorderRadius.only(
                        topRight: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                        topLeft: Radius.circular(30),
                      )
                    : const BorderRadius.only(
                        topRight: Radius.circular(30),
                        bottomLeft: Radius.circular(30),
                        topLeft: Radius.circular(30),
                      ),
              ),
              margin: const EdgeInsets.only(
                top: 10,
                right: 10,
                left: 10,
              ),
              padding: !isImage
                  ? const EdgeInsets.only(
                      top: 10, bottom: 10, left: 20, right: 20)
                  : const EdgeInsets.only(top: 0, bottom: 0, left: 0, right: 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    isNotMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  isImage
                      ? GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => ImageDialog(
                                  imgUrl: message.message,
                                ),
                              ),
                            );
                          },
                          child: SizedBox(
                            height: 200,
                            width: 200,
                            child: CachedImageNetworkimage(
                              url: message.message,
                              width: 200,
                              isBorder: true,
                              height: 200,
                              isCircle: false,
                              isMaxHeight: true,
                            ),
                          ),
                        )
                      : GestureDetector(
                          onLongPress: () async {
                            await Clipboard.setData(
                              ClipboardData(
                                text: message.message,
                              ),
                            ).then((value) {
                              flutterToast(
                                "Message copied to clipboard",
                              );
                            });
                          },
                          child: ReadMoreText(
                            "${message.message} ",
                            isExpandable: false,
                            isCollapsed: ValueNotifier(false),
                            trimMode: TrimMode.Line,
                            trimLines: 300,
                            style: TextStyle(
                              fontSize: 14,
                              color: isNotMe ? Colors.black : Colors.white,
                            ),
                            colorClickableText:
                                isNotMe ? Colors.black : Colors.white,
                            trimCollapsedText: 'Show more',
                            trimExpandedText: "",
                            moreStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            lessStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            annotations: [
                              Annotation(
                                regExp: RegExp(r'#([a-zA-Z0-9_]+)'),
                                spanBuilder: (
                                        {required String text,
                                        TextStyle? textStyle}) =>
                                    TextSpan(
                                  text: text,
                                  style: textStyle?.copyWith(
                                    color:
                                        isNotMe ? Colors.black : Colors.white,
                                  ),
                                ),
                              ),
                              Annotation(
                                regExp: RegExp(r'@([a-zA-Z0-9_]+)'),
                                spanBuilder: (
                                        {required String text,
                                        TextStyle? textStyle}) =>
                                    TextSpan(
                                  text: text,
                                  style: textStyle?.copyWith(
                                    color:
                                        isNotMe ? Colors.black : Colors.white,
                                    decoration: TextDecoration.underline,
                                    decorationColor:
                                        isNotMe ? Colors.black : Colors.white,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      LaunchUrl.openLink(
                                        url: "https://gsconnect.web.app/$text",
                                        context: context,
                                        launchMode: LaunchMode
                                            .externalNonBrowserApplication,
                                      );
                                    },
                                ),
                              ),
                              Annotation(
                                regExp: RegExp(r'https:\/\/\S+'),
                                spanBuilder: (
                                        {required String text,
                                        TextStyle? textStyle}) =>
                                    TextSpan(
                                  text: text,
                                  style: textStyle?.copyWith(
                                    color:
                                        isNotMe ? Colors.black : Colors.white,
                                    decoration: TextDecoration.underline,
                                    decorationColor:
                                        isNotMe ? Colors.black : Colors.white,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      LaunchUrl.openLink(
                                        url: text,
                                        context: context,
                                        launchMode: LaunchMode
                                            .externalNonBrowserApplication,
                                      );
                                    },
                                ),
                              ),
                            ],
                          ),
                        ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                right: isNotMe ? 0 : 10,
                left: isNotMe ? 10 : 0,
              ),
              child: Text(
                isLastMessage
                    ? getFormattedDate(message.timeStamp)
                    : timeago.format(
                        DateTime.fromMillisecondsSinceEpoch(
                          int.parse(
                            message.timeStamp,
                          ),
                        ),
                      ),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      );
}

List<String> extractLinks(String text) {
  // Regular expression to find URLs in the text
  RegExp linkRegex = RegExp(r'https?://\S+|www\.\S+');

  // Extract all matches
  Iterable<RegExpMatch> matches = linkRegex.allMatches(text);

  // Convert matches to a list of strings
  List<String> links = matches.map((match) => match.group(0)!).toList();

  return links;
}
