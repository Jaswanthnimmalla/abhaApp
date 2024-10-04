import 'package:abha/services/encryption.dart';
import 'package:abha/screens/auth/otp_verify_screen.dart';
import 'package:abha/utils/notification_widget.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController aadhaarController = TextEditingController();

  final TextEditingController mobileController = TextEditingController();

  final String publicKeyUrl =
      'https://healthidsbx.abdm.gov.in/api/v1/auth/cert';

  final String tokenUrl = 'https://dev.abdm.gov.in/gateway/v0.5/sessions';

  Future<String> getPublicKey() async {
    final response = await http.get(Uri.parse(publicKeyUrl));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load public key');
    }
  }

  Future<String> generateToken() async {
    final response = await http.post(
      Uri.parse(tokenUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "clientId": "SBX_002928",
        "clientSecret": "5b24ab9e-2194-4f5f-aca3-fdb0a4872312",
        "grantType": "client_credentials"
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['accessToken'];
    } else {
      throw Exception('Failed to generate token');
    }
  }

  bool isLoading = false;

  void onLogin(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });

      final publicKeyPem = await getPublicKey();

      final aadhaarNumber = aadhaarController.text.trim();
      final encryptedData = encryptAadhaar(aadhaarNumber, publicKeyPem);
      final token = await generateToken();
      print(encryptedData);
      requestOTP(context, encryptedData, token, publicKeyPem);
      // Navigate to OTP Request screen
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => OTPRequestScreen(
      //         encryptedData: encryptedData,
      //         token: token,
      //         publickKey: publicKeyPem),
      //   ),
      // );
    } catch (e) {
      print('Error: $e');
      appNotify("Servers not available try again", false, context);
      // Handle error (e.g., show a dialog or a Snackbar)
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String getCurrentTimestamp() {
    // Get current time in UTC
    final now = DateTime.now().toUtc();

    // Format the DateTime to ISO 8601 format (UTC)
    print(now.toIso8601String());
    return now.toIso8601String();
  }

  Future<void> requestOTP(BuildContext context, String encryptedData,
      String token, String publickKey) async {
    try {
      setState(() {
        isLoading = true;
      });
      final String otpUrl =
          'https://abhasbx.abdm.gov.in/abha/api/v3/enrollment/request/otp';
      final response = await http.post(
        Uri.parse(otpUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'REQUEST-ID': 'c9e1441f-cb78-45fb-bcc3-66e984f417df',
          'TIMESTAMP': getCurrentTimestamp(),
        },
        body: jsonEncode({
          "scope": ["abha-enrol"],
          "loginHint": "aadhaar",
          "loginId": encryptedData,
          "otpSystem": "aadhaar",
        }),
      );

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final txnId = jsonResponse['txnId'];
        final message = jsonResponse['message'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(
              message: message,
              txnId: txnId,
              token: token,
              publickKey: publickKey,
              phone: mobileController.text.toString(),
            ),
          ),
        );
      } else {
        appNotify("Servers not available try again", false, context);
        throw Exception('Failed to request OTP');
      }
    } catch (e) {
      appNotify("Servers not available try again", false, context);
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // "Login" text
                Center(
                  child: Text(
                    ' ABHA PHR Login',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),

                SizedBox(height: 20),
                Center(
                  child: Image.asset(
                    'assets/images/account.png',
                    height: 150,
                    width: 150,
                  ),
                ),
                SizedBox(height: 30),
                // "Enter Aadhaar Number" text
                Text(
                  'Enter Aadhaar Number',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 10),

                // Aadhaar Number input field
                TextField(
                  controller: aadhaarController,
                  decoration: InputDecoration(
                    labelText: 'Aadhaar Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 12,
                ),
                SizedBox(height: 10),

                // "Enter Registered Mobile Number" text
                Text(
                  'Enter Registered Mobile Number',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 10),

                // Mobile Number input field
                TextField(
                  controller: mobileController,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                ),
                SizedBox(height: 40),

                // "Get OTP & Register" button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white),
                    onPressed: () {
                      if (mobileController.text.isEmpty ||
                          mobileController.text.length != 10) {
                        appNotify(
                            "Please enter valid mobile number", false, context);
                      } else if (aadhaarController.text.isEmpty ||
                          aadhaarController.text.length != 12) {
                        appNotify(
                            "Please enter valid aadhar number", false, context);
                      } else {
                        onLogin(context);
                      }
                    },
                    child: isLoading
                        ? Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : Text('Get OTP & Register'),
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
