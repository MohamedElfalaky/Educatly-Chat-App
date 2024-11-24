import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:googleapis/storage/v1.dart' as servicecontroller;
import 'package:googleapis_auth/auth_io.dart' as authh;

class PushNotification {
  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "chatapptest-3e0a6",
      "private_key_id": "29222bfb04774895a6f6721565fddf275a013b9b",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQCZAdeZc5FE2KSQ\n0UxnnNjrecFxLAJOMnCr1bxlQyW1A6J/VNfskJNI5tT0cIl2fPiGdlcW7SGttq93\nafox+kffleAgQf2Hj0JHuAUPFCB6IQNEmNSnJAU0MururPeDRz+0Usq9/RMjjHQz\ngnVwWTDpTDBd71sYrJyrRDvsPAGU3vKLV19gcNq6zmR4QP16P05XizwaylVYY/Xy\nd08sAIYfWXQlE2cCwjAUQrPLd2oRsn0uCJs76kHY4pqgBB4p98Yt223EHW1uE315\nBEOMKpdd8Il2kJ367fV1pwtu8CLVUKYH1LVvMmedy2ADl0poe9j540Ozw48hBIOD\nk/dmIDohAgMBAAECggEABVo2ktejiLmUiCoTUif/CgbfMgre7ljHpfINR2Ih8dVj\nSdWU04ZEV5Pydf8nhrtKtlco3ea7aShBtollYp7BBOXXAUnf9tu8E4rDRxzmRfG4\njdSdG8TWzlXL79IPce8OaSdOkFJHxIsnjpyWQ7D/nimlR39e4G4XFhRhjWRL/Cbd\n/5WQqSK916i5xZVNxsLq3UZGMfcSzvxO3w8WvxjcwEx/kI/DjVfHJkMoPca2+i/4\ntEZ1DvMCdZJamLoijrDEWmUC7ofI26b/qa7dLiXhS7frb5BeCoZuVji+5Uvhk/MS\n9aQOKNylT9XWoTresr58czsGgvpmNHX+SolTncR3AQKBgQDLlbJc8W9Y86cx0U0G\n/eW3qmlonfJAsI6LZqWDMyQ0e6YcZRB4gVSq0vAuqzmbbr508t8/vw/Ouu/Ycs50\nVTqZNnlgas5S/jouUzD6p0ukNCOUYkBPZmmVIQFjnGyZON2iSB3mZaTyENcHSZWE\nR9WSNVk7p+YVGT8p0fw11ZN//QKBgQDAZpIYRgsxPRqIFtlMbblgCOOsBvm/wG9O\nei5PHCBraoQjwVzTQ2q4xq4PnSrmRchRxlueArdTRoDnvB95XzcXz8wEh9dWzIPR\nfxEM/g128OARFc2jog4782Cua/t+6QK0rI3NVvVJybs3xxyU4OZuIyl8ZqB4oFCn\n/dKqkS3B9QKBgQC9M7tXC36rEY5iCx1mERKr1bEu7BNXMX7YaSYLP703FW80Vmyv\nQarZMz7KcJESNiLE926phLyBKVR8OX5LuWXDPFAjXj+v+9tAcEpFuLLgwSAL6B/S\nauBXGxx6Yca/w4yfJBy9odtgqGvetvFAxa3jurbabVi0ZQlBqYiW043IVQKBgQC+\nH110oRqEQIZMPo/iB3csX/xizM3U3xreaLwELp4Wpz4Gexf4J+F4z9PG2B9BR2nI\n7QMxpCt2HfBZjjtn21/8prlLLNTtD9GenjrCJPY3N5WjLHF1pjj8ouZB1bDC2wxy\nbyT86VYf4Tmgx6AFuivaX+Kp7Fvcd0bcimS3ahjWVQKBgQC7/dEULuFc3R1yZ5Xw\ntuB7O++94jNNXCNWQb6GlaGV4Npast/3CdRC5jzNIFosQyycciiQMSzMgQe/MOx5\nT2iXVoBk96V/FrT5rOX/Kazob/HvQ2QNaisdkG0yUuGg5NFMpnd0ZvrQnJma3FJW\n6Q012sRKBTcy6SmE3DlLoTEwvA==\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-oad23@chatapptest-3e0a6.iam.gserviceaccount.com",
      "client_id": "108140395952153838955",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-oad23%40chatapptest-3e0a6.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await authh.clientViaServiceAccount(
        authh.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

// get access token

    authh.AccessCredentials credentials =
        await authh.obtainAccessCredentialsViaServiceAccount(
            authh.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);

    client.close();

    return credentials.accessToken.data;
  }

  static sendNotification(String deviceToken, String messege) async {
    final String serverAccessTokenKey = await getAccessToken();

    print('Access Token: $serverAccessTokenKey');

    String endPointFirebaseCloudMesseging =
        'https://fcm.googleapis.com/v1/projects/chatapptest-3e0a6/messages:send';

    final Map<String, dynamic> message = {
      'message': {
        'token': deviceToken,
        'notification': {
          'title': "New message",
          'body': messege,
        },
        'data': {
          'messege': messege, // Custom data
          'click_action':
              "FLUTTER_NOTIFICATION_CLICK", // Needed for handling clicks
        },
      },
    };

    final http.Response response =
        await http.post(Uri.parse(endPointFirebaseCloudMesseging),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $serverAccessTokenKey'
            },
            body: jsonEncode(message));

    if (response.statusCode == 200) {
      print("Notification sent successfully!");
    } else {
      print("Failed to send notification: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
  }
}
