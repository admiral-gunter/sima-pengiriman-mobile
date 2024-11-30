import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sima_pengiriman/size_config.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

const kPrimaryColor = Color(0xFFFF7643);
const kPrimaryLightColor = Color(0xFFFFECDF);
const kPrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFFA53E), Color(0xFFFF7643)],
);
const kSecondaryColor = Color(0xFF979797);
const kTextColor = Color(0xFF757575);

const kAnimationDuration = Duration(milliseconds: 200);

final headingStyle = TextStyle(
  fontSize: getProportionateScreenWidth(28),
  fontWeight: FontWeight.bold,
  color: Colors.black,
  height: 1.5,
);

const defaultDuration = Duration(milliseconds: 250);

// Form Error
final RegExp emailValidatorRegExp =
    RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
const String kEmailNullError = "Please Enter your email";
const String kInvalidEmailError = "Please Enter Valid Email";
const String kPassNullError = "Please Enter your password";
const String kShortPassError = "Password is too short";
const String kMatchPassError = "Passwords don't match";
const String kNamelNullError = "Please Enter your name";
const String kPhoneNumberNullError = "Please Enter your phone number";
const String kAddressNullError = "Please Enter your address";

final otpInputDecoration = InputDecoration(
  contentPadding:
      EdgeInsets.symmetric(vertical: getProportionateScreenWidth(15)),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    // borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)),
    borderSide: BorderSide(color: kTextColor),
  );
}

const pfixRnded18 = 5.0;
//
// String HOST = 'http://192.168.1.5/simait';

// String HOST = 'http://192.168.1.4/simait';
String HOST = 'https://devgrobx.sinarmaju.co.id';
// String HOST = 'https://grobx.sinarmaju.co.id';

// String HOST = 'https://grobx.sinarmaju.co.id';

// const kURL_ORIGIN = 'https://appid.sinarmaju.co.id/api/';
final kURL_ORIGIN = '$HOST/api/';

// const kURL_ORIGIN = 'https://devgrobx.sinarmaju.co.id/api/';

final kURL_ORIGIN_ASSET = '$HOST/uploads/image/';

void showSuccessMessage(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: TextStyle(color: Colors.white),
    ),
    backgroundColor: Colors.green, // Success color
    behavior: SnackBarBehavior.floating, // Makes it float
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8)), // Rounded corners
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Future<File> compressImage(File imageFile) async {
  // Check if the file size is greater than 2MB
  const int maxFileSize = 2 * 1024 * 1024; // 2MB in bytes
  final int fileSize = await imageFile.length();

  if (fileSize <= maxFileSize) {
    // Return the original file if it's already less than or equal to 2MB
    return imageFile;
  }

  // Decode the image
  final originalImage = img.decodeImage(imageFile.readAsBytesSync());

  // Resize and compress the image
  final resizedImage = img.copyResize(originalImage!, width: 200);

  // Save the compressed image to a temporary file
  final tempDir = Directory.systemTemp;
  final compressedImageFile = File('${tempDir.path}/compressed_image.jpg');
  compressedImageFile
      .writeAsBytesSync(img.encodeJpg(resizedImage, quality: 10));

  return compressedImageFile;
}
