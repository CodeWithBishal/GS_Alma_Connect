import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gsconnect/theme/colors.dart';
import 'package:gsconnect/widgets/toast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as pathpackage;

Future<List> pickImage({
  required bool isProfile,
}) async {
  late String imagePath;
  late String extensionImg;
  final imgFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (imgFile?.path == null) return [];
  CroppedFile? croppedFile = await ImageCropper().cropImage(
    maxHeight: isProfile ? 500 : null,
    maxWidth: isProfile ? 500 : null,
    sourcePath: imgFile!.path,
    aspectRatioPresets: isProfile
        ? [
            CropAspectRatioPreset.square,
          ]
        : [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: ColorDefination.bgColor,
        backgroundColor: ColorDefination.bgColor,
        statusBarColor: ColorDefination.blue,
        activeControlsWidgetColor: ColorDefination.blue,
        toolbarWidgetColor: ColorDefination.blue,
        initAspectRatio: isProfile
            ? CropAspectRatioPreset.square
            : CropAspectRatioPreset.original,
        lockAspectRatio: isProfile ? true : false,
      ),
    ],
  );
  if (croppedFile?.path == null) return [];

  await compressAndFilePath(
    path: croppedFile!.path,
    isProfile: isProfile,
  ).then((value) {
    if (value.isEmpty) return;
    imagePath = value[0];
    extensionImg = value[1];
  });
  return [imagePath, extensionImg];
}

Future<List> compressAndFilePath({
  required String path,
  required bool isProfile,
}) async {
  String base = pathpackage.basenameWithoutExtension(path);
  final extensionImg = pathpackage.extension(path);
  String newImage =
      path.replaceAll(base + extensionImg, "$base-compress$extensionImg");
  FlutterImageCompress.validator.ignoreCheckExtName = true;
  var result = await FlutterImageCompress.compressAndGetFile(
    path,
    newImage,
    quality: 70,
  );
  if (result == null) return [];
  return [result.path, extensionImg];
}

Future<String> imgURLfromFirebase({
  required String imgURLpath,
  required String extensionImg,
  required User? user,
  required bool isProfile,
  required Reference storageRef,
}) async {
  final String cacheID = DateTime.now().millisecondsSinceEpoch.toString();
  await storageRef.putFile(
      File(
        imgURLpath,
      ),
      SettableMetadata(
        contentType: "image/${extensionImg.replaceAll(".", "")}",
        cacheControl: isProfile ? "no-store" : null,
        customMetadata: isProfile
            ? Map.from(
                {
                  "id": cacheID,
                },
              )
            : null,
      ));
  final String downloadURL = await storageRef.getDownloadURL();
  return downloadURL;
}

Future<bool> calculateFileLength(
    {required String imagePath, required int maxSize}) async {
  final File file = File(imagePath);
  int sizeInBytes = await file.length();
  double sizeInMB = sizeInBytes / (1024 * 1024);
  if (sizeInBytes != -1 && sizeInMB > maxSize) {
    flutterToast(
      "Image size should not exceed ${maxSize}MB",
    );
    return false;
  } else {
    return true;
  }
}
