// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:smartq/constants/constants.dart';
// import '../models/menu_item.dart';

// class OrderCard extends StatelessWidget {
//   final List<MenuItem> cartItems;
//   final double totalAmount;

//   const OrderCard(
//       {super.key, required this.cartItems, required this.totalAmount});

//   Future<void> handlePayment(BuildContext context) async {
//     try {
//       // 1️⃣ Create a Payment Intent (Server-side implementation recommended)
//       final response = await http.post(
//         Uri.parse('https://api.stripe.com/v1/payment_intents'),
//         headers: {
//           'Authorization': SecretKey, // Replace with actual Secret Key
//           'Content-Type': 'application/x-www-form-urlencoded',
//         },
//         body: {
//           'amount': (totalAmount * 100).toString(),
//           'currency': 'inr', // Change as per country
//         },
//       );

//       final paymentIntent = jsonDecode(response.body);

//       // 2️⃣ Initialize Stripe Payment Sheet
//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           paymentIntentClientSecret: paymentIntent['client_secret'],
//           merchantDisplayName: 'SmartQ Canteen',
//         ),
//       );

//       // 3️⃣ Show Payment Sheet
//       await Stripe.instance.presentPaymentSheet();

//       // 4️⃣ Success Message
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Payment Successful!')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Payment Failed: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Order Summary')),
//       body: Padding(
//         padding: const EdgeInsets.all(10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Your Order',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 10),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: cartItems.length,
//                 itemBuilder: (context, index) {
//                   final item = cartItems[index];
//                   return ListTile(
//                     leading: ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: Image.network(
//                         item.imageUrl,
//                         width: 50,
//                         height: 50,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) =>
//                             const Icon(Icons.fastfood,
//                                 size: 50, color: Colors.grey),
//                       ),
//                     ),
//                     title:
//                         Text(item.name, style: const TextStyle(fontSize: 16)),
//                     subtitle: Text('₹${item.price} x ${item.quantity}'),
//                     trailing:
//                         Text('₹${(item.price * item.quantity).toString()}'),
//                   );
//                 },
//               ),
//             ),
//             const Divider(),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 'Total: ₹${totalAmount.toStringAsFixed(2)}',
//                 style:
//                     const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             ),
//             const SizedBox(height: 10),
//             Center(
//               child: ElevatedButton(
//                 onPressed: () => handlePayment(context),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                 ),
//                 child: const Text('Pay Now',
//                     style: TextStyle(fontSize: 16, color: Colors.white)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
