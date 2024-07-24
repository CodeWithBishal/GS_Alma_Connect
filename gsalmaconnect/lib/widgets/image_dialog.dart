import 'package:flutter/material.dart';
import 'package:gsconnect/widgets/image.dart';
import 'package:gsconnect/widgets/snacbar.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class ImageDialog extends StatelessWidget {
  final String imgUrl;
  const ImageDialog({super.key, required this.imgUrl});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_outlined,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              var permission = await Permission.photos.request();
              if (permission.isGranted) {
                final response = await http.get(Uri.parse(imgUrl));
                if (response.statusCode == 200) {
                  ImageGallerySaver.saveImage(response.bodyBytes);
                  if (!context.mounted) return;
                  customSnacBar(context, "Image Saved to Gallery");
                } else {
                  if (!context.mounted) return;
                  customSnacBar(
                    context,
                    "Check your internet connection and try again later",
                  );
                }
              } else if (context.mounted) {
                customSnacBarWithAction(
                  context,
                  "Allow Storage Permission!",
                  SnackBarAction(
                    label: "Settings",
                    onPressed: () {
                      openAppSettings();
                    },
                  ),
                );
                await Permission.storage.request();
              }
            },
            icon: const Icon(
              Icons.download_outlined,
            ),
          ),
          const SizedBox(
            width: 5,
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: width - width / 15,
          child: ListView(
            shrinkWrap: true,
            children: [
              InteractiveViewer(
                panEnabled: false,
                child: Hero(
                  tag: imgUrl,
                  child: CachedImageNetworkimage(
                    url: imgUrl,
                    width: width,
                    isBorder: true,
                    height: height,
                    isCircle: false,
                    isMaxHeight: false,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              )
            ],
          ),
        ),
      ),
    );
  }
}
