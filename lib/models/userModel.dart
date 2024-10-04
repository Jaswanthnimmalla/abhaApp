class ApiResponse {
  final String? message;
  final String? txnId;
  final Tokens? tokens;
  final AbhaProfile? abhaProfile;

  ApiResponse({
    this.message,
    this.txnId,
    this.tokens,
    this.abhaProfile,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      message: json['message'],
      txnId: json['txnId'],
      tokens: json['tokens'] != null ? Tokens.fromJson(json['tokens']) : null,
      abhaProfile: json['ABHAProfile'] != null
          ? AbhaProfile.fromJson(json['ABHAProfile'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'txnId': txnId,
      'tokens': tokens?.toJson(),
      'ABHAProfile': abhaProfile?.toJson(),
    };
  }
}

// Tokens model class
class Tokens {
  final String? token;
  final String? refreshToken;

  Tokens({
    this.token,
    this.refreshToken,
  });

  factory Tokens.fromJson(Map<String, dynamic> json) {
    return Tokens(
      token: json['token'],
      refreshToken: json['refreshToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
    };
  }
}

// ABHAProfile model class
class AbhaProfile {
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? dob;
  final String? gender;
  final String? photo;
  final String? mobile;
  final String? email;
  final List<String>? phrAddress;
  final String? address;
  final String? districtCode;
  final String? stateCode;
  final String? pinCode;
  final String? abhaType;
  final String? stateName;
  final String? districtName;
  final String? abhaNumber;
  final String? abhaStatus;

  AbhaProfile({
    this.firstName,
    this.middleName,
    this.lastName,
    this.dob,
    this.gender,
    this.photo,
    this.mobile,
    this.email,
    this.phrAddress,
    this.address,
    this.districtCode,
    this.stateCode,
    this.pinCode,
    this.abhaType,
    this.stateName,
    this.districtName,
    this.abhaNumber,
    this.abhaStatus,
  });

  factory AbhaProfile.fromJson(Map<String, dynamic> json) {
    return AbhaProfile(
      firstName: json['firstName'],
      middleName: json['middleName'],
      lastName: json['lastName'],
      dob: json['dob'],
      gender: json['gender'],
      photo: json['photo'],
      mobile: json['mobile'],
      email: json['email'],
      phrAddress: json['phrAddress'] != null
          ? List<String>.from(json['phrAddress'])
          : null,
      address: json['address'],
      districtCode: json['districtCode'],
      stateCode: json['stateCode'],
      pinCode: json['pinCode'],
      abhaType: json['abhaType'],
      stateName: json['stateName'],
      districtName: json['districtName'],
      abhaNumber: json['ABHANumber'],
      abhaStatus: json['abhaStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'dob': dob,
      'gender': gender,
      'photo': photo,
      'mobile': mobile,
      'email': email,
      'phrAddress': phrAddress,
      'address': address,
      'districtCode': districtCode,
      'stateCode': stateCode,
      'pinCode': pinCode,
      'abhaType': abhaType,
      'stateName': stateName,
      'districtName': districtName,
      'ABHANumber': abhaNumber,
      'abhaStatus': abhaStatus,
    };
  }
}
