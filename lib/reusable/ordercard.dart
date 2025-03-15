import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartq/constants/constants.dart';
import 'package:smartq/models/order.dart';
import 'package:http/http.dart' as http;

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onOrderCanceled;

  const OrderCard({
    super.key,
    required this.order,
    this.onOrderCanceled,
  });

  Future<void> _cancelOrder(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context); // Store navigator
    final url = "${baseUrl}user/orders/${order.id}";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
            content: Text("Authentication error. Please log in again.")),
      );
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            barrierDismissible: false,
            context: navigator.context,
            builder: (dialogContext) => AlertDialog(
              title: const Text("Order Cancelled"),
              content: const Text("The remitted amount will be refunded."),
              actions: [
                TextButton(
                  onPressed: () {
                    navigator.pop(); // Close dialog
                    onOrderCanceled?.call(); // Refresh orders
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        });
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text("Failed: ${response.body}")),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("Error canceling order")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                order.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.fastfood, size: 50, color: Colors.grey),
              ),
            ),
            title: Text(
              order.itemName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Order No: ${order.orderNo}"), //  Show Order No
            trailing: Text(
              "₹${order.price.toStringAsFixed(2)}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Status: ${order.status}",
                  style: TextStyle(
                    fontSize: 14,
                    color: _getStatusColor(
                        order.status), // Dynamically set color based on status
                  ),
                ),
                const SizedBox(height: 4),
                Text("Date: ${_formatDate(order.dateTime)}",
                    style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          if (order.status == "Pending")
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _cancelOrder(context),
                    icon: const Icon(Icons.cancel, color: Colors.white),
                    label: const Text("Cancel Order"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green; // Green for Delivered
      case 'Cancelled':
        return Colors.red; // Red for Cancelled
      case 'Pending':
        return Colors.orange; // Orange for Pending
      default:
        return Colors.black; // Default color if status is unknown
    }
  }

  String _formatDate(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
  }
}
