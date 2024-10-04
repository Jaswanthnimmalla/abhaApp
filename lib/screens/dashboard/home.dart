import 'dart:convert';

import 'package:abha/controllers/user_info_controller.dart';
import 'package:abha/screens/auth/login.dart';
import 'package:abha/screens/dashboard/profile.dart';
import 'package:abha/utils/confirmation_dialog.dart';
import 'package:abha/utils/notification_widget.dart';
import 'package:abha/utils/userData.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final userInfoController = Get.put(UserInfoController());
  var barcodeScanRes = '';
  String getCurrentTimestamp() {
    // Get current time in UTC
    final now = DateTime.now().toUtc();
    print(now.toIso8601String());
    return now.toIso8601String(); // Return ISO 8601 format
  }

  @override
  void initState() {
    super.initState();
    print(userInfoController.userModel.value);
  }

  Future<void> fetchProfile(String token) async {
    // Prepare the URL
    const String url =
        'https://abhasbx.abdm.gov.in/abha/api/v3/profile/account';

    // Prepare the headers
    final String timestamp = getCurrentTimestamp();
    final Map<String, String> headers = {
      'Authorization': "Bearer $token", // Ensure token is correct

      'TIMESTAMP': timestamp,
    };

    // Log headers for debugging
    print('Headers: $headers');

    // Prepare the body
    final Map<String, dynamic> body = {
      'dob': '2001',
    };

    try {
      // Make the API request
      final response = await http.patch(
        // Use POST instead of PATCH if that's expected
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      // Check the response status code
      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print('Response data: $jsonResponse');
      } else {
        // Handle error response
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Handle any exceptions
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userInfoController = Get.put(UserInfoController());
    return Scaffold(
      appBar: AppBar(
        title: Text('ABHA'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: Icon(Icons.menu),
        actions: [
          InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return ConfirmationDialog(
                      onTapYes: () {
                        UserInfo().removeData();
                        Get.delete<UserInfoController>();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (BuildContext context) => LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      onTapNo: () {
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
              child: Icon(Icons.logout_outlined))
        ],
        bottom: PreferredSize(
          preferredSize: Size(MediaQuery.of(context).size.width, 120),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/logo.svg',
                  height: 50,
                  width: 50,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        print(userInfoController
                            .userModel.value?.abhaProfile?.firstName);
                      },
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Welcome!!',
                            style: TextStyle(fontSize: 15, color: Colors.white),
                          )),
                    ),
                    Obx(() {
                      if (userInfoController.userModel.value == null) {
                        return Text(
                            'Hi User'); // Show loading indicator until data is loaded
                      } else {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${userInfoController.userModel.value?.abhaProfile?.firstName ?? ''}" +
                                ' ' +
                                "${userInfoController.userModel.value?.abhaProfile?.lastName ?? 'User'}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white),
                          ),
                        );
                      }
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  height: 50,
                ),
                GestureDetector(
                  onTap: () async {
                    try {
                      //svgBarcode.value = "";

                      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
                      setState(() {});
                      print(barcodeScanRes);
                      appNotify("Successfully Scanned", true, context);
                    } on PlatformException {
                      appNotify("Failed to Scan", false, context);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.symmetric(horizontal: 50),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.indigo),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/qr-code-scan.png',
                          height: 100,
                          width: 100,
                        ),
                        SizedBox(
                          height: 35,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Scan QR Code',
                              style: TextStyle(
                                color: Colors.indigo,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.indigo,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                barcodeScanRes.isEmpty || barcodeScanRes == "-1"
                    ? SizedBox()
                    : Container(
                        padding: EdgeInsets.all(20),
                        margin: EdgeInsets.symmetric(horizontal: 50),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.indigo),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: SelectableText(
                                    'Scanned Data : $barcodeScanRes',
                                    style: TextStyle(
                                      color: Colors.indigo,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                  onTap: () async {
                                    try {
                                      await Share.share('$barcodeScanRes');
                                    } catch (e) {
                                      appNotify(
                                          "Failed to share", false, context);
                                    }
                                  },
                                  child: Icon(
                                    Icons.share,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  onTap: () {
                    if (userInfoController.userModel.value != null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileDetailScreen(
                                    fullData:
                                        userInfoController.userModel.value,
                                  )));
                    } else {
                      appNotify('User profile not available', false, context);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.symmetric(horizontal: 50),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.indigo)),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/profile.png',
                          height: 100,
                          width: 100,
                        ),
                        SizedBox(
                          height: 35,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'My Profile',
                              style: TextStyle(
                                color: Colors.indigo,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.indigo,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
