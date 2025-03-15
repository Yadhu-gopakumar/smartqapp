import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartq/constants/constants.dart';

class BookingService {
  Future<bool> addBooking(String paymentId, List<Map<String, dynamic>> items,
      double totalAmount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload(); //  Force refresh

    final String? token = prefs.getString('token');
    // print(token);
    if (token == null || token.isEmpty) {
      // print("🚨 No token found!");
      return false;
    }

    // Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

    // Map<String, dynamic> userSub =
    //     jsonDecode(decodedToken['sub']); // Convert String to Map
    // String userId = userSub['id'].toString(); // Extract user ID

    // print("🔍 Extracted User ID: $userId");

    final response = await http.post(
      Uri.parse("${baseUrl}user/order"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "paymentId": paymentId,
        "items": items,
        "total_amount": totalAmount
      }),
    );

    // print("Booking Response: ${response.body}");

    return response.statusCode == 200;
  }
}
