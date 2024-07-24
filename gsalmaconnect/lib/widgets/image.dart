import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gsconnect/theme/colors.dart';
import 'package:shimmer/shimmer.dart';

class CachedImageNetworkimage extends StatefulWidget {
  final String url;
  final double width;
  final bool isBorder;
  final double height;
  final bool isCircle;
  final bool isMaxHeight;
  const CachedImageNetworkimage({
    super.key,
    required this.url,
    required this.width,
    required this.isBorder,
    required this.height,
    required this.isCircle,
    required this.isMaxHeight,
  });

  @override
  State<CachedImageNetworkimage> createState() =>
      _CachedImageNetworkimageState();
}

class _CachedImageNetworkimageState extends State<CachedImageNetworkimage> {
  @override
  Widget build(BuildContext context) {
    return widget.url.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: widget.url,
            fit: BoxFit.cover,
            width: widget.width - widget.width / 15,
            imageBuilder: (context, imageProvider) => widget.isCircle
                ? CircleAvatar(
                    backgroundImage: NetworkImage(widget.url),
                    backgroundColor: ColorDefination.bgColor,
                  )
                : Container(
                    constraints: widget.isMaxHeight
                        ? BoxConstraints(
                            maxHeight: widget.height / 2,
                          )
                        : null,
                    child: ClipRRect(
                      borderRadius: widget.isBorder
                          ? const BorderRadius.all(
                              Radius.circular(11),
                            )
                          : const BorderRadius.all(Radius.zero),
                      child: Image(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
            progressIndicatorBuilder: (context, url, downloadProgress) {
              return imageErrorWidget(
                widget.width,
                widget.height,
              );
            },
            errorWidget: (context, url, error) {
              return imageErrorWidget(
                widget.width,
                widget.height,
              );
            },
            color: Colors.transparent,
          )
        : imageErrorWidget(
            widget.width,
            widget.height,
          );
  }
}

Widget imageErrorWidget(double width, height) {
  return Shimmer.fromColors(
    baseColor: (Colors.grey[300])!,
    highlightColor: (Colors.grey[100])!,
    child: Image.asset(
      "assets/logo/loading_img.png",
      fit: BoxFit.contain,
      width: width,
      height: height / 3,
    ),
  );
}
