

import 'package:encrypt/encrypt.dart'; // Import the encrypt package
import 'package:pointycastle/asymmetric/api.dart'; // Optional, in case you want to hash your data

String encryptAadhaar(String aadhaarNumber, String publicKeyPem) {
  // Parse the RSA public key from the PEM format
  final parser = RSAKeyParser();
  final publicKey = parser.parse(publicKeyPem) as RSAPublicKey;

  // Initialize the RSA encrypter
  final encrypter =
      Encrypter(RSA(publicKey: publicKey, encoding: RSAEncoding.OAEP));

  // Encrypt the Aadhaar number
  final encrypted = encrypter.encrypt(aadhaarNumber);

  // Return the encrypted string in base64 format
  return encrypted.base64;
}
