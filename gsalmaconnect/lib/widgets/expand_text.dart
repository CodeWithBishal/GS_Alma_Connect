import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gsconnect/theme/colors.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;

  const ExpandableText({super.key, required this.text, this.maxLines = 3});

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;
  bool isBtn = false;

  bool seeMore() {
    return widget.text.length >= (widget.maxLines) * 30;
  }

  @override
  void initState() {
    seeMore();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
            text: isExpanded ? widget.text : _getTruncatedText(),
            style: DefaultTextStyle.of(context).style,
            children: seeMore()
                ? <TextSpan>[
                    TextSpan(
                      text: isExpanded ? ' ' : '... ',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: isExpanded ? 'Show less' : 'See more',
                      style: TextStyle(
                        color: ColorDefination.blue,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                    ),
                  ]
                : [const TextSpan()],
          ),
          maxLines: isExpanded ? 10000 : widget.maxLines,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _getTruncatedText() {
    if (widget.text.length >= (widget.maxLines) * 30) {
      return widget.text.substring(0, (widget.maxLines) * 30);
    }
    return widget.text;
  }
}
