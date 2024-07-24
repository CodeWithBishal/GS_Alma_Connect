import 'package:flutter/material.dart';
import 'package:gsconnect/theme/colors.dart';

class BadgeWidget extends StatelessWidget {
  final String communityRole;
  final String text;
  final TextStyle? textStyle;
  const BadgeWidget({
    super.key,
    required this.communityRole,
    required this.text,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return communityRole != "null"
        ? Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                child: textStyle != null
                    ? Text(
                        text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textStyle,
                      )
                    : Text(
                        text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              const SizedBox(
                width: 5,
              ),
              Badge(
                backgroundColor: communityRole == "Student"
                    ? Colors.blue
                    : communityRole == "Faculty"
                        ? Colors.red
                        : ColorDefination.yellow,
                label: Text(communityRole),
                textStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        : Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
  }
}
