import 'dart:convert';

import 'package:abha/controllers/user_info_controller.dart';
import 'package:abha/services/encryption.dart';
import 'package:abha/screens/dashboard/home.dart';
import 'package:abha/utils/notification_widget.dart';
import 'package:abha/utils/userData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String txnId;
  final String token;
  final String publickKey;
  final String phone;
  final String message;

  OTPVerificationScreen(
      {required this.txnId,
      required this.token,
      required this.message,
      required this.publickKey,
      required this.phone});

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  final uuid = Uuid();
  String getCurrentTimestamp() {
    // Get current time in UTC
    final now = DateTime.now().toUtc();

    // Format the DateTime to ISO 8601 format (UTC)
    return now.toIso8601String();
  }

  bool isLoading = false;
  Future<void> verifyOTP(BuildContext context) async {
    final String verifyUrl =
        'https://abhasbx.abdm.gov.in/abha/api/v3/enrollment/enrol/byAadhaar';
    final otpValue = otpController.text.trim();
    final String requestId = uuid.v4();
    print(otpValue);
    final encryptedOTPData = encryptAadhaar(otpValue, widget.publickKey);
    // Prepare the body for the request
    final requestBody = jsonEncode({
      "authData": {
        "authMethods": ["otp"],
        "otp": {
          "timeStamp": "${getCurrentTimestamp()}",
          "txnId": widget.txnId,
          "otpValue": encryptedOTPData,
          "mobile": widget.phone // Use the correct mobile number
        }
      },
      "consent": {"code": "abha-enrollment", "version": "1.4"}
    });

    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.post(
        Uri.parse(verifyUrl),
        headers: {
          'Content-Type': 'application/json',
          'REQUEST-ID': requestId,
          'TIMESTAMP': getCurrentTimestamp(),
          'Authorization':
              'Bearer ${widget.token}', // Make sure you pass the token
        },
        body: requestBody,
      );

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        // OTP verified successfully
        final jsonResponse = jsonDecode(response.body);
        print('Verification Success: $jsonResponse');

        Get.lazyPut(() => UserInfoController());
        var userInfoController = Get.find<UserInfoController>();
        UserInfo().addUserLogin = true;

        userInfoController.storeUserResponse = jsonResponse;
        setState(() {});

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (route) => false);
        appNotify("Successfully Registered", true, context);
      } else {
        appNotify("Server is not available try again", false, context);
        print('Failed to verify OTP: ${response.body}');
        throw Exception('Failed to verify OTP');
      }
    } catch (error) {
      appNotify("Server is not available try again", false, context);
      print('Error: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  // @override
  // void codeUpdated() {
  //   setState(() {
  //     _code = code ?? ""; // Update the code when received
  //   });
  //   if (_code.length == 5) {
  //     FocusScope.of(context).requestFocus(FocusNode()); // Dismiss the keyboard
  //   }
  // }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/otp_check.png',
                  scale: 2,
                ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  'OTP Verification',
                  style: TextStyle(
                      color: Color(0xff203757),
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  'Enter the OTP sent to',
                  style: TextStyle(color: Color(0xffB1B1B1), fontSize: 18.0),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  widget.message,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: otpController,
                  decoration: InputDecoration(
                    labelText: 'Enter OTP',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 6,
                ),
                SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive code? ",
                        style:
                            TextStyle(color: Color(0xffB1B1B1), fontSize: 18.0),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Re-Enter",
                          style: TextStyle(
                              color: Color(0xff203757), fontSize: 16.0),
                        ),
                      ),
                    ],
                  ),
                ),
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : InkWell(
                        onTap: () {
                          if (otpController.text.isEmpty ||
                              otpController.text.length != 6) {
                            appNotify("Please enter valid mobile number", false,
                                context);
                          } else {
                            verifyOTP(context);
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 40,
                          width: MediaQuery.of(context).size.width / 2,
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20)),
                          child: const Text(
                            'VERIFY',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
